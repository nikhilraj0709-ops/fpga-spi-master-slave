`timescale 1ns/1ps
module spi_master #(
    parameter int DATA_WIDTH = 8,
    parameter int CLK_DIV    = 4
)(
    input  logic                  clk,
    input  logic                  rst_n,

    input  logic                  start,
    input  logic [DATA_WIDTH-1:0] tx_data,

    input  logic                  miso,

    output logic                  sclk,
    output logic                  cs_n,
    output logic                  mosi,

    output logic [DATA_WIDTH-1:0] rx_data,
    output logic                  busy,
    output logic                  done
);

    // ---------------------------------------------------------
    // Counter widths
    // ---------------------------------------------------------
    localparam int DIV_WIDTH =
        (CLK_DIV <= 1) ? 1 : $clog2(CLK_DIV);

    localparam int BIT_CNT_WIDTH =
        (DATA_WIDTH <= 1) ? 1 : $clog2(DATA_WIDTH + 1);


    // ---------------------------------------------------------
    // Internal signals
    // ---------------------------------------------------------
    logic [DIV_WIDTH-1:0]     clk_count;
    logic [BIT_CNT_WIDTH-1:0] bit_count;

    logic [DATA_WIDTH-1:0] tx_shift;
    logic [DATA_WIDTH-1:0] rx_shift;


    // ---------------------------------------------------------
    // SPI MASTER
    //
    // SPI MODE 0:
    // CPOL = 0
    // CPHA = 0
    //
    // Rising edge  -> sample MISO
    // Falling edge -> change MOSI
    // ---------------------------------------------------------
    always_ff @(posedge clk) begin

        // -----------------------------------------------------
        // RESET
        // -----------------------------------------------------
        if (!rst_n) begin

            clk_count <= '0;
            bit_count <= '0;

            tx_shift <= '0;
            rx_shift <= '0;
            rx_data  <= '0;

            sclk <= 1'b0;
            cs_n <= 1'b1;
            mosi <= 1'b0;

            busy <= 1'b0;
            done <= 1'b0;
        end

        else begin

            // done is only a one-clock pulse
            done <= 1'b0;


            // =================================================
            // IDLE STATE
            // =================================================
            if (!busy) begin

                sclk      <= 1'b0;
                cs_n      <= 1'b1;
                clk_count <= '0;
                bit_count <= '0;

                // Start new SPI transaction
                if (start) begin

                    busy <= 1'b1;
                    cs_n <= 1'b0;

                    tx_shift <= tx_data;
                    rx_shift <= '0;

                    // MSB first
                    mosi <= tx_data[DATA_WIDTH-1];
                end
            end


            // =================================================
            // TRANSFER STATE
            // =================================================
            else begin

                // SPI clock divider
                if (clk_count == CLK_DIV-1) begin

                    clk_count <= '0;


                    // -----------------------------------------
                    // SCLK currently LOW
                    // Generate RISING EDGE
                    // -----------------------------------------
                    if (sclk == 1'b0) begin

                        sclk <= 1'b1;

                        // Sample MISO on rising edge
                        rx_shift <= {
                            rx_shift[DATA_WIDTH-2:0],
                            miso
                        };

                        bit_count <= bit_count + 1'b1;
                    end


                    // -----------------------------------------
                    // SCLK currently HIGH
                    // Generate FALLING EDGE
                    // -----------------------------------------
                    else begin

                        sclk <= 1'b0;

                        // All bits already received
                        if (bit_count == DATA_WIDTH) begin

                            cs_n <= 1'b1;
                            busy <= 1'b0;
                            done <= 1'b1;

                            rx_data <= rx_shift;

                            mosi <= 1'b0;
                        end

                        // Send next MOSI bit
                        else begin

                            tx_shift <= {
                                tx_shift[DATA_WIDTH-2:0],
                                1'b0
                            };

                            mosi <= tx_shift[DATA_WIDTH-2];
                        end
                    end
                end

                else begin
                    clk_count <= clk_count + 1'b1;
                end
            end
        end
    end

endmodule