LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY shiftLeft IS
	GENERIC (
		N : INTEGER := 2;
		W : INTEGER := 32
	);
	PORT (
		addressIN  : IN STD_LOGIC_VECTOR(W - 1 DOWNTO 0);
		addressOUT : OUT STD_LOGIC_VECTOR(W - 1 DOWNTO 0)
	);
END shiftLeft;
ARCHITECTURE Behavioral OF shiftLeft IS
BEGIN
	addressOUT(W - 1)          <= addressIN(W - 1);
	addressOUT(W - 2 DOWNTO N) <= addressIN(W - 2 - N DOWNTO 0);
	addressOUT(N - 1 DOWNTO 0) <= (OTHERS => '0');
END Behavioral;