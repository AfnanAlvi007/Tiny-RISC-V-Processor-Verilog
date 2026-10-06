//program counter
module Program_Counter(clk,reset,PC_in,PC_out);
    input clk,reset;
    input [31:0] PC_in;
    output reg [31:0] PC_out;
    always @(posedge clk or posedge reset)
    begin
        if(reset)
        PC_out <= 32'b0;
        else
        PC_out <=PC_in;
    end
endmodule
 
 //PC+4

 module PCplus4(fromPC, NextoPC);
 input [31:0] fromPC;
 output [31:0] NextoPC;
 assign NextoPC = 4 + fromPC;
endmodule

// Instruction Memory

module Instruction_Memory(clk,reset,read_address,instruction_out);
input clk,reset;
input [31:0] read_address;
output [31:0] instruction_out;
integer k;
reg [31:0] I_Mem[63:0]; // 64 words of 32 bits
assign instruction_out = I_Mem[read_address[31:2]];
 
always @(posedge clk or posedge reset)
begin 
    if(reset)
    begin
        for(k=0;k<64;k=k+1) begin
            I_Mem[k] <=32'b00;
        end

        // R-type
        I_Mem[0]  <= 32'b00000000000000000000000000000000; // no operation
        I_Mem[1]  <= 32'b0000000_11001_10000_000_01101_0110011; // add x13, x16, x25
        I_Mem[2]  <= 32'b0100000_00011_01000_000_00101_0110011; // sub x5, x8, x3
        I_Mem[3]  <= 32'b0000000_00011_00010_111_00001_0110011; // and x1, x2, x3
        I_Mem[4]  <= 32'b0000000_00101_00011_110_00100_0110011; // or x4, x3, x5
        // I-type
        I_Mem[5]  <= 32'b000000000011_10101_000_10110_0010011; // addi x22, x21, 3
        I_Mem[6]  <= 32'b000000000001_01000_110_01001_0010011; // ori x9, x8, 1
        // L-type
        I_Mem[7]  <= 32'b000000001111_00101_010_01000_0000011; // lw x8, 15(x5)
        I_Mem[8]  <= 32'b000000000011_00011_010_01001_0000011; // lw x9, 3(x3)
        // S-type
        I_Mem[9]  <= 32'b0000000_01111_00101_010_01100_0100011; // sw x15, 12(x5)
        I_Mem[10] <= 32'b0000000_01110_00110_010_01010_0100011; // sw x14, 10(x6)
        // SB-type
        I_Mem[11] <= 32'h00948663; // beq x9, x9, 12
    end
end
endmodule

//Register File
module Reg_File(clk,reset,Rs1,Rs2,Rd,Write_data,read_data1,read_data2,RegWrite);
input clk,reset,RegWrite;
input [4:0] Rs1,Rs2,Rd;
input [31:0] Write_data;
output [31:0] read_data1,read_data2;
integer k;
reg [31:0] Registers[31:0];
always @(posedge clk or posedge reset)
begin 
    if(reset)
    begin
        for(k=0;k<32;k=k+1) begin
            Registers[k] <= 32'b0;
        end
    end
    else if(RegWrite) begin
        Registers[Rd] <= Write_data;
    end
end
assign read_data1 = Registers[Rs1];
assign read_data2 = Registers[Rs2];
endmodule

// Immediate Generator
module Immgen(OPcode,instruction,ImmExt);

input [6:0] OPcode;
input [31:0] instruction;
output reg [31:0] ImmExt;

always @(*)
begin
        case(OPcode)
        7'b0000011: ImmExt = {{20{instruction[31]}} , instruction[31:20]}; // I-type
        7'b0010011: ImmExt = {{20{instruction[31]}} , instruction[31:20]}; // I-type (addi, ori)
         7'b0100011: ImmExt = {{20{instruction[31]}} , instruction[31:25], instruction[11:7]}; // S-type
         7'b1100011: ImmExt = {{20{instruction[31]}} , instruction[7], instruction[30:25], instruction[11:8], 1'b0}; // B-type
         default: ImmExt = 32'b0;
        endcase
end
endmodule

//Control Unit
module Control_Unit(instruction,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite);
 
input [6:0] instruction;
output reg Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite;
output reg [1:0] ALUOp;
always @(*)
begin
    case(instruction)
    7'b0110011 :{ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp} <= 8'b001000_10; //R-type
    7'b0010011 :{ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp} <= 8'b101000_11; //I-type (addi, ori)
    7'b0000011 :{ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp} <= 8'b111100_00; //I-type
    7'b0100011 :{ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp} <= 8'b100010_00; //S-type
    7'b1100011 :{ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp} <= 8'b000001_01; //B-type
    default    :{ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,Branch,ALUOp} <= 8'b000000_00;
    endcase
end
endmodule

//ALU
module ALU_unit(A,B,Control_in, ALU_result,zero);
input [31:0] A,B;
input [3:0] Control_in;
output reg zero;
output reg [31:0] ALU_result;

always @(Control_in, A, B)
begin
    case(Control_in)
        4'b0000: begin zero<=0; ALU_result <= A & B; end //AND
        4'b0001: begin zero<=0; ALU_result <= A | B; end //OR
        4'b0010: begin zero<=0; ALU_result <= A + B; end //ADD
        4'b0110: begin if(A==B) zero<=1; else zero<=0; ALU_result <= A - B; end //SUB
        default: begin zero<=0; ALU_result <= 32'b0; end
    endcase
end
endmodule

// ALU Control
module ALU_Control(ALUOp,fun7,fun3,Control_out);
input fun7;
input [2:0] fun3;
input [1:0] ALUOp;
output reg [3:0] Control_out;
always @(*)
begin
    casex({ALUOp,fun7,fun3})
         6'b00_?_???: Control_out <= 4'b0010; //ADD
         6'b01_?_???: Control_out <= 4'b0110; //SUB
         6'b10_0_000: Control_out <= 4'b0010; //ADD
         6'b10_1_000: Control_out <= 4'b0110; //SUB
         6'b10_0_111: Control_out <= 4'b0000; //AND
         6'b10_0_110: Control_out <= 4'b0001; //OR
         6'b11_?_000: Control_out <= 4'b0010; //ADDI
         6'b11_?_110: Control_out <= 4'b0001; //ORI
         default: Control_out <= 4'b0010;
endcase
end
endmodule

//Data Memory
module Data_Memory(clk,reset,MemRead,MemWrite,read_address,Write_data,MemData_out);
input clk,reset,MemRead,MemWrite;
input [31:0] read_address,Write_data;
output [31:0] MemData_out;
integer k;
reg [31:0] D_Memory[63:0];

always @(posedge clk or posedge reset)
begin 
    if(reset)
    begin
        for(k=0;k<64;k=k+1) begin
            D_Memory[k] <=32'b00;
        end
    end
    else if(MemWrite) begin
        D_Memory[read_address[31:2]] <= Write_data;
    end
end
assign MemData_out = (MemRead) ? D_Memory[read_address[31:2]] : 32'b00;
endmodule

//Multiplexers
module Mux1(sel1,A1,B1,Mux1_out);
input sel1;
input [31:0] A1,B1;
output [31:0] Mux1_out;
assign Mux1_out = (sel1==1'b0) ? A1 : B1;
endmodule
//Mux2
module Mux2(sel2,A2,B2,Mux2_out);
input sel2;
input [31:0] A2,B2;
output [31:0] Mux2_out;
assign Mux2_out = (sel2==1'b0) ? A2 : B2;
endmodule
//Mux3
module Mux3(sel3,A3,B3,Mux3_out);
input sel3;
input [31:0] A3,B3;
output [31:0] Mux3_out;
assign Mux3_out = (sel3==1'b0) ? A3 : B3;
endmodule

// AND logic
module AND_logic(Branch,zero,and_out);
input Branch,zero;
output and_out;
assign and_out = Branch & zero;
endmodule

//Adder
module Adder(in_1,in_2,Sum_out);

input [31:0] in_1,in_2;
output [31:0] Sum_out;
assign Sum_out =in_1 + in_2;
endmodule

// All modules instantiated here----=>

module top(clk,reset);
input clk,reset;

wire [31:0] PC_top, instruction_top, RD1_top,RD2_top,ImmExt_top, mux1_top,Sum_out_top,NextoPC_top, PCin_top, address_top,MemData_top,WriteBack_top;
wire RegWrite_top, ALUSrc_top, zero_top, branch_top, sel2_top, MemtoReg_top,MemWrite_top,MemRead_top;
wire [1:0] ALUOp_top;
wire [3:0] control_top;


// Program Counter
Program_Counter PC(.clk(clk),.reset(reset),.PC_in(PCin_top),.PC_out(PC_top));

// PC Adder
PCplus4 PC_Adder(.fromPC(PC_top),.NextoPC(NextoPC_top));

// Instruction Memory
Instruction_Memory Inst_Memory(.clk(clk),.reset(reset),.read_address(PC_top),.instruction_out(instruction_top));

//Register File
Reg_File Reg_File(.clk(clk),.reset(reset),.Rs1(instruction_top[19:15]),.Rs2(instruction_top[24:20]),.Rd(instruction_top[11:7]),.Write_data(WriteBack_top),.read_data1(RD1_top),.read_data2(RD2_top),.RegWrite(RegWrite_top));

// Immediate Generator
Immgen ImmGen(.OPcode(instruction_top[6:0]),.instruction(instruction_top),.ImmExt(ImmExt_top));

//Control Unit
Control_Unit Control_Unit(.instruction(instruction_top[6:0]),.Branch(branch_top),.MemRead(MemRead_top),.MemtoReg(MemtoReg_top),.ALUOp(ALUOp_top),.MemWrite(MemWrite_top),.ALUSrc(ALUSrc_top),.RegWrite(RegWrite_top));

// ALU Control
ALU_Control ALU_Control(.ALUOp(ALUOp_top),.fun7(instruction_top[30]),.fun3(instruction_top[14:12]),.Control_out(control_top));

// ALU
ALU_unit ALU(.A(RD1_top),.B(mux1_top),.Control_in(control_top),.ALU_result(address_top),.zero(zero_top));

//ALU Mux
Mux1 ALU_Mux(.sel1(ALUSrc_top),.A1(RD2_top),.B1(ImmExt_top),.Mux1_out(mux1_top));

// Adder
Adder Adder(.in_1(PC_top),.in_2(ImmExt_top),.Sum_out(Sum_out_top));

// AND Gate
AND_logic AND(.Branch(branch_top),.zero(zero_top),.and_out(sel2_top));

// MUX
Mux2 Adder_Mux(.sel2(sel2_top),.A2(NextoPC_top),.B2(Sum_out_top),.Mux2_out(PCin_top));

// Data Memory
Data_Memory Data_mem(.clk(clk),.reset(reset),.MemRead(MemRead_top),.MemWrite(MemWrite_top),.read_address(address_top),.Write_data(RD2_top),.MemData_out(MemData_top));

// MUX
Mux3 Memory_mux(.sel3(MemtoReg_top),.A3(address_top),.B3(MemData_top),.Mux3_out(WriteBack_top));

endmodule


// testbench
module tb_top;

reg clk,reset;
integer i;
top uut(.clk(clk),.reset(reset));

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0,tb_top);
    for (i = 0; i < 32; i = i + 1) $dumpvars(0, uut.Reg_File.Registers[i]);
    for (i = 0; i < 64; i = i + 1) $dumpvars(0, uut.Data_mem.D_Memory[i]);
    clk = 0;
    reset = 1;
    #12;
    reset = 0;
    // load program and data (reset clears the memories)
    // starting register values
    uut.Reg_File.Registers[16] = 10;
    uut.Reg_File.Registers[25] = 20;
    uut.Reg_File.Registers[8]  = 40;
    uut.Reg_File.Registers[3]  = 8;
    uut.Reg_File.Registers[2]  = 12;
    uut.Reg_File.Registers[21] = 7;
    uut.Reg_File.Registers[6]  = 16;
    uut.Reg_File.Registers[14] = 99;
    uut.Reg_File.Registers[15] = 55;
    // starting data memory values
    uut.Data_mem.D_Memory[2]  = 88;
    uut.Data_mem.D_Memory[11] = 77;
    #400;
    $display("x13=%0d x5=%0d x1=%0d x4=%0d x22=%0d x8=%0d x9=%0d",uut.Reg_File.Registers[13],uut.Reg_File.Registers[5],uut.Reg_File.Registers[1],uut.Reg_File.Registers[4],uut.Reg_File.Registers[22],uut.Reg_File.Registers[8],uut.Reg_File.Registers[9]);
    $display("Mem[11]=%0d Mem[6]=%0d",uut.Data_mem.D_Memory[11],uut.Data_mem.D_Memory[6]);
    $finish;
end

always begin
  #5  clk = ~clk;
end
endmodule