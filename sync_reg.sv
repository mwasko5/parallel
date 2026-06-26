`timescale 1ns / 1ps

module sync_reg #(
    parameter int DATA_WIDTH = 32
)(
    input logic CLK,
    input logic RST_N,
    
    input  logic [DATA_WIDTH - 1:0] IN,
    output logic [DATA_WIDTH - 1:0] OUT
);
    
    logic [DATA_WIDTH - 1:0] in_s1;
    
    always_ff @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            in_s1 <= '0;
        end else begin
            in_s1 <= IN;
        end
    end
    
    always_comb begin
        OUT = in_s1;
    end
endmodule