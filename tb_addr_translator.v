`timescale 1ns/1ps
module tb_addr_translator;

reg clk = 0;
reg rst_n = 0;
reg scl = 1;
reg sda_drive = 1;
reg sda_en = 0;
wire sda;

assign sda = sda_en ? sda_drive : 1'bz;

wire scl_s1, scl_s2;
wire sda_s1, sda_s2;

i2c_addr_translator dut (
    .clk(clk),
    .reset(rst_n),
    .scl(scl),
    .sda(sda),
    .scl_s1(scl_s1),
    .sda_s1(sda_s1),
    .scl_s2(scl_s2),
    .sda_s2(sda_s2)
);

// Clock generation
always #5 clk = ~clk;
always #500 scl = ~scl;

// Stimulus
initial begin
    rst_n = 0;
    #100;
    rst_n = 1;

    // START condition
    #100; sda_drive = 1; sda_en = 1;
    #100; sda_drive = 0;

    // Address byte: 0x92
    @(negedge scl); sda_drive = 1; @(posedge scl); #100;
    @(negedge scl); sda_drive = 0; @(posedge scl); #100;
    @(negedge scl); sda_drive = 0; @(posedge scl); #100;
    @(negedge scl); sda_drive = 1; @(posedge scl); #100;
    @(negedge scl); sda_drive = 0; @(posedge scl); #100;
    @(negedge scl); sda_drive = 0; @(posedge scl); #100;
    @(negedge scl); sda_drive = 1; @(posedge scl); #100;
    @(negedge scl); sda_drive = 0; @(posedge scl); #100;

    // Data byte: 0xAB
    #1000; sda_en = 1;
    @(negedge scl); sda_drive = 1; @(posedge scl); #100;
    @(negedge scl); sda_drive = 0; @(posedge scl); #100;
    @(negedge scl); sda_drive = 1; @(posedge scl); #100;
    @(negedge scl); sda_drive = 0; @(posedge scl); #100;
    @(negedge scl); sda_drive = 1; @(posedge scl); #100;
    @(negedge scl); sda_drive = 0; @(posedge scl); #100;
    @(negedge scl); sda_drive = 1; @(posedge scl); #100;
    @(negedge scl); sda_drive = 1; @(posedge scl); #100;
    
    // Release SDA for ACK
    @(negedge scl); sda_drive = 0; sda_en = 1;
    
    // STOP condition: SDA goes high while SCL is high
    @(posedge scl); sda_drive = 1; sda_en = 1;
    
    #2000; sda_drive = 0;
    // Address byte: 0x90
    @(negedge scl); sda_drive = 1; @(posedge scl); #100;
    @(negedge scl); sda_drive = 0; @(posedge scl); #100;
    @(negedge scl); sda_drive = 0; @(posedge scl); #100;
    @(negedge scl); sda_drive = 1; @(posedge scl); #100;
    @(negedge scl); sda_drive = 0; @(posedge scl); #100;
    @(negedge scl); sda_drive = 0; @(posedge scl); #100;
    @(negedge scl); sda_drive = 0; @(posedge scl); #100;
    @(negedge scl); sda_drive = 0; @(posedge scl); #100;

    // Data byte: 0xAB
    #1000; sda_en = 1;
    @(negedge scl); sda_drive = 1; @(posedge scl); #100;
    @(negedge scl); sda_drive = 0; @(posedge scl); #100;
    @(negedge scl); sda_drive = 1; @(posedge scl); #100;
    @(negedge scl); sda_drive = 0; @(posedge scl); #100;
    @(negedge scl); sda_drive = 1; @(posedge scl); #100;
    @(negedge scl); sda_drive = 0; @(posedge scl); #100;
    @(negedge scl); sda_drive = 1; @(posedge scl); #100;
    @(negedge scl); sda_drive = 1; @(posedge scl); #100;
    
    // Release SDA for ACK
    @(negedge scl); sda_drive = 0; sda_en = 1;
    
    // STOP condition: SDA goes high while SCL is high
    @(posedge scl); sda_drive = 1; sda_en = 1;

    #5000;
    $finish;
end

endmodule
