library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fifo_top is
    Port (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        wr_en : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        full : OUT STD_LOGIC;
        empty : OUT STD_LOGIC
     );
end fifo_top;

architecture Behavioral of fifo_top is
    COMPONENT fifo
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
    
    COMPONENT uart_trx
      PORT (
      CLK         :   IN STD_LOGIC;
      RST_IN      :   IN STD_LOGIC;
      RX_IN       :   IN STD_LOGIC;
      TX_OUT      :   OUT STD_LOGIC
      );
    END COMPONENT;

begin
    
    U0_Fifo : fifo
      Port map (
        clk => clk,
        rst => rst,
        din => din,
        wr_en => wr_en,
        rd_en => rd_en,
        dout => dout,
        full => full,
        empty => empty
      );
      
    U1_uart_trx : uart_trx

      Port map (
      CLK       =>  clk,
      RST_IN    =>  rst,
      RX_IN     =>  
      TX_OUT    =>
      );
end Behavioral;
