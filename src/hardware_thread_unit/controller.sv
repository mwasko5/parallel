`timescale 1ns / 1ps

// This module decodes instructions

module controller (
    input  logic [31:0] INST_IN,          // 32-bit instruction from CPU/Memory
    
    // Outputs mapped to your thread_top.sv inputs
    output logic [7:0]  READ_ADDR_A,
    output logic [7:0]  READ_ADDR_B,
    output logic [7:0]  WRITE_ADDR,
    output logic [1:0]  OP_SEL,
    output logic        WRITE_EN,
    output logic        EXT_WRITE_SEL
);

    // Internal wires for instruction fields
    logic [5:0] opcode;
    logic [7:0] dest_reg;
    logic [7:0] src_a_reg;
    logic [7:0] src_b_reg;

    // Field slicing (Hardwired routing - zero latency)
    assign opcode    = INST_IN[31:26];
    assign dest_reg  = INST_IN[25:18];
    assign src_a_reg = INST_IN[17:10];
    assign src_b_reg = INST_IN[9:2];

    // Route register addresses directly
    assign READ_ADDR_A = src_a_reg;
    assign READ_ADDR_B = src_b_reg;
    assign WRITE_ADDR  = dest_reg;

    // Control Signal Generation
    always_comb begin
        // Default assignments to prevent latches
        OP_SEL        = 2'b00;
        WRITE_EN      = 1'b0;
        EXT_WRITE_SEL = 1'b0;

        case (opcode)
            6'b000001: begin // V_ADD
                OP_SEL   = 2'b00;
                WRITE_EN = 1'b1;
            end
            
            6'b000010: begin // V_SUB
                OP_SEL   = 2'b01;
                WRITE_EN = 1'b1;
            end
            
            6'b000011: begin // V_MUL
                OP_SEL   = 2'b10;
                WRITE_EN = 1'b1;
            end
            
            6'b100000: begin // LDR_EXT (CPU writing to VRF)
                WRITE_EN      = 1'b1;
                EXT_WRITE_SEL = 1'b1;
            end
            
            default: begin // NOP or Unknown
                WRITE_EN = 1'b0;
            end
        endcase
    end

endmodule