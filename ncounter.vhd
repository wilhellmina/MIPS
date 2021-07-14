-- ncounter.vhd - N進カウンタ
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

-- N進カウンタ
entity NCOUNTER is
	generic (
		K: integer := 4; -- ビット幅
		RADIX: integer := 10 -- 基数
	);
	port (
		CLK: in std_logic; -- クロック
		RST_a: in std_logic; -- 非同期リセット
		CLEAR: in std_logic := '0'; -- カウント値を0に戻す。
		CNT: in std_logic := '1'; -- カウントする。
		CO: out std_logic; -- 桁上がり
		Q: out std_logic_vector(K - 1 downto 0) -- カウント値
	);
end NCOUNTER;

architecture BEHAVIOR of NCOUNTER is
-- バイナリカウンタ
component BINCOUNTER
	generic (
		N: integer := 8 -- ビット幅を表すパラメータ
	);
	port (
		CLK:	in std_logic; -- クロック
		RST_a:	in std_logic; -- 非同期リセット
		CLEAR:	in std_logic; -- カウント値を0に戻す。
		CNT:	in std_logic; -- カウントする。
		Q:		out std_logic_vector(N - 1 downto 0) -- カウント値
	);
end component BINCOUNTER;

-- N進カウント用信号
signal COUT: std_logic_vector(K - 1 downto 0);
signal CT_CLEAR: std_logic;
signal OVERFLOW: std_logic;

begin
	OVERFLOW <= '1' when (CNT = '1') and (COUT = RADIX - 1) else
				'0';
	CT_CLEAR <= '1' when (CLEAR = '1') or (OVERFLOW = '1') else
				'0';

	-- バイナリカウンタ
	CT: BINCOUNTER
		generic map (
			N => K
		)
		port map (
			CLK => CLK,
			RST_a => RST_a,
			CLEAR => CT_CLEAR,
			CNT => CNT,
			Q => COUT
		);

	-- 桁上がりの出力
	CO <= OVERFLOW;
	-- カウンタの保持している値の出力
	Q <= COUT;
end BEHAVIOR;
