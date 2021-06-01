##======================================================================##
##                                 UART                                 ##
##======================================================================##

##J15 pin 1 ==> Y7
##J15 pin 2 ==> T5
set_property -dict {PACKAGE_PIN Y7 IOSTANDARD LVCMOS33} [get_ports RX_IN]
set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports TX_OUT]
