-- bincounter.vhd - Nビットバイナリカウンタ
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;  -- カウントアップの加算に用いる。

-- バイナリカウンタ
entity BINCOUNTER is
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
end BINCOUNTER;

architecture BEHAVIOR of BINCOUNTER is
-- 記憶されている値を表す信号 
signal COUT: std_logic_vector(N - 1 downto 0);

begin
	-- カウンタを表すプロセス
	process (CLK, RST_a,CNT)
	begin
		if RST_a = '1' then
			-- リセットする。
			COUT <= (others => '0');
		elsif CLK'event and CLK = '1' then
			-- クロックの立ち上がり時の動作
			if CLEAR = '1' then
				COUT <= (others => '0');
			elsif CNT = '1' then
				COUT <= COUT + 1;
			end if;
		end if;
	end process;

	-- カウンタの保持している値を出力する。
	Q <= COUT;
end BEHAVIOR;
