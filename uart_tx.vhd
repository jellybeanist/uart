library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_tx is
    generic 
    (  
        CLK_FREQ            :   INTEGER := 100_000_000;
        BAUD_RATE           :   INTEGER := 115_200
    );
    port (
        CLK                 :   IN STD_LOGIC;           
        RST_IN              :   IN STD_LOGIC;     
                       
        DATA_IN             :   IN STD_LOGIC_VECTOR (7 DOWNTO 0); 
        TX_START_IN         :   IN STD_LOGIC; 
                            
        TX_BUSY             :   OUT STD_LOGIC;
        TX_OUT              :   OUT STD_LOGIC;                    
        TX_DONE_OUT         :   OUT STD_LOGIC                     
    );
end uart_tx;

architecture Behavioral of uart_tx is

type states is (IDLE, START, TRANSFER, STOP);
signal state                :   states := IDLE; 
constant clock_count_lim    :   integer := CLK_FREQ/BAUD_RATE+1;  

signal data                 :   std_logic_vector(7 downto 0) := (others=>'0');
signal clock_counter        :   integer range 0 to (clock_count_lim)-1 := 0;
signal data_index           :   integer range 0 to 7 := 0;
signal tx                   :   std_logic := '1';
signal i_tx_busy            :   std_logic;
signal tx_done              :   std_logic := '0';


begin
    TX_OUT      <=  tx;
    TX_DONE_OUT <=  tx_done;
    TX_BUSY     <=  i_tx_busy;

MAIN :  process (CLK, RST_IN) begin
        
            if (RST_IN = '1') then
                state <= IDLE;
                clock_counter <= 0;
                data_index <= 0;
                data <= (others=>'0');
                tx <= '1';
                tx_done <= '0';
        
            elsif rising_edge(CLK) then
            i_tx_busy <= '1';
                case state is
                    when IDLE =>
                        tx  			<= '1'; 
                        tx_done	        <= '0';
                        clock_counter	<= 0;
                        i_tx_busy <= '0';
                        if (TX_START_IN = '1') then
                            state       <= START;
                            data        <= data_in;
                            tx          <= '0';
                            i_tx_busy   <= '1';
                        end if;
                
                    when START =>
                    -- tx_out is equal to 0 when program enters here.
                        if (clock_counter = clock_count_lim-1) then
                            state           <= TRANSFER; 
                            clock_counter	<= 0;
                        else
                            clock_counter	<= clock_counter + 1;
                        end if;
                            
                    when TRANSFER =>
                        tx <= data(data_index);
                        if (clock_counter = clock_count_lim-1) then
                            clock_counter   <= 0;
                            if (data_index = 7) then
                                data_index  <= 0;
                                state       <= STOP;
                            else
                                data_index  <= data_index+1;
                            end if;
                        else
                            clock_counter   <= clock_counter+1;
                        end if;		
                    
                    when STOP =>
                        tx <= '1';		
                        if (clock_counter = clock_count_lim-1) then
                            state		    <= IDLE;
                            tx_done		    <= '1';
                        else
                            clock_counter	<= clock_counter + 1;				
                        end if;		
                end case;
            end if;
        end process;

end Behavioral;
