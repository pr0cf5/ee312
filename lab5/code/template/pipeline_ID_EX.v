module ID_EX(
	input wire CLK,
	input wire RSTn,
	input wire latchn,
	input wire[31:0] regVal1_i,
	input wire[31:0] regVal2_i,
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
	input wire isJtype_i,
	input wire probablyHalt_i,
	input wire[6:0] opcode_i,
	input wire[6:0] funct7_i,
	input wire[11:0] pc_i,
	input wire[31:0] branchPc_i,
	input wire bpr_i,
	input wire flush_i,
	output wire[31:0] regVal1_o,
	output wire[31:0] regVal2_o,
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
	output wire isJtype_o,
	output wire probablyHalt_o,
	output wire[6:0] opcode_o,
	output wire[6:0] funct7_o,
	output wire[11:0] pc_o,
	output wire[31:0] branchPc_o,
	output wire bpr_o,
	output wire flush_o
);

	reg[31:0] regVal1_r;
	reg[31:0] regVal2_r;
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
	reg isJtype_r;
	reg probablyHalt_r;
	reg[6:0] opcode_r;
	reg[6:0] funct7_r;
	reg[11:0] pc_r;
	reg[31:0] branchPc_r;
	reg bpr_r;
	reg flush_r;

	assign regVal1_o = regVal1_r;
	assign regVal2_o = regVal2_r;
	assign opType_o = opType_r;
	assign rd_o = rd_r;
	assign rs1_o = rs1_r;
	assign rs2_o = rs2_r;
	assign aluOp1_o = aluOp1_r;
	assign aluOp2_o = aluOp2_r;
	assign imm_o = imm_r;
	assign isBtype_o = flush_r ? 1'b0 : isBtype_r;
	assign isItype_o = flush_r ? 1'b0 : isItype_r;
	assign isRtype_o = flush_r ? 1'b0 : isRtype_r;
	assign isStype_o = flush_r ? 1'b0 : isStype_r;
	assign isJtype_o = flush_r ? 1'b0 : isJtype_r;
	assign probablyHalt_o = flush_r ? 1'b0 : probablyHalt_r;
	assign opcode_o = opcode_r;
	assign funct7_o = funct7_r;
	assign pc_o = pc_r;
	assign branchPc_o = branchPc_r;
	assign bpr_o = bpr_r;
	assign flush_o = flush_r;

	// commit values synchronized to clock
	always @(posedge CLK) begin
		if (RSTn & (~latchn)) begin
			regVal1_r <= regVal1_i;
			regVal2_r <= regVal2_i;
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
			isJtype_r <= isJtype_i;
			probablyHalt_r <= probablyHalt_i;
			opcode_r <= opcode_i;
			funct7_r <= funct7_i;
			pc_r <= pc_i;
			branchPc_r <= branchPc_i;
			bpr_r <= bpr_i;
			flush_r <= flush_i;
		end
	end

	initial begin
		flush_r <= 1;
	end

endmodule