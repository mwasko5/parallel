`timescale 1ns / 1ps

module alu #(
    parameter int DATA_WIDTH = 32
) (
    input  logic [DATA_WIDTH - 1:0] IN_A, IN_B,
    input  logic SELECT,

    output logic [DATA_WIDTH - 1:0] OUT
);

    always_comb begin
        case (SELECT)
            1'b0:
                OUT = IN_A + IN_B;
            1'b1:
                OUT = IN_A - IN_B;
            default:
                OUT = IN_A + IN_B;
        endcase
    end
endmodule
