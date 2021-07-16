library IEEE;
use IEEE.std_logic_1164.all;

entity DISPALL7SEG is
    port(
        D :in std_logic_vector(23 downto 0);
        H0,H1,H2,H3,H4,H5 :out std_logic_vector(6 downto 0)
    );
end entity;

architecture RTL of DISPALL7SEG is
    component DEC7SEG
    port(
        D :in std_logic_vector(3 downto 0);
        Y :out std_logic_vector(6 downto 0)
    );
    end component;

    begin
        
    dec1:DEC7SEG
    port map(
        D => D(3 downto 0),
        Y => H0
    );

    dec2:DEC7SEG
    port map(
        D => D(7 downto 4),
        Y => H1
    );

    dec3:DEC7SEG
    port map(
        D => D(11 downto 8),
        Y => H2
    );

    dec4:DEC7SEG
    port map(
        D => D(15 downto 12),
        Y => H3
    );

    dec5:DEC7SEG
    port map(
        D => D(19 downto 16),
        Y => H4
    );

    dec6:DEC7SEG
    port map(
        D => D(23 downto 20),
        Y => H5
    );
    
end architecture;