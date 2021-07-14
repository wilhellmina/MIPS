LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity keypress_fsm is
    port(
        CLK :in std_logic;
        RST_a :in std_logic;
        key :in std_logic;
        key_out :out std_logic
    );
end entity;

architecture RTL of keypress_fsm is
    type STATE is(KEY_ON,KEY_OFF);
    signal CURRENT_STATE, NEXT_STATE: STATE;
    begin
    --fsm
    COMB:process(CURRENT_STATE,KEY)
    begin
        case CURRENT_STATE is
            when KEY_OFF =>
                if key = '1' then
                    NEXT_STATE <= KEY_ON;
                    KEY_OUT <= '1';
                else
                    NEXT_STATE <= CURRENT_STATE;
                end if;
            when KEY_ON => 
                if key = '1' then
                    KEY_OUT <= '0';
                    NEXT_STATE <= CURRENT_STATE;
                else
                    KEY_OUT <= '0';  
                    NEXT_STATE <= KEY_OFF;
                end if;
        end case;
    end process;

    STATE_REG:process(CLK,RST_a)
    begin
        if RST_a = '1' then
            CURRENT_STATE <= KEY_OFF;
        elsif rising_edge(CLK) then
            CURRENT_STATE <= NEXT_STATE;
        end if;
    end process;

end architecture;