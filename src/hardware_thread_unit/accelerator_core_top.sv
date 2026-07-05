`timescale 1ns / 1ps

// This module intersects the thread_top and controller
module accelerator_core_top (
    input logic CLK,
    input logic RST_N
);

    controller controller1 (
        .INST_IN(),          // 32-bit instruction from CPU/Memory
    
        // Outputs mapped to your thread_top.sv inputs
        .READ_ADDR_A(),
        .READ_ADDR_B(),
        .WRITE_ADDR(),
        .OP_SEL(),
        .WRITE_EN(),
        .EXT_WRITE_SEL()
    );

    thread_top thread_top1 (
        .CLK(CLK),
        .RST_N(RST_N),
    
        .READ_ADDR_A(),
        .READ_ADDR_B(),
        .WRITE_ADDR(),
        .OP_SEL(),
    
        .WRITE_EN(),
    
        .EXT_WRITE_SEL(), // 1 = Write External Data, 0 = Write SIMT Data
        .EXT_WRITE_DATA(), 
    
        .SIMT_OUT_DATA() // Renamed for clarity
    );

endmodule