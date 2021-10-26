LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
ENTITY instructionMemory IS
	PORT (
		readAddress : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		instruction : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END instructionMemory;
ARCHITECTURE Behavioral OF instructionMemory IS
	TYPE RAM_16_x_32 IS ARRAY(0 TO 15) OF std_logic_vector(31 DOWNTO 0);
	SIGNAL IM : RAM_16_x_32 := (
		x"00000000",
		x"018b6825",
		x"01285020",
		x"01285022",
		x"0149402a",
		x"08100000",
		x"01285024",
		x"018b6825",
		x"01285020",
		x"01285022",
		x"0149402a",
		x"08100000",
		x"00000000",
		x"00000000",
		x"00000000",
		x"00000000"
	);
BEGIN
	-- Note: 4194304 = 0x0040 0000
	-- reset when address is 003FFFFC else if readAddress is 0040 0000 then reset also
	instruction <= x"00000000" when readAddress = x"003FFFFC" else 
		IM(( to_integer(unsigned(readAddress)) - 4194304) /4);
END Behavioral;