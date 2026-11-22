`timescale 1ns/1ps

module spi_tb;

    localparam int DATA_WIDTH = 8;
    localparam int CLK_DIV    = 4;

    logic clk;
    logic rst_n;
    logic start;

    logic [DATA_WIDTH-1:0] master_tx_data;
    logic [DATA_WIDTH-1:0] slave_tx_data;

    logic [DATA_WIDTH-1:0] master_rx_data;
    logic [DATA_WIDTH-1:0] slave_rx_data;

    logic busy;
    logic master_done;
    logic slave_done;

    logic sclk;
    logic cs_n;
    logic mosi;
    logic miso;

    int total_checks;
    int pass_checks;
    int fail_checks;

    // Coverage closure values
    logic [DATA_WIDTH-1:0] cov_values [0:8];


    // =========================================================
    // DUT
    // =========================================================
    spi_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .CLK_DIV   (CLK_DIV)
    ) dut (
        .clk            (clk),
        .rst_n          (rst_n),
        .start          (start),

        .master_tx_data (master_tx_data),
        .slave_tx_data  (slave_tx_data),

        .master_rx_data (master_rx_data),
        .slave_rx_data  (slave_rx_data),

        .busy           (busy),
        .master_done    (master_done),
        .slave_done     (slave_done),

        .sclk           (sclk),
        .cs_n           (cs_n),
        .mosi           (mosi),
        .miso           (miso)
    );


    // =========================================================
    // ASSERTION MODULE
    // =========================================================
    spi_assertions assertions_i (
        .clk         (clk),
        .rst_n       (rst_n),
        .start       (start),
        .busy        (busy),
        .master_done (master_done),
        .cs_n        (cs_n),
        .sclk        (sclk)
    );


    // =========================================================
    // FUNCTIONAL COVERAGE MODULE
    // =========================================================
    spi_coverage #(
        .DATA_WIDTH(DATA_WIDTH)
    ) coverage_i (
        .clk            (clk),
        .rst_n          (rst_n),
        .master_done    (master_done),

        .master_tx_data (master_tx_data),
        .slave_tx_data  (slave_tx_data),

        .master_rx_data (master_rx_data),
        .slave_rx_data  (slave_rx_data)
    );


    // =========================================================
    // 100 MHz SYSTEM CLOCK
    // =========================================================
    always #5 clk = ~clk;


    // =========================================================
    // RESET TASK
    // =========================================================
    task automatic reset_dut();
        begin
            rst_n = 1'b0;
            start = 1'b0;

            master_tx_data = '0;
            slave_tx_data  = '0;

            repeat (5)
                @(posedge clk);

            rst_n = 1'b1;

            repeat (2)
                @(posedge clk);

            $display("------------------------------------------");
            $display("RESET COMPLETED");
            $display("------------------------------------------");
        end
    endtask


    // =========================================================
    // SPI TRANSACTION TASK
    // =========================================================
    task automatic run_spi_test(
        input logic [DATA_WIDTH-1:0] master_data,
        input logic [DATA_WIDTH-1:0] slave_data
    );

        begin

            master_tx_data = master_data;
            slave_tx_data  = slave_data;

            wait (busy == 1'b0);

            @(posedge clk);
            start = 1'b1;

            @(posedge clk);
            start = 1'b0;

            @(posedge master_done);

            @(posedge clk);


            // =================================================
            // CHECK MASTER -> SLAVE
            // =================================================
            total_checks++;

            if (slave_rx_data === master_data) begin

                pass_checks++;

                $display(
                    "[PASS] MASTER -> SLAVE | TX = 0x%02h | RX = 0x%02h",
                    master_data,
                    slave_rx_data
                );

            end
            else begin

                fail_checks++;

                $error(
                    "[FAIL] MASTER -> SLAVE | TX = 0x%02h | RX = 0x%02h",
                    master_data,
                    slave_rx_data
                );

            end


            // =================================================
            // CHECK SLAVE -> MASTER
            // =================================================
            total_checks++;

            if (master_rx_data === slave_data) begin

                pass_checks++;

                $display(
                    "[PASS] SLAVE -> MASTER | TX = 0x%02h | RX = 0x%02h",
                    slave_data,
                    master_rx_data
                );

            end
            else begin

                fail_checks++;

                $error(
                    "[FAIL] SLAVE -> MASTER | TX = 0x%02h | RX = 0x%02h",
                    slave_data,
                    master_rx_data
                );

            end


            repeat (3)
                @(posedge clk);

        end

    endtask


    // =========================================================
    // MAIN TEST
    // =========================================================
    initial begin

        clk = 1'b0;

        total_checks = 0;
        pass_checks  = 0;
        fail_checks  = 0;


        // =====================================================
        // COVERAGE CLOSURE DATA VALUES
        // =====================================================
        cov_values[0] = 8'h00;
        cov_values[1] = 8'hFF;
        cov_values[2] = 8'h20;
        cov_values[3] = 8'h48;
        cov_values[4] = 8'h55;
        cov_values[5] = 8'h80;
        cov_values[6] = 8'hAA;
        cov_values[7] = 8'hB0;
        cov_values[8] = 8'hE0;


        // Reset DUT
        reset_dut();


        $display("");
        $display("==========================================");
        $display("       SPI VERIFICATION STARTED");
        $display("==========================================");


        // =====================================================
        // DIRECTED TESTS
        // =====================================================

        $display("");
        $display("---------- DIRECTED TESTS ----------------");


        run_spi_test(
            8'hA5,
            8'h3C
        );


        run_spi_test(
            8'h55,
            8'hAA
        );


        run_spi_test(
            8'hFF,
            8'h00
        );


        run_spi_test(
            8'h00,
            8'hFF
        );


        // =====================================================
        // RANDOM TESTS
        // =====================================================

        $display("");
        $display("---------- RANDOM TESTS ------------------");


        for (int i = 0; i < 50; i++) begin

            run_spi_test(
                $urandom_range(0, 255),
                $urandom_range(0, 255)
            );

        end


        // =====================================================
        // COVERAGE CLOSURE TESTS
        // =====================================================

        $display("");
        $display("---------- COVERAGE CLOSURE TESTS --------");


        for (int i = 0; i < 9; i++) begin

            for (int j = 0; j < 9; j++) begin

                run_spi_test(
                    cov_values[i],
                    cov_values[j]
                );

            end

        end


        // =====================================================
        // FINAL TEST SUMMARY
        // =====================================================

        $display("");
        $display("==========================================");
        $display("          SPI TEST SUMMARY");
        $display("==========================================");

        $display("TOTAL CHECKS : %0d", total_checks);
        $display("PASS CHECKS  : %0d", pass_checks);
        $display("FAIL CHECKS  : %0d", fail_checks);


        if (fail_checks == 0) begin

            $display("------------------------------------------");
            $display("OVERALL RESULT : PASS");
            $display("------------------------------------------");

        end
        else begin

            $display("------------------------------------------");
            $display("OVERALL RESULT : FAIL");
            $display("------------------------------------------");

        end


        $display("==========================================");
        $display("       SPI VERIFICATION COMPLETED");
        $display("==========================================");


        #100;

        $finish;

    end

endmodule