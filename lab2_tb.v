`timescale 1ns / 1ps

module lab2_tb;
    reg clk_i;
    reg rst_i;
    reg [7:0] a_i;
    reg [7:0] b_i;
    reg start_i;
    wire busy_o;
    wire [3:0] y_bo;
    
    lab2 lab2_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .a_i(a_i),
        .b_i(b_i),
        .start_i(start_i),
        .busy_o(busy_o),
        .y_bo(y_bo)
    );

    task test_lab2;
        input [3:0] test_n;
        input [7:0] a;
        input [7:0] b;
        input [3:0] expected_out;
        begin
            #100
            rst_i = 1;
            #20
            rst_i = 0;
            #10
            a_i = a;
            b_i = b;
            start_i = 1;
            #20
            start_i = 0;
            while (busy_o) begin
                #1;
            end
            if (y_bo == expected_out) begin
                $display ( "Test ", test_n, " passed.", " , a =", a, " , b=", b, " y=", y_bo, " , y_exp =" , expected_out);
            end 
            else begin 
                $display ( "Test ", test_n, " failed.", " , a =", a, " , b=", b, " y=", y_bo, " , y_exp =" , expected_out);
            end
        end
    endtask
    
    initial begin
        clk_i = 0;
        rst_i = 1;
        # 10
        rst_i = 0;
        test_lab2(1, 0, 0, 0);
        test_lab2(2, 1, 1, 1);
        test_lab2(3, 200, 60, 5);
        test_lab2(4, 0, 255, 2);
        test_lab2(5, 255, 255, 6);
        test_lab2(6, 255, 0, 6);
        test_lab2(7, 230, 194, 6);
        test_lab2(8, 50, 100, 3);  
        test_lab2(9, 50, 255, 4);
        test_lab2(10, 99, 30, 4);
    end

    always begin
        #5
        clk_i = !clk_i;
    end

endmodule