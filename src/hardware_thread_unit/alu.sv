`timescale 1ns / 1ps

module alu (
    input logic  [31:0] IN_A, IN_B,
    input logic  [1:0] OP_SEL,

    output logic [31:0] OUT
);

    always_comb begin
        case (OP_SEL)
            1'b00: // ADD
                OUT = IN_A + IN_B;
            1'b01: // SUB
                OUT = IN_A - IN_B;
            1'b10: // MUL
                OUT = IN_A[15:0] * IN_B[15:0];
            default:
                OUT = IN_A + IN_B;
        endcase
    end

endmodule