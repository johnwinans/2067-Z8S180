EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLedger 17000 11000
encoding utf-8
Sheet 1 1
Title "Z8S180 Breakout"
Date "2024-02-19"
Rev "1.2"
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L jb-symbol:IS61WV20488BLL-10TLI U2
U 1 1 6485F08F
P 13550 5100
F 0 "U2" H 13850 6450 50  0000 C CNN
F 1 "IS61WV10248EDBLL-10TLI" V 13550 5100 50  0000 C CNN
F 2 "Package_SO:TSOP-II-44_10.16x18.41mm_P0.8mm" H 13050 6250 50  0001 C CNN
F 3 "" H 13550 5100 50  0001 C CNN
	1    13550 5100
	1    0    0    -1  
$EndComp
$Comp
L jb-symbol:Z8S18020FSG U1
U 1 1 6486EB89
P 9250 5050
F 0 "U1" H 10700 6150 50  0000 L CNN
F 1 "Z8S18020FSG" H 9000 5050 50  0000 L CNN
F 2 "jb-footprint:PQFP-80_14x20mm_P0.8mm" H 10650 6400 50  0001 C CNN
F 3 "" H 10650 6400 50  0001 C CNN
	1    9250 5050
	1    0    0    -1  
$EndComp
$Comp
L Connector_Generic:Conn_02x30_Odd_Even J2
U 1 1 64879A1C
P 5300 5000
F 0 "J2" H 5350 6617 50  0000 C CNN
F 1 "Conn_02x30_Odd_Even" H 5350 6526 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x30_P2.54mm_Vertical" H 5300 5000 50  0001 C CNN
F 3 "~" H 5300 5000 50  0001 C CNN
	1    5300 5000
	1    0    0    -1  
$EndComp
Wire Wire Line
	5100 3600 4350 3600
Wire Wire Line
	4350 3600 4350 3700
Wire Wire Line
	5100 3700 4350 3700
Connection ~ 4350 3700
Wire Wire Line
	4350 3700 4350 3750
Wire Wire Line
	5600 3600 6650 3600
Wire Wire Line
	6650 3600 6650 3700
Wire Wire Line
	5600 3700 6650 3700
Connection ~ 6650 3700
Wire Wire Line
	6650 3700 6650 3750
$Comp
L power:GND #PWR0101
U 1 1 64886800
P 6650 3750
F 0 "#PWR0101" H 6650 3500 50  0001 C CNN
F 1 "GND" H 6655 3577 50  0000 C CNN
F 2 "" H 6650 3750 50  0001 C CNN
F 3 "" H 6650 3750 50  0001 C CNN
	1    6650 3750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0102
U 1 1 6488739A
P 4350 3750
F 0 "#PWR0102" H 4350 3500 50  0001 C CNN
F 1 "GND" H 4355 3577 50  0000 C CNN
F 2 "" H 4350 3750 50  0001 C CNN
F 3 "" H 4350 3750 50  0001 C CNN
	1    4350 3750
	1    0    0    -1  
$EndComp
Wire Wire Line
	5100 6400 4950 6400
Wire Wire Line
	4950 6400 4950 6650
Wire Wire Line
	5600 6400 5800 6400
Wire Wire Line
	5800 6400 5800 6650
$Comp
L power:GND #PWR0103
U 1 1 6488B324
P 5800 6650
F 0 "#PWR0103" H 5800 6400 50  0001 C CNN
F 1 "GND" H 5805 6477 50  0000 C CNN
F 2 "" H 5800 6650 50  0001 C CNN
F 3 "" H 5800 6650 50  0001 C CNN
	1    5800 6650
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0104
U 1 1 6488B97A
P 4950 6650
F 0 "#PWR0104" H 4950 6400 50  0001 C CNN
F 1 "GND" H 4955 6477 50  0000 C CNN
F 2 "" H 4950 6650 50  0001 C CNN
F 3 "" H 4950 6650 50  0001 C CNN
	1    4950 6650
	1    0    0    -1  
$EndComp
Wire Wire Line
	5600 6500 6500 6500
Wire Wire Line
	5100 6500 4350 6500
$Comp
L power:+3.3V #PWR0105
U 1 1 6488E58E
P 4350 6500
F 0 "#PWR0105" H 4350 6350 50  0001 C CNN
F 1 "+3.3V" H 4365 6673 50  0000 C CNN
F 2 "" H 4350 6500 50  0001 C CNN
F 3 "" H 4350 6500 50  0001 C CNN
	1    4350 6500
	1    0    0    -1  
$EndComp
$Comp
L power:+3.3V #PWR0106
U 1 1 6489040D
P 6500 6500
F 0 "#PWR0106" H 6500 6350 50  0001 C CNN
F 1 "+3.3V" H 6515 6673 50  0000 C CNN
F 2 "" H 6500 6500 50  0001 C CNN
F 3 "" H 6500 6500 50  0001 C CNN
	1    6500 6500
	1    0    0    -1  
$EndComp
Wire Wire Line
	10750 4300 11200 4300
