`timescale 1ns / 1ps

module tb_thread_top;

    // -------------------------------------------------------------------------
    // Signal Declarations
    // -------------------------------------------------------------------------
    logic         CLK;
    logic         RST_N;

    logic [7:0]   READ_ADDR_A;
    logic [7:0]   READ_ADDR_B;
    logic [7:0]   WRITE_ADDR;
    logic [1:0]   OP_SEL;
    
    logic         WRITE_EN;
    logic         EXT_WRITE_SEL;
    logic [255:0] EXT_WRITE_DATA;

    logic [255:0] SIMT_OUT_DATA;

    // -------------------------------------------------------------------------
    // Unit Under Test (UUT) Instantiation
    // -------------------------------------------------------------------------
    thread_top uut (
        .CLK(CLK),
        .RST_N(RST_N),
        .READ_ADDR_A(READ_ADDR_A),
        .READ_ADDR_B(READ_ADDR_B),
        .WRITE_ADDR(WRITE_ADDR),
        .OP_SEL(OP_SEL),
        .WRITE_EN(WRITE_EN),
        .EXT_WRITE_SEL(EXT_WRITE_SEL),
        .EXT_WRITE_DATA(EXT_WRITE_DATA),
        .SIMT_OUT_DATA(SIMT_OUT_DATA)
    );

    // -------------------------------------------------------------------------
    // Clock Generation (100 MHz)
    // -------------------------------------------------------------------------
    always #5 CLK = ~CLK;

    // -------------------------------------------------------------------------
    // Helper Task: Peek directly into VRF Memory and Print
    // -------------------------------------------------------------------------
    task dump_vrf_row(input [7:0] addr, input string name);
        logic [255:0] row_data;
        begin
            // Hierarchical reference to probe the internal memory array directly
            row_data = uut.vrf_1.vrf_mem_s[addr];
            $display(">>> %s (VRF[%0d]):", name, addr);
            $display("    W7:%0d | W6:%0d | W5:%0d | W4:%0d | W3:%0d | W2:%0d | W1:%0d | W0:%0d",
                row_data[7*32 +: 32], row_data[6*32 +: 32],
                row_data[5*32 +: 32], row_data[4*32 +: 32],
                row_data[3*32 +: 32], row_data[2*32 +: 32],
                row_data[1*32 +: 32], row_data[0*32 +: 32]);
            $display("--------------------------------------------------------------------------------");
        end
    endtask

    // -------------------------------------------------------------------------
    // Helper Task: Load Data from External Bus into VRF
    // -------------------------------------------------------------------------
    task load_vector(input [7:0] addr, input [255:0] data);
        begin
            @(posedge CLK);
            EXT_WRITE_SEL  <= 1'b1;
            WRITE_EN       <= 1'b1;
            WRITE_ADDR     <= addr;
            EXT_WRITE_DATA <= data;
            
            @(posedge CLK);
            WRITE_EN       <= 1'b0;
        end
    endtask

    // -------------------------------------------------------------------------
    // Helper Task: Execute SIMT Operation
    // -------------------------------------------------------------------------
    task exec_op(input [1:0] op, input [7:0] src_a, input [7:0] src_b, input [7:0] dest);
        begin
            // Cycle 1: Present Read Addresses to the VRF
            @(posedge CLK);
            READ_ADDR_A   <= src_a;
            READ_ADDR_B   <= src_b;
            OP_SEL        <= op;     
            WRITE_EN      <= 1'b0;
            EXT_WRITE_SEL <= 1'b0; 

            // Cycle 2: Read data arrives at SIMT Unit; setup write-back
            @(posedge CLK);
            WRITE_ADDR    <= dest;
            WRITE_EN      <= 1'b1;
            
            // Cycle 3: Data is written to VRF. Clear control signals.
            @(posedge CLK);
            WRITE_EN      <= 1'b0;
        end
    endtask

    // -------------------------------------------------------------------------
    // Main Test Sequence
    // -------------------------------------------------------------------------
    initial begin
        // Setup waveform dumping for command-line simulators
        $dumpfile("simt_pipeline.vcd");
        $dumpvars(0, tb_thread_top);

        // Initialize Inputs
        CLK = 0;
        RST_N = 0;
        READ_ADDR_A = 0;
        READ_ADDR_B = 0;
        WRITE_ADDR = 0;
        OP_SEL = 0;
        WRITE_EN = 0;
        EXT_WRITE_SEL = 0;
        EXT_WRITE_DATA = 0;

        #100;
        @(posedge CLK);
        RST_N = 1;
        #10;

        $display("\n================================================================================");
        $display(" PHASE 1: LOADING INITIAL DATA");
        $display("================================================================================");
        
        load_vector(8'h00, {32'd8, 32'd7, 32'd6, 32'd5, 32'd4, 32'd3, 32'd2, 32'd1});
        load_vector(8'h01, {8{32'd10}});
        
        @(posedge CLK); // Buffer cycle
        dump_vrf_row(8'h00, "Initial Vector A");
        dump_vrf_row(8'h01, "Initial Vector B");


        $display("\n================================================================================");
        $display(" PHASE 2: EXECUTING SIMT PIPELINE");
        $display("================================================================================");
        
        // 1. ADD: VRF[0] + VRF[1] -> Store in VRF[2]
        exec_op(2'b00, 8'h00, 8'h01, 8'h02);
        @(posedge CLK); 
        dump_vrf_row(8'h02, "Result of ADD (Vector A + Vector B)");
        
        // 2. SUB: VRF[2] - VRF[0] -> Store in VRF[3]
        exec_op(2'b01, 8'h02, 8'h00, 8'h03);
        @(posedge CLK);
        dump_vrf_row(8'h03, "Result of SUB (VRF[2] - Vector A)");

        // 3. MUL: VRF[0] * VRF[1] -> Store in VRF[4]
        exec_op(2'b10, 8'h00, 8'h01, 8'h04);
        @(posedge CLK);
        dump_vrf_row(8'h04, "Result of MUL (Vector A * Vector B)");

        $display("\nSimulation Complete.\n");
        #50;
        $finish;
    end

endmodule