library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity DEC7SEG is
    port(
        D :in std_logic_vector(3 downto 0);
        Y :out std_logic_vector(6 downto 0)
    );
end DEC7SEG;

architecture RTL of DEC7SEG is
    begin
    process(D) is
        begin
        case D is
            when X"0" => Y <= "1000000";
            when X"1" => Y <= "1111001";
            when X"2" => Y <= "0100100";
            when X"3" => Y <= "0110000";
            when X"4" => Y <= "0011001";
            when X"5" => Y <= "0010010";
            when X"6" => Y <= "0000010";
            when X"7" => Y <= "1111000";
            when X"8" => Y <= "0000000";
            when X"9" => Y <= "0010000";
            when X"A" => Y <= "0001000";
            when X"B" => Y <= "0000011";
            when X"C" => Y <= "1000110";
            when X"D" => Y <= "0100001";
            when X"E" => Y <= "0000110";
            when X"F" => Y <= "0001110";
            
            when others => Y <= "1110111";
        end case;
    end process;
end RTL;