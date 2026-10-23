module ALUControl(
    input  [1:0] ALUOp,       
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg [3:0] ALUControl
);
    localparam ADD = 4'b0000;
    localparam SUB = 4'b0001;
    localparam AND = 4'b0010;
    localparam OR  = 4'b0011;
    localparam XOR = 4'b0100;
    localparam SLL = 4'b0101;
    localparam SRL = 4'b0110;

    always @(*) begin
        ALUControl = ADD;   

        case (ALUOp)
            2'b00: ALUControl = ADD;   
            2'b01: ALUControl = SUB;   

            2'b10: begin               
                case (funct3)
                    3'b000: begin
                        if (funct7[5] == 1)
                            ALUControl = SUB;
                        else
                            ALUControl = ADD;
                    end
                    3'b001: ALUControl = SLL;
                    3'b101: ALUControl = SRL;
                    3'b111: ALUControl = AND;
                    3'b110: ALUControl = OR;
                    3'b100: ALUControl = XOR;
                    default: ALUControl = ADD;
                endcase
            end

            2'b11: ALUControl = ADD;   
        endcase
    end
endmodule