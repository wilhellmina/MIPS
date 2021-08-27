library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;


-- transmitter module
entity tx is port(
  clk: in std_logic;
  rst: in std_logic;
  clk_tx: in std_logic;
  txd: out std_logic;
  din: in std_logic_vector(7 downto 0);
  en: in std_logic;
  stby: out std_logic);
end tx;

architecture rtl of tx is
  signal en_tmp: std_logic;
  signal cnt_bit: integer range 0 to 9;
  signal buf: std_logic_vector(7 downto 0); 
  
  begin
    process(clk, rst) begin
      if(rst = '1') then
        txd <= '1';
        en_tmp <= '0';
        stby <= '1';
        cnt_bit <=  0;
        buf <= (others => '0');
      elsif(clk'event and clk = '1') then
        if(en = '1') then
          en_tmp <= '1';
          stby <= '0';
          buf <= din;
        elsif(clk_tx = '1' and en_tmp = '1') then
          case cnt_bit is
            when 0 => 
              txd <= '0';
              cnt_bit <= cnt_bit + 1;
            when 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 => 
              txd <= buf(0);
              buf <= '1' & buf(7 downto 1);
              cnt_bit <= cnt_bit + 1;
            when others => 
              txd <= '1';
              en_tmp <= '0';
              stby <= '1';
              cnt_bit <= 0;
          end case;
        end if;
      end if;
    end process;

end rtl;