Text Label 11200 4300 2    50   ~ 0
D5
Wire Wire Line
	10750 4400 11200 4400
Text Label 11200 4400 2    50   ~ 0
D4
Wire Wire Line
	10750 4500 11200 4500
Text Label 11200 4500 2    50   ~ 0
D3
Wire Wire Line
	10750 4600 11200 4600
Text Label 11200 4600 2    50   ~ 0
D2
Wire Wire Line
	10750 4700 11200 4700
Text Label 11200 4700 2    50   ~ 0
D1
Wire Wire Line
	10750 4800 11200 4800
Text Label 11200 4800 2    50   ~ 0
D0
Wire Wire Line
	10750 5800 11200 5800
Text Label 11200 5800 2    50   ~ 0
A13
Text Label 11200 5700 2    50   ~ 0
A14
Text Label 11200 5600 2    50   ~ 0
A15
Text Label 11200 5500 2    50   ~ 0
A16
Text Label 11200 5400 2    50   ~ 0
A17
Text Label 11200 5200 2    50   ~ 0
A18
Text Label 11200 5000 2    50   ~ 0
A19
Wire Wire Line
	10750 5000 11200 5000
Wire Wire Line
	10750 5200 11200 5200
Wire Wire Line
	10750 5400 11200 5400
Wire Wire Line
	11200 5500 10750 5500
Wire Wire Line
	11200 5600 10750 5600
Wire Wire Line
	11200 5700 10750 5700
Wire Wire Line
	10750 5100 11400 5100
Wire Wire Line
	11400 5100 11400 4750
$Comp
L power:+3.3V #PWR0107
U 1 1 648BBA28
P 11400 4750
F 0 "#PWR0107" H 11400 4600 50  0001 C CNN
F 1 "+3.3V" H 11415 4923 50  0000 C CNN
F 2 "" H 11400 4750 50  0001 C CNN
F 3 "" H 11400 4750 50  0001 C CNN
	1    11400 4750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0108
U 1 1 648BE075
P 11600 4950
F 0 "#PWR0108" H 11600 4700 50  0001 C CNN
F 1 "GND" H 11605 4777 50  0000 C CNN
F 2 "" H 11600 4950 50  0001 C CNN
F 3 "" H 11600 4950 50  0001 C CNN
	1    11600 4950
	1    0    0    -1  
$EndComp
Wire Wire Line
	10750 4900 11600 4900
Wire Wire Line
	11600 4950 11600 4900
Wire Wire Line
	8100 6600 8100 6150
Wire Wire Line
	8400 6600 8400 6150
Wire Wire Line
	8500 6600 8500 6150
Wire Wire Line
	8600 6600 8600 6150
Wire Wire Line
	8700 6600 8700 6150
Wire Wire Line
	8800 6600 8800 6150
Wire Wire Line
	8900 6600 8900 6150
Wire Wire Line
	9000 6600 9000 6150
Wire Wire Line
	9100 6600 9100 6150
Wire Wire Line
	9200 6600 9200 6150
Wire Wire Line
	9300 6600 9300 6150
Wire Wire Line
	9500 6600 9500 6150
Wire Wire Line
	9600 6600 9600 6150
Wire Wire Line
	9700 6600 9700 6150
Wire Wire Line
	9800 6600 9800 6150
Wire Wire Line
	9900 6600 9900 6150
Wire Wire Line
	10000 6600 10000 6150
Wire Wire Line
	10100 6600 10100 6150
Wire Wire Line
	10400 6600 10400 6150
Wire Wire Line
	7650 5800 7200 5800
Wire Wire Line
	7650 5700 7200 5700
Wire Wire Line
	7650 5600 7200 5600
Wire Wire Line
	7650 5500 7200 5500
Wire Wire Line
	7650 5400 7200 5400
Wire Wire Line
	7650 5000 7550 5000
Wire Wire Line
	7650 4900 7200 4900
Wire Wire Line
	7650 4800 7200 4800
Wire Wire Line
	7650 4700 7200 4700
Wire Wire Line
	7650 4600 7200 4600
Wire Wire Line
	7650 4500 7200 4500
Wire Wire Line
	7650 4400 7200 4400
Wire Wire Line
	7650 4300 7200 4300
Wire Wire Line
	8100 3950 8100 3500
Wire Wire Line
	8400 3950 8400 3500
Wire Wire Line
	8500 3950 8500 3500
Wire Wire Line
	8600 3950 8600 3500
Wire Wire Line
	8700 3950 8700 3500
Wire Wire Line
	8800 3950 8800 3500
Wire Wire Line
	8900 3950 8900 3500
Wire Wire Line
	9000 3950 9000 3500
Wire Wire Line
	9100 3950 9100 3500
Wire Wire Line
	9300 3950 9300 3500
Wire Wire Line
	9500 3950 9500 3500
Wire Wire Line
	9600 3950 9600 3500
Wire Wire Line
	9700 3950 9700 3500
Wire Wire Line
	9800 3950 9800 3500
Wire Wire Line
	9900 3950 9900 3500
Wire Wire Line
	10000 3950 10000 3500
