LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY registerFile IS
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
END registerFile;
ARCHITECTURE Behavioral OF registerFile IS
	-- create type 2d array
	TYPE reg_file_type IS ARRAY (0 TO 2 ** W - 1) OF std_logic_vector(B - 1 DOWNTO 0);
	-- create 32 registers of 32 bits
	SIGNAL array_reg : reg_file_type := (
		x"00000000", --$zero
		x"11111111", --$at
		x"22222222", --$v0
		x"33333333", --$v1
		x"44444444", --$a0
		x"55555555", --$a1
		x"66666666", --$a2
		x"77777777", --$a3
		x"88888888", --$t0
		x"99999999", --$t1
		x"aaaaaaaa", --$t2
		x"bbbbbbbb", --$t3
		x"cccccccc", --$t4
		x"dddddddd", --$t5
		x"eeeeeeee", --$t6
		x"ffffffff", --$t7
		x"00000000", --$s0
		x"11111111", --$s1
		x"22222222", --$s2
		x"33333333", --$s3
		x"44444444", --$s4
		x"55555555", --$s5
		x"66666666", --$s6
		x"77777777", --$s7
		x"88888888", --$t8
		x"99999999", --$t9
		x"aaaaaaaa", --$k0
		x"bbbbbbbb", --$k1
		x"10008000", --$global pointer
		x"7FFFF1EC", --$stack pointer
		x"eeeeeeee", --$frame pointer
		x"ffffffff" --$return address
	);

	signal mux_data : std_logic_vector(31 downto 0);
	signal mux_adr : std_logic_vector(4 downto 0);

	signal reg_we : std_logic;

	signal mips_ctrl_we : std_logic;

BEGIN
	reg_we <= registerWrite OR we_rpi;

	process(we_rpi,registerWrite)
	begin
		if(we_rpi = '1') then
			mips_ctrl_we <= '0';
		else
			mips_ctrl_we <= registerWrite;
		end if;
	end process;
			

	process(we_rpi,mips_ctrl_we)
	begin
		if(we_rpi = '1') then
			mux_data <= w_data_rpi;
			mux_adr <= w_adr_rpi;
		elsif(mips_ctrl_we = '1') then
			mux_data <= writeData;
			mux_adr <= writeRegister;
		end if;
	end process;

	PROCESS (CLK) -- pulse on write
	BEGIN
		-- writeRegister is the register which we want to write to
		-- writeData is the data which we dant to save
		if rising_edge(CLK) then
			IF (reg_we = '1') THEN
			array_reg(to_integer(unsigned(mux_adr))) <= mux_data;
			end if;
		END IF;
	END PROCESS;

	--read port
	process(readRegister1)
	begin
		if(readRegister1 = X"0"& '0') then
			readData1 <= X"00000000";
		else
			readData1 <= array_reg(to_integer(unsigned(readRegister1)));
		end if;
	end process;

	--process(readRegister1)
	--begin
	--	case readRegister1 is
	--		when X"0" & '0' => readData1 <= X"00000000";
	--		when others => readData1 <= array_reg(to_integer(unsigned(readRegister1)));
	--	end case;
	--end process;

	process(readRegister2)
	begin
		if(readRegister2 = X"0"& '0') then
			readData2 <= X"00000000";
		else
			readData2 <= array_reg(to_integer(unsigned(readRegister2)));
		end if;
	end process;

	process(readRegister3)
	begin
		if(readRegister3 = X"0" & '0') then
			readData3 <= X"00000000";
		else
		readData3 <= array_reg(to_integer(unsigned(readRegister3)));
		end if;
	end process;

	--readData1 <= array_reg(to_integer(unsigned(readRegister1)));
	--readData2 <= array_reg(to_integer(unsigned(readRegister2)));
END Behavioral;