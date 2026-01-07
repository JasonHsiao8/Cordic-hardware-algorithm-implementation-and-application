//==============================================================================
// Module: cordic_multiply
// Description: CORDIC-based fixed-point multiplication using linear mode
//              Computes the product of two Q1.14 numbers without using
//              hardware multiplier
// Algorithm: Linear mode CORDIC (hyperbolic approximation)
// Format: Q1.14 fixed-point representation
// Author: Chia-Hung Hsiao
// Date: 2025/9/29
//==============================================================================
module cordic_multiply #(
    parameter WL = 16,      // Word length
    parameter FL = 14,      // Fractional length
    parameter N_ITER = 15   // Number of iterations
)(
    input  wire                clk,      // Clock signal
    input  wire                rst_n,    // Active-low reset
    input  wire                start,    // Start computation
    input  wire signed [WL-1:0] in1,     // First operand, Q1.14
    input  wire signed [WL-1:0] in2,     // Second operand, Q1.14
    output reg  signed [WL-1:0] out,     // Product output, Q1.14
    output reg                 done      // Computation complete flag
);

    //--------------------------------------------------------------------------
    // Internal registers
    //--------------------------------------------------------------------------
    reg signed [WL-1:0]   x;            // X accumulator (holds in1)
    reg signed [WL:0]     y;            // Y accumulator (product accumulator, extended by 1 bit)
    reg signed [WL-1:0]   z;            // Z accumulator (holds in2, decremented)
    reg        [4:0]      i;            // Iteration counter
    reg        [1:0]      state;        // Current FSM state
    reg        [1:0]      next_state;   // Next FSM state
    reg        [WL-1:0]   two;          // Constant 2.0 in Q1.14 format

    //--------------------------------------------------------------------------
    // State machine definitions
    //--------------------------------------------------------------------------
    localparam IDLE   = 2'd0;
    localparam APPROX = 2'd1;
    localparam DONE   = 2'd2;

    //--------------------------------------------------------------------------
    // FSM state register
    // Sequential logic for state transitions
    //--------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    //--------------------------------------------------------------------------
    // FSM next state logic
    // Combinational logic for determining next state
    //--------------------------------------------------------------------------
    always @(*) begin
        case (state)
            IDLE:    next_state = start ? APPROX : IDLE;
            APPROX:  next_state = (i == N_ITER-1) ? DONE : APPROX;
            DONE:    next_state = IDLE;
            default: next_state = IDLE;
        endcase 
    end

    //--------------------------------------------------------------------------
    // Main CORDIC multiplication computation
    // Implements shift-and-add algorithm to approximate multiplication
    // Uses the relationship: in1 × in2 ≈ Σ(±in1 × 2^-i) based on in2's bits
    //--------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset outputs and counter
            out <= 0;
            i   <= 0;
        end 
        else begin
            case (state)
                //--------------------------------------------------------------
                // IDLE state: Wait for start signal and initialize registers
                //--------------------------------------------------------------
                IDLE: begin
                    if (start) begin
                        x   <= in1;                         // Load first operand
                        y   <= 0;                           // Initialize product accumulator
                        z   <= in2;                         // Load second operand
                        two <= 16'sb0100_0000_0000_0000;    // Initialize 2.0 in Q1.14 (2^15/2^14 = 2)
                        i   <= 0;                           // Reset iteration counter
                    end
                end

                //--------------------------------------------------------------
                // APPROX state: Perform iterative approximation
                // Decomposes in2 into sum of powers of 2 and accumulates
                // corresponding scaled values of in1
                //--------------------------------------------------------------
                APPROX: begin
                    if (z[WL-1] == 0) begin
                        // Positive residual: add scaled x to product
                        y <= y + (x >>> i);
                        z <= z - (two >>> i);
                    end 
                    else begin
                        // Negative residual: subtract scaled x from product
                        y <= y - (x >>> i);
                        z <= z + (two >>> i);
                    end
                    i <= i + 1;  // Increment iteration counter
                end

                //--------------------------------------------------------------
                // DONE state: Latch final result
                // Divide by 2 (right shift by 1) to correct for Q format
                //--------------------------------------------------------------
                DONE: begin
                    out <= y[16:1];  // Extract Q1.14 result from extended accumulator
                end
            endcase
        end
    end

    //--------------------------------------------------------------------------
    // Done flag generation
    // Indicates when computation is complete
    //--------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            done <= 0;
        else begin
            case (state)
                IDLE:    done <= 0;
                DONE:    done <= 1;
                default: done <= done;
            endcase
        end
    end

endmodule
