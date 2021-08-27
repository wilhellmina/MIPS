LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity transfer_fsm is
    port(
        CLK :in std_logic;
        RST_a :in std_logic;

        st :in std_logic;
        state_out :out std_logic_vector(2 downto 0);
        en_tx :out std_logic
    );
end entity;

architecture behavior of transfer_fsm is
    type STATE is(ready,wait_d,first,secound,third,fourth,dum_first,dum_secound,dum_third,dum_fourth);
    signal CURRENT_STATE, NEXT_STATE: STATE;

    --tx serial signal changes when clk_tx high
    --8bit with start stop bit must require 10*clk_tx
    --for stability wait *20 clock rising_edge(clk_tx) due to the dumbess of my brain, cant even do a math
    -- 434 * 20 = 8680
    signal cnt_stby :integer range 0 to 8679;
    signal stby :std_logic;

    begin
        stby <= '1' when (cnt_stby = 8679) else '0';
        counter:process(CLK,RST_A)
        begin
            if(rst_a = '1')then
                cnt_stby <= 0;
            elsif rising_edge(CLK) then
                if(cnt_stby = 8679) then
                    cnt_stby <= 0;
                else
                    cnt_stby <= cnt_stby + 1;
                end if;
            end if;
        end process;

        COMB:process(CURRENT_STATE,ST,STBY)
        begin
            next_state <= current_state;
            state_out <= "000";
            EN_TX <= '0';
            case current_state is
                when ready => 
                if ST = '1' then
                    next_state <= wait_d;
                end if;

                when wait_d =>
                if STBY = '1' then
                    next_state <= first;
                end if;

                when first =>
                if STBY = '1' then
                    next_state <= dum_first;
                end if;
                state_out <= "001";
                en_tx <= '1';

                when dum_first =>
                if STBY = '1' then
                    next_state <= secound;
                end if;
                state_out <= "010";
                en_tx <= '0';

                when secound =>
                if STBY = '1' then
                    next_state <= dum_secound;
                end if;
                state_out <= "010";
                en_tx <= '1';

                when dum_secound =>
                if stby = '1' then
                    next_state <= third;
                end if;
                state_out <= "010";
                en_tx <= '0';

                when third =>
                if STBY = '1' then
                    next_state <= dum_third;
                end if;
                state_out <= "011";
                en_tx <= '1';

                when dum_third =>
                if stby = '1' then
                    next_state <= fourth;
                end if;
                state_out <= "011";
                en_tx <= '0';

                when fourth => 
                if STBY = '1' then
                    next_state <= dum_fourth;   
                end if;
                state_out <= "100";
                en_tx <= '1';

                when dum_fourth =>
                if stby = '1' then
                    next_state <= ready;
                end if;
                state_out <= "100";
                en_tx <= '0';

            end case;
        end process;

        STATE_REG: process(CLK, RST_a)
        begin
            if RST_a= '1' then 
            CURRENT_STATE <= READY;--初期状態の指定
            elsif CLK'event and CLK = '1' then 
            CURRENT_STATE <= NEXT_STATE;
            end if;
        end process;

end architecture;