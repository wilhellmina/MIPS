library IEEE;
use IEEE.std_logic_1164.all;

entity TEST is
    port(
        CLOCK2_50 :in std_logic;
        SW : in std_logic_vector(9 downto 0);
        KEY:  in  std_logic_vector(3 downto 0);
        RESET_N :in std_logic;
        

        HEX0: out std_logic_vector(0 to 6);
        HEX1: out std_logic_vector(6 downto 0);
        HEX2: out std_logic_vector(6 downto 0);
        HEX3: out std_logic_vector(6 downto 0);
        HEX4: out std_logic_vector(6 downto 0);
        HEX5: out std_logic_vector(6 downto 0)
    );
end entity;

architecture RTL of TEST is
    begin
        
end architecture;