Wire Wire Line
	10100 3950 10100 3500
Wire Wire Line
	10400 3950 10400 3500
Wire Wire Line
	12950 4300 12500 4300
Wire Wire Line
	12950 4200 12500 4200
Wire Wire Line
	12950 4100 12500 4100
Wire Wire Line
	12950 4000 12500 4000
Wire Wire Line
	12950 4700 12500 4700
Wire Wire Line
	12950 4600 12500 4600
Wire Wire Line
	12950 4500 12500 4500
Wire Wire Line
	12950 4400 12500 4400
Wire Wire Line
	12950 5100 12500 5100
Wire Wire Line
	12950 5000 12500 5000
Wire Wire Line
	12950 4900 12500 4900
Wire Wire Line
	12950 4800 12500 4800
Wire Wire Line
	12950 5500 12500 5500
Wire Wire Line
	12950 5400 12500 5400
Wire Wire Line
	12950 5300 12500 5300
Wire Wire Line
	12950 5200 12500 5200
Wire Wire Line
	12950 5900 12500 5900
Wire Wire Line
	12950 5800 12500 5800
Wire Wire Line
	12950 5700 12500 5700
Wire Wire Line
	12950 5600 12500 5600
Wire Wire Line
	12950 6150 12500 6150
Wire Wire Line
	12950 6250 12500 6250
Wire Wire Line
	12950 6350 12500 6350
Wire Wire Line
	14600 4300 14150 4300
Wire Wire Line
	14600 4200 14150 4200
Wire Wire Line
	14600 4100 14150 4100
Wire Wire Line
	14600 4000 14150 4000
Wire Wire Line
	14600 4700 14150 4700
Wire Wire Line
	14600 4600 14150 4600
Wire Wire Line
	14600 4500 14150 4500
Wire Wire Line
	14600 4400 14150 4400
Wire Wire Line
	13550 3800 13550 3600
$Comp
L power:+3.3V #PWR0109
U 1 1 64919089
P 13550 3600
F 0 "#PWR0109" H 13550 3450 50  0001 C CNN
F 1 "+3.3V" H 13565 3773 50  0000 C CNN
F 2 "" H 13550 3600 50  0001 C CNN
F 3 "" H 13550 3600 50  0001 C CNN
	1    13550 3600
	1    0    0    -1  
$EndComp
Wire Wire Line
	13550 6500 13550 6600
$Comp
L power:GND #PWR0110
U 1 1 6491D57E
P 13550 6600
F 0 "#PWR0110" H 13550 6350 50  0001 C CNN
F 1 "GND" H 13555 6427 50  0000 C CNN
F 2 "" H 13550 6600 50  0001 C CNN
F 3 "" H 13550 6600 50  0001 C CNN
	1    13550 6600
	1    0    0    -1  
$EndComp
Text Label 12500 4000 0    50   ~ 0
A0
Text Label 12500 4100 0    50   ~ 0
A1
Text Label 12500 4200 0    50   ~ 0
A2
Text Label 12500 4300 0    50   ~ 0
A3
Text Label 12500 4400 0    50   ~ 0
A4
Text Label 12500 4500 0    50   ~ 0
A5
Text Label 12500 4600 0    50   ~ 0
A6
Text Label 12500 4700 0    50   ~ 0
A7
Text Label 12500 4800 0    50   ~ 0
A8
Text Label 12500 4900 0    50   ~ 0
A9
Text Label 12500 5000 0    50   ~ 0
A10
Text Label 12500 5100 0    50   ~ 0
A11
Text Label 12500 5200 0    50   ~ 0
A12
Text Label 12500 5300 0    50   ~ 0
A13
Text Label 12500 5400 0    50   ~ 0
A14
Text Label 12500 5500 0    50   ~ 0
A15
Text Label 12500 5600 0    50   ~ 0
A16
Text Label 12500 5700 0    50   ~ 0
A17
Text Label 12500 5800 0    50   ~ 0
A18
Text Label 12500 5900 0    50   ~ 0
A19
Text Label 12500 6150 0    50   ~ 0
~CE
Text Label 12500 6250 0    50   ~ 0
~OE
Text Label 12500 6350 0    50   ~ 0
~WE
Text Label 14600 4000 2    50   ~ 0
D0
Text Label 14600 4100 2    50   ~ 0
D1
Text Label 14600 4200 2    50   ~ 0
D2
Text Label 14600 4300 2    50   ~ 0
D3
Text Label 14600 4400 2    50   ~ 0
D4
Text Label 14600 4500 2    50   ~ 0
D5
Text Label 14600 4600 2    50   ~ 0
D6
Text Label 14600 4700 2    50   ~ 0
D7
Text Label 8800 6600 1    50   ~ 0
A0
Text Label 8900 6600 1    50   ~ 0
A1
Text Label 9000 6600 1    50   ~ 0
A2
Text Label 9100 6600 1    50   ~ 0
A3
Text Label 9300 6600 1    50   ~ 0
A4
Text Label 9500 6600 1    50   ~ 0
A5
Text Label 9600 6600 1    50   ~ 0
A6
Text Label 9700 6600 1    50   ~ 0
A7
Text Label 9800 6600 1    50   ~ 0
A8
Text Label 9900 6600 1    50   ~ 0
A9
Text Label 10000 6600 1    50   ~ 0
A10
Text Label 10100 6600 1    50   ~ 0
A11
Text Label 10400 6600 1    50   ~ 0
A12
$Comp
L power:GND #PWR0111
U 1 1 649B0FFA
P 9200 6600
F 0 "#PWR0111" H 9200 6350 50  0001 C CNN
F 1 "GND" H 9205 6427 50  0000 C CNN
F 2 "" H 9200 6600 50  0001 C CNN
F 3 "" H 9200 6600 50  0001 C CNN
	1    9200 6600
	1    0    0    -1  
