# SPI Industrial Project - Hardware Validation

## FPGA Board
Real Digital Boolean Board
Device: Xilinx Spartan-7 XC7S50CSGA324-1

## Hardware Test Results

| Master TX | Slave TX | Slave RX LED[7:0] | Master RX LED[15:8] | Result |
|-----------|----------|--------------------|----------------------|--------|
| A5        | 3C       | A5                 | 3C                   | PASS   |
| 55        | AA       | 55                 | AA                   | PASS   |
| FF        | 00       | FF                 | 00                   | PASS   |
| 00        | FF       | 00                 | FF                   | PASS   |
| FF        | FF       | FF                 | FF                   | PASS   |

## Hardware Test Procedure

1. Set SW[7:0] as Master transmit data.
2. Set SW[15:8] as Slave transmit data.
3. Press and release BTN0 for reset.
4. Press BTN1 to start SPI transaction.
5. LED[7:0] shows data received by the SPI slave.
6. LED[15:8] shows data received by the SPI master.

## Result

Full-duplex SPI communication was successfully validated on the Spartan-7 FPGA hardware using multiple normal, alternating-bit, and boundary-value test patterns.
