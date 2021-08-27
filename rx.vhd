library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;


-- receiver module
entity rx is port(
  clk: in std_logic;
  rst: in std_logic;
  clk_rx: in std_logic;
  rxd: in std_logic;
  dout: out std_logic_vector(7 downto 0);
  en: in std_logic;
  stby: out std_logic);
end rx;

architecture rtl of rx is
  type state_type is (idle, detect, proc, stopbit);
  signal state: state_type;
  signal dout_reg: std_logic_vector(7 downto 0);
  signal en_tmp: std_logic;
  signal cnt_bitnum: integer range 0 to 7;
  signal cnt_bitwidth: integer range 0 to 15;
  signal buf: std_logic; 
  
  begin
    dout <= dout_reg;
    
    process(clk, rst) begin
      if(rst ='1') then
        buf <= '0';
      elsif(clk'event and clk = '1') then
        buf <= rxd;
      end if;
    end process;
    
    process(clk, rst) begin
      if(rst ='1') then
        en_tmp <= '0';
        stby <= '1';
        dout_reg <= (others => '0');
        cnt_bitnum <= 0;
        cnt_bitwidth <= 0;
        state <= idle;
      elsif(clk'event and clk = '1') then
        if(en = '1') then
          en_tmp <= '1';
          stby <= '0';
        end if;
        if(en_tmp = '1') then
          case state is
            when idle => 
              if(buf = '0') then
                cnt_bitnum <= 0;
                cnt_bitwidth <= 0;
                state <= detect;
              else
                state <= state;
              end if;
            when detect =>
              if(clk_rx = '1') then
                if(cnt_bitwidth = 7) then
                  cnt_bitwidth <= 0;
                  state <= proc;
                else
                  cnt_bitwidth <= cnt_bitwidth + 1;
                  state <= state;
                end if;
              else
                state <= state;
              end if;
            when proc =>
              if(clk_rx = '1') then
                if(cnt_bitwidth = 15) then
                  if(cnt_bitnum = 7) then
                    cnt_bitnum <= 0;
                    state <= stopbit;
                  else
                    cnt_bitnum <= cnt_bitnum + 1;
                    state <= state;
                  end if;
                  dout_reg <= rxd & dout_reg(7 downto 1);
                  cnt_bitwidth <= 0;
                else
                  cnt_bitwidth <= cnt_bitwidth + 1;
                  state <= state;
                end if;
              else
                state <= state;
              end if;
            when stopbit =>
              if(clk_rx = '1') then
                if(cnt_bitwidth = 15) then
                  en_tmp <= en;
                  state <= idle;
                else
                  cnt_bitwidth <= cnt_bitwidth + 1;
                  state <= state;
                end if;
              else
                state <= state;
              end if;
            when others =>
              en_tmp <= '0';
              state <= idle;
          end case;
        elsif(en = '0' and en_tmp = '0') then
          stby <= '1';
        end if;
      end if;
    end process;
  
end rtl;