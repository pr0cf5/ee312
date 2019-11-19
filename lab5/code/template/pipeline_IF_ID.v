module IF_ID(
	input wire CLK,
	input wire[2:0] opType_i,
	input wire[4:0] rd_i,
	input wire[4:0] rs1_i,
	input wire[4:0] rs2_i,
	input wire[2:0] aluOp1_i,
	input wire[2:0] aluOp2_i,
	input wire[11:0] imm_i,
	input wire isBtype_i,
	input wire isItype_i,
	input wire isRtype_i,
	input wire isStype_i,
	input wire[6:0] opcode_i,
	input wire[6:0] funct7_i,
	output wire[2:0] opType_o,
	output wire[4:0] rd_o,
	output wire[4:0] rs1_o,
	output wire[4:0] rs2_o,
	output wire[2:0] aluOp1_o,
	output wire[2:0] aluOp2_o,
	output wire[11:0] imm_o,
	output wire isBtype_o,
	output wire isItype_o,
	output wire isRtype_o,
	output wire isStype_o,
	output wire[6:0] opcode_o,
	output wire[6:0] funct7_o
);

	reg[2:0] opType_r;
	reg[4:0] rd_r;
	reg[4:0] rs1_r;
	reg[4:0] rs2_r;
	reg[2:0] aluOp1_r;
	reg[2:0] aluOp2_r;
	reg[11:0] imm_r;
	reg isBtype_r;
	reg isItype_r;
	reg isRtype_r;
	reg isStype_r;
	reg[6:0] opcode_r;
	reg[6:0] funct7_r;

	assign opType_o = opType_r;
	assign rd_o = rd_r;
	assign rs1_o = rs1_r;
	assign rs2_o = rs2_r;
	assign aluOp1_o = aluOp1_r;
	assign aluOp2_o = aluOp2_r;
	assign imm_o = imm_r;
	assign isBtype_o = isBtype_r;
	assign isItype_o = isItype_r;
	assign isRtype_o = isRtype_r;
	assign isStype_o = isStype_r;
	assign opcode_o = opcode_r;
	assign funct7_o = funct7_r;

	// commit values synchronized to clock
	always @(posedge CLK) begin
		opType_r <= opType_i;
		rd_r <= rd_i;
		rs1_r <= rs1_i;
		rs2_r <= rs2_i;
		aluOp1_r <= aluOp1_i;
		aluOp2_r <= aluOp2_i;
		imm_r <= imm_i;
		isBtype_r <= isBtype_i;
		isItype_r <= isItype_i;
		isRtype_r <= isRtype_i;
		isStype_r <= isStype_i;
		opcode_r <= opcode_i;
		funct7_r <= funct7_i;
	end


endmodule