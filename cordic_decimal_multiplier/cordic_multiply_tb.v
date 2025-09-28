`timescale 1ns/1ps

module cordic_multiply_tb;

    // ===== Parameter Definitions =====
    parameter WL = 16;    // Word length
    parameter FL = 14;    // Fraction length
    parameter N_ITER = 15;

    // ===== Testbench Signals =====
    reg clk;
    reg rst_n;
    reg start;
    reg  signed [WL-1:0] in1;  // 
    reg  signed [WL-1:0] in2;   //
    wire signed [WL-1:0] out;   // 
    wire done;

    // ===== Instantiate the CORDIC Module =====
    cordic_multiply #(WL, FL, N_ITER) uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .in1(in1),
        .in2(in2),
        .out(out),
        .done(done)
    );

    // ===== Clock Generation =====
    always begin
        #5 clk = ~clk;  // 100 MHz clock
    end

    // ===== Testbench Procedure =====
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 1;
        start = 0;
        in1 = 16'sd0;
        in2 = 16'sd0;

        // Reset the DUT
        rst_n = 0;
        #10 rst_n = 1;
        
        // Test Case 1: 0 * 0.75
        in1 = 16'sd0;  // 0 in Q1.14 format
        in2 = 16'sb0011_0000_0000_0000;
        start = 1;
        #10 start = 0;
        
        // Wait for the calculation to finish
        wait(done);
        $display("Test 1 : 0 * 0.75 = %d", out);

        // Test Case 2: 0.5 * 0.5
        in1 = 16'sb0010_0000_0000_0000;
        in2 = 16'sb0010_0000_0000_0000; 
        #10 start = 1;
        #10 start = 0;
        
        // Wait for the calculation to finish
        wait(done);
        $display("Test 2 : 0.5 * 0.5 = %d", out);
        
        // Test Case 3: -0.5 * 0.5

        in1 =  16'sb0010_0000_0000_0000;
        in2 = -16'sb0010_0000_0000_0000; 
        #10 start = 1;
        #10 start = 0;
        
        // Wait for the calculation to finish
        wait(done);
        $display("Test 3 : -0.5 * 0.5 = %d", out);

        // Test Case 4: 1.9999 * 1.9999
        
        in1 = 16'sb0111_1111_1111_1111;
        in2 = 16'sb0111_1111_1111_1111;  
        #10 start = 1;
        #10 start = 0;
        
        // Wait for the calculation to finish
        wait(done);
        $display("Test 4 : 1.9999 * 1.9999 = %d", out);
        
        // Test Case 5: 1.9999 * -1.9999
        in1 =  16'sb0111_1111_1111_1111;
        in2 = -16'sb0111_1111_1111_1111;  
        #10 start = 1;
        #10 start = 0;
        
        // Wait for the calculation to finish
        wait(done);
        $display("Test 5 : 1.9999 * -1.9999 = %d", out);

        // End the simulation
        #10
        $finish;
    end

endmodule