$EndComp
Text Label 8100 6600 1    50   ~ 0
~NMI
Text Label 8400 6600 1    50   ~ 0
~INT0
Text Label 8500 6600 1    50   ~ 0
~INT1
Text Label 8600 6600 1    50   ~ 0
~INT2
Text Label 8700 6600 1    50   ~ 0
ST
Text Label 10400 3500 3    50   ~ 0
D6
Text Label 10100 3500 3    50   ~ 0
D7
Text Label 10000 3500 3    50   ~ 0
~RTS0
Text Label 9900 3500 3    50   ~ 0
~CTS0
Text Label 9800 3500 3    50   ~ 0
~DCD0
Text Label 9700 3500 3    50   ~ 0
TXA0
Text Label 9600 3500 3    50   ~ 0
RXA0
Text Label 9500 3500 3    50   ~ 0
CKA0
Text Label 9300 3500 3    50   ~ 0
TXA1
Text Label 9100 3500 3    50   ~ 0
RXA1
Text Label 9000 3500 3    50   ~ 0
CKA1
Text Label 8900 3500 3    50   ~ 0
TXS
Text Label 8800 3500 3    50   ~ 0
RXS
Text Label 8700 3500 3    50   ~ 0
CKS
Text Label 8600 3500 3    50   ~ 0
~DREQ1
Text Label 8500 3500 3    50   ~ 0
~TEND1
Text Label 8400 3500 3    50   ~ 0
~HALT
Text Label 8100 3500 3    50   ~ 0
~RFSH
NoConn ~ 7650 5200
Text Label 7200 4300 0    50   ~ 0
~IORQ
Text Label 7200 4400 0    50   ~ 0
~MREQ
Text Label 7200 4500 0    50   ~ 0
E
Text Label 7200 4600 0    50   ~ 0
~M1
Text Label 7200 4700 0    50   ~ 0
~WR
Text Label 7200 4800 0    50   ~ 0
~RD
Text Label 7200 4900 0    50   ~ 0
PHI
Text Label 7200 5400 0    50   ~ 0
EXTAL
Text Label 7200 5500 0    50   ~ 0
~WAIT
Text Label 7200 5600 0    50   ~ 0
~BUSACK
Text Label 7200 5700 0    50   ~ 0
~BUSREQ
Text Label 7200 5800 0    50   ~ 0
~RESET
Wire Wire Line
	7650 5100 7550 5100
Wire Wire Line
	7550 5100 7550 5000
Connection ~ 7550 5000
Wire Wire Line
	7550 5000 7200 5000
$Comp
L power:GND #PWR0112
U 1 1 649CE1C2
P 7200 5000
F 0 "#PWR0112" H 7200 4750 50  0001 C CNN
F 1 "GND" H 7205 4827 50  0000 C CNN
F 2 "" H 7200 5000 50  0001 C CNN
F 3 "" H 7200 5000 50  0001 C CNN
	1    7200 5000
	1    0    0    -1  
$EndComp
Wire Wire Line
	5600 3800 5950 3800
Wire Wire Line
	5600 3900 5950 3900
Wire Wire Line
	5600 4000 5950 4000
Wire Wire Line
	5600 4100 5950 4100
Wire Wire Line
	5600 4200 5950 4200
Wire Wire Line
	5600 4300 5950 4300
Wire Wire Line
	5600 4400 5950 4400
Wire Wire Line
	5600 4500 5950 4500
Wire Wire Line
	5600 4600 5950 4600
Wire Wire Line
	5600 4700 5950 4700
Wire Wire Line
	5600 4800 5950 4800
Wire Wire Line
	5600 4900 5950 4900
Wire Wire Line
	5600 5000 5950 5000
Wire Wire Line
	5600 5100 5950 5100
Wire Wire Line
	5600 5200 5950 5200
Wire Wire Line
	5600 5300 5950 5300
Wire Wire Line
	5600 5400 5950 5400
Wire Wire Line
	5600 5500 5950 5500
Wire Wire Line
	5600 5600 5950 5600
Wire Wire Line
	5600 5700 5950 5700
Wire Wire Line
	5600 5800 5950 5800
Wire Wire Line
	5600 5900 5950 5900
Wire Wire Line
	5600 6000 5950 6000
Wire Wire Line
	5600 6100 5950 6100
