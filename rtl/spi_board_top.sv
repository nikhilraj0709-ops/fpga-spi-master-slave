`timescale 1ns/1ps

module spi_board_top #(
    parameter int DATA_WIDTH     = 8,
    parameter int CLK_DIV        = 4,
    parameter int DEBOUNCE_COUNT = 1_000_000
)(
    input  logic        clk,
    input  logic [15:0] sw,
    input  logic [1:0]  btn,
    output logic [15:0] led
);

    localparam int DEBOUNCE_WIDTH =
        (DEBOUNCE_COUNT <= 1) ? 1 : $clog2(DEBOUNCE_COUNT);


    // =========================================================
    // RESET SYNCHRONIZER
    //
    // btn[0] pressed:
    //   asynchronous reset assertion
    //
    // btn[0] released:
    //   reset deassertion synchronized to system clock
    // =========================================================

    logic raw_rst_n;
    logic rst_n;

    (* ASYNC_REG = "TRUE" *)
    logic [1:0] rst_sync;

    assign raw_rst_n = ~btn[0];
    assign rst_n     = rst_sync[1];

    always_ff @(posedge clk or negedge raw_rst_n) begin

        if (!raw_rst_n) begin
            rst_sync <= 2'b00;
        end
        else begin
            rst_sync[0] <= 1'b1;
            rst_sync[1] <= rst_sync[0];
        end

    end


    // =========================================================
    // SWITCH SYNCHRONIZERS
    //
    // Board switches are asynchronous to 100 MHz system clock.
    // Two-stage synchronization reduces metastability risk.
    // =========================================================

    (* ASYNC_REG = "TRUE" *)
    logic [15:0] sw_meta;

    (* ASYNC_REG = "TRUE" *)
    logic [15:0] sw_sync;

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            sw_meta <= '0;
            sw_sync <= '0;

        end
        else begin

            sw_meta <= sw;
            sw_sync <= sw_meta;

        end

    end


    // =========================================================
    // START BUTTON SYNCHRONIZER
    // =========================================================

    (* ASYNC_REG = "TRUE" *)
    logic btn_start_meta;

    (* ASYNC_REG = "TRUE" *)
    logic btn_start_sync;

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            btn_start_meta <= 1'b0;
            btn_start_sync <= 1'b0;

        end
        else begin

            btn_start_meta <= btn[1];
            btn_start_sync <= btn_start_meta;

        end

    end


    // =========================================================
    // START BUTTON DEBOUNCE
    // =========================================================

    logic btn_start_debounced;

    logic [DEBOUNCE_WIDTH-1:0] debounce_counter;

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            debounce_counter    <= '0;
            btn_start_debounced <= 1'b0;

        end
        else begin

            if (btn_start_sync == btn_start_debounced) begin

                debounce_counter <= '0;

            end
            else begin

                if (debounce_counter == DEBOUNCE_COUNT-1) begin

                    btn_start_debounced <= btn_start_sync;
                    debounce_counter    <= '0;

                end
                else begin

                    debounce_counter <= debounce_counter + 1'b1;

                end

            end

        end

    end


    // =========================================================
    // START EDGE DETECTOR
    // =========================================================

    logic btn_start_prev;
    logic start_event;
    logic start_pulse;

    assign start_event =
        btn_start_debounced &
        ~btn_start_prev;


    // =========================================================
    // TRANSACTION DATA REGISTERS
    //
    // Switch values are captured before SPI transaction starts.
    // This prevents switch movement during an active transaction
    // from changing the transmitted byte.
    // =========================================================

    logic [DATA_WIDTH-1:0] master_tx_data;
    logic [DATA_WIDTH-1:0] slave_tx_data;

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            btn_start_prev <= 1'b0;

            master_tx_data <= '0;
            slave_tx_data  <= '0;

            start_pulse    <= 1'b0;

        end
        else begin

            btn_start_prev <= btn_start_debounced;

            // One-clock start pulse.
            //
            // Data is captured on start_event.
            // SPI core observes start_pulse on the following clock,
            // therefore TX data is already stable.
            start_pulse <= start_event;

            if (start_event) begin

                master_tx_data <= sw_sync[7:0];
                slave_tx_data  <= sw_sync[15:8];

            end

        end

    end


    // =========================================================
    // SPI RECEIVE DATA
    // =========================================================

    logic [DATA_WIDTH-1:0] master_rx_data;
    logic [DATA_WIDTH-1:0] slave_rx_data;


    // =========================================================
    // SPI CORE
    // =========================================================

    spi_top #(
        .DATA_WIDTH (DATA_WIDTH),
        .CLK_DIV    (CLK_DIV)
    ) u_spi_top (

        .clk            (clk),
        .rst_n          (rst_n),
        .start          (start_pulse),

        .master_tx_data (master_tx_data),
        .slave_tx_data  (slave_tx_data),

        .master_rx_data (master_rx_data),
        .slave_rx_data  (slave_rx_data),

        .busy           (),
        .master_done    (),
        .slave_done     (),

        .sclk           (),
        .cs_n           (),
        .mosi           (),
        .miso           ()

    );


    // =========================================================
    // LED DISPLAY
    //
    // led[7:0]  = byte received by slave
    // led[15:8] = byte received by master
    // =========================================================

    assign led[7:0]  = slave_rx_data;
    assign led[15:8] = master_rx_data;


endmodule
