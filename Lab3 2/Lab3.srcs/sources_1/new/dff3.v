/*
`timescale 1ns / 1ps

module counter(input [31:0] nextPc, input clk, output reg [31:0] pc);
    initial begin
        pc = 32'd100;  
    end
    
    always @(posedge clk) begin
        pc <= nextPc;
    end
endmodule

module instructionmemory(input [31:0] pc, output reg [31:0] instOut);
    reg [31:0] memory [63:0];
    initial begin
        memory[0] = 32'hA00000AA;
        memory[1] = 32'h10000011;
        memory[2] = 32'h20000022;
        memory[3] = 32'h30000033;
        memory[4] = 32'h40000044;
        memory[5] = 32'h50000055;
        memory[6] = 32'h60000066;
        memory[7] = 32'h70000077;
        memory[8] = 32'h80000088;
        memory[9] = 32'h90000099;
        memory[25] = {6'b100011, 5'b00010, 5'b00001, 5'b00000, 5'b00000, 6'b000000}; // lw $v0, 00($at)
        memory[26] = {6'b100011, 5'b00011, 5'b00001, 5'b00000, 5'b00000, 6'b000100}; // lw $v1, 04($at)

    end
    always @(*) begin
           instOut <= memory[pc[7:2]]; 
    end

endmodule

module pcadder(input [31:0] pc, output reg [31:0] nextPc);
    always @(*) begin
        nextPc <= pc + 4;
    end
endmodule

module ifidpipelineregister(input [31:0] instOut, input clk, output reg [31:0] dinstOut);
    always @(posedge clk) begin
        dinstOut <= instOut;
    end
endmodule

module controlunit(input [5:0] opcode, input [5:0] func, output reg wreg, output reg m2reg, output reg wmem, 
output reg [3:0] aluc, output reg aluimm, output reg regrt);
    always @(*) begin
        case (opcode)
            6'b000000: // r type
            begin
                wreg <= 1'b1;
                m2reg <= 1'b0;
                wmem <= 1'b0;
                aluimm <= 1'b0;
                regrt <= 1'b0;
                
                case (func)
                    6'b100000: begin
                        aluc <= 4'b0010;
                    end
                endcase
            end
            6'b100011: // lw
            begin
                wreg <= 1'b0;
                m2reg <= 1'b1;
                wmem <= 1'b0;
                aluc <= 4'b0010;
                aluimm <= 1'b1;
                regrt <= 1'b1;
            end
            6'b101011: //sw
            begin
                wreg <= 1'b0;
                m2reg <= 1'bX; 
                wmem <= 1'b1;
                aluc <= 4'b0010;
                aluimm <= 1'b1;
                regrt <= 1'bX;
                
            end
        endcase
    end

endmodule

module regrtmultiplexer(input regrt, input [4:0] rd, input [4:0] rt, output reg [4:0] destReg);
    always @(*) begin
        if (regrt == 1) begin
            destReg <= rd;
        end
        else begin
            destReg <= rt;
        end
    end
endmodule

module registerfile(input [4:0] rs, input [4:0] rt, output reg [31:0] qa, output reg [31:0] qb);
    reg [31:0] registers [31:0];
    
    always @(*) begin
        qa <= registers[rs];
        qb <= registers[rt];
    end
    
endmodule

module immediateextender(input [15:0] imm, output reg [31:0] imm32);
    always @(*) begin
        imm32[15:0] <= imm;
        if (imm[15] == 1) begin
            imm32[31:16] <= 16'hFFFF;
        end
        else begin
            imm32[31:16] <= 16'h0000;
        end
     end
endmodule
    
module idexepipelineregister(input wreg, input m2reg, input wmem, input [3:0] aluc, input aluimm, input [5:0] destReg,
input [31:0] qa, input[31:0] qb, input [31:0] imm32, input clk, output reg ewreg, output reg em2reg, output reg ewmem,
output reg [3:0] ealuc, output reg ealuimm, output reg [4:0] edestReg, output reg [31:0] eqa, output reg [31:0] eqb, 
output reg [31:0] eimm32);
    always @(posedge clk) begin
        ewreg <= wreg;
        em2reg <= m2reg;
        ewmem <= wmem;
        ealuc <= aluc;
        ealuimm <= aluimm;
        edestReg <= destReg;
        eqa <= qa;
        eqb <= qb;
        eimm32 <= imm32;
    end
endmodule

module datapath (input clk, output wire [31:0] pc, output wire [31:0] dinstOut, output wire ewreg, output wire em2reg, output wire ewmem, 
output wire [3:0] ealuc, output wire ealuimm, output wire [4:0] edestReg, output wire [31:0] eqa, output wire [31:0] eqb, 
output wire [31:0] eimm32);
    wire [31:0] nextPc;
    wire [31:0] instOut;
    wire wreg, m2reg, wmem, aluimm, regrt;
    wire [3:0] aluc;
    wire [4:0] destReg;
    wire [31:0] qa;
    wire [31:0] qb;
    wire [31:0] imm32;
    counter counter1(.i0(nextPc),.i1(clk),.o(pc));
    
    instructionmemory instructionmemory1(.i0(pc),.o(instOut));
    
    pcadder pcadder1(.i(pc), .o(nextPc));
    
    ifidpipelineregister ifidpipelineregister1(.i0(instOut), .i1(clk), .o(dinstOut));
    
    controlunit controlunit1(.i0(dinstOut[31:26]), .i1(dinstOut[5:0]), .o0(wreg), .o1(m2reg), .o2(wmem), .o3(aluc),
    .o4(aluimm), .o5(regrt));
    
    regrtmultiplexer regrtmultiplexer1(.i0(regrt), .i1(dinstOut[15:11]), .i2(dinstOut[20:16]), .o(destReg));
    
    registerfile registerfile1(.i0(dinstOut[25:21]), .i1(dinstOut[20:16]), .o1(qa), .o2(qb));
    
    immediateextender immediateextender1(.i(dinstOut[15:0]),.o(imm32));
    
    idexepipelineregister idexepipelineregister1(.i0(wreg), .i1(m2reg), .i2(wmem), .i3(aluc), .i4(aluimm), .i5(destReg), .i6(qa),
    .i7(qb), .i8(imm32), .i9(clk), .o0(ewreg), .o1(em2reg), .o2(ewmem), .o3(ealuc), .o4(ealuimm), .o5(edestReg), .o6(eqa),
    .o7(eqb), .o8(eimm32));
    
endmodule

*/