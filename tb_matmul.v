`timescale 1ns/1ps
module tb_matmul;
    parameter N = 3;
    parameter W = 32;
    reg [N*N*W-1:0] a, b;
    wire [N*N*W-1:0] c, shared_c;
    reg clk = 0;
    reg rst = 1;
    reg start = 0;
    wire busy, done;
    integer expected [0:N*N-1];
    integer i, j, k, s, cycles;
    reg signed [31:0] av, bv;

    matmul #(N, W) dut(a, b, c);
    matmul_shared9 #(W) shared_dut(
        clk, rst, start, a, b, shared_c, busy, done
    );
    always #5 clk = ~clk;

    task check_case;
        input integer case_number;
        begin
            for (i = 0; i < N; i = i+1)
                for (j = 0; j < N; j = j+1) begin
                    s = 0;
                    for (k = 0; k < N; k = k+1) begin
                        av = a[(i*N+k)*W +: W];
                        bv = b[(k*N+j)*W +: W];
                        s = s + av*bv;
                    end
                    expected[i*N+j] = s;
                end
            #1;
            for (i = 0; i < N*N; i = i+1)
                if ($signed(c[i*W +: W]) !== expected[i])
                    $fatal(1, "Combinational mismatch: case %0d index %0d",
                           case_number, i);
            @(negedge clk);
            start = 1;
            @(negedge clk);
            start = 0;
            cycles = 0;
            while (!done && cycles < N+1) begin
                @(negedge clk);
                cycles = cycles+1;
            end
            if (!done || cycles != N)
                $fatal(1, "Wrong completion time: %0d cycles", cycles);
            for (i = 0; i < N*N; i = i+1)
                if ($signed(shared_c[i*W +: W]) !== expected[i])
                    $fatal(1, "Shared mismatch: case %0d index %0d",
                           case_number, i);
            if (case_number == 1) begin
                $display("Verilog 3x3 result:");
                for (i = 0; i < N; i = i+1)
                    $display("%4d %4d %4d",
                        $signed(c[(i*N)*W +: W]),
                        $signed(c[(i*N+1)*W +: W]),
                        $signed(c[(i*N+2)*W +: W]));
                $display("9 shared multipliers: same result, %0d compute cycles",
                         cycles);
            end
            $display("Case %0d: combinational and shared PASS", case_number);
        end
    endtask

    initial begin
        a = 0;
        b = 0;
        @(negedge clk);
        rst = 0;
        for (i = 0; i < N*N; i = i+1) begin
            a[i*W +: W] = i+1;
            b[i*W +: W] = 9-i;
        end
        check_case(1);
        for (i = 0; i < N*N; i = i+1) begin
            a[i*W +: W] = i-4;
            b[i*W +: W] = (i%3)-1;
        end
        check_case(2);
        a = 0;
        check_case(3);
        $display("PASS: 27/27 outputs match the integer reference.");
        $finish;
    end
endmodule

