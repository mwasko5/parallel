`timescale 1ns / 1ps

// CURRENT # WARPS: 8 (output width of vector register file must be #_WARPS * 32)

module vector_register_file (
    input  logic           CLK,
    input  logic           RST_N,

    // --- Read Port A (Source Operand 1) ---
    input  logic [7:0]     READ_ADDR_A,
    output logic [255:0]   READ_DATA_A,

    // --- Read Port B (Source Operand 2) ---
    input  logic [7:0]     READ_ADDR_B,
    output logic [255:0]   READ_DATA_B,

    // --- Write Port (Unmasked) ---
    input  logic [7:0]     WRITE_ADDR,
    input  logic           WRITE_EN,
    input  logic [255:0]   WRITE_DATA
);

    // -------------------------------------------------------------------------
    // Memory array declaration
    // 256-bit wide vectors, 256 rows deep (8 warps * 32 registers)
    // -------------------------------------------------------------------------
    logic [255:0] vrf_mem_s [0:255];

    integer i;

    initial begin
        for (i = 0; i < 256; i++) begin
            vrf_mem_s[i] = 0;
        end
    end

    // -------------------------------------------------------------------------
    // Synchronous read and write logic
    // -------------------------------------------------------------------------
    always_ff @(posedge CLK) begin
        
        // synchronous reads
        READ_DATA_A <= vrf_mem_s[READ_ADDR_A];
        READ_DATA_B <= vrf_mem_s[READ_ADDR_B];

        // unmasked write (writes the entire 256-bit vector at once)
        if (WRITE_EN) begin
            vrf_mem_s[WRITE_ADDR] <= WRITE_DATA;
        end
    end

endmodule