`timescale 1ns / 1ps

// WARP SIZE = number of copies of this module
// contains ALU, multiplier, and FPU

module simt_unit (
    input  logic [255:0] READ_A, READ_B,
    input  logic [1:0]   OP_SEL,
    output logic [255:0] WRITE
);
    genvar i;

    generate // generate ALUs
        for (i = 0; i < 8; i++) begin : gen_alu
            alu alu_inst (
                .IN_A(READ_A[i*32 +: 32]),
                .IN_B(READ_B[i*32 +: 32]),
                .OP_SEL(OP_SEL),
                .OUT (WRITE[i*32 +: 32])
            );
        end
    endgenerate

    // generate multipliers

    // generate FPUs
endmodule