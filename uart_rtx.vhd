library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_rtx is
Port ( 
        CLK         : IN STD_LOGIC;
        RST_IN      : IN STD_LOGIC;
        RX_IN       : IN STD_LOGIC;
        TX_OUT      : OUT STD_LOGIC
);
end uart_rtx;

architecture behavioral of uart_rtx is
    component uart_tx
        generic(
            CLK_FREQ    : INTEGER := 100_000_000;
            BAUD_RATE   : INTEGER := 115_200
                );
        port(
            CLK             : IN STD_LOGIC;                             
            RST_IN          : IN STD_LOGIC;                      
            DATA_IN         : IN STD_LOGIC_VECTOR (7 DOWNTO 0);  
            TX_START_IN     : IN STD_LOGIC;                      
            TX_OUT          : OUT STD_LOGIC;                     
            TX_DONE_OUT     : OUT STD_LOGIC                      
            );
    end component;
    
    component uart_rx
        generic(
            CLK_FREQ    : INTEGER := 100_000_000;
            BAUD_RATE   : INTEGER := 115_200
                );
        port(
            CLK             : IN STD_LOGIC;                         --1 bit clock.  
            RST_IN          : IN STD_LOGIC;                         --1 bit reset.      
            RX_IN           : IN STD_LOGIC;                         --1 bit input.
            RX_OUT          : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);    --Data to transmit after receiving.        
            RX_DONE_OUT     : OUT STD_LOGIC                         --Done check.
            );
    end component;

type data_control is (IDLE, RECEIVE, TRANSMIT);



begin


uart_tx_map : uart_tx
generic map(
CLK_FREQ => 100000000,
BAUD_RATE => 115200
);
port map (
CLK => CLK,
RST_IN => RST_IN,
tx_done_out =>


);

uart_rx_map : uart_rx
generic map(
CLK_FREQ => 100000000,
BAUD_RATE => 115200
);
port map (
CLK => CLK,
RST_IN => RST_IN,


);


end behavioral;
