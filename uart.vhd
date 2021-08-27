--------------------------------------------------------------------------------
-- UART Interface Unit
--  Start-stop synchronous communication (RS-232C)
--  115200bps, 8bit, no-parity, 1stop-bit
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


-- top module
entity UART is port(
  CLK: in std_logic;
  RST: in std_logic;
  TXD: out std_logic;
  RXD: in std_logic;
  DIN: in std_logic_vector(7 downto 0);
  DOUT: out std_logic_vector(7 downto 0);
  EN_TX: in std_logic;
  EN_RX: in std_logic;
  STBY_TX: out std_logic;
  STBY_RX: out std_logic);
end UART;

architecture rtl of UART is
  signal CLK_TX: std_logic;
  signal CLK_RX: std_logic;
  
  component clk_generator port(
    clk: in std_logic;
    rst: in std_logic;
    clk_tx: out std_logic;
    clk_rx: out std_logic);
  end component;
  
  component tx port(
    clk: in std_logic;
    rst: in std_logic;
    clk_tx: in std_logic;
    txd: out std_logic;
    din: in std_logic_vector(7 downto 0);
    en: in std_logic;
    stby: out std_logic);
  end component;
  
  component rx port(
    clk: in std_logic;
    rst: in std_logic;
    clk_rx: in std_logic;
    rxd: in std_logic;
    dout: out std_logic_vector(7 downto 0);
    en: in std_logic;
    stby: out std_logic);
  end component;
  
  begin
    uclk_generator: clk_generator port map(
      clk => CLK,
      rst => RST,
      clk_tx => clk_tx,
      clk_rx => clk_rx);
    
    utx: tx port map(
      clk => CLK,
      rst => RST,
      clk_tx => clk_tx,
      txd => TXD,
      din => DIN,
      en => EN_TX,
      stby => STBY_TX);
    
    urx: rx port map(
      clk => CLK,
      rst => RST,
      clk_rx => clk_rx,
      rxd => RXD,
      dout => DOUT,
      en => EN_RX,
      stby=> STBY_RX);

end rtl;