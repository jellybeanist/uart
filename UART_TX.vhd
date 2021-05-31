library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all ;
use ieee.std_logic_unsigned.all ;

entity UART_TX is
	port 
	( 
		CLK 			: IN  	STD_LOGIC;
        RST 			: IN  	STD_LOGIC;
		
        SER_TX 			: OUT	STD_LOGIC;
		
		CLK_DIV_BAUD	: IN	STD_LOGIC_VECTOR(31 DOWNTO 0);
		
        TX_DATA 		: IN  	STD_LOGIC_VECTOR(7 DOWNTO 0);
        TX_DATA_VALID 	: IN  	STD_LOGIC;
        TX_BUSY			: OUT  	STD_LOGIC
	);
end UART_TX;

architecture Behavioral of UART_TX is

	signal baudCounter			: integer := 0;
	signal bitCounter			: integer range 0 to 8 := 0;
	signal tx_data_sreg			: std_logic_vector(7 downto 0) := (others=>'0');
	signal state				: integer range 0 to 3 := 0;
    
    signal i_tx_busy            : std_logic;

begin

    tx_busy <= i_tx_busy; -- or tx_data_valid;

	state_machine_p : process(clk)
	begin
		if(rising_edge(clk)) then
			
			i_tx_busy <= '1';

			case state is
			
				-- idle
				when 0 =>
					ser_tx <= '1';
					i_tx_busy <= '0';
					baudCounter <= 0;
					bitCounter <= 0;
					if(tx_data_valid='1' and CLK_DIV_BAUD>0) then
						tx_data_sreg <= tx_data;
						ser_tx <= '0';
						baudCounter <= 1;
                        i_tx_busy <= '1';
						state <= 1;
					end if;
					
				-- send start bit
				when 1 =>
					if(baudCounter>=conv_integer(clk_div_baud)) then
						baudCounter <= 1;
						ser_tx <= tx_data_sreg(bitCounter);
						bitCounter <= bitCounter + 1;
						baudCounter <= 1;
						state <= 2;
					else
						baudCounter <= baudCounter + 1;
					end if;
					
				-- send data bits
				when 2 =>
					if(baudCounter>=conv_integer(clk_div_baud)) then
						if(bitCounter>=8) then
							ser_tx <= '1';
							state <= 3;
						else
							ser_tx <= tx_data_sreg(bitCounter);
						end if;
						bitCounter <= bitCounter + 1;
						baudCounter <= 1;
					else
						baudCounter <= baudCounter + 1;
					end if;
					
				-- send stop bits
				when 3 =>
					if(baudCounter>=conv_integer(clk_div_baud)) then
						state <= 0;
					else
						baudCounter <= baudCounter + 1;
					end if;
					
                when others =>
                    state <= 0;
                    
			end case;
			
			if(rst='1') then
				state <= 0;
				ser_tx <= '0';
			end if;
		end if;
	end process;
end Behavioral;