`timescale 1ns/1ps
module control_tb;

    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;
    
    MainControl mc (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .Branch(Branch),
        .ALUOp(ALUOp)
    );

    ALUControl ac (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );


    task apply;
        input [31:0] name;
        input [6:0] op;
        input [2:0] f3;
        input [6:0] f7;
        begin
            opcode = op;
            funct3 = f3;
            funct7 = f7;
            #10;
            $display("%s | RegW=%b ALUSrc=%b MemR=%b MemW=%b M2R=%b Br=%b ALUOp=%b ALUCtrl=%b",
                      name, RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp, ALUControl);
        end
    endtask

    initial begin
      
        $dumpfile("control_tb.vcd");
        $dumpvars(0, control_tb);

    
        apply("ADD ", 7'b0110011, 3'b000, 7'b0000000);
        apply("SUB ", 7'b0110011, 3'b000, 7'b0100000);
        apply("SLL ", 7'b0110011, 3'b001, 7'b0000000);
        apply("SRL ", 7'b0110011, 3'b101, 7'b0000000);
        apply("AND ", 7'b0110011, 3'b111, 7'b0000000);
        apply("OR  ", 7'b0110011, 3'b110, 7'b0000000);
        apply("XOR ", 7'b0110011, 3'b100, 7'b0000000);

    
        apply("ADDI", 7'b0010011, 3'b000, 7'b0000000);
        apply("ADDI", 7'b0010011, 3'b000, 7'b0100000); 
  
        apply("LW  ", 7'b0000011, 3'b010, 7'b0000000);
        apply("LH  ", 7'b0000011, 3'b001, 7'b0000000);
        apply("LB  ", 7'b0000011, 3'b000, 7'b0000000);


        apply("SW  ", 7'b0100011, 3'b010, 7'b0000000);
        apply("SH  ", 7'b0100011, 3'b001, 7'b0000000);
        apply("SB  ", 7'b0100011, 3'b000, 7'b0000000);

        apply("BEQ ", 7'b1100011, 3'b000, 7'b0000000);

        $finish;
    end

endmodule