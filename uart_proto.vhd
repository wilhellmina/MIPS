library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;


entity uart_proto is
    port(
        CLK : in std_logic;
        RST_a : in std_logic;

        tx :out std_logic;
        rx :in std_logic;

        din :in std_logic_vector(31 downto 0);
        regaddr :out std_logic_vector(4 downto 0)
    );
end entity;

architecture beh of uart_proto is
    component transfer_fsm
    port(
        CLK :in std_logic;
        RST_a :in std_logic;

        st:in std_logic;
        state_out :out std_logic_vector(2 downto 0);
        en_tx :out std_logic
    );
    end component;

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

    component UART 
    port(
        CLK: in std_logic;
        RST: in std_logic;
        TXD: out std_logic;
        RXD: in std_logic;
        DIN: in std_logic_vector(7 downto 0);
        DOUT: out std_logic_vector(7 downto 0);
        EN_TX: in std_logic;
        EN_RX: in std_logic;
        STBY_TX: out std_logic;
        STBY_RX: out std_logic
    );
    end component;

    component registerFile
    GENERIC (
		B : INTEGER := 32; --number of bits
		W : INTEGER := 5 --number of address bits
	);
	PORT (
		readRegister1 : IN std_logic_vector (W - 1 DOWNTO 0);
		readRegister2 : IN std_logic_vector (W - 1 DOWNTO 0);
		writeRegister : IN std_logic_vector (W - 1 DOWNTO 0);
		writeData     : IN std_logic_vector (B - 1 DOWNTO 0);
		registerWrite : IN std_logic;
		readData1     : OUT std_logic_vector (B - 1 DOWNTO 0);
		readData2     : OUT std_logic_vector (B - 1 DOWNTO 0);

		readRegister3 :IN std_logic_vector(W -1 downto 0);
		readData3 : out std_logic_vector(B -1 downto 0)
	);
    end component;

    component dispall7seg
    port(
        D :in std_logic_vector(23 downto 0);
        H0,H1,H2,H3,H4,H5 :out std_logic_vector(6 downto 0)
    );
    end component;

    signal state_out: std_logic_vector(2 downto 0);
    signal st,s_en_tx: std_logic;

    signal cnt_half_clock : integer range 0 to 2;
    signal half_clock : std_logic;

    signal previous_din:std_logic_vector(31 downto 0);
    signal rxdata :std_logic_vector(7 downto 0);
    signal dout :std_logic_vector(7 downto 0);

    begin
        --clock 4 reg to save previous value
        half_clock <= '1' when(cnt_half_clock = 2) else '0';
        process(CLK,RST_a)
        begin
            if(RST_a = '1') then
                cnt_half_clock <= 0;
            elsif rising_edge(CLK) then
                if(cnt_half_clock = 2)then
                    cnt_half_clock <= 0;
                else 
                    cnt_half_clock <= cnt_half_clock + 1; 
                end if;
            end if;
        end process;

        u0_reg_preval:reg
        generic map(
            N => 32
        )
        port map(
            CLK => half_clock,
            RST_a => RST_a,
            LOAD => '1',
            D => DIN,
            Q => previous_din
        );

        u1:transfer_fsm
        port map(
            CLK => CLK,
            RST_a => RST_a,

            state_out => state_out,
            st => st,
            en_tx => s_en_tx
        );

        u2:uart
        port map(
            CLK => CLK,
            RST => RST_a,
            
            --TX
            txd => tx,
            din => dout,
            en_tx => s_en_tx,

            --rx
            rxd => rx,
            dout => rxdata,
            en_rx => '1'
        );

        compare_with_preval:process(CLK)
        begin
            if rising_edge(CLK) then
                if DIN /= previous_din then
                    st <= '1';
                else
                    st <= '0';
                end if;
            end if;
        end process;
        
        s_each8b:process(state_out)
        begin
            case state_out is
                when "000" => dout <= X"00";
                when "001" => dout <= din(7 downto 0);
                when "010" => dout <= din(15 downto 8);
                when "011" => dout <= din(23 downto 16);
                when "100" => dout <= din(31 downto 24);
                when others => dout <= X"00";
            end case;
        end process;
        
        regaddr <= rxdata(4 downto 0);

end architecture;