`timescale 1ns / 1ps

module cuberoot(
    input clk_i,
    input rst_i,
    input [8:0] a_i,
    input start_i,
    output wire busy_o,
    output reg [3:0] y_bo
);

localparam IDLE = 0;
localparam WORK = 1;
localparam MUL1 = 2;
localparam MUL2 = 3;
localparam WAIT_MUL2 = 4;
localparam CHECK_X = 5;
localparam SUB_B = 6;

reg signed [15:0] s;

wire end_step;

reg [8:0] x;
reg [31:0] b, y, tmp1;
reg [4:0] state;


reg  [7:0] mult1_a;
reg  [7:0] mult1_b;

wire [15:0] mult1_y;
reg  mult1_start;
wire mult1_busy;

mul mul_inst(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .a_bi(mult1_a),
    .b_bi(mult1_b),
    .start_i(mult1_start),
    .busy_o(mult1_busy),
    .y_bo(mult1_y)
);

assign end_step = (s == 'hfffd); // s == -3
assign busy_o = (state != IDLE);

always @(posedge clk_i) begin
    if (rst_i) begin
        y_bo <= 0;
        s <= 0;
        mult1_start <= 0;
        state <= IDLE;
    end else begin
        case (state)
            IDLE:
                begin
                    if (start_i) begin
                        y_bo <= 0;
                        mult1_start <= 0;
                        state <= WORK;
                        x <= a_i;
                        s <= 'd30; // s = 30
                        y <= 0;
                    end
                end
            WORK:
                begin
                    if (end_step) begin
                        state <= IDLE;
                        y_bo <= y;
                    end else begin
                        y <= y << 1;
                        state <= MUL1;
                    end
                end
            MUL1:
                begin
                    tmp1 <= y << 1;
                    state <= MUL2;
                end
            MUL2:
                begin
                    mult1_a <= tmp1 + y;
                    mult1_b <= y + 1;
                    mult1_start <= 1;
                    state <= WAIT_MUL2;
                 end
            WAIT_MUL2:
                 begin
                    mult1_start <= 0;
                    if(~mult1_busy && ~mult1_start) begin
                        b <= mult1_y + 1 << s;
                        s <= s - 3;
                        state <= CHECK_X;
                    end
                end
            CHECK_X:
                begin
                    if (x >= b) begin
                        y <= y + 1;
                        state <= SUB_B;
                    end else begin
                        state <= WORK;
                    end
                end
            SUB_B:
                begin
                      x <= x + ~b + 1;
                      state <= WORK;
                end
        endcase
    end
end
endmodule