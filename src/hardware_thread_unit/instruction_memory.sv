`timescale 1ns / 1ps

module instruction_memory (
    input logic [31:0] ADDRESS,

    output logic [31:0] INSTRUCTION
);

    logic [31:0] memory_s [0:1023];

    integer i;

    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            memory_s[i] = 0;
        end

        // $readmemh("instruction_memory.mem", memory_s);
    end

    always_comb begin
        INSTRUCTION = memory_s[ADDRESS[11:2]]; // instruction is byte addressed
        // the least 2 significant bits address index into which of the 4 bytes in the 32 bit word
    end

endmodule