library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART_TOP_BASYS3 is
    Port 
    (
        CLK                 :   IN STD_LOGIC; --For BASYS 3
        U0_RX_IN            :   IN STD_LOGIC;
        U0_TX_OUT           :   OUT STD_LOGIC;
        
        U1_RX_IN            :   IN STD_LOGIC;
        U1_TX_OUT           :   OUT STD_LOGIC
     );
end UART_TOP_BASYS3;

architecture Behavioral of UART_TOP_BASYS3 is

     type states is (IDLE, U0toU1_SET,U0toU1_WRITE,U0toU1_READ, U1toU0_SET, U1toU0_WRITE, U1toU0_READ);
     signal state                :   states  :=  IDLE;
    

    signal alive_counter        :   std_logic_vector(31 downto 0) := (others => '0');
    signal i_clk100             :   std_logic   := '0';
    signal i_rst                :   std_logic   := '1';

    signal u0_i_rx_f_dout       :   std_logic_vector(7 downto 0)    := (others => '0');
    signal u0_i_rx_f_ren        :   std_logic   := '0';
    signal u0_i_rx_f_empty      :   std_logic;
    
    signal u0_i_tx_f_din        :   std_logic_vector(7 downto 0)    := (others => '0');
    signal u0_i_tx_f_wr_en      :   std_logic   := '0';
    signal u0_i_tx_f_full       :   std_logic;
    
    signal u1_i_rx_f_dout       :   std_logic_vector(7 downto 0)    := (others => '0');
    signal u1_i_rx_f_ren        :   std_logic   := '0';
    signal u1_i_rx_f_empty      :   std_logic;
    
    signal u1_i_tx_f_din        :   std_logic_vector(7 downto 0)    := (others => '0');
    signal u1_i_tx_f_wr_en      :   std_logic   := '0';
    signal u1_i_tx_f_full       :   std_logic;

    signal data_length          :   std_logic_vector(7 downto 0)    := (others => '0');            
    signal data_count           :   std_logic_vector(7 downto 0)    := (others => '0');
    --signal written_data_count   :   std_logic_vector(7 downto 0)    := (others => '0'); 
    signal data_sent            :   std_logic_vector(7 downto 0)    := (others => '0');
    signal set_count            :   std_logic   := '0';  

begin

    i_clk100 <= CLK; -- for BASYS 3

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
    
U3: process (i_clk100)
        begin
        
        --if ((u0_i_rx_f_empty = '0')) then--and (u0_i_rx_f_dout = x"0A")) then
                            u1_i_tx_f_wr_en  <= (not u0_i_rx_f_empty) and (not u1_i_tx_f_full);
                            u0_i_rx_f_ren    <= (not u0_i_rx_f_empty);
                            u1_i_tx_f_din    <= (u0_i_rx_f_dout);
                            
        --elsif ((u1_i_rx_f_empty = '0')) then -- and (u1_i_rx_f_dout = x"BB")) then                   
                            u0_i_tx_f_wr_en  <= (not u1_i_rx_f_empty) and (not u0_i_tx_f_full);
                            u1_i_rx_f_ren    <= (not u1_i_rx_f_empty);
                            u0_i_tx_f_din    <= (u1_i_rx_f_dout);     
        --end if;
    end process;
--    U1: process (i_clk100) begin
--        case state is
--            when IDLE =>
--                data_sent <=x"00";
--                if ((u0_i_rx_f_empty = '0') and (u0_i_rx_f_dout = x"0A")) then
--                     state       <= U0toU1_SET;
--                    u0_i_rx_f_ren <= '1';
--                    set_count <= '0';
--                elsif ((u1_i_rx_f_empty = '0') and (u1_i_rx_f_dout = x"BB")) then
--                    state       <= U1toU0_SET;
--                    u1_i_rx_f_ren <= '1';
--                    set_count <= '0';                       
--                else
--                    state       <= IDLE;
--                end if;
                           
--            when U0toU1_SET =>
--                data_length <= u0_i_rx_f_dout;
--                data_count  <= x"00";
--                state       <= U0toU1_WRITE;
--                u0_i_rx_f_ren <= '0';
                
--            when U1toU0_SET =>
--                    data_length <= u1_i_rx_f_dout;
--                    data_count  <= x"00";
--                    state       <= U1toU0_WRITE;
--                    u1_i_rx_f_ren <= '0';
                    
--            when U0toU1_WRITE =>
--                if (data_count = data_length) then
--                    data_count <= x"00";
--                    state      <= U0toU1_READ;
--                    u0_i_rx_f_ren <= '1';
--                    --written_data_count <= data_count;                            
--                else
--                    data_count <= data_count+1;
--                end if;		
            
--            when U1toU0_WRITE =>
--                if (data_count=data_length) then
--                    data_count <= x"00";
--                    state      <= U1toU0_READ;
--                    u1_i_rx_f_ren <= '1';
--                    --written_data_count <= data_count;                            
--                else
--                    data_count <= data_count+1;
--                end if;
                
--             when U0toU1_READ =>
--                if (u0_i_rx_f_empty = '0') then
--                    u1_i_tx_f_wr_en  <= (not u0_i_rx_f_empty) and (not u1_i_tx_f_full);
--                    u0_i_rx_f_ren    <= (not u0_i_rx_f_empty);
--                    u1_i_tx_f_din    <= (u0_i_rx_f_dout);
--                    data_sent <= data_sent+1;
--                else
--                    state <= IDLE;
--                end if;    
             
--             when U1toU0_READ =>
--                if (u1_i_rx_f_empty = '0') then                  
--                    u0_i_tx_f_wr_en  <= (not u1_i_rx_f_empty) and (not u0_i_tx_f_full);
--                    u1_i_rx_f_ren    <= (not u1_i_rx_f_empty);
--                    u0_i_tx_f_din    <= (u1_i_rx_f_dout);
--                    data_sent <= data_sent+1;
--                else
--                    state <= IDLE;   
--                end if;
--        end case;
--    end process;



    U0_UART_TRX : entity work.UART_TRX_BASYS3
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
          
    U1_UART_TRX : entity work.UART_TRX_BASYS3
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
            
end Behavioral;
