library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity TRAIN1 is
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

architecture RTL of TRAIN1 is
    component DEC7SEG 
    port(
        D :in std_logic_vector(3 downto 0);
        Y :out std_logic_vector(6 downto 0)
    );
    end component;

    component BINCOUNTER is
        generic (
		N: integer := 8  -- ビット幅を表すパラメータ
	);
	port (
		CLK: in std_logic;  -- クロック
		RST_a: in std_logic;  -- 非同期リセット
		CLEAR: in std_logic := '0';  -- カウント値を0に戻す。
		CNT: in std_logic := '1';  -- カウントする。
		Q: out std_logic_vector(N - 1 downto 0)  -- カウント値
	);
    end component;
    
    signal ct : std_logic_vector( 23 downto 0);
    signal temp1,temp2,temp3 :std_logic_vector( 9 downto 0);
    --
    begin
        process (KEY, RESET_N,CLOCK_50) is
        begin
            if RESET_N = '0' then
                temp1 <= (others => '0');
                temp2 <= (others => '0');
            elsif rising_edge(CLOCK_50) then
                if KEY(0) = '0' then
                    temp1 <= SW;
                elsif KEY(1) = '0' then
                    temp2 <= SW;
                end if;
            end if;
        end process;
        
    
        process(KEY, CLOCK_50) is
            begin
                if RESET_N = '0' then
                    ct <= (others => '0');
                elsif CLOCK_50'event and CLOCK_50 = '1' then
                    if KEY(2) = '0' then
                        ct(9 downto 0) <= temp1 + temp2;
                    elsif KEY(3) = '0' then
                        ct(9 downto 0) <= temp1 - temp2;
                    end if; 
                end if;
        end process;

        dec0:DEC7SEG
        port map(
            D => ct(3 downto 0),
            Y => HEX0
        );

        dec1:DEC7SEG
        port map(
            D => ct(7 downto 4),
            Y => HEX1
        );
        
        dec2:DEC7SEG
        port map(
            D => ct(11 downto 8),
            Y => HEX2
        );

        dec3:DEC7SEG
        port map(
            D => ct(15 downto 12),
            Y => HEX3
        );

        dec4:DEC7SEG
        port map(
            D => ct(19 downto 16),
            Y => HEX4
        );

        dec5:DEC7SEG
        port map(
            D => ct(23 downto 20),
            Y => HEX5
        );

end architecture;