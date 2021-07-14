library IEEE;
use IEEE.std_logic_1164.all;

entity SHIFTREG8 is
    generic(
        N : integer := 8
    );
    port(
    CLK,RST_a:in std_logic;
    SHL,SHR :in std_logic;
    SH_IN :in std_logic;
    D :in std_logic_vector(N - 1 downto 0);
    LOAD,CLEAR :in std_logic;
    Q :out std_logic_Vector(N - 1 downto 0);
    SH_OUT :out std_logic
    );
end SHIFTREG8;

architecture logic of SHIFTREG8 is
    --declear component REG
    component REG is
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

    --declear component LSHREG
    component LSHREG is
        generic (
		N: integer := 8 -- ビット幅を表すパラメータ
	);
	port (
		CLK:	in std_logic; -- クロック
		RST_a: in std_logic; -- 非同期リセット
		CLEAR: in std_logic := '0'; -- クリア
		LOAD: in std_logic := '0'; -- ロード
		SH_IN: in std_logic := '0'; -- シフト入力
		SHL, SHR: in std_logic := '0'; -- 左シフト・右シフト
		D: in std_logic_vector(N - 1 downto 0); -- データ入力
		SH_OUT: out std_logic; -- シフト出力
		Q: out std_logic_vector(N - 1 downto 0) -- データ出力
    );
    end component;

    --signals 
    signal shlr :std_logic;
    signal shifted,mux,sq: std_logic_vector(N - 1 downto 0);

    begin
    shlr <= SHL or SHR;

    process (D,shlr,shifted)
    begin
        if shlr ='1' then
            mux <= shifted;
        else
            mux <= D;
        end if;
    end process;

    yuki:REG
    generic map(
        N => N
    )
    port map(
        CLK => CLK,
        RST_a => RST_a,
        CLEAR => CLEAR,
        LOAD => shlr or LOAD,
        D => mux,
        Q => sq
    );

    Q <= SQ;
    
    yuuki:LSHREG
    generic map(
        N => N
    )
    port map(
        CLK => CLK,
        RST_a => RST_a,
        SH_IN => SH_IN,
        SHL => SHL,
        SHR => SHR,
        D => sq,
        SH_OUT => SH_OUT,
        Q => shifted
    );

end logic;