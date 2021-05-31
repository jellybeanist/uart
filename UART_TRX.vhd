library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_TRX is
	port
	(
		CLK				: IN	STD_LOGIC;
		RST				: IN	STD_LOGIC;
		
		CLK_DIV_BAUD	: IN	STD_LOGIC_VECTOR(31 DOWNTO 0);
		
		SER_TX			: OUT	STD_LOGIC;
		SER_RX			: IN	STD_LOGIC;
		
		RX_BUF_EMPTY	: OUT	STD_LOGIC;
		RX_BUF_RDEN		: IN	STD_LOGIC;
		RX_BUF_DATA		: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
        		
		TX_BUF_FULL		: OUT  	STD_LOGIC;
		TX_BUF_WREN		: IN  	STD_LOGIC;
		TX_BUF_DATA		: IN	STD_LOGIC_VECTOR(7 DOWNTO 0)		
	);
end UART_TRX;

architecture Behavioral of UART_TRX is

	signal rx_fifo_full			: std_logic := '0';
	signal rx_fifo_wr_en		: std_logic := '0';
	signal rx_fifo_din			: std_logic_vector(7 downto 0) := (others=>'0');
	signal rx_data				: std_logic_vector(7 downto 0) := (others=>'0');
	signal rx_data_valid		: std_logic := '0';
	
	signal tx_data				: std_logic_vector(7 downto 0) := (others=>'0');
	signal tx_data_valid		: std_logic := '0';
	signal tx_busy				: std_logic := '0';
	signal tx_fifo_rden			: std_logic := '0';
	signal tx_fifo_empty		: std_logic := '0';
	signal tx_fifo_dout			: std_logic_vector(7 downto 0) := (others=>'0');

    COMPONENT RX_FIFO
      PORT (
        rst         : IN STD_LOGIC;
        clk         : IN STD_LOGIC;
        din         : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        wr_en       : IN STD_LOGIC;
        rd_en       : IN STD_LOGIC;
        dout        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        full        : OUT STD_LOGIC;
        empty       : OUT STD_LOGIC
      );
       end component RX_FIFO;
       
    COMPONENT TX_FIFO
        PORT (
          rst       : IN STD_LOGIC;
          clk       : IN STD_LOGIC;
          din       : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
          wr_en     : IN STD_LOGIC;
          rd_en     : IN STD_LOGIC;
          dout      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
          full      : OUT STD_LOGIC;
          empty     : OUT STD_LOGIC
        );
 end component TX_FIFO;
 
begin

	uart_rx_i : entity work.UART_RX 
		port map
		(
			CLK 			=> CLK,
			rst			 	=> RST,
			
			ser_rx 			=> ser_rx,
			
			clk_div_baud 	=> CLK_DIV_BAUD,
			
			rx_data 		=> rx_data,
			rx_data_valid 	=> rx_data_valid,
			rx_err 			=> open
		);

	rx_fifo_wr_en <= rx_data_valid and (not rx_fifo_full);
	rx_fifo_din <= rx_data; 
	
	U0_DBG_RX_FWFT_FIFO : RX_FIFO
        PORT MAP 
        (
            rst         => RST,      
            clk         => CLK,
            
            din         => rx_fifo_din,
            rd_en       => RX_BUF_RDEN,
            wr_en       => rx_fifo_wr_en,
            
            dout        => RX_BUF_DATA,
            full        => rx_fifo_full,
            empty       => RX_BUF_EMPTY
        );
           		
	uart_tx_i : entity work.UART_TX 
		port map 
		(
			clk 			=> CLK,
			rst 			=> RST,
			
			ser_tx 			=> ser_tx,
			
			clk_div_baud 	=> CLK_DIV_BAUD,
			
			tx_data 		=> tx_data,
			tx_data_valid 	=> tx_data_valid,
			tx_busy 		=> tx_busy
        );
        
	tx_data <= tx_fifo_dout;
	tx_data_valid <= tx_fifo_rden;
	tx_fifo_rden <= (not tx_fifo_empty) and (not tx_busy);

    U1_DBG_TX_FWFT_FIFO : TX_FIFO
        PORT MAP 
        (
            rst         => RST,
            clk         => CLK,
            din         => TX_BUF_DATA,
            wr_en       => TX_BUF_WREN,
            rd_en       => tx_fifo_rden,
            dout        => tx_fifo_dout,
            full        => TX_BUF_FULL,
            empty       => tx_fifo_empty
        );
end Behavioral;