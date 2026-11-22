`timescale 1ns/1ps

module spi_top #(
    parameter int DATA_WIDTH = 8,
    parameter int CLK_DIV    = 4
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  start,

    input  logic [DATA_WIDTH-1:0] master_tx_data,
    input  logic [DATA_WIDTH-1:0] slave_tx_data,

    output logic [DATA_WIDTH-1:0] master_rx_data,
    output logic [DATA_WIDTH-1:0] slave_rx_data,

    output logic                  busy,
    output logic                  master_done,
    output logic                  slave_done,

    output logic                  sclk,
    output logic                  cs_n,
    output logic                  mosi,
    output logic                  miso
);


    // =========================================================
    // SPI MASTER
    // =========================================================

    spi_master #(
        .DATA_WIDTH(DATA_WIDTH),
        .CLK_DIV   (CLK_DIV)
    ) u_spi_master (

        .clk     (clk),
        .rst_n   (rst_n),

        .start   (start),
        .tx_data (master_tx_data),

        .miso    (miso),

        .sclk    (sclk),
        .cs_n    (cs_n),
        .mosi    (mosi),

        .rx_data (master_rx_data),

        .busy    (busy),
        .done    (master_done)

    );


    // =========================================================
    // SPI SLAVE
    //
    // IMPORTANT:
    // Slave registers also use system clock "clk".
    // SCLK is now an edge-detected protocol signal rather
    // than an internally generated FPGA clock.
    // =========================================================

    spi_slave #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_spi_slave (

        .clk     (clk),
        .rst_n   (rst_n),

        .sclk    (sclk),
        .cs_n    (cs_n),

        .mosi    (mosi),
        .miso    (miso),

        .tx_data (slave_tx_data),
        .rx_data (slave_rx_data),

        .done    (slave_done)

    );


endmodule