##======================================================================##
##                                 UART                                 ##
##======================================================================##

##J15 pin 1 ==> Y7
##J15 pin 2 ==> T5
set_property -dict {PACKAGE_PIN Y7 IOSTANDARD LVCMOS33} [get_ports U0_RX_IN]
set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports U0_TX_OUT]

##J14 pin 1 ==> W11
##J14 pin 2 ==> Y9
set_property -dict {PACKAGE_PIN W11 IOSTANDARD LVCMOS33} [get_ports U1_RX_IN]
set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVCMOS33} [get_ports U1_TX_OUT]