Wire Wire Line
	4750 3800 5100 3800
Wire Wire Line
	4750 3900 5100 3900
Wire Wire Line
	4750 4000 5100 4000
Wire Wire Line
	4750 4100 5100 4100
Wire Wire Line
	4750 4200 5100 4200
Wire Wire Line
	4750 4300 5100 4300
Wire Wire Line
	4750 4400 5100 4400
Wire Wire Line
	4750 4500 5100 4500
Wire Wire Line
	4750 4600 5100 4600
Wire Wire Line
	4750 4700 5100 4700
Wire Wire Line
	4750 4800 5100 4800
Wire Wire Line
	4750 4900 5100 4900
Wire Wire Line
	4750 5000 5100 5000
Wire Wire Line
	4750 5100 5100 5100
Wire Wire Line
	4750 5200 5100 5200
Wire Wire Line
	4750 5300 5100 5300
Wire Wire Line
	4750 5400 5100 5400
Wire Wire Line
	4750 5500 5100 5500
Wire Wire Line
	4750 5600 5100 5600
Wire Wire Line
	4750 5700 5100 5700
Wire Wire Line
	4750 5800 5100 5800
Wire Wire Line
	4750 5900 5100 5900
Wire Wire Line
	4750 6000 5100 6000
Wire Wire Line
	4750 6100 5100 6100
Wire Wire Line
	5600 6200 5950 6200
Wire Wire Line
	5600 6300 5950 6300
Wire Wire Line
	4750 6200 5100 6200
Wire Wire Line
	4750 6300 5100 6300
$Comp
L Device:C_Small C3
U 1 1 648729E4
P 6000 1550
F 0 "C3" H 6092 1596 50  0000 L CNN
F 1 "1uF" H 6092 1505 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 6000 1550 50  0001 C CNN
F 3 "~" H 6000 1550 50  0001 C CNN
	1    6000 1550
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C1
U 1 1 64873D24
P 5200 1550
F 0 "C1" H 5292 1596 50  0000 L CNN
F 1 ".1uF" H 5292 1505 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 5200 1550 50  0001 C CNN
F 3 "~" H 5200 1550 50  0001 C CNN
	1    5200 1550
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C4
U 1 1 648743D5
P 6400 1550
F 0 "C4" H 6492 1596 50  0000 L CNN
F 1 "1uF" H 6492 1505 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 6400 1550 50  0001 C CNN
F 3 "~" H 6400 1550 50  0001 C CNN
	1    6400 1550
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C2
U 1 1 64874616
P 5550 1550
F 0 "C2" H 5642 1596 50  0000 L CNN
F 1 ".1uF" H 5642 1505 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 5550 1550 50  0001 C CNN
F 3 "~" H 5550 1550 50  0001 C CNN
	1    5550 1550
	1    0    0    -1  
$EndComp
Wire Wire Line
	5200 1450 5300 1450
Connection ~ 5550 1450
Wire Wire Line
	5550 1450 6000 1450
Connection ~ 6000 1450
Wire Wire Line
	6000 1450 6200 1450
Wire Wire Line
	5200 1650 5300 1650
Connection ~ 5550 1650
Wire Wire Line
	5550 1650 6000 1650
Connection ~ 6000 1650
Wire Wire Line
	6000 1650 6200 1650
$Comp
L power:GND #PWR02
U 1 1 64894606
P 6200 1650
F 0 "#PWR02" H 6200 1400 50  0001 C CNN
F 1 "GND" H 6205 1477 50  0000 C CNN
F 2 "" H 6200 1650 50  0001 C CNN
F 3 "" H 6200 1650 50  0001 C CNN
	1    6200 1650
	1    0    0    -1  
$EndComp
Connection ~ 6200 1650
Wire Wire Line
	6200 1650 6400 1650
$Comp
L power:+3.3V #PWR01
U 1 1 64896257
P 6200 1450
F 0 "#PWR01" H 6200 1300 50  0001 C CNN
F 1 "+3.3V" H 6215 1623 50  0000 C CNN
F 2 "" H 6200 1450 50  0001 C CNN
F 3 "" H 6200 1450 50  0001 C CNN
	1    6200 1450
	1    0    0    -1  
$EndComp
Connection ~ 6200 1450
Wire Wire Line
	6200 1450 6400 1450
$Comp
L Connector_Generic:Conn_02x12_Odd_Even J1
U 1 1 648C4D26
P 9100 2050
F 0 "J1" H 9150 2767 50  0000 C CNN
F 1 "Conn_02x12_Odd_Even" H 9150 2676 50  0001 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x12_P2.54mm_Vertical" H 9100 2050 50  0001 C CNN
F 3 "~" H 9100 2050 50  0001 C CNN
	1    9100 2050
	1    0    0    -1  
$EndComp
Wire Wire Line
	8900 1750 8300 1750
Wire Wire Line
	8900 1850 8300 1850
Wire Wire Line
	8900 1950 8300 1950
Wire Wire Line
	8900 2050 8300 2050
Wire Wire Line
	8900 2150 8300 2150
