#Clock signal
set_property PACKAGE_PIN W5 [get_ports CLK]
    set_property IOSTANDARD LVCMOS33 [get_ports CLK]
    create_clock -period 10.00 -waveform {0 5} [get_ports CLK]
	
#Pmod Header JA
    #JA1 for U0_RX_IN
    #Sch name = JA1
        set_property PACKAGE_PIN J1 [get_ports {U0_RX_IN}]                    
            set_property IOSTANDARD LVCMOS33 [get_ports {U0_RX_IN}]

    #JA2 for U0_TX_OUT        
    ##Sch name = JA2
        set_property PACKAGE_PIN L2 [get_ports {U0_TX_OUT}]                    
            set_property IOSTANDARD LVCMOS33 [get_ports {U0_TX_OUT}]

#Pmod Header JB
    #Sch name = JB1
    #JB1 for U1_RX_IN
	   set_property PACKAGE_PIN A14 [get_ports {U1_RX_IN}]					
            set_property IOSTANDARD LVCMOS33 [get_ports {U1_RX_IN}]
            
    #JB2 for U1_TX_OUT            
            set_property PACKAGE_PIN A16 [get_ports {U1_TX_OUT}]					
                    set_property IOSTANDARD LVCMOS33 [get_ports {U1_TX_OUT}]
