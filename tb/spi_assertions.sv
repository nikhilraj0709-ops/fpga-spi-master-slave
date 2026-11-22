`timescale 1ns/1ps

module spi_assertions (
    input logic clk,
    input logic rst_n,
    input logic start,
    input logic busy,
    input logic master_done,
    input logic cs_n,
    input logic sclk
);

    // =========================================================
    // ASSERTION 1
    // When SPI is busy, slave must remain selected.
    // =========================================================
    property p_busy_cs_low;
        @(posedge clk)
        disable iff (!rst_n)
        busy |-> !cs_n;
    endproperty

    a_busy_cs_low:
        assert property (p_busy_cs_low)
        else $error(
            "[ASSERT FAIL] CS_N became HIGH while SPI was BUSY"
        );


    // =========================================================
    // ASSERTION 2
    // SPI Mode 0:
    // SCLK must remain LOW while controller is idle.
    // =========================================================
    property p_idle_sclk_low;
        @(posedge clk)
        disable iff (!rst_n)
        !busy |-> (sclk == 1'b0);
    endproperty

    a_idle_sclk_low:
        assert property (p_idle_sclk_low)
        else $error(
            "[ASSERT FAIL] SCLK is not LOW while SPI is IDLE"
        );


    // =========================================================
    // ASSERTION 3
    // DONE must only remain HIGH for one system-clock cycle.
    // =========================================================
    property p_done_one_cycle;
        @(posedge clk)
        disable iff (!rst_n)
        master_done |=> !master_done;
    endproperty

    a_done_one_cycle:
        assert property (p_done_one_cycle)
        else $error(
            "[ASSERT FAIL] MASTER_DONE stayed HIGH for more than one cycle"
        );


    // =========================================================
    // ASSERTION 4
    // When transaction completes:
    // BUSY must be LOW and CS_N must be HIGH.
    // =========================================================
    property p_done_status;
        @(posedge clk)
        disable iff (!rst_n)
        master_done |-> (!busy && cs_n);
    endproperty

    a_done_status:
        assert property (p_done_status)
        else $error(
            "[ASSERT FAIL] Invalid BUSY/CS_N state when transaction completed"
        );


    // =========================================================
    // ASSERTION 5
    // Start request while idle must cause transaction to start.
    // =========================================================
    property p_start_transaction;
        @(posedge clk)
        disable iff (!rst_n)
        (start && !busy) |=> busy;
    endproperty

    a_start_transaction:
        assert property (p_start_transaction)
        else $error(
            "[ASSERT FAIL] START request did not begin SPI transaction"
        );


endmodule