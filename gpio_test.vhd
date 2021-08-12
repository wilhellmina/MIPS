library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity GPIO_TEST is
    port(
        CLOCK_50 :in std_logic;
        GPIO_0 :out std_logic_vector(35 downto 0);
        SW :in std_logic_vector(9 downto 0);
        LEDR: out std_logic_vector(9 downto 0)
    );
end entity;

architecture beh of GPIO_TEST is
    begin
        LEDR(0) <= SW(0);
        GPIO_0(0) <= SW(0);
        LEDR(9 downto 1) <= ("0" & X"00");
end architecture;
