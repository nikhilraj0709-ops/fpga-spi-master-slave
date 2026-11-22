`timescale 1ns/1ps

module spi_slave #(
    parameter int DATA_WIDTH = 8
)(
    // System clock domain
    input  logic                  clk,
    input  logic                  rst_n,

    // SPI interface
    input  logic                  sclk,
    input  logic                  cs_n,
    input  logic                  mosi,
    output logic                  miso,

    input  logic [DATA_WIDTH-1:0] tx_data,
    output logic [DATA_WIDTH-1:0] rx_data,

    output logic                  done
);

    localparam int BIT_CNT_WIDTH =
        (DATA_WIDTH <= 1) ? 1 : $clog2(DATA_WIDTH);

    logic [DATA_WIDTH-1:0] rx_shift;
    logic [DATA_WIDTH-1:0] rx_shift_next;
    logic [DATA_WIDTH-1:0] tx_latched;

    logic [BIT_CNT_WIDTH-1:0] bit_count;

    logic sclk_d;
    logic active;

    logic sclk_rise;
    logic sclk_fall;


    // =========================================================
    // SCLK EDGE DETECTION
    //
    // SCLK is treated as DATA, not as an FPGA fabric clock.
    // Everything runs from the 100 MHz system clock.
    // =========================================================

    assign sclk_rise =  sclk & ~sclk_d;
    assign sclk_fall = ~sclk &  sclk_d;


    // =========================================================
    // NEXT RECEIVE VALUE
    // =========================================================

    always_comb begin

        rx_shift_next = rx_shift;

        rx_shift_next[
            DATA_WIDTH - 1 - bit_count
        ] = mosi;

    end


    // =========================================================
    // SINGLE-CLOCK SPI SLAVE
    //
    // SPI Mode 0:
    // CPOL = 0
    // CPHA = 0
    //
    // MOSI sampled on rising SCLK edge.
    // MISO advances after falling SCLK edge.
    // =========================================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            sclk_d      <= 1'b0;

            active      <= 1'b0;

            rx_shift    <= '0;
            rx_data     <= '0;

            tx_latched  <= '0;

            bit_count   <= '0;

            miso        <= 1'b0;
            done        <= 1'b0;

        end
        else begin

            // Save previous SCLK level
            sclk_d <= sclk;

            // DONE is a one-system-clock pulse
            done <= 1'b0;


            // =================================================
            // SPI NOT SELECTED
            // =================================================

            if (cs_n) begin

                active    <= 1'b0;
                bit_count <= '0;

                miso      <= 1'b0;

            end


            // =================================================
            // NEW SPI TRANSACTION
            // =================================================

            else if (!active) begin

                active     <= 1'b1;

                bit_count  <= '0;
                rx_shift   <= '0;

                // Capture slave transmit byte
                tx_latched <= tx_data;

                // Mode-0 first MISO bit must already be valid
                miso       <= tx_data[DATA_WIDTH-1];

            end


            // =================================================
            // ACTIVE SPI TRANSACTION
            // =================================================

            else begin

                // ---------------------------------------------
                // Rising SCLK:
                // Sample MOSI
                // ---------------------------------------------

                if (sclk_rise) begin

                    rx_shift <= rx_shift_next;

                    if (bit_count == DATA_WIDTH-1) begin

                        rx_data   <= rx_shift_next;

                        bit_count <= '0;
                        done      <= 1'b1;

                    end
                    else begin

                        bit_count <= bit_count + 1'b1;

                    end

                end


                // ---------------------------------------------
                // Falling SCLK:
                // Prepare next MISO bit
                // ---------------------------------------------

                if (sclk_fall) begin

                    if (bit_count < DATA_WIDTH) begin

                        miso <=
                            tx_latched[
                                DATA_WIDTH - 1 - bit_count
                            ];

                    end

                end

            end

        end

    end

endmodule