Wire Wire Line
	8900 2250 8300 2250
Wire Wire Line
	8900 2350 8300 2350
Wire Wire Line
	10000 1850 9400 1850
Wire Wire Line
	10000 1950 9400 1950
Wire Wire Line
	10000 2050 9400 2050
Wire Wire Line
	10000 2150 9400 2150
Wire Wire Line
	10000 2250 9400 2250
Text Label 5950 6300 2    50   ~ 0
A9
Text Label 5950 6200 2    50   ~ 0
A8
Text Label 5950 6100 2    50   ~ 0
A7
Text Label 5950 6000 2    50   ~ 0
A6
Text Label 5950 5900 2    50   ~ 0
A5
Text Label 5950 5800 2    50   ~ 0
~WE
Text Label 5950 5700 2    50   ~ 0
D3
Text Label 5950 5600 2    50   ~ 0
D2
Text Label 5950 5500 2    50   ~ 0
D1
Text Label 5950 5400 2    50   ~ 0
D0
Text Label 4750 6300 0    50   ~ 0
A19
Text Label 4750 6200 0    50   ~ 0
A10
Text Label 4750 6100 0    50   ~ 0
A11
Text Label 4750 6000 0    50   ~ 0
A12
Text Label 4750 5900 0    50   ~ 0
A13
Text Label 4750 5800 0    50   ~ 0
A14
Text Label 4750 5700 0    50   ~ 0
D4
Text Label 4750 5600 0    50   ~ 0
D5
Text Label 4750 5500 0    50   ~ 0
D6
Text Label 4750 5400 0    50   ~ 0
D7
Text Label 4750 5300 0    50   ~ 0
~OE
Text Label 4750 5200 0    50   ~ 0
A15
Text Label 4750 5100 0    50   ~ 0
A16
Text Label 4750 5000 0    50   ~ 0
A17
Text Label 4750 4900 0    50   ~ 0
A18
Text Label 4750 4800 0    50   ~ 0
~INT0
Text Label 4750 4700 0    50   ~ 0
~INT1
Text Label 4750 4600 0    50   ~ 0
~INT2
Text Label 4750 4500 0    50   ~ 0
ST
Text Label 4750 4400 0    50   ~ 0
E
Text Label 4750 4300 0    50   ~ 0
~MREQ
Text Label 4750 4200 0    50   ~ 0
~IORQ
Text Label 4750 4100 0    50   ~ 0
~RFSH
Text Label 4750 4000 0    50   ~ 0
~HALT
Text Label 4750 3900 0    50   ~ 0
~TEND1
Text Label 5950 3800 2    50   ~ 0
~DREQ1
Text Label 5950 5300 2    50   ~ 0
~CE
Text Label 5950 5200 2    50   ~ 0
A4
Text Label 5950 5100 2    50   ~ 0
A3
Text Label 5950 5000 2    50   ~ 0
A2
Text Label 5950 4900 2    50   ~ 0
A1
Text Label 5950 4800 2    50   ~ 0
A0
Text Label 5950 4700 2    50   ~ 0
~NMI
Text Label 5950 4600 2    50   ~ 0
~RESET
Text Label 5950 4500 2    50   ~ 0
~BUSREQ
Text Label 5950 4400 2    50   ~ 0
~BUSACK
Text Label 5950 4300 2    50   ~ 0
~WAIT
Text Label 5950 4200 2    50   ~ 0
EXTAL
Text Label 5950 4100 2    50   ~ 0
PHI
Text Label 5950 4000 2    50   ~ 0
~RD
Text Label 5950 3900 2    50   ~ 0
~WR
Text Label 4750 3800 0    50   ~ 0
~M1
Wire Wire Line
	8900 1550 8750 1550
Wire Wire Line
	8750 1550 8750 1450
Wire Wire Line
	8750 1450 9500 1450
Wire Wire Line
	9500 1450 9500 1550
Wire Wire Line
	9500 1550 9400 1550
$Comp
L power:+3.3V #PWR0113
U 1 1 649052CB
P 9500 1450
F 0 "#PWR0113" H 9500 1300 50  0001 C CNN
F 1 "+3.3V" H 9515 1623 50  0000 C CNN
F 2 "" H 9500 1450 50  0001 C CNN
F 3 "" H 9500 1450 50  0001 C CNN
	1    9500 1450
	1    0    0    -1  
$EndComp
Connection ~ 9500 1450
Wire Wire Line
	9400 1650 10400 1650
$Comp
L power:GND #PWR0114
U 1 1 649178C8
P 10400 1650
F 0 "#PWR0114" H 10400 1400 50  0001 C CNN
F 1 "GND" H 10405 1477 50  0000 C CNN
F 2 "" H 10400 1650 50  0001 C CNN
F 3 "" H 10400 1650 50  0001 C CNN
	1    10400 1650
	1    0    0    -1  
$EndComp
Wire Wire Line
	7900 1650 8900 1650
$Comp
L power:GND #PWR0115
U 1 1 64929BE9
P 7900 1650
F 0 "#PWR0115" H 7900 1400 50  0001 C CNN
F 1 "GND" H 7905 1477 50  0000 C CNN
F 2 "" H 7900 1650 50  0001 C CNN
F 3 "" H 7900 1650 50  0001 C CNN
	1    7900 1650
	1    0    0    -1  
$EndComp
Text Label 8300 1750 0    50   ~ 0
CKS
Text Label 8300 1850 0    50   ~ 0
RXS
Text Label 10000 1850 2    50   ~ 0
TXS
Text Label 8300 1950 0    50   ~ 0
CKA1
Text Label 10000 1950 2    50   ~ 0
RXA1
Text Label 8300 2050 0    50   ~ 0
TXA1
Text Label 10000 2050 2    50   ~ 0
CKA0
Text Label 8300 2150 0    50   ~ 0
RXA0
Text Label 10000 2150 2    50   ~ 0
TXA0
Text Label 8300 2250 0    50   ~ 0
~DCD0
Text Label 10000 2250 2    50   ~ 0
~CTS0
Text Label 8300 2350 0    50   ~ 0
~RTS0
Wire Wire Line
	9400 2650 10400 2650
$Comp
L power:GND #PWR0116
U 1 1 64950AB5
P 10400 2650
F 0 "#PWR0116" H 10400 2400 50  0001 C CNN
F 1 "GND" H 10405 2477 50  0000 C CNN
F 2 "" H 10400 2650 50  0001 C CNN
F 3 "" H 10400 2650 50  0001 C CNN
	1    10400 2650
	1    0    0    -1  
$EndComp
Wire Wire Line
	7900 2650 8900 2650
$Comp
L power:GND #PWR0117
U 1 1 64961DF5
P 7900 2650
F 0 "#PWR0117" H 7900 2400 50  0001 C CNN
F 1 "GND" H 7905 2477 50  0000 C CNN
F 2 "" H 7900 2650 50  0001 C CNN
F 3 "" H 7900 2650 50  0001 C CNN
	1    7900 2650
	1    0    0    -1  
$EndComp
NoConn ~ 8900 2450
NoConn ~ 8900 2550
NoConn ~ 9400 2550
NoConn ~ 9400 2450
NoConn ~ 9400 2350
NoConn ~ 9400 1750
$Comp
L Graphic:Logo_Open_Hardware_Small LOGO1
U 1 1 649BC4AB
P 16150 8950
F 0 "LOGO1" H 16150 9225 50  0001 C CNN
F 1 "Logo_Open_Hardware_Small" H 16150 8725 50  0001 C CNN
F 2 "Symbol:OSHW-Logo2_9.8x8mm_SilkScreen" H 16150 8950 50  0001 C CNN
F 3 "~" H 16150 8950 50  0001 C CNN
	1    16150 8950
	1    0    0    -1  
$EndComp
$Comp
L power:PWR_FLAG #FLG0101
U 1 1 657E0B1B
P 5300 1450
F 0 "#FLG0101" H 5300 1525 50  0001 C CNN
F 1 "PWR_FLAG" H 5300 1623 50  0000 C CNN
F 2 "" H 5300 1450 50  0001 C CNN
F 3 "~" H 5300 1450 50  0001 C CNN
	1    5300 1450
	1    0    0    -1  
$EndComp
Connection ~ 5300 1450
Wire Wire Line
	5300 1450 5550 1450
$Comp
L power:PWR_FLAG #FLG0102
U 1 1 657E16AA
P 5300 1650
F 0 "#FLG0102" H 5300 1725 50  0001 C CNN
F 1 "PWR_FLAG" H 5300 1823 50  0000 C CNN
F 2 "" H 5300 1650 50  0001 C CNN
F 3 "~" H 5300 1650 50  0001 C CNN
	1    5300 1650
	-1   0    0    1   
$EndComp
Connection ~ 5300 1650
Wire Wire Line
	5300 1650 5550 1650
$Comp
L Mechanical:MountingHole H4
U 1 1 65813670
P 10200 9400
F 0 "H4" H 10300 9446 50  0000 L CNN
F 1 "MountingHole" H 10300 9355 50  0000 L CNN
F 2 "MountingHole:MountingHole_2.7mm_M2.5" H 10200 9400 50  0001 C CNN
F 3 "~" H 10200 9400 50  0001 C CNN
	1    10200 9400
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole H3
U 1 1 6581477E
P 10200 9200
F 0 "H3" H 10300 9246 50  0000 L CNN
F 1 "MountingHole" H 10300 9155 50  0000 L CNN
F 2 "MountingHole:MountingHole_2.7mm_M2.5" H 10200 9200 50  0001 C CNN
F 3 "~" H 10200 9200 50  0001 C CNN
	1    10200 9200
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole H2
U 1 1 65814A12
P 10200 9000
F 0 "H2" H 10300 9046 50  0000 L CNN
F 1 "MountingHole" H 10300 8955 50  0000 L CNN
F 2 "MountingHole:MountingHole_2.7mm_M2.5" H 10200 9000 50  0001 C CNN
F 3 "~" H 10200 9000 50  0001 C CNN
	1    10200 9000
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole H1
U 1 1 65814BEB
P 10200 8800
F 0 "H1" H 10300 8846 50  0000 L CNN
F 1 "MountingHole" H 10300 8755 50  0000 L CNN
F 2 "MountingHole:MountingHole_2.7mm_M2.5" H 10200 8800 50  0001 C CNN
F 3 "~" H 10200 8800 50  0001 C CNN
	1    10200 8800
	1    0    0    -1  
