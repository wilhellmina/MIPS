LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity mips4edu is
    port(
        clk : in std_logic;
        reset_a : in std_logic
    );
end entity;

architecture behavior of mips4edu is
    --signal for programcounter interconnect
    signal PC_IN,PC_OUT : std_logic_vector(31 downto 0);

    component programCounter is
    PORT (
		clk :in std_logic;
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
    signal reg1out,reg2out:std_logic_vector(31 downto 0);
    component registerFile
    GENERIC (
		B : INTEGER := 32; --number of bits
		W : INTEGER := 5 --number of address bits
	);
	PORT (
		readRegister1 : IN std_logic_vector (W - 1 DOWNTO 0);
		readRegister2 : IN std_logic_vector (W - 1 DOWNTO 0);
		writeRegister : IN std_logic_vector (W - 1 DOWNTO 0);
		writeData     : IN std_logic_vector (B - 1 DOWNTO 0);
		registerWrite : IN std_logic;
		readData1     : OUT std_logic_vector (B - 1 DOWNTO 0);
		readData2     : OUT std_logic_vector (B - 1 DOWNTO 0)
	);
    end component;

    --controller and signal for that
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
    
    --component MUX

    --signals for register
    signal inst_mux_zero,inst_mux_one : std_logic_vector(4 downto 0);
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


    begin
        PC_IN <= mux_pc_out;

        --program counter
        PC:programCounter
        port map(
            clk => clk,
            programCounterIn => PC_IN,
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
        readRegister1 => instruction(25 downto 21),
		readRegister2 => instruction(20 downto 16),
		writeRegister => writereg, --from mux ofc 5bit
		writeData => mux_datamem_out,
		registerWrite => RegWrite, --like write enable
		readData1 => reg1out,
		readData2 => reg2out
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

    end behavior;