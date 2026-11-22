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
    // Assertion failure counters
    // =========================================================
    int unsigned assertion_failures = 0;

    int unsigned busy_cs_failures    = 0;
    int unsigned idle_sclk_failures  = 0;
    int unsigned done_cycle_failures = 0;
    int unsigned done_state_failures = 0;
    int unsigned start_failures      = 0;


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
        else begin
            assertion_failures++;
            busy_cs_failures++;

            $error(
                "[ASSERT FAIL] CS_N became HIGH while SPI was BUSY"
            );
        end


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
        else begin
            assertion_failures++;
            idle_sclk_failures++;

            $error(
                "[ASSERT FAIL] SCLK is not LOW while SPI is IDLE"
            );
        end


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
        else begin
            assertion_failures++;
            done_cycle_failures++;

            $error(
                "[ASSERT FAIL] MASTER_DONE stayed HIGH for more than one cycle"
            );
        end


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
        else begin
            assertion_failures++;
            done_state_failures++;

            $error(
                "[ASSERT FAIL] Invalid BUSY/CS_N state when transaction completed"
            );
        end


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
        else begin
            assertion_failures++;
            start_failures++;

            $error(
                "[ASSERT FAIL] START request did not begin SPI transaction"
            );
        end


    // =========================================================
    // Final assertion summary
    // Printed automatically when simulation finishes.
    // =========================================================
    final begin

        $display("");
        $display("==========================================");
        $display("          ASSERTION SUMMARY");
        $display("==========================================");

        $display(
            "BUSY / CS_N failures        : %0d",
            busy_cs_failures
        );

        $display(
            "IDLE SCLK failures          : %0d",
            idle_sclk_failures
        );

        $display(
            "DONE pulse failures         : %0d",
            done_cycle_failures
        );

        $display(
            "DONE state failures         : %0d",
            done_state_failures
        );

        $display(
            "START transaction failures  : %0d",
            start_failures
        );

        $display("------------------------------------------");

        $display(
            "TOTAL ASSERTION FAILURES    : %0d",
            assertion_failures
        );

        if (assertion_failures == 0)
            $display("ASSERTION RESULT            : PASS");
        else
            $display("ASSERTION RESULT            : FAIL");

        $display("==========================================");
        $display("");

    end

endmodule