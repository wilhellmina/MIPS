library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity JTAG_FSM is
    port(
        START,CLK,RST_a: in std_logic;
        R1L,R2L,R3L : out std_logic;
        FIN :out std_logic
    );
end entity;

architecture smachine of jtag_fsm is
    type STATE is (READY,S1,S2,S3);
    signal CURRENT_STATE,NEXT_STATE: STATE;
    begin
        COMB:process(CURRENT_STATE,START)
        begin
            FIN <= '0';
            R1L <= '0';
            R2L <= '0';
            R3L <= '0';
            case CURRENT_STATE is
                when READY => 
                    if START = '0' then
                        NEXT_STATE <= CURRENT_STATE;
                    else
                        NEXT_STATE <= S1;
                    end if;
                when S1 =>
                    NEXT_STATE <= S2;
                    R3L <= '1';
                when S2 => 
                    NEXT_STATE <= S3;
                    R2L <= '1';
                    R3L <= '1';
                when S3 => 
                    NEXT_STATE <= READY;
                    R1L <= '1';
                    R2L <= '1';
                    R3L <= '1';
                    FIN <= '1';
            end case;
        end process;
    
        STATE_REG: process(CLK, RST_a)
            begin
                if RST_a= '1' then 
                CURRENT_STATE <= READY;
                elsif CLK'event and CLK = '1' then 
                CURRENT_STATE <= NEXT_STATE;
                end if;
            end process;

    end architecture;