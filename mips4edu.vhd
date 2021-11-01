LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity mips4edu is
    port(
        CLOCK_50 : in std_logic;
        RESET_N :in std_logic;
        HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 : out std_logic_vector(6 downto 0);
        KEY : in std_logic_vector(3 downto 0);

        GPIO_1 :inout std_logic_vector(1 downto 0);

        rx : in std_logic;
        tx : out std_logic;

        LEDR: out std_logic_vector(9 downto 0)
    );
end entity;

architecture behavior of mips4edu is
    --signals for programcounter interconnect
    signal PC_IN,PC_OUT : std_logic_vector(31 downto 0);

    component programCounter is
    PORT (
		clk,reset :in std_logic;
        we_rpi : in std_logic;
		w_pc : in std_logic_vector(31 downto 0);

		programCounterIn   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		programCounterOut  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
    end component;

    --signal for instruction from instruction register
    signal instruction :std_logic_vector(31 downto 0);
    component instructionMemory
    PORT (
		readAddress : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		instruction : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
    end component;

    --register and signals
    signal reg1out,reg2out,reg3out:std_logic_vector(31 downto 0);
    signal regaddr :std_logic_vector(4 downto 0);
    component registerFile
	GENERIC (
		B : INTEGER := 32; --number of bits
		W : INTEGER := 5 --number of address bits
	);
	PORT (
        CLK : in std_logic;
		readRegister1 : IN std_logic_vector (W - 1 DOWNTO 0);
		readRegister2 : IN std_logic_vector (W - 1 DOWNTO 0);
		writeRegister : IN std_logic_vector (W - 1 DOWNTO 0);
		writeData     : IN std_logic_vector (B - 1 DOWNTO 0);
		registerWrite : IN std_logic;
		readData1     : OUT std_logic_vector (B - 1 DOWNTO 0);
		readData2     : OUT std_logic_vector (B - 1 DOWNTO 0);

		readRegister3 :IN std_logic_vector(W -1 downto 0);
		readData3 : out std_logic_vector(B -1 downto 0);

		we_rpi : in std_logic;
		w_adr_rpi : in std_logic_vector(W - 1 downto 0);
		w_data_rpi : in std_logic_vector(B - 1 downto 0)
	);
	end component;

    --controller and signals for that
    signal RegDst,Jump,branch,memRead,memToRegister,memWrite,ALUsrc,regWrite :std_logic;
    signal ALUop :std_logic_vector(1 downto 0);
    component Controller
    PORT (
		opcode        : IN std_logic_vector(5 DOWNTO 0); -- instruction 31-26
		regDst        : OUT std_logic;
		jump          : OUT std_logic;
		branch        : OUT std_logic;
		memRead       : OUT std_logic;
		memToRegister : OUT std_logic;
		ALUop         : OUT std_logic_vector(1 DOWNTO 0);
		memWrite      : OUT std_logic;
		ALUsrc        : OUT std_logic;
		regWrite      : OUT std_logic
	);
    end component;
    
    --signals for register
    signal writereg : std_logic_vector(4 downto 0);

    --signals for ALU
    signal mux_reg2_out:std_logic_vector(31 downto 0);
    
    --signals for MUX datamem
    signal mux_datamem_out :std_logic_vector(31 downto 0);

    --signal for mux pc out
    signal mux_pc_out :std_logic_vector(31 downto 0);

    --signal for ctrl ALU
    signal ctrl_signal_alu2 :std_logic;

    component MUX
    GENERIC (
		N : INTEGER := 32
	);
	PORT (
		mux_in0  : IN std_logic_vector(N - 1 DOWNTO 0);
		mux_in1  : IN std_logic_vector(N - 1 DOWNTO 0);
		mux_ctl  : IN STD_logic;
		mux_out  : OUT STD_logic_vector(N - 1 DOWNTO 0)
	);
    end component;

    --alu control
    signal operation : std_logic_vector(3 downto 0);

    component ALU_CONTROL
    PORT (
		funct     : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		ALUop     : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		operation : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
    end component;

    --ALU
    signal is_zero :std_logic;
    signal alu_out,alu2_out :std_logic_vector(31 downto 0);
    component ALU
    PORT (
		a1           : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		a2           : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		alu_control  : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		alu_result   : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		zero         : OUT STD_LOGIC
	);
    end component;

    --sign extender
    signal se_out :std_logic_vector(31 downto 0);
    component SignExtender
    PORT (
		se_in   : IN STD_logic_vector(15 DOWNTO 0);
		se_out  : OUT STD_logic_vector(31 DOWNTO 0)
	);
    end component;

    --data memory
    signal datamem_out :std_logic_vector(31 downto 0);

    component dataMemory
    PORT (
		address   : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		writeData : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		memRead   : IN STD_LOGIC;
		memWrite  : IN STD_LOGIC;
		readData  : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
    end component;

    --pc adder 4byte
    signal added_pc :std_logic_vector(31 downto 0);
    component programCounterAdder
    PORT (
		programCounterIn   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		programCounterOut  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
    end component;

    --shiftleft2bit 
    signal shifted2bit :std_logic_vector(31 downto 0);
    signal jump_operand_shifter_in :std_logic_vector(27 downto 0);
    signal shiftedinstruction :std_logic_vector(27 downto 0);
    signal jumpaddress :std_logic_vector(31 downto 0);
    component shiftLeft
    GENERIC (
		N : INTEGER := 2;
		W : INTEGER := 32
	);
	PORT (
		addressIN  : IN STD_LOGIC_VECTOR(W - 1 DOWNTO 0);
		addressOUT : OUT STD_LOGIC_VECTOR(W - 1 DOWNTO 0)
	);
    end component;

    --4fun
    component DISPALL7SEG is
        port(
            D :in std_logic_vector(23 downto 0);
            H0,H1,H2,H3,H4,H5 :out std_logic_vector(6 downto 0)
        );
    end component;

    signal key_o : std_logic;
    component keypress_fsm is
        port(
            CLK :in std_logic;
            RST_a :in std_logic;
            key :in std_logic;
            key_out :out std_logic
        );
    end component;

    component uart_proto
    port(
        CLK : in std_logic;
        RST_a : in std_logic;

        tx :out std_logic;
        rx :in std_logic;

        din :in std_logic_vector(31 downto 0);
        regaddr :out std_logic_vector(4 downto 0)
    );
    end component;

    signal clk_by_human : std_logic;
    signal rst_active_low : std_logic;

    --i2c slave
    component i2cSlave
	generic(
		DEVICE 		: std_logic_vector(7 downto 0) := x"38"
	);
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		SDA_IN		: in	std_logic;
		SCL_IN		: in	std_logic;
		SDA_OUT		: out	std_logic;
		SCL_OUT		: out	std_logic;
		ADDRESS		: out	std_logic_vector(7 downto 0);
		DATA_OUT	: out	std_logic_vector(31 downto 0);
		DATA_IN		: in	std_logic_vector(7 downto 0);
		WR			: out	std_logic;
		RD			: out	std_logic
	);
	end component;

    signal SDA_IN		: std_logic;
	signal SCL_IN		: std_logic;
	signal SDA_OUT, SDA_OUT2		: std_logic;
	signal SCL_OUT, SCL_OUT2		: std_logic;

    signal SCL_O,SDA_O :std_logic;

    signal w_data_rpi : std_logic_vector(31 downto 0);
    signal w_adr_rpi : std_logic_vector(7 downto 0);
    signal we_rpi : std_logic;

    signal we_pc_rpi : std_logic;
    signal w_pc_ptr : std_logic_vector(31 downto 0);
        
    begin
        --LEDR <= ("00" & X"00");
        LEDR <= RegWrite & '0' & X"00";


        clk_by_human <= not KEY(0);
        rst_active_low <= not RESET_N;

        i2c_reg:I2CSLAVE
		generic map (
			DEVICE => x"38"
		)
		port map(
		MCLK => CLOCK_50,
		nRST => RESET_N,
		address => w_adr_rpi,
		DATA_OUT => w_data_rpi,
		DATA_IN => X"55",

		WR => we_rpi,
		SDA_IN		=> SDA_IN,
		SCL_IN		=> SCL_IN,
		SDA_OUT		=> SDA_OUT,
		SCL_OUT		=> SCL_OUT
		);

        i2c_pc:I2CSLAVE
        generic map (
			DEVICE => x"39"
		)
        port map(
		MCLK => CLOCK_50,
		nRST => RESET_N,
        DATA_IN => X"00",
        DATA_OUT => w_pc_ptr,
        WR => we_pc_rpi,

        SDA_IN		=> SDA_IN,
		SCL_IN		=> SCL_IN,
        SDA_OUT		=> SDA_OUT2,
		SCL_OUT		=> SCL_OUT2
        );

        --fanout
        SCL_O <= NOT(SCL_OUT xor SCL_OUT2);
		SDA_O <= NOT(SDA_OUT xor SDA_OUT2);

        GPIO_1(0) <= 'Z' when SCL_O='1' else '0';
		SCL_IN <= to_UX01(GPIO_1(0));

		GPIO_1(1) <= 'Z' when SDA_O='1' else '0';
		SDA_IN <= to_UX01(GPIO_1(1));

        uart0:uart_proto
        port map(
            CLK => CLOCK_50,
            RST_a => rst_active_low,

            tx => tx,
            rx => rx,

            din => reg3out,
            regaddr => regaddr
        );

        kpf:keypress_fsm
        port map(
            CLK => CLOCK_50,
            RST_a => rst_active_low,
            key => key(0),
            key_out => key_o
        );

        --instanstiate disp7seg
        d7s:DISPALL7SEG
        port map(
            D => PC_OUT(23 downto 0),
            H0 => HEX0,
            H1 => HEX1,
            H2 => HEX2,
            H3 => HEX3,
            H4 => HEX4,
            H5 => HEX5
        );

        --program counter
        PC:programCounter
        port map(
            reset => rst_active_low,
            clk => clk_by_human,
            we_rpi => we_pc_rpi,
		    w_pc => w_pc_ptr,

            programCounterIn => pc_in,
            programCounterOut => PC_OUT
        );

        --instruction memory
        IM:instructionMemory
        PORT map(
		readAddress => PC_OUT,
		instruction => instruction
	    );

        --controllerrrr
        ctrl:Controller
        PORT map(
		opcode => instruction(31 downto 26),
		regDst => RegDst,
		jump => jump,
		branch => branch,
		memRead => memRead,
		memToRegister => memToRegister,
		ALUop => ALUop,
		memWrite => memWrite,
		ALUsrc => ALUsrc,
		regWrite => regWrite
	    );

        mux_instruction:MUX
        generic map(
            N => 5
        )
        port map(
            mux_in0 => instruction(20 downto 16),
            mux_in1 => instruction(15 downto 11),
            mux_ctl => regdst,
            mux_out => writereg
        );

        --register instantiate
        reg:registerFile
        generic map(
            B => 32,
            W => 5
        )
        port map(
        CLK => CLOCK_50,
        readRegister1 => instruction(25 downto 21),
		readRegister2 => instruction(20 downto 16),
		writeRegister => writereg, --from mux ofc 5bit
		writeData => mux_datamem_out,
		registerWrite => RegWrite, --like write enable
		readData1 => reg1out,
		readData2 => reg2out,

        readRegister3 => regaddr,
        readData3 => reg3out,

        we_rpi => we_rpi,
        w_adr_rpi => w_adr_rpi(4 downto 0),
        w_data_rpi => w_data_rpi
        );

        ctrl_alu:ALU_CONTROL
        port map(
            funct => instruction(5 downto 0),
            ALUop => ALUop,
            operation => operation
        );

        SE:SignExtender
        port map(
            se_in => instruction(15 downto 0),
            se_out => se_out
        );

        mux_reg2:MUX
        generic map(
            N => 32
        )
        port map(
            mux_in0 => reg2out,
            mux_in1 => se_out,
            mux_ctl => ALUsrc,
            mux_out => mux_reg2_out
        );

        ALU_1:ALU
        port map(
            a1 => reg1out,
            a2 => mux_reg2_out,
            alu_control => operation,
            alu_result => alu_out,
            zero => is_zero
        );

        datamem:dataMemory
        port map(
            address => alu_out,
            writeData => reg2out,
            readData => datamem_out,
            memRead => memRead,
            memWrite => memWrite
        );

        mux_datamem:MUX
        generic map(
            N => 32
        )
        port map(
            MUX_IN1 => datamem_out,
            MUX_IN0 => alu_out,
            MUX_OUT => mux_datamem_out,
            mux_ctl => memToRegister
        );

        --program counter adder
        pc_adder4:programCounterAdder
        port map(
            programCounterIn => PC_OUT,
            programCounterOut => added_pc
        );

        sLeft:shiftLeft
        generic map(
            N => 2,
            W => 32
        )
        port map(
            addressIN => se_out,
            addressOUT => shifted2bit
        );

        ALU_2:ALU
        port map(
            a1 => shifted2bit,
            a2 => added_pc,
            alu_control => "0010",
            alu_result => alu2_out
        );

        ctrl_signal_alu2 <= branch AND is_zero;

        mux_pc_alu:MUX
        generic map(
            N => 32
        )
        port map(
            mux_in0 => added_pc,
            mux_in1 => alu2_out,
            mux_out => mux_pc_out,
            mux_ctl => ctrl_signal_alu2
        );

        jump_operand_shifter:shiftLeft
        generic map(
            N=> 2,
            W => 28
        )
        port map(
            addressIN => jump_operand_shifter_in,
            addressOUT => shiftedinstruction
        );
        jump_operand_shifter_in <= "00" & instruction(25 downto 0);
        jumpaddress <= added_pc(31 downto 28) & shiftedinstruction;

        mux_pc_jump:MUX
        generic map(
            N => 32
        )
        port map(
            mux_in0 => mux_pc_out,
            mux_in1 => jumpaddress,
            mux_ctl => jump,
            mux_out => pc_in
        );
    end behavior;