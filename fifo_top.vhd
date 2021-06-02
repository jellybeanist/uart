library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FIFO_TOP is
    Port 
    (
        U0_RX_IN            :   IN STD_LOGIC;
        U0_TX_OUT           :   OUT STD_LOGIC;
        
        U1_RX_IN            :   IN STD_LOGIC;
        U1_TX_OUT           :   OUT STD_LOGIC;
       
        DDR_addr            :   inout STD_LOGIC_VECTOR ( 14 downto 0 );
        DDR_ba              :   inout STD_LOGIC_VECTOR ( 2 downto 0 );
        DDR_cas_n           :   inout STD_LOGIC;
        DDR_ck_n            :   inout STD_LOGIC;
        DDR_ck_p            :   inout STD_LOGIC;
        DDR_cke             :   inout STD_LOGIC;
        DDR_cs_n            :   inout STD_LOGIC;
        DDR_dm              :   inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_dq              :   inout STD_LOGIC_VECTOR ( 31 downto 0 );
        DDR_dqs_n           :   inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_dqs_p           :   inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_odt             :   inout STD_LOGIC;
        DDR_ras_n           :   inout STD_LOGIC;
        DDR_reset_n         :   inout STD_LOGIC;
        DDR_we_n            :   inout STD_LOGIC;

        FIXED_IO_ddr_vrn    :   inout STD_LOGIC;
        FIXED_IO_ddr_vrp    :   inout STD_LOGIC;
        FIXED_IO_mio        :   inout STD_LOGIC_VECTOR ( 53 downto 0 );
        FIXED_IO_ps_clk     :   inout STD_LOGIC;
        FIXED_IO_ps_porb    :   inout STD_LOGIC;
        FIXED_IO_ps_srstb   :   inout STD_LOGIC
     );
end FIFO_TOP;

architecture Behavioral of FIFO_TOP is

    signal alive_counter       :  std_logic_vector(31 downto 0) := (others => '0');
    signal i_clk100            :  std_logic := '0';
    signal i_rst               :  std_logic := '1';

    signal u0_i_rx_f_dout      :   std_logic_vector(7 downto 0)  := (others => '0');
    signal u0_i_rx_f_ren       :   std_logic := '0';
    signal u0_i_rx_f_empty     :   std_logic;
    
    signal u0_i_tx_f_din       :   std_logic_vector(7 downto 0)  := (others => '0');
    signal u0_i_tx_f_wr_en     :   std_logic := '0';
    signal u0_i_tx_f_full      :   std_logic;
    
    signal u1_i_rx_f_dout      :   std_logic_vector(7 downto 0)  := (others => '0');
    signal u1_i_rx_f_ren       :   std_logic := '0';
    signal u1_i_rx_f_empty     :   std_logic;
    
    signal u1_i_tx_f_din       :   std_logic_vector(7 downto 0)  := (others => '0');
    signal u1_i_tx_f_wr_en     :   std_logic := '0';
    signal u1_i_tx_f_full      :   std_logic;

--    ATTRIBUTE MARK_DEBUG : string;
--    ATTRIBUTE MARK_DEBUG of i_rx_f_empty : SIGNAL IS "TRUE";
--    ATTRIBUTE MARK_DEBUG of i_rx_f_dout  : SIGNAL IS "TRUE";
--    ATTRIBUTE MARK_DEBUG of i_rx_f_ren   : SIGNAL IS "TRUE";
--    ATTRIBUTE MARK_DEBUG of i_tx_f_wr_en : SIGNAL IS "TRUE";
--    ATTRIBUTE MARK_DEBUG of i_tx_f_din   : SIGNAL IS "TRUE";
--    ATTRIBUTE MARK_DEBUG of i_tx_f_full  : SIGNAL IS "TRUE";
        
begin
U0: process (i_clk100) begin
        if rising_edge(i_clk100) then
            if (alive_counter = 100_000) then
                alive_counter <= (others => '0');
                i_rst <= '0';
            else
                alive_counter <= alive_counter + 1;
            end if;
        end if;
    end process;

    u1_i_tx_f_wr_en  <= (not u0_i_rx_f_empty) and (not u1_i_tx_f_full);
    u0_i_rx_f_ren    <= (not u0_i_rx_f_empty);
    u1_i_tx_f_din    <= (u0_i_rx_f_dout);
   
    u0_i_tx_f_wr_en  <= (not u1_i_rx_f_empty) and (not u0_i_tx_f_full);
    u1_i_rx_f_ren    <= (not u1_i_rx_f_empty);
    u0_i_tx_f_din    <= (u1_i_rx_f_dout);

      
U0_UART_TRX : entity work.UART_TRX
    Port map 
    (
        CLK                =>    i_clk100,
        RST_IN             =>    i_rst,
 
        RX_IN              =>    U0_RX_IN,
        TX_OUT             =>    U0_TX_OUT,
 
        RX_F_EMPTY         =>    u0_i_rx_f_empty,
        RX_F_DOUT          =>    u0_i_rx_f_dout,
        RX_F_REN           =>    u0_i_rx_f_ren,
 
        TX_F_DIN           =>    u0_i_tx_f_din,
        TX_F_WEN           =>    u0_i_tx_f_wr_en,
        TX_F_FULL          =>    u0_i_tx_f_full
    );
      
U1_UART_TRX : entity work.UART_TRX
        Port map 
        (
            CLK                =>    i_clk100,
            RST_IN             =>    i_rst,
     
            RX_IN              =>    U1_RX_IN,
            TX_OUT             =>    U1_TX_OUT,
     
            RX_F_EMPTY         =>    u1_i_rx_f_empty,
            RX_F_DOUT          =>    u1_i_rx_f_dout,
            RX_F_REN           =>    u1_i_rx_f_ren,
     
            TX_F_DIN           =>    u1_i_tx_f_din,
            TX_F_WEN           =>    u1_i_tx_f_wr_en,
            TX_F_FULL          =>    u1_i_tx_f_full
        );
        
U2_CPU : entity work.block_design_wrapper
    Port Map
    (
        CLK100MHZ          =>    i_clk100,
  
        DDR_addr           =>    DDR_addr,
        DDR_ba             =>    DDR_ba,
        DDR_cas_n          =>    DDR_cas_n,
        DDR_ck_n           =>    DDR_ck_n,
        DDR_ck_p           =>    DDR_ck_p,
        DDR_cke            =>    DDR_cke,
        DDR_cs_n           =>    DDR_cs_n,
        DDR_dm             =>    DDR_dm,
        DDR_dq             =>    DDR_dq,
        DDR_dqs_n          =>    DDR_dqs_n,
        DDR_dqs_p          =>    DDR_dqs_p,
        DDR_odt            =>    DDR_odt,
        DDR_ras_n          =>    DDR_ras_n,
        DDR_reset_n        =>    DDR_reset_n,
        DDR_we_n           =>    DDR_we_n,
      
        FIXED_IO_ddr_vrn   =>    FIXED_IO_ddr_vrn,
        FIXED_IO_ddr_vrp   =>    FIXED_IO_ddr_vrp,
        FIXED_IO_mio       =>    FIXED_IO_mio,
        FIXED_IO_ps_clk    =>    FIXED_IO_ps_clk,
        FIXED_IO_ps_porb   =>    FIXED_IO_ps_porb,
        FIXED_IO_ps_srstb  =>    FIXED_IO_ps_srstb
    );      
end Behavioral;