$EndComp
Text Notes 4500 3800 0    50   Italic 10
55
Text Notes 4500 3900 0    50   Italic 10
48
Text Notes 4500 4000 0    50   Italic 10
45
Text Notes 4500 4100 0    50   Italic 10
43
Text Notes 4500 4200 0    50   Italic 10
41
Text Notes 4500 4300 0    50   Italic 10
38
Text Notes 4500 4400 0    50   Italic 10
34
Text Notes 4500 4500 0    50   Italic 10
32
Text Notes 4500 4600 0    50   Italic 10
29
Text Notes 4500 4700 0    50   Italic 10
26
Text Notes 4500 4800 0    50   Italic 10
24
Text Notes 4500 4900 0    50   Italic 10
22
Text Notes 4500 5000 0    50   Italic 10
20
Text Notes 4500 5100 0    50   Italic 10
18
Text Notes 4500 5200 0    50   Italic 10
16
Text Notes 4500 5300 0    50   Italic 10
12
Text Notes 4500 5400 0    50   Italic 10
10
Text Notes 4500 5500 0    50   Italic 10
8
Text Notes 4500 5600 0    50   Italic 10
4
Text Notes 4500 5700 0    50   Italic 10
2
Text Notes 4500 5800 0    50   Italic 10
144
Text Notes 4500 5900 0    50   Italic 10
142
Text Notes 4500 6000 0    50   Italic 10
139
Text Notes 4500 6100 0    50   Italic 10
137
Text Notes 4500 6200 0    50   Italic 10
135
Text Notes 4500 6300 0    50   Italic 10
130
Text Notes 6150 6300 0    50   Italic 10
129
Text Notes 6150 6200 0    50   Italic 10
134
Text Notes 6150 6100 0    50   Italic 10
136
Text Notes 6150 6000 0    50   Italic 10
138
Text Notes 6150 5900 0    50   Italic 10
141
Text Notes 6150 5800 0    50   Italic 10
143
Text Notes 6150 5700 0    50   Italic 10
1
Text Notes 6150 5600 0    50   Italic 10
3
Text Notes 6150 5500 0    50   Italic 10
7
Text Notes 6150 5400 0    50   Italic 10
9
Text Notes 6150 5300 0    50   Italic 10
11
Text Notes 6150 5200 0    50   Italic 10
15
Text Notes 6150 5100 0    50   Italic 10
17
Text Notes 6150 5000 0    50   Italic 10
19
Text Notes 6150 4900 0    50   Italic 10
21
Text Notes 6150 4800 0    50   Italic 10
23
Text Notes 6150 4700 0    50   Italic 10
25
Text Notes 6150 4600 0    50   Italic 10
28
Text Notes 6150 4500 0    50   Italic 10
31
Text Notes 6150 4400 0    50   Italic 10
33
Text Notes 6150 4300 0    50   Italic 10
37
Text Notes 6150 4200 0    50   Italic 10
39
Text Notes 6150 4100 0    50   Italic 10
42
Text Notes 6150 4000 0    50   Italic 10
44
Text Notes 6150 3900 0    50   Italic 10
47
Text Notes 6150 3800 0    50   Italic 10
49
$Comp
L power:GND #PWR?
U 1 1 65D61870
P 12100 6000
F 0 "#PWR?" H 12100 5750 50  0001 C CNN
F 1 "GND" H 12105 5827 50  0000 C CNN
F 2 "" H 12100 6000 50  0001 C CNN
F 3 "" H 12100 6000 50  0001 C CNN
	1    12100 6000
	1    0    0    -1  
$EndComp
Wire Wire Line
	12950 6000 12100 6000
Text Notes 14350 5600 0    51   ~ 0
IS61WV5128FBLL-10TLI\nIS61WV10248EDBLL-10TLI\nIS61WV20488BLL-10TLI
Text Notes 14350 5300 0    50   ~ 10
Viable SRAM substitutes:
Text Notes 12300 9850 0    39   ~ 0
Copyright (C) 2019, 2023 John Winans\n\nThis documentation describes Open Hardware and is licensed under the CERN OHL v. 1.2.\n\nYou may redistribute and modify this documentation under the terms of the CERN OHL v.1.2. (http://ohwr.org/cernohl). \nThis documentation is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY, \nSATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.  Please see the CERN OHL v.1.2 for applicable conditions\n\nIf you chose to manufacture products based on this design, please notify me (see license section 4.2) via john@winans.org\n
Text Notes 14700 9250 0    50   ~ 10
https://github.com/johnwinans/2067-Z8S180
$EndSCHEMATC
