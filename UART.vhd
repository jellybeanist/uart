library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all ;
use ieee.std_logic_unsigned.all ;

entity UART is
    Port 
    ( 
        RX                      : IN    STD_LOGIC;
        TX                      : OUT   STD_LOGIC;
        
        DDR_addr                : INOUT STD_LOGIC_VECTOR ( 14 downto 0 );
        DDR_ba                  : INOUT STD_LOGIC_VECTOR ( 2 downto 0 );
        DDR_cas_n               : INOUT STD_LOGIC;
        DDR_ck_n                : INOUT STD_LOGIC;
        DDR_ck_p                : INOUT STD_LOGIC;
        DDR_cke                 : INOUT STD_LOGIC;
        DDR_cs_n                : INOUT STD_LOGIC;
        DDR_dm                  : INOUT STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_dq                  : INOUT STD_LOGIC_VECTOR ( 31 downto 0 );
        DDR_dqs_n               : INOUT STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_dqs_p               : INOUT STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_odt                 : INOUT STD_LOGIC;
        DDR_ras_n               : INOUT STD_LOGIC;
        DDR_reset_n             : INOUT STD_LOGIC;
        DDR_we_n                : INOUT STD_LOGIC;
        
        FIXED_IO_ddr_vrn        : INOUT STD_LOGIC;
        FIXED_IO_ddr_vrp        : INOUT STD_LOGIC;
        FIXED_IO_PS_CLK         : INOUT STD_LOGIC;
        FIXED_IO_PS_PORB        : INOUT STD_LOGIC;
        FIXED_IO_PS_SRSTB       : INOUT STD_LOGIC;
        FIXED_IO_MIO            : INOUT STD_LOGIC_VECTOR(53 downto 0)
    );
end UART;

architecture Behavioral of UART is

    signal i_clk100             : std_logic := '0';
    signal i_rst                : std_logic := '1'; 
    signal alive_counter        : std_logic_vector(31 downto 0) := (others => '0');
    
    signal baudrade             : std_logic_vector(31 downto 0):= x"00000364";
    
    signal i_rx_buf_empty       : std_logic;
    signal i_rx_buf_rden        : std_logic := '0';
    signal i_rx_buf_data        : std_logic_vector(7 downto 0):= (others => '0');
    
    signal i_tx_buf_full        : std_logic;
    signal i_tx_buf_wren        : std_logic := '0';
    signal i_tx_buf_data        : std_logic_vector(7 downto 0):= (others => '0');
    
    ATTRIBUTE MARK_DEBUG : string;
    ATTRIBUTE MARK_DEBUG of i_rx_buf_empty: SIGNAL IS "TRUE";
    ATTRIBUTE MARK_DEBUG of i_rx_buf_rden: SIGNAL IS "TRUE";
    ATTRIBUTE MARK_DEBUG of i_rx_buf_data: SIGNAL IS "TRUE";
    ATTRIBUTE MARK_DEBUG of i_tx_buf_full: SIGNAL IS "TRUE";
    ATTRIBUTE MARK_DEBUG of i_tx_buf_wren: SIGNAL IS "TRUE";
    ATTRIBUTE MARK_DEBUG of i_tx_buf_data: SIGNAL IS "TRUE";
    ATTRIBUTE MARK_DEBUG of i_clk100: SIGNAL IS "TRUE";

begin
    U0_Alive : process (i_clk100) 
    begin
        if rising_edge(i_clk100) then
            if (alive_counter = 1_000_000) then
                alive_counter <= (others => '0');
                i_rst <= '0';
            else
                alive_counter <= alive_counter + 1;
            end if;
        end if;
    end process;    
    
    
    i_rx_buf_rden <= (not i_rx_buf_empty);
    i_tx_buf_wren <= (not i_rx_buf_empty) and (not i_tx_buf_full);
    i_tx_buf_data <= i_rx_buf_data;     
    
    U0_cpu : entity work.bd_wrapper
    port map
    (
        CLK100                  => i_clk100,
                
        DDR_addr                => DDR_addr,
        DDR_ba                  => DDR_ba,
        DDR_cas_n               => DDR_cas_n,
        DDR_ck_n                => DDR_ck_n,
        DDR_ck_p                => DDR_ck_p,
        DDR_cke                 => DDR_cke,
        DDR_cs_n                => DDR_cs_n,
        DDR_dm                  => DDR_dm,
        DDR_dq                  => DDR_dq,
        DDR_dqs_n               => DDR_dqs_n,
        DDR_dqs_p               => DDR_dqs_p,
        DDR_odt                 => DDR_odt,
        DDR_ras_n               => DDR_ras_n,
        DDR_reset_n             => DDR_reset_n,
        DDR_we_n                => DDR_we_n,
        
        FIXED_IO_ddr_vrn        => FIXED_IO_ddr_vrn,
        FIXED_IO_ddr_vrp        => FIXED_IO_ddr_vrp,
        FIXED_IO_mio            => FIXED_IO_mio,
        FIXED_IO_ps_clk         => FIXED_IO_ps_clk,
        FIXED_IO_ps_porb        => FIXED_IO_ps_porb,
        FIXED_IO_ps_srstb       => FIXED_IO_ps_srstb       
    );
    
    U1_UART_TRX : entity work.UART_TRX 
    port map
    (
        CLK             => i_clk100,
        RST				=> i_rst,
        
        CLK_DIV_BAUD    => baudrade,
        
        SER_TX          => TX,  
        SER_RX          => RX,
        
        RX_BUF_EMPTY    => i_rx_buf_empty,
        RX_BUF_RDEN     => i_rx_buf_rden,
        RX_BUF_DATA     => i_rx_buf_data,
        
        TX_BUF_FULL     => i_tx_buf_full,
        TX_BUF_WREN     => i_tx_buf_wren,
        TX_BUF_DATA     => i_tx_buf_data
    );


end Behavioral;
