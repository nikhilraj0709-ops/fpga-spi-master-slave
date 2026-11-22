# SPI Master-Slave FPGA Design & Verification

> **SystemVerilog RTL implementation of an 8-bit full-duplex SPI Master-Slave system, verified through simulation, assertions, functional coverage, static checks, timing closure, and real Spartan-7 FPGA hardware validation.**

![SystemVerilog](https://img.shields.io/badge/HDL-SystemVerilog-blue)
![FPGA](https://img.shields.io/badge/FPGA-Xilinx%20Spartan--7-blue)
![Vivado](https://img.shields.io/badge/Tool-AMD%20Vivado%202025.1-orange)
![Verification](https://img.shields.io/badge/Functional%20Coverage-100%25-brightgreen)
![Regression](https://img.shields.io/badge/Regression-270%2F270%20PASS-brightgreen)
![Lint](https://img.shields.io/badge/RTL%20Lint-0%20Violations-brightgreen)
![Timing](https://img.shields.io/badge/Post--Route%20Timing-PASS-brightgreen)
![Hardware](https://img.shields.io/badge/FPGA%20Hardware-Validated-success)

---


## Architecture Overview

![SPI Master-Slave FPGA Architecture](docs/architecture.png)

## Project Highlights

- **8-bit full-duplex SPI Master-Slave architecture**
- **270 / 270 functional checks passed**
- **100% functional coverage**
- **0 RTL lint violations**
- **Post-route timing closed successfully**
- **0 DRC errors**
- **CDC-aware board input synchronization**
- **Asynchronous reset assertion with synchronous release**
- **SystemVerilog assertions and coverage**
- **Validated on real Xilinx Spartan-7 FPGA hardware**

---
A synthesizable, verified, timing-clean, FPGA-deployed SPI full-duplex communication project implemented in SystemVerilog and validated on a Real Digital Boolean Board using a Xilinx Spartan-7 FPGA.

## Project Overview

This project implements an SPI master and SPI slave connected in full-duplex mode.

The design supports simultaneous data transfer between the master and slave using MOSI and MISO while generating SPI clock and chip-select control from the master.

The project was developed beyond basic simulation functionality, with emphasis on RTL quality, CDC/reset robustness, lint cleanliness, timing closure, methodology review, FPGA implementation, and physical board validation.

## Target Platform

- FPGA Family: Xilinx Spartan-7
- Device: XC7S50CSGA324-1
- Board: Real Digital Boolean Board
- Tool: AMD Vivado 2025.1
- HDL: SystemVerilog
- System Clock: 100 MHz

## SPI Configuration

- Full-duplex communication
- Data width: 8 bits
- Master-generated serial clock
- Active-low chip select
- Parameterized clock divider
- MSB-first data transfer

## RTL Architecture

Main RTL modules:

- spi_master.sv
  - Generates SCLK and CS
  - Serializes Master TX data on MOSI
  - Samples MISO
  - Produces received byte and transaction status

- spi_slave.sv
  - Operates using the system clock
  - Detects SCLK edges internally
  - Samples MOSI
  - Drives MISO
  - Avoids using protocol SCLK as an internal FPGA clock

- spi_top.sv
  - Connects master and slave
  - Provides full-duplex data path

- spi_board_top.sv
  - FPGA board integration wrapper
  - Reset synchronization
  - Switch synchronization
  - Start-button synchronization and debounce
  - Transaction data capture
  - LED result display

## CDC and Reset Handling

The board wrapper includes:

- Asynchronous reset assertion
- Synchronous reset deassertion
- Two-stage synchronization for asynchronous switch inputs
- Two-stage synchronization for the start button
- Button debounce logic
- Single-cycle start pulse generation
- Stable transaction data capture before SPI transfer starts

The SPI slave was redesigned to avoid using internally generated SCLK as a separate FPGA clock domain.

Instead, SCLK is treated as a protocol signal and its rising and falling edges are detected using the 100 MHz system clock.

This removes the earlier non-clocked sequential methodology issue and keeps the design within a single primary clock domain.

## FPGA I/O Interface

- SW[7:0]   : Master transmit data
- SW[15:8]  : Slave transmit data
- BTN0       : Reset
- BTN1       : Start SPI transaction
- LED[7:0]   : Data received by the SPI slave
- LED[15:8]  : Data received by the SPI master

## Verification and Signoff Results

### Functional Verification

- Total checks: 270
- Passed checks: 270
- Failed checks: 0
- Overall result: PASS

### Functional Coverage

- Master TX coverage: 100%
- Slave TX coverage: 100%
- Master RX coverage: 100%
- Slave RX coverage: 100%
- TX cross coverage: 100%
- Overall functional coverage: 100%

### RTL Lint

- Linter messages: 0
- Warnings: 0
- Critical warnings: 0
- Errors: 0
- Result: PASS

### Timing Analysis

- Post-route timing completed successfully
- All user specified timing constraints are met
- Result: PASS

### Design Rule Check

- DRC errors: 0
- Bitstream precondition DRC: PASS
- Result: PASS

### Methodology Review

- Active methodology checks: 0
- Documented waived checks: 34
- TIMING-17 issue: resolved
- TIMING-18 warnings: documented and waived for asynchronous human-interface board I/O

No artificial input/output delay values were added for manual switches, push buttons, or LEDs.

## Power Estimate

Vivado post-route vectorless estimate:

- Total On-Chip Power: 0.073 W
- Dynamic Power: 0.002 W
- Device Static Power: 0.072 W

## Hardware Validation

The design was successfully programmed and tested on the physical Spartan-7 FPGA board.

| Master TX | Slave TX | Slave RX | Master RX | Result |
|-----------|----------|----------|-----------|--------|
| A5 | 3C | A5 | 3C | PASS |
| 55 | AA | 55 | AA | PASS |
| FF | 00 | FF | 00 | PASS |
| 00 | FF | 00 | FF | PASS |
| FF | FF | FF | FF | PASS |

## Key Engineering Improvements

This project evolved from a basic SPI implementation into a more robust FPGA design by adding:

- Single-system-clock RTL architecture
- CDC-safe asynchronous input handling
- Reset synchronization
- Button synchronization and debounce
- Stable transaction-level switch data capture
- SystemVerilog assertions
- Functional coverage
- RTL lint analysis
- Post-route timing analysis
- DRC and methodology review
- Documented methodology waivers
- Physical FPGA hardware validation

## Final Status

The design successfully passed:

- RTL simulation
- 270 out of 270 functional checks
- 100% functional coverage
- RTL lint
- Synthesis
- Implementation
- Post-route timing analysis
- DRC
- Methodology review
- Bitstream generation
- Multiple FPGA hardware tests

## Skills Demonstrated

SystemVerilog, RTL Design, SPI Protocol, FPGA Design, CDC, Reset Design, Functional Verification, Assertions, Functional Coverage, AMD Vivado, Static Timing Analysis, DRC, Methodology Analysis, FPGA Hardware Validation.


## Verification Evidence

### SPI Waveform Verification

Representative full-duplex SPI transaction:

![Single SPI Transaction](docs/verification/single_transaction_waveform.png)

Directed test sequence covering multiple data patterns:

![Directed Test Overview](docs/verification/directed_test_overview.png)

Coverage-closure regression waveform:

![Coverage Closure Waveform](docs/verification/coverage_closure_waveform.png)

### Regression, Coverage, and Assertions

The SystemVerilog verification environment completed **270/270 checks with zero failures**, achieved **100% functional coverage**, and completed all protocol assertions with **0 assertion failures**.

![Verification Summary](docs/verification/verification_summary.png)

![Assertion Summary](docs/verification/assertion_summary.png)

Verification components:
- [`tb/spi_tb.sv`](tb/spi_tb.sv) - directed, random, and coverage-closure tests
- [`tb/spi_assertions.sv`](tb/spi_assertions.sv) - protocol and transaction assertions
- [`tb/spi_coverage.sv`](tb/spi_coverage.sv) - functional coverage model
## Hardware Validation Gallery

The design was validated on the Real Digital Boolean Board using multiple transmit patterns to verify full-duplex SPI communication on physical FPGA hardware.

<table>
<tr>
<td align="center"><b>A5 / 3C</b><br><img src="docs/board_demo/test_A5_3C.jpg" width="430"><br>Slave RX = A5 | Master RX = 3C<br><b>PASS</b></td>
<td align="center"><b>55 / AA</b><br><img src="docs/board_demo/test_55_AA.jpg" width="430"><br>Slave RX = 55 | Master RX = AA<br><b>PASS</b></td>
</tr>
<tr>
<td align="center"><b>FF / 00</b><br><img src="docs/board_demo/test_FF_00.jpg" width="430"><br>Slave RX = FF | Master RX = 00<br><b>PASS</b></td>
<td align="center"><b>00 / FF</b><br><img src="docs/board_demo/test_00_FF.jpg" width="430"><br>Slave RX = 00 | Master RX = FF<br><b>PASS</b></td>
</tr>
<tr>
<td colspan="2" align="center"><b>FF / FF</b><br><img src="docs/board_demo/test_FF_FF.jpg" width="430"><br>Slave RX = FF | Master RX = FF<br><b>PASS</b></td>
</tr>
</table>

All tested patterns successfully completed bidirectional SPI data transfer on the physical Spartan-7 FPGA board.

---


## Project Structure

```text
fpga-spi-master-slave/
|
|-- rtl/
|   |-- spi_master.sv
|   |-- spi_slave.sv
|   |-- spi_top.sv
|   -- spi_board_top.sv
|
|-- tb/
|   |-- spi_tb.sv
|   |-- spi_assertions.sv
|   -- spi_coverage.sv
|
|-- constraints/
|   -- spi_board.xdc
|
|-- docs/
|   |-- architecture.png
|   |-- hardware_validation.md
|   |-- verification_summary.md
|   -- board_demo/
|
|-- reports/
|-- scripts/
|-- .gitignore
|-- LICENSE
`-- README.md
```

## How to Run

### 1. RTL Simulation

Use the RTL files in `rtl/` together with the verification files in `tb/`.

Simulation top: `spi_tb`

The verification environment includes directed and randomized transactions, assertions, functional coverage, and end-to-end data checking.

### 2. RTL Lint

Run: `scripts/run_spi_lint.tcl`

### 3. Synthesis and Implementation

Run: `scripts/run_spi_impl.tcl`

This flow performs synthesis, implementation, timing analysis, methodology checks, and DRC reporting.

### 4. Final Signoff

Run: `scripts/run_spi_final.tcl`

This generates final timing, DRC, power reports, and the FPGA bitstream.

### 5. Hardware Test

- Set `SW[7:0]` as Master TX data.
- Set `SW[15:8]` as Slave TX data.
- Press `BTN0` for reset.
- Press `BTN1` to start the SPI transaction.
- Observe received bytes on `LED[7:0]` and `LED[15:8]`.

---

## Key Results

| Metric | Result |
|--------|--------|
| Functional checks | 270 / 270 PASS |
| Functional coverage | 100% |
| RTL lint violations | 0 |
| DRC errors | 0 |
| Active methodology checks | 0 |
| Post-route timing | PASS |
| FPGA hardware validation | PASS |
| Hardware test patterns | A5/3C, 55/AA, FF/00, 00/FF, FF/FF |
| Total on-chip power | 0.073 W |

---


