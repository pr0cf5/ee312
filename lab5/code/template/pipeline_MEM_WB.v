module MEM_WB(
	input wire CLK,
	input wire[31:0] aluResult_i,
	input wire[4:0] rd_i,
	input wire[4:0] rs1_i,
	input wire[4:0] rs2_i,
	input wire isBtype_i,
	input wire isItype_i,
	input wire isRtype_i,
	input wire isStype_i,
	input wire[6:0] opcode_i,
	input wire[31:0] memWriteValue_i,
	input wire[31:0] memReadValue_i,
	output wire[31:0] aluResult_o,
	output wire[4:0] rd_o,
	output wire[4:0] rs1_o,
	output wire[4:0] rs2_o,
	output wire isBtype_o,
	output wire isItype_o,
	output wire isRtype_o,
	output wire isStype_o,
	output wire[6:0] opcode_o,
	output wire[31:0] memWriteValue_o,
	output wire[31:0] memReadValue_o
);

	reg[31:0] aluResult_r;
	reg[4:0] rd_r;
	reg[4:0] rs1_r;
	reg[4:0] rs2_r;
	reg isBtype_r;
	reg isItype_r;
	reg isRtype_r;
	reg isStype_r;
	reg[6:0] opcode_r;
	reg[31:0] memWriteValue_r;
	reg[31:0] memReadValue_r;

	assign aluResult_o = aluResult_r;
	assign rd_o = rd_r;
	assign rs1_o = rs1_r;
	assign rs2_o = rs2_r;
	assign isBtype_o = isBtype_r;
	assign isItype_o = isItype_r;
	assign isRtype_o = isRtype_r;
	assign isStype_o = isStype_r;
	assign opcode_o = opcode_r;
	assign memWriteValue_o = memWriteValue_r;
	assign memReadValue_o = memReadValue_r;

	// commit values synchronized to clock
	always @(posedge CLK) begin
		aluResult_r <= aluResult_i;
		rd_r <= rd_i;
		rs1_r <= rs1_i;
		rs2_r <= rs2_i;
		isBtype_r <= isBtype_i;
		isItype_r <= isItype_i;
		isRtype_r <= isRtype_i;
		isStype_r <= isStype_i;
		opcode_r <= opcode_i;
		memWriteValue_r <= memWriteValue_i;
		memReadValue_r <= memReadValue_i;
	end


endmodule