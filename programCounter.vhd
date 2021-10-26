LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY programCounter IS
	PORT (
		clk,reset :in std_logic;
		we_rpi : in std_logic;
		w_pc : in std_logic_vector(31 downto 0);

		programCounterIn   : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		programCounterOut  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := X"00400000"
	);
END programCounter;


ARCHITECTURE Behavioral OF programCounter IS
BEGIN
	process(CLK,reset,w_pc)
	begin
		if (reset = '1') then
			ProgramCounterOut <= X"00400000";
		elsif (we_rpi = '1') then
			programCounterOut <= w_pc;
		elsif rising_edge(CLK) then
			programCounterOut <= programCounterIn;
	end if;
	
	end process;
	-- programCounterOut <= x"00400000" OR std_logic_vector(to_unsigned(progamCounterIn * 4, 32));
END Behavioral;