`timescale 1ns / 1ps
module top_fsm_system (
    input wire clk,
    input wire pbin,
    input wire [15:0] physical_sw,
    output wire [15:0] physical_leds
);

   
    wire rst_clean;
    wire [31:0] switch_data;
    reg  [31:0] led_write_data = 32'd0;
    wire slow_clk;

    debouncer rst_db (
        .clk(clk),
        .pbin(pbin),
        .pbout(rst_clean)
    );

    leds switch_reader (
        .clk(clk), .rst(rst_clean),
        .btns(16'd0),
        .writeData(32'd0),
        .writeEnable(1'b0),
        .readEnable(1'b1),
        .memAddress(30'd0),
        .switches(physical_sw),
        .readData(switch_data)
    );

    switches led_writer (
        .clk(clk), .rst(rst_clean),
        .writeData(led_write_data),
        .writeEnable(1'b1),
        .readEnable(1'b0), .memAddress(30'd0),
        .readData(),
        .leds(physical_leds)
    );

    clock_divider ticker (
        .clk_in(clk),
        .rst(rst_clean),
        .clk_out(slow_clk)
    );

    reg slow_clk_d = 1'b0;
    always @(posedge clk) slow_clk_d <= slow_clk;
    wire tick = slow_clk & ~slow_clk_d;

    // ---------- Lab 9 parts ----------
    // saved copies of the switch fields
    reg [6:0] opcode_reg = 7'd0;
    reg [2:0] funct3_reg = 3'd0;
    reg       f7bit5_reg = 1'b0;

    // control outputs
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;
    wire [3:0] alu_ctrl;

    MainControl mc (
        .opcode(opcode_reg),
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
        .funct3(funct3_reg),
        .funct7({1'b0, f7bit5_reg, 5'b00000}),   // only bit 5 matters
        .ALUControl(alu_ctrl)
    );

    // ---------- FSM ----------
    localparam IDLE = 2'b00;
    localparam READ = 2'b01;
    localparam SHOW = 2'b10;

    reg [1:0] state = IDLE;

    always @(posedge clk) begin
        if (rst_clean) begin
            state          <= IDLE;
            led_write_data <= 32'd0;
        end else begin
            case (state)
                IDLE: begin
                    if (tick)                 // wait for the slow tick
                        state <= READ;
                end

                READ: begin                   // take a "photo" of the switches
                    opcode_reg <= switch_data[6:0];
                    funct3_reg <= switch_data[9:7];
                    f7bit5_reg <= switch_data[10];
                    state      <= SHOW;
                end

                SHOW: begin                   // put the results on the LEDs
                    led_write_data <= {20'd0, alu_ctrl, ALUOp,
                                       Branch, MemtoReg, MemWrite,
                                       MemRead, ALUSrc, RegWrite};
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule