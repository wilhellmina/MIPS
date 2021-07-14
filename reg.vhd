-- reg.vhd - Nビット非同期リセット付きレジスタ
library IEEE;
use IEEE.std_logic_1164.all;

-- 非同期リセット付きレジスタ
entity REG is
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
end REG;

architecture BEHAVIOR of REG is
begin
	-- レジスタを表すプロセス
	process (CLK, RST_a)
	begin
		if RST_a = '1' then
			Q <= (others => '0');  -- Qの値をリセットする。
		elsif CLK'event and CLK = '1' then
			if CLEAR = '1' then
				Q <= (others => '0');  -- 0に戻す。
			elsif LOAD = '1' then
				Q <= D;  -- Dの値に更新する。
			end if;
		end if;
		-- その他の場合にはQは変化しない。
	end process;
end BEHAVIOR;