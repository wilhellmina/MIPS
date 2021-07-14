--use SDRAM on the board
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity MEM_TEST is
    port(
        CLOCK_50 :in std_logic;
        RESET_N :in std_logic;
        SW :in std_logic_vector(9 downto 0);
        KEY :in std_logic_vector(3 downto 0);

        HEX0: out std_logic_vector(6 downto 0);
        HEX1: out std_logic_vector(6 downto 0);
        HEX2: out std_logic_vector(6 downto 0);
        HEX3: out std_logic_vector(6 downto 0);
        HEX4: out std_logic_vector(6 downto 0);
        HEX5: out std_logic_vector(6 downto 0);

        LEDR: out std_logic_vector(9 downto 0)
    );
end entity;

architecture RTL of MEM_TEST is
    --component ram
    component ram
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
    end component;

    --disp ram there
    component DISPALL7SEG
    port(
        D :in std_logic_vector(23 downto 0);
        H0,H1,H2,H3,H4,H5 :out std_logic_vector(6 downto 0)
    );
    end component;

    component KEYPRESS_FSM
    port(
        CLK :in std_logic;
        RST_a :in std_logic;
        key :in std_logic;
        key_out :out std_logic
    );
    end component;


    signal ptr :std_logic_vector(3 downto 0);
    signal temp :std_logic_vector(31 downto 0);
    signal ram_out :std_logic_vector(31 downto 0);
    signal kp3,kp2 :std_logic;
    signal count :std_logic_vector(24 downto 0);
    signal shift :std_logic;

    begin
        --turn pesky LED OFF
        --too bright annoying af
        LEDR <= ("00" & X"00");
        
        --sw bitstream to register
        process(CLOCK_50,RESET_N) is
            begin
                if RESET_N = '0' then
                    temp <= (others => '0');
                elsif rising_edge(CLOCK_50) then
                    temp <= temp + X"F";
                end if;
        end process;

        fsm_kp3:keypress_fsm
        port map(
            CLK => CLOCK_50,
            RST_a => NOT RESET_N,
            KEY => NOT KEY(3),
            KEY_OUT => KP3
        );
        fsm_kp2:keypress_fsm
        port map(
            CLK => CLOCK_50,
            RST_a => NOT RESET_N,
            KEY => NOT KEY(2),
            KEY_OUT => KP2
        );

        --address selector
        process(CLOCK_50,RESET_N) is
            begin
                if RESET_N = '0' then
                    ptr <= (others => '0');
                elsif rising_edge(CLOCK_50) then
                    if KP3 = '1' then
                        ptr <= ptr + 1;
                    elsif KP2 = '1' then
                        ptr <= ptr - 1;
                    end if;
                end if;
        end process;

        --RAM instatiate 
        r:ram
        port map(
            address => X"00" & ptr,
            clock => CLOCK_50,
            data => temp,
            wren => NOT KEY(0),
            q => ram_out
        );
        
        --counter
        process (RESET_N,CLOCK_50) is
            begin
                if RESET_N = '0' then
                    count <= (others => '0');
                elsif rising_edge(CLOCK_50) then
                    count <= count + '1';
                end if;
        end process;

        process(count) is
            begin
                if count = X"FFFFF" then
                    shift <= '1';
                else
                    shift <= '0';
                end if;
        end process;
        
        disp:DISPALL7SEG 
        port map(
            D => ram_out(23 downto 0),
            H0 => HEX0,
            H1 => HEX1,
            H2 => HEX2,
            H3 => HEX3,
            H4 => HEX4,
            H5 => HEX5
        );

end architecture;