library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all ;
use ieee.std_logic_unsigned.all ;

entity UART_RX is
    port 
    ( 
        CLK 			: IN  	STD_LOGIC;
        RST             : IN      STD_LOGIC;
            
        SER_RX          : IN      STD_LOGIC;
            
        CLK_DIV_BAUD    : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
            
        RX_DATA         : OUT      STD_LOGIC_VECTOR(7 DOWNTO 0);
        RX_DATA_VALID   : OUT      STD_LOGIC;
        RX_ERR          : OUT      STD_LOGIC
    );
end UART_RX;

architecture Behavioral of UART_RX is

	signal clk_div_baud_half	: std_logic_vector(31 downto 0) := (others=>'0');
	signal ser_rx_sync			: std_logic := '1';                         
	signal ser_rx_sync_dl1		: std_logic := '1';                      
	signal baudCounter			: integer := 0;                             
	signal bitCounter			: integer range 0 to 7 := 0;                 
	signal i_rx_data			: std_logic_vector(7 downto 0) := (others=>'0');
    signal i_rx_data_valid 		: std_logic := '0';                  
    signal i_rx_err 			: std_logic := '0';                        
	signal state				: integer range 0 to 3 := 0;
	
begin

	rx_data 		<= i_rx_data;                                                                      
    rx_data_valid 	<= i_rx_data_valid;                                                        
    rx_err 			<= i_rx_err;                                                                    
                                                                                              
	clk_div_baud_half <= '0' & clk_div_baud(31 downto 1);                                        
                                                                                              
	input_reg_p : process(clk)                                                                   
	begin                                                                                        
		if(rising_edge(clk)) then                                                                   
			ser_rx_sync 		<= ser_rx;                                                                   
			ser_rx_sync_dl1		<= ser_rx_sync;                                                           
		end if;                                                                                     
	end process;                                                                                 
                                                                                              
	state_machine_p : process(clk)                                                               
	begin                                                                                        
		if(rising_edge(clk)) then                                                                   
		                                                                                            
			i_rx_data_valid <= '0';                                                                    
			                                                                                           
			case state is                                                                              
			                                                                                           
				-- check for start bit                                                                    
				when 0 =>                                                                                 
					baudCounter <= 0;                                                                        
					bitCounter <= 0;                                                                         
					if(ser_rx_sync_dl1='1' and ser_rx_sync='0' and CLK_DIV_BAUD>0) then                      
						state <= 1;                                                                             
						baudCounter <= 1;                                                                       
						bitCounter <= 0;                                                                        
					end if;                                                                                  
				                                                                                          
				-- validate start bit at the center of bit interval                                       
				when 1 =>                                                                                 
					if(baudCounter>=clk_div_baud_half) then                                                  
						if(ser_rx_sync='0') then                                                                
							state <= 2;                                                                            
							baudCounter <= 1;                                                                      
							bitCounter <= 0;                                                                       
						else                                                                                    
							-- hata durumu                                                                         
						end if;                                                                                 
					else                                                                                     
						baudCounter <= baudCounter + 1;                                                         
					end if;                                                                                  
					                                                                                         
				-- sample data bits                                                                       
				when 2 =>                                                                                 
					if(baudCounter>=clk_div_baud) then                                                       
						baudCounter <= 1;                                                                       
						i_rx_data(bitCounter) <= ser_rx_sync;                                                   
						if(bitCounter>=7) then                                                                  
							state <= 3;                                                                            
						else                                                                                    
							bitCounter <= bitCounter + 1;                                                          
						end if;                                                                                 
					else                                                                                     
						baudCounter <= baudCounter + 1;                                                         
					end if;                                                                                  
					                                                                                         
				-- check stop bit                                                                         
				when 3 =>                                                                                 
					if(baudCounter>=clk_div_baud) then                                                       
						state <= 0;                                                                             
						if(ser_rx_sync='1') then                                                                
							i_rx_data_valid <= '1';                                                                
						else                                                                                    
							i_rx_err <= '1';                                                                       
						end if;                                                                                 
					else                                                                                     
						baudCounter <= baudCounter + 1;                                                         
					end if;                                                                                  
					                                                                                         
				when others =>                                                                            
					state <= 0;                                                                              
					i_rx_err <= '0';                                                                         
					i_rx_data <= (others=>'0');
							                                                                                     
			end case;                                                                                  
			                                                                                           
			if(rst='1') then                                                                           
				state <= 0;                                                                               
				i_rx_err <= '0';                                                                          
				i_rx_data <= (others=>'0');                                                               
			end if;                                                                                                                                                                             
		end if;                                                                                     
	end process; 
end Behavioral;


