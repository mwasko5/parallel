`timescale 1ns / 1ps

module thread_top (
    input logic CLK,
    input logic RST_N,
    
    input logic [7:0] READ_ADDR_A,
    input logic [7:0] READ_ADDR_B,
    input logic [7:0] WRITE_ADDR,
    input logic [1:0] OP_SEL,
    
    input logic WRITE_EN,
    
    input logic         EXT_WRITE_SEL, // 1 = Write External Data, 0 = Write SIMT Data
    input logic [255:0] EXT_WRITE_DATA, 
    
    output logic [255:0] SIMT_OUT_DATA // Renamed for clarity
);

    logic [255:0] read_data_a_s;
    logic [255:0] read_data_b_s;
    logic [255:0] write_back_data_s;

    assign write_back_data_s = EXT_WRITE_SEL ? EXT_WRITE_DATA : SIMT_OUT_DATA;

    vector_register_file vrf_1 (
        .CLK(CLK),
        .RST_N(RST_N),

        .READ_ADDR_A(READ_ADDR_A),
        .READ_DATA_A(read_data_a_s),

        .READ_ADDR_B(READ_ADDR_B),
        .READ_DATA_B(read_data_b_s),

        .WRITE_ADDR(WRITE_ADDR),
        .WRITE_EN(WRITE_EN),
        .WRITE_DATA(write_back_data_s)
    );

    simt_unit simt_unit_1 (
        .READ_A(read_data_a_s), 
        .READ_B(read_data_b_s),
        .OP_SEL(OP_SEL),

        .WRITE(SIMT_OUT_DATA)
    );

endmodule