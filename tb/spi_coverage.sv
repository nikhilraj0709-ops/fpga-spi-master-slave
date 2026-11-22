`timescale 1ns/1ps

module spi_coverage #(
    parameter int DATA_WIDTH = 8
)(
    input logic                  clk,
    input logic                  rst_n,
    input logic                  master_done,

    input logic [DATA_WIDTH-1:0] master_tx_data,
    input logic [DATA_WIDTH-1:0] slave_tx_data,

    input logic [DATA_WIDTH-1:0] master_rx_data,
    input logic [DATA_WIDTH-1:0] slave_rx_data
);

    // =========================================================
    // FUNCTIONAL COVERAGE
    // =========================================================
    covergroup spi_cg;

        option.per_instance = 1;

        // -----------------------------------------------------
        // MASTER TX COVERAGE
        // -----------------------------------------------------
        cp_master_tx : coverpoint master_tx_data {

            bins zero       = {8'h00};
            bins all_ones   = {8'hFF};

            bins low_range  = {[8'h01:8'h3F]};

            // Exclude 55 and AA so bins do not overlap
            bins mid_low    = {[8'h40:8'h54]};
            bins alt_55     = {8'h55};
            bins mid_middle = {[8'h56:8'hA9]};
            bins alt_AA     = {8'hAA};
            bins mid_high   = {[8'hAB:8'hBF]};

            bins high_range = {[8'hC0:8'hFE]};
        }


        // -----------------------------------------------------
        // SLAVE TX COVERAGE
        // -----------------------------------------------------
        cp_slave_tx : coverpoint slave_tx_data {

            bins zero       = {8'h00};
            bins all_ones   = {8'hFF};

            bins low_range  = {[8'h01:8'h3F]};

            bins mid_low    = {[8'h40:8'h54]};
            bins alt_55     = {8'h55};
            bins mid_middle = {[8'h56:8'hA9]};
            bins alt_AA     = {8'hAA};
            bins mid_high   = {[8'hAB:8'hBF]};

            bins high_range = {[8'hC0:8'hFE]};
        }


        // -----------------------------------------------------
        // MASTER RX COVERAGE
        // -----------------------------------------------------
        cp_master_rx : coverpoint master_rx_data {

            bins zero       = {8'h00};
            bins all_ones   = {8'hFF};
            bins low_range  = {[8'h01:8'h3F]};
            bins mid_range  = {[8'h40:8'hBF]};
            bins high_range = {[8'hC0:8'hFE]};
        }


        // -----------------------------------------------------
        // SLAVE RX COVERAGE
        // -----------------------------------------------------
        cp_slave_rx : coverpoint slave_rx_data {

            bins zero       = {8'h00};
            bins all_ones   = {8'hFF};
            bins low_range  = {[8'h01:8'h3F]};
            bins mid_range  = {[8'h40:8'hBF]};
            bins high_range = {[8'hC0:8'hFE]};
        }


        // -----------------------------------------------------
        // TX CROSS COVERAGE
        // -----------------------------------------------------
        cross_master_slave_tx :
            cross cp_master_tx, cp_slave_tx;

    endgroup


    // =========================================================
    // COVERGROUP INSTANCE
    // =========================================================
    spi_cg cg;

    initial begin
        cg = new();
    end


    // =========================================================
    // EXPLICIT SAMPLING
    //
    // Sample after master_done rises so all RX/TX values are
    // stable before coverage is collected.
    // =========================================================
    always @(posedge master_done) begin

        #1;

        cg.sample();

        $display("");
        $display(
            "[COVERAGE] MASTER TX = %0.2f%%",
            cg.cp_master_tx.get_inst_coverage()
        );

        $display(
            "[COVERAGE] SLAVE TX  = %0.2f%%",
            cg.cp_slave_tx.get_inst_coverage()
        );

        $display(
            "[COVERAGE] MASTER RX = %0.2f%%",
            cg.cp_master_rx.get_inst_coverage()
        );

        $display(
            "[COVERAGE] SLAVE RX  = %0.2f%%",
            cg.cp_slave_rx.get_inst_coverage()
        );

        $display(
            "[COVERAGE] TX CROSS  = %0.2f%%",
            cg.cross_master_slave_tx.get_inst_coverage()
        );

        $display(
            "[COVERAGE] OVERALL   = %0.2f%%",
            cg.get_inst_coverage()
        );

    end

endmodule