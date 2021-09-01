LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity mips4edu is
    port(
        CLOCK_50 : in std_logic;
        RESET_N :in std_logic;
        HEX0,HEX1,HEX2,HEX3,HEX4,HEX5 : out std_logic_vector(6 downto 0);
        KEY : in std_logic_vector(3 downto 0);
        GPIO_0 :inout std_logic_vector(35 downto 0);
        LEDR: out std_logic_vector(9 downto 0)
    );
end entity;

