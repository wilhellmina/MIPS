-- lshreg.vhd - Nビット論理シフトレジスタ
library IEEE;
use IEEE.std_logic_1164.all;

-- Nビット論理シフトレジスタ
entity LSHREG is
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
end LSHREG;

architecture BEHAVIOR of LSHREG is
-- 記憶している値を表す信号
signal R: std_logic_vector(N - 1 downto 0);

begin
	-- シフトレジスタの振る舞い
	process (CLK, RST_a)
	begin
		if RST_a = '1' then
			R <= (others => '0');		
		elsif CLK'event and CLK = '1' then
			if CLEAR = '1' then
				R <= (others => '0');
			elsif SHL = '1' then
				-- 左シフト
				R <= R(N - 2 downto 0) & SH_IN;
			elsif SHR = '1' then
				-- 右シフト 
				R <= SH_IN & R(N - 1 downto 1);
			elsif LOAD = '1' then
				R <= D;
			end if;
		end if;
	end process;

	SH_OUT <= R(N - 1) when SHL = '1' else
				R(0) when SHR = '1' else
				'-';
	-- 記憶している値をそのまま出力する。
	Q <= R;
end BEHAVIOR;
