module cordic #(parameter WL = 16, FL = 14, N_ITER = 15)(
    input      clk,
    input      rst_n,
    input      start,
    input      signed [WL-1:0] angle_in,   // Q1.14  [-π/2, π/2]
    output reg signed [WL-1:0] cos_out,    // Q1.14 
    output reg signed [WL-1:0] sin_out,    // Q1.14 
    output reg done
);

    // ===== Arctan LUT Declaration =====
    reg signed [WL-1:0] atan_table [0:N_ITER-1];

    // ===== Registers Definition =====
    reg signed [WL-1:0] x, y, z;
    reg [4:0] i;
    reg [1:0] state, next_state;

    // ====== STATE Declaration ======
    localparam IDLE = 2'd0, ROTATE = 2'd1, DONE = 2'd2;

    // ===== CORDIC Scaling Factor (K ≈ 0.60725) =====
    localparam signed [WL-1:0] K = 16'sd9949; // ≈ 0.60725 × 2^14

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)  state <= IDLE;
        else        state <= next_state;
    end

    always @(*) begin
    case (state)
        IDLE    : next_state = (start) ? ROTATE : IDLE;
        ROTATE  : next_state = (i == N_ITER-1) ? DONE : ROTATE;
        DONE    : next_state = IDLE;
        default :;
    endcase 
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cos_out <= 0;
            sin_out <= 0;
            i       <= 0;
            atan_table[0]  <= 16'sb0011_0010_0100_0100;   // atan(2^-0)  ≈ 45°      ≈ 0.78539
            atan_table[1]  <= 16'sb0001_1101_1010_1100;   // atan(2^-1)  ≈ 26.565°  ≈ 0.39383
            atan_table[2]  <= 16'sb0000_1111_1010_1110;   // atan(2^-2)  ≈ 14.036°  ≈ 0.24497
            atan_table[3]  <= 16'sb0000_0111_1111_0101;   // atan(2^-3)  ≈ 7.125°   ≈ 0.12435
            atan_table[4]  <= 16'sb0000_0011_1111_1111;   // atan(2^-4)  ≈ 3.576°   ≈ 0.06241
            atan_table[5]  <= 16'sb0000_0010_0000_0000;   // atan(2^-5)  ≈ 1.789°   ≈ 0.03122
            atan_table[6]  <= 16'sb0000_0001_0000_0000;   // atan(2^-6)  ≈ 0.895°   ≈ 0.01562
            atan_table[7]  <= 16'sb0000_0000_1000_0000;   // atan(2^-7)  ≈ 0.447°   ≈ 0.00780
            atan_table[8]  <= 16'sb0000_0000_0100_0000;   // atan(2^-8)  ≈ 0.224°   ≈ 0.00391
            atan_table[9]  <= 16'sb0000_0000_0010_0000;   // atan(2^-9)  ≈ 0.112°   ≈ 0.00195
            atan_table[10] <= 16'sb0000_0000_0001_0000;   // atan(2^-10) ≈ 0.056°   ≈ 0.00098
            atan_table[11] <= 16'sb0000_0000_0000_1000;   // atan(2^-11) ≈ 0.028°   ≈ 0.00049
            atan_table[12] <= 16'sb0000_0000_0000_0100;   // atan(2^-12) ≈ 0.014°   ≈ 0.00024
            atan_table[13] <= 16'sb0000_0000_0000_0010;   // atan(2^-13) ≈ 0.007°   ≈ 0.00012
            atan_table[14] <= 16'sb0000_0000_0000_0001;   // atan(2^-14) ≈ 0.0035°  ≈ 0.00006
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        x <= K;
                        y <= 0;
                        z <= angle_in;
                        i <= 0;
                    end
                end

                ROTATE: begin
                    if (z[WL-1] == 0) begin // positive 
                        x <= x - (y >>> i);
                        y <= y + (x >>> i);
                        z <= z - atan_table[i];
                        //state <= ((z - atan_table[i]) == 16'sd0) ? DONE : ROTATE;
                    end else begin
                        x <= x + (y >>> i);
                        y <= y - (x >>> i);
                        z <= z + atan_table[i];
                        //state <= ((z + atan_table[i]) == 16'sd0) ? DONE : ROTATE;
                    end
                    i <= i + 1;
                end

                DONE: begin
                    cos_out <= x;
                    sin_out <= y;
                end
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) done <= 0;
        else begin
            case (state)
                IDLE  : done <= 0;
                DONE  : done <= 1;
                default:; 
            endcase
        end
    end
endmodule
