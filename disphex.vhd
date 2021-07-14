library IEEE;
use IEEE.std_logic_1164.all;
    use IEEE.std_logic_misc.all;
    use IEEE.std_logic_arith.all;
    use IEEE.std_logic_unsigned.all;

entity DISPHEX is
    port(
        CLOCK_50 :in std_logic;
        SW : in std_logic_vector(9 downto 0);
        KEY:  in  std_logic_vector(3 downto 0);
        RESET_N :in std_logic;

        HEX0: out std_logic_vector(6 downto 0);
        HEX1: out std_logic_vector(6 downto 0);
        HEX2: out std_logic_vector(6 downto 0);
        HEX3: out std_logic_vector(6 downto 0);
        HEX4: out std_logic_vector(6 downto 0);
        HEX5: out std_logic_vector(6 downto 0);

        LEDR: out std_logic_vector(9 downto 0)
    );
end entity;

architecture RTL of DISPHEX is
    component DEC7SEG
    port(
        D :in std_logic_vector(3 downto 0);
        Y :out std_logic_vector(6 downto 0)
    );
    end component;

    component DISPALL7SEG
    port(
        D :in std_logic_vector(23 downto 0);
        H0,H1,H2,H3,H4,H5 :out std_logic_vector(6 downto 0)
    );
    end component;

    signal ct :std_logic_vector(23 downto 0);
    signal temp :std_logic_vector(23 downto 0);
    signal led :std_logic_vector(9 downto 0);
    begin
        process (CLOCK_50, RESET_N) is
            begin
                if RESET_N = '0' then
                    ct <= (others => '0');
                elsif rising_edge(CLOCK_50) then
                    ct <= ct + '1';
                end if;
        end process;

        process(CLOCK_50,SW,RESET_N) is
            begin
            if RESET_N = '0' then
                temp <= (others => '0');
            elsif rising_edge(CLOCK_50) then
                temp(9 downto 0) <= SW;
            end if;
        end process;
        
        disp:DISPALL7SEG 
        port map(
            D => temp,
            H0 => HEX0,
            H1 => HEX1,
            H2 => HEX2,
            H3 => HEX3,
            H4 => HEX4,
            H5 => HEX5
        );

        process(ct) is
            begin
                case ct is
                    when X"000000" => led <= "1111111111";
                    when others => led <= "0000000000";
                end case;
        end process;

        LEDR <= LED;

end architecture;



