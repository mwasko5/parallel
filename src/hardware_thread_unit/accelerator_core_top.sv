`timescale 1ns / 1ps

// This module intersects the thread_top and controller
module accelerator_core_top (
    input logic CLK,
    input logic RST_N,

    input logic [31:0] INSTRUCTION,

    output logic [31:0] EXT_WRITE_DATA,
    output logic [31:0] SIMT_OUT_DATA
);

    logic [7:0] read_addr_a_s;
    logic [7:0] read_addr_b_s;
    logic [7:0] write_addr_s;

    logic [1:0] op_sel_s;

    logic write_en_s;
    logic ext_write_sel_s;

    logic [255:0] ext_write_data_s;
    logic [255:0] simt_out_data_s;

    controller controller1 (
        .INST_IN(INSTRUCTION), // 32-bit instruction from CPU/Memory
    
        // Outputs mapped to your thread_top.sv inputs
        .READ_ADDR_A(read_addr_a_s),
        .READ_ADDR_B(read_addr_b_s),
        .WRITE_ADDR(write_addr_s),
        .OP_SEL(op_sel_s),
        .WRITE_EN(write_en_s),
        .EXT_WRITE_SEL(ext_write_sel_s)
    );

    thread_top thread_top1 (
        .CLK(CLK),
        .RST_N(RST_N),
    
        .READ_ADDR_A(read_addr_a_s),
        .READ_ADDR_B(read_addr_b_s),
        .WRITE_ADDR(write_addr_s),
        .OP_SEL(op_sel_s),
    
        .WRITE_EN(write_en_s),
    
        .EXT_WRITE_SEL(ext_write_sel_s), // 1 = Write External Data, 0 = Write SIMT Data
        .EXT_WRITE_DATA(ext_write_data_s), 
    
        .SIMT_OUT_DATA(simt_out_data_s) // Renamed for clarity
    );

    assign EXT_WRITE_DATA = ext_write_data_s[31:0]; 
    assign SIMT_OUT_DATA  = simt_out_data_s[31:0];

endmodule