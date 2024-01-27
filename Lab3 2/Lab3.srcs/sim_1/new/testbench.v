`timescale 1ns / 1ps

module testbench();
    reg clk;
    wire [31:0] pc;
    wire [31:0] dinstOut;
    wire ewreg, em2reg, ewmem, ealuimm;
    wire [3:0] ealuc;
    wire [4:0] edestReg;
    wire [31:0] eqa;
    wire [31:0] eqb;
    wire [31:0] eimm32;
    wire mwreg;
    wire mm2reg;
    wire mwmem;
    wire [4:0] mdestReg;
    wire [31:0] mr;
    wire [31:0] mqb;
    wire wwreg;
    wire wm2reg;
    wire [4:0] wdestReg;
    wire [31:0] wr;
    wire [31:0] wdo;
    wire [31:0] qa;
    wire [31:0] qb;
    
    datapath datapath_tb(clk, pc, dinstOut, ewreg, em2reg, ewmem, ealuc, ealuimm, edestReg, eqa, eqb, eimm32,
    mwreg, mm2reg, mwmem, mdestReg, mr, mqb, wwreg, wm2reg, wdestReg, wr, wdo, qa, qb);
    initial begin
        clk = 0;
    end
    always begin
        #10 clk = ~clk;
    end
    
endmodule