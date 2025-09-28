module cordic_multiply #(parameter WL = 16, FL = 14, N_ITER = 15)(
    input      clk,
    input      rst_n,
    input      start,
    input      signed [WL-1:0] in1,    // Q1.14  
    input      signed [WL-1:0] in2,    // Q1.14  
    output reg signed [WL-1:0] out,    // Q1.14  
    output reg done
);

    // ===== Registers Definition =====
    reg signed [WL-1:0] x, z;
    reg signed [WL:0] y;
    reg [4:0] i;
    reg [1:0] state, next_state;
    reg [WL-1:0] two;

    // ====== STATE Declaration ======
    localparam IDLE = 2'd0, APPROX = 2'd1, DONE = 2'd2;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)  state <= IDLE;
        else        state <= next_state;
    end

    always @(*) begin
    case (state)
        IDLE    : next_state = (start) ? APPROX : IDLE;
        APPROX  : next_state = (i == N_ITER-1) ? DONE : APPROX;
        DONE    : next_state = IDLE;
        default :;
    endcase 
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out <= 0;
            i   <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        x <= in1;
                        y <= 0;
                        z <= in2;
                        two <= 16'sb0100_0000_0000_0000;
                        i <= 0;
                    end
                end

                APPROX: begin
                    if (z[WL-1] == 0) begin // positive 
                        y <= y + (x >>> i);
                        z <= z - (two >>> i); 
                    end else begin 
                        y <= y - (x >>> i);
                        z <= z + (two >>> i);
                    end
                    i <= i + 1;
                end

                DONE: begin
                    out <= y[16:1];
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
