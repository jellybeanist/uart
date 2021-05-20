library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_rtx is
Port ( 
        CLK         :   IN STD_LOGIC;
        RST_IN      :   IN STD_LOGIC;
        RX_IN       :   IN STD_LOGIC;
        TX_OUT      :   OUT STD_LOGIC
);
end uart_rtx;

architecture behavioral of uart_rtx is

type data_controls is (IDLE, RECEIVE, TRANSMIT);
signal data_control :   data_controls := IDLE;
signal tx_start     :   std_logic := '0';
signal tx_done      :   std_logic := '0';
signal rx_done      :   std_logic := '0';
signal data         :   std_logic_vector(7 downto 0);
signal tx_data      :   std_logic_vector(7 downto 0);
signal rx_data      :   std_logic_vector(7 downto 0);


begin

process(CLK,RST_IN)
begin
    if(RST_IN='1') then
        data_control <= IDLE;
        data <= (others => '0');        
     elsif rising_edge(CLK) then
        tx_start <= '0';
        
        case data_control is
            when IDLE =>
                data_control <= RECEIVE;
                
            when RECEIVE =>
                if rx_done = '1' then
                    tx_data <= rx_data;
                    tx_start <= '1';
                end if;
            when TRANSMIT =>
                if tx_done = '1' then
                    data_control <= IDLE;
                end if;
            when others => NULL;
        end case;
     end if;
end process;
                

uart_tx_map : entity work.uart_tx
Generic Map(
    CLK_FREQ        =>  100_000_000,
    BAUD_RATE       =>  115_200
)
Port map (
    CLK             =>  CLK,
    RST_IN          =>  RST_IN,
    TX_START_IN     =>  tx_start,
    DATA_IN         =>  tx_data,
    TX_OUT          =>  TX_OUT,
    TX_DONE_OUT     =>  tx_done
);

uart_rx_map : entity work.uart_rx
Generic Map(
    CLK_FREQ        =>  100_000_000,
    BAUD_RATE       =>  115_200
)
Port map (
    CLK             =>  CLK,
    RST_IN          =>  RST_IN,
    RX_IN           =>  RX_IN,
    RX_OUT          =>  rx_data,
    RX_DONE_OUT     =>  rx_done
);


end behavioral;
