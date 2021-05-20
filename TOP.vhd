library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TOP is
    Port 
    ( 
        TX_OUT              :       OUT STD_LOGIC;
        RX_IN               :       IN STD_LOGIC;
        
        DDR_addr            :       inout STD_LOGIC_VECTOR ( 14 downto 0 );
        DDR_ba              :       inout STD_LOGIC_VECTOR ( 2 downto 0 );
        DDR_cas_n           :       inout STD_LOGIC;
        DDR_ck_n            :       inout STD_LOGIC;
        DDR_ck_p            :       inout STD_LOGIC;
        DDR_cke             :       inout STD_LOGIC;
        DDR_cs_n            :       inout STD_LOGIC;
        DDR_dm              :       inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_dq              :       inout STD_LOGIC_VECTOR ( 31 downto 0 );
        DDR_dqs_n           :       inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_dqs_p           :       inout STD_LOGIC_VECTOR ( 3 downto 0 );
        DDR_odt             :       inout STD_LOGIC;
        DDR_ras_n           :       inout STD_LOGIC;
        DDR_reset_n         :       inout STD_LOGIC;
        DDR_we_n            :       inout STD_LOGIC;

        FIXED_IO_ddr_vrn    :       inout STD_LOGIC;
        FIXED_IO_ddr_vrp    :       inout STD_LOGIC;
        FIXED_IO_mio        :       inout STD_LOGIC_VECTOR ( 53 downto 0 );
        FIXED_IO_ps_clk     :       inout STD_LOGIC;
        FIXED_IO_ps_porb    :       inout STD_LOGIC;
        FIXED_IO_ps_srstb   :       inout STD_LOGIC       
    );
end TOP;

architecture Behavioral of TOP is
    signal i_clk100 : std_logic := '0';
    signal i_rst : std_logic := '0';
begin
    U0_CPU : entity work.bd_wrapper
    Port Map
    (
     CLK100                 =>      i_clk100,
     
     DDR_addr               =>      DDR_addr,
     DDR_ba                 =>      DDR_ba,
     DDR_cas_n              =>      DDR_cas_n,
     DDR_ck_n               =>      DDR_ck_n,
     DDR_ck_p               =>      DDR_ck_p,
     DDR_cke                =>      DDR_cke,
     DDR_cs_n               =>      DDR_cs_n,
     DDR_dm                 =>      DDR_dm,
     DDR_dq                 =>      DDR_dq,
     DDR_dqs_n              =>      DDR_dqs_n,
     DDR_dqs_p              =>      DDR_dqs_p,
     DDR_odt                =>      DDR_odt,
     DDR_ras_n              =>      DDR_ras_n,
     DDR_reset_n            =>      DDR_reset_n,
     DDR_we_n               =>      DDR_we_n,
     
     FIXED_IO_ddr_vrn       =>      FIXED_IO_ddr_vrn,
     FIXED_IO_ddr_vrp       =>      FIXED_IO_ddr_vrp,
     FIXED_IO_mio           =>      FIXED_IO_mio,
     FIXED_IO_ps_clk        =>      FIXED_IO_ps_clk,
     FIXED_IO_ps_porb       =>      FIXED_IO_ps_porb,
     FIXED_IO_ps_srstb      =>      FIXED_IO_ps_srstb
    );
    
    U1_rtx : entity work.uart_rtx
    Port Map
    (
    CLK                     =>      i_clk100,
    RST_IN                  =>      i_rst,
    RX_IN                   =>      RX_IN,
    TX_OUT                  =>      TX_OUT   
    );
    
end Behavioral;
