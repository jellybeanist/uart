library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_rx is
generic (
        CLK_FREQ        : INTEGER := 100_000_000;   --100 MHz clock.
        BAUD_RATE       : INTEGER := 115_200        --Baudrate.
);
port (
        CLK             : IN STD_LOGIC;                         --1 bit clock.  
        RST_IN          : IN STD_LOGIC;                         --1 bit reset.      
        RX_IN           : IN STD_LOGIC;                         --1 bit input.
        RX_OUT          : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);    --Data to transmit after receiving.        
        RX_DONE_OUT     : OUT STD_LOGIC                         --Done check.


);
end uart_rx;

architecture Behavioral of uart_rx is

type states is (IDLE, START, RECEIVE, STOP);
signal state : states := IDLE; --IDLE is the default state.
constant clock_count_lim : integer := CLK_FREQ/BAUD_RATE+1;  --How many clocks to wait for bit check


signal clock_counter : integer range 0 to (clock_count_lim)-1 := 0;
signal data_index : integer range 0 to 7 := 0;
signal data : std_logic_vector(7 downto 0) := (others=>'0');
signal shift_start_receive : std_logic_vector(2 downto 0) := (others=>'0');
signal rx_done : std_logic := '0';

begin
    RX_OUT      <= data;
    RX_DONE_OUT <= rx_done;

MAIN :  process (CLK) begin
        
            if (RST_IN = '1') then
                state <= IDLE;
                clock_counter <= 0;
                data_index <= 0;
                data <= (others=>'0');
                shift_start_receive <= (others=>'0');
                rx_done <= '0';
        
            elsif rising_edge(CLK) then
                shift_start_receive <= shift_start_receive(1 downto 0) & RX_IN;
                rx_done <= '0';
                    case state is
                        when IDLE =>
                            --default parameters, program stands here.
                            --stays here until the change of high to low, which means start receiving.
                            if (shift_start_receive(2 downto 1) = "10") then
                                state	<= START;
                            end if;
                    
                        when START =>
                        -- tx_out is equal to 0 when program enters here.
                            if (clock_counter = (clock_count_lim-1)/2) then
                                state           <= RECEIVE; 
                                clock_counter	<= 0;
                            else
                                clock_counter	<= clock_counter + 1;
                            end if;
                                
                        when RECEIVE =>
                            data(data_index) <= shift_start_receive(2);
                            if (clock_counter = clock_count_lim-1) then
                                clock_counter <= 0;
                                if (data_index = 7) then
                                    data_index <= 0;
                                    state <= STOP;
                                else
                                    data_index <= data_index+1;
                                end if;
                            else
                                clock_counter <= clock_counter+1;
                            end if;		
                        
                        when STOP =>		
                            if (clock_counter = clock_count_lim-1) then
                                state		    <= IDLE;
                                rx_done		    <= '1';
                                clock_counter	<= 0;
                            else
                                clock_counter	<= clock_counter + 1;				
                            end if;		
                        when others => NULL;                     
                    end case;
                end if;
        end process;

end Behavioral;