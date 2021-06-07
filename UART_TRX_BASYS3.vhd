library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_TRX_BASYS3 is
    Port 
    ( 
            CLK             : IN STD_LOGIC;
            RST_IN          : IN STD_LOGIC;
                        
            RX_IN           : IN STD_LOGIC;
            TX_OUT          : OUT STD_LOGIC;
                        
            RX_F_EMPTY      : OUT STD_LOGIC;
            RX_F_DOUT       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            RX_F_REN        : IN  STD_LOGIC;
                        
            TX_F_DIN        : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            TX_F_WEN        : IN  STD_LOGIC;
            TX_F_FULL       : OUT STD_LOGIC
    );
end UART_TRX_BASYS3;

architecture behavioral of UART_TRX_BASYS3 is
   
    signal i_rx_dout        : std_logic_vector(7 downto 0) := (others=>'0');
    signal i_rx_done        : std_logic := '0';
    signal i_rx_wr_en       : std_logic := '0';
    
    signal i_rx_f_din       : std_logic_vector(7 downto 0) := (others=>'0');
    signal i_rx_f_full      : std_logic := '0';
    
    signal i_tx_din         : std_logic_vector(7 downto 0) := (others=>'0');
    signal i_tx_rd_en       : std_logic := '0';
    signal i_tx_start_in    : std_logic := '0';
    
    signal i_tx_f_dout      : std_logic_vector(7 downto 0) := (others=>'0');
    signal i_tx_f_empty     : std_logic := '0';
    signal i_tx_busy        : std_logic := '0';

    
COMPONENT RX_FIFO_BASYS3
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        wr_en : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        full : OUT STD_LOGIC;
        empty : OUT STD_LOGIC
    );
END COMPONENT;

COMPONENT TX_FIFO_BASYS3
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        wr_en : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        full : OUT STD_LOGIC;
        empty : OUT STD_LOGIC
    );
END COMPONENT;
    
begin              

U0_0_UART_RX : entity work.UART_RX_BASYS3
    Generic Map
    (
        CLK_FREQ        =>  100_000_000,
        BAUD_RATE       =>  115_200
    )
    Port map (
        CLK             =>  CLK,
        RST_IN          =>  RST_IN,
        RX_IN           =>  RX_IN,
        RX_OUT          =>  i_rx_dout,
        RX_DONE_OUT     =>  i_rx_done
    );
 
    i_rx_f_din  <=  i_rx_dout;
    i_rx_wr_en  <=  i_rx_done and (not i_rx_f_full);
   
U0_1_UART_RX_F : RX_FIFO_BASYS3
    PORT MAP 
    (
        clk             => CLK,
        rst             => RST_IN,
        din             => i_rx_f_din,      --RX modulunden gelen girecek.
        wr_en           => i_rx_wr_en,      --rx_done gelecek.
        rd_en           => RX_F_REN,        --if not empty.
        dout            => RX_F_DOUT,       --fifo cikisi direkt.
        full            => i_rx_f_full,     --fifo
        empty           => RX_F_EMPTY       --fifo
    );
    
U0_2_UART_TX : entity work.UART_TX_BASYS3
    Generic Map
    (
        CLK_FREQ        =>  100_000_000,
        BAUD_RATE       =>  115_200
    )
    Port map (
        CLK             =>  CLK,
        RST_IN          =>  RST_IN,
        TX_START_IN     =>  i_tx_start_in,
        DATA_IN         =>  i_tx_din,
        
        TX_OUT          =>  TX_OUT,
        TX_BUSY         =>  i_tx_busy,
        TX_DONE_OUT     =>  open
    );
    
    i_tx_start_in <= (not i_tx_f_empty) and (not i_tx_busy);--busy eklendi.
    i_tx_rd_en <=  (not i_tx_f_empty) and (not i_tx_busy);
    i_tx_din <= i_tx_f_dout;
        
U0_3_UART_TX_F : TX_FIFO_BASYS3
    PORT MAP (
        clk             =>  CLK,
        rst             =>  RST_IN,
        din             =>  TX_F_DIN,            --rx fifonun dout'u
        wr_en           =>  TX_F_WEN,            --if rx not empty
        rd_en           =>  i_tx_rd_en,          --?
        dout            =>  i_tx_f_dout,         --tx in gibi olacak
        full            =>  TX_F_FULL,           --fifo
        empty           =>  i_tx_f_empty         --fifo
    );
    
end behavioral;
