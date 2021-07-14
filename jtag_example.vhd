library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity JTAG_EXAMPLE is
    port(
        CLK,RST_a,CLEAR,START : in std_logic;
        test_data : in std_logic_vector(31 downto 0);
        data_out : out std_logic_vector(31 downto 0)
    );
end entity;

architecture RTL of JTAG_EXAMPLE is
    component REG
    generic (
		N: integer := 4  -- 保持するデータのビット幅
	);
	port (
		CLK: in std_logic;  -- クロック
		RST_a: in std_logic;  -- 非同期リセット
		CLEAR: in std_logic := '0';  -- 保持している値を0に戻す。
		LOAD: in std_logic;  -- 保持している値を更新する。
		D: in std_logic_vector(N - 1 downto 0);  -- 新しく保持する値
		Q: out std_logic_vector(N - 1 downto 0)  -- 現在保持している値
	);
    end component;

    component JTAG_FSM
    port(
        START,CLK,RST_a: in std_logic;
        R1L,R2L,R3L : out std_logic;
        FIN :out std_logic
    );
    end component;

    signal REG1_OUT,REG2_OUT:std_logic_vector(31 downto 0);
    signal R1L,R2L,R3L,FIN :std_logic;

    begin
        --fsm
        fsm:JTAG_FSM
        port map(
            CLK => CLK,
            RST_a => RST_a,
            START => START,
            R1L => R1L,
            R2L => R2L,
            R3L => R3L,
            FIN => FIN
        );

        --mux
        --controlled by fsm

        --registers
        reg1:REG
        generic map(
            N => 32
        )
        port map(
            CLK => CLK,
            RST_a => RST_a,
            LOAD => R1L, 
            D => test_data,
            Q => REG1_OUT
        );

        --mux (data selector??)

        reg2:REG
        generic map(
            N => 32
        )
        port map(
            CLK => CLK,
            RST_a => RST_a,
            LOAD => R2L,
            D => REG1_OUT,
            Q => REG2_OUT
        );

        --mux 

        reg3:REG
        generic map(
            N => 32
        )
        port map(
            CLK => CLK,
            RST_a => RST_a,
            LOAD => R3L,
            D => REG2_OUT,
            Q => data_out
        );

        --mux


    end architecture;



    


