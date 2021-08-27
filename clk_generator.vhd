library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;


-- clock generator module
entity clk_generator is port(
  clk: in std_logic;
  rst: in std_logic;
  clk_tx: out std_logic;
  clk_rx: out std_logic);
end clk_generator;

architecture rtl of clk_generator is
  -- (1 / 115200bps) / (1 / 50MHz) = 434
  signal cnt_tx: integer range 0 to 433;
  -- (1 / 115200bps) / (1 / 50MHz) / 16 = 27
  signal cnt_rx: integer range 0 to 26;
  
  begin
    clk_tx <= '1' when(cnt_tx = 433) else '0';
    process(clk, rst) begin
      if(rst = '1') then
        cnt_tx <= 0;
      elsif(clk'event and clk = '1') then
        if(cnt_tx = 433) then
          cnt_tx <= 0;
        else
          cnt_tx <= cnt_tx + 1;
        end if;
      end if;
    end process;
    
    clk_rx <= '1' when(cnt_rx = 26) else '0';
    process(clk, rst) begin
      if(rst = '1') then
        cnt_rx <= 0;
      elsif(clk'event and clk = '1') then
        if(cnt_rx = 26) then
          cnt_rx<= 0;
        else
          cnt_rx <= cnt_rx + 1;
        end if; 
      end if;
    end process;

end rtl;
