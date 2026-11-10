`timescale 1ns/1ps
// 3x3 integer matrix multiplication.
// The combinational design has N*N dot-product cells and N*N*N products.
module matmul #(
    parameter N = 3,
    parameter W = 32
) (
    input wire [N*N*W-1:0] a,
    input wire [N*N*W-1:0] b,
    output wire [N*N*W-1:0] c
);
    localparam SW = 2*W + $clog2(N);
    genvar i, j, k;
    generate
        for (i = 0; i < N; i = i+1) begin: rows
            for (j = 0; j < N; j = j+1) begin: cols
                wire signed [SW-1:0] sum [0:N];
                assign sum[0] = 0;
                for (k = 0; k < N; k = k+1) begin: products
                    wire signed [W-1:0] av;
                    wire signed [W-1:0] bv;
                    wire signed [2*W-1:0] product;
                    assign av = a[(i*N+k)*W +: W];
                    assign bv = b[(k*N+j)*W +: W];
                    assign product = av * bv;
                    assign sum[k+1] = sum[k] + product;
                end
                assign c[(i*N+j)*W +: W] = sum[N][W-1:0];
            end
        end
    endgenerate
endmodule

// Resource-sharing 3x3 version: nine multipliers, reused over three cycles.
// Inputs must remain stable from start until done.
module matmul_shared9 #(
    parameter W = 32
) (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [9*W-1:0] a,
    input wire [9*W-1:0] b,
    output reg [9*W-1:0] c,
    output reg busy,
    output reg done
);
    localparam N = 3;
    reg [1:0] k;
    genvar i, j;
    generate
        for (i = 0; i < N; i = i+1) begin: rows
            for (j = 0; j < N; j = j+1) begin: cols
                wire signed [2*W-1:0] product;
                wire signed [W-1:0] av;
                wire signed [W-1:0] bv;
                assign av = (k == 0) ? a[(i*N)*W +: W] :
                            (k == 1) ? a[(i*N+1)*W +: W] :
                                       a[(i*N+2)*W +: W];
                assign bv = (k == 0) ? b[j*W +: W] :
                            (k == 1) ? b[(N+j)*W +: W] :
                                       b[(2*N+j)*W +: W];
                assign product = av * bv;
                always @(posedge clk) begin
                    if (rst || (start && !busy))
                        c[(i*N+j)*W +: W] <= 0;
                    else if (busy)
                        c[(i*N+j)*W +: W] <=
                            c[(i*N+j)*W +: W] + product[W-1:0];
                end
            end
        end
    endgenerate

    always @(posedge clk) begin
        if (rst) begin
            k <= 0;
            busy <= 0;
            done <= 0;
        end else begin
            done <= 0;
            if (start && !busy) begin
                k <= 0;
                busy <= 1;
            end else if (busy) begin
                if (k == N-1) begin
                    busy <= 0;
                    done <= 1;
                end else
                    k <= k+1;
            end
        end
    end
endmodule

