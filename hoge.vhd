library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity HOGE is
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
        HEX5: out std_logic_vector(6 downto 0)
    );
end entity;

architecture RTL of HOGE is
    constant kDigit0 : std_logic_vector(6 downto 0) := "1000000";
    constant kDigit1 : std_logic_vector(6 downto 0) := "1111001";
    constant kDigit2 : std_logic_vector(6 downto 0) := "0100100";
    constant kDigit3 : std_logic_vector(6 downto 0) := "0110000";
    constant kDigit4 : std_logic_vector(6 downto 0) := "0011001";
    constant kDigit5 : std_logic_vector(6 downto 0) := "0010010";
    constant kDigit6 : std_logic_vector(6 downto 0) := "0000010";
    constant kDigit7 : std_logic_vector(6 downto 0) := "1111000";
    constant kDigit8 : std_logic_vector(6 downto 0) := "0000000";
    constant kDigit9 : std_logic_vector(6 downto 0) := "0010000";
    constant kDigitA : std_logic_vector(6 downto 0) := "0001000";
    constant kDigitB : std_logic_vector(6 downto 0) := "0000011";
    constant kDigitC : std_logic_vector(6 downto 0) := "1000110";
    constant kDigitD : std_logic_vector(6 downto 0) := "0100001";
    constant kDigitE : std_logic_vector(6 downto 0) := "0000110";
    constant kDigitF : std_logic_vector(6 downto 0) := "0001110";

    type tDigitSelect is array(0 to 15) of std_logic_vector(6 downto 0);
    
    constant kDigit : tDigitSelect := ( kDigit0, kDigit1, kDigit2, kDigit3,
                                        kDigit4, kDigit5, kDigit6, kDigit7,
                                        kDigit8, kDigit9, kDigitA, kDigitB,
                                        kDigitC, kDigitD, kDigitE, kDigitF
                                      );
    
    -- clock = 50MHz (20ns)
    -- 1s = 50,000,000 cycle
    -- log2(50,000,000) = 25.5 := 26bit
    signal count1s    : std_logic_vector(25 downto 0);
    signal countdigit : std_logic_vector( 3 downto 0);
    
begin
    process (CLOCK_50, RESET_N) is
    begin
        if RESET_N = '0' then
            count1s <= (others => '0');
        elsif rising_edge(CLOCK_50) then
            count1s <= count1s + '1';
        end if;
    end process;

    process (KEY, RESET_N,CLOCK_50) is
    begin
        if RESET_N = '0' then
            countdigit <= (others => '0');
        elsif rising_edge(CLOCK_50) then
            countdigit <= countdigit + '1';
        end if;
    end process;


    process (CLOCK_50, RESET_N) is
    begin
        if RESET_N = '0' then
            HEX0 <= (others => '1');
            HEX1 <= (others => '1');
            HEX2 <= (others => '1');
            HEX3 <= (others => '1');
            HEX4 <= (others => '1');
            HEX5 <= (others => '1');
        elsif rising_edge(CLOCK_50) then
            HEX0 <= kDigit(conv_integer(countdigit));
        end if;
    end process;

end RTL;