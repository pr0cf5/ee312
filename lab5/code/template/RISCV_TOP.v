module RISCV_TOP (
	//General Signals
	input wire CLK,
	input wire RSTn,

	//I-Memory Signals
	output wire I_MEM_CSN,
	input wire [31:0] I_MEM_DI,//input from IM
	output reg [11:0] I_MEM_ADDR,//in byte address

	//D-Memory Signals
	output wire D_MEM_CSN,
	input wire [31:0] D_MEM_DI,
	output wire [31:0] D_MEM_DOUT,
	output wire [11:0] D_MEM_ADDR,//in word address
	output wire D_MEM_WEN,
	output wire [3:0] D_MEM_BE,

	//RegFile Signals
	output wire RF_WE,
	output wire [4:0] RF_RA1,
	output wire [4:0] RF_RA2,
	output wire [4:0] RF_WA1,
	input wire [31:0] RF_RD1,
	input wire [31:0] RF_RD2,
	output wire [31:0] RF_WD,
	output wire HALT,                   // if set, terminate program
	output reg [31:0] NUM_INST,         // number of instruction completed
	output wire [31:0] OUTPUT_PORT      // equal RF_WD this port is used for test
	);

	assign OUTPUT_PORT = RF_WD;

	initial begin
		NUM_INST <= 0;
	end

	// Only allow for NUM_INST
	
	/*
	always @ (negedge CLK) begin
		if (RSTn) NUM_INST <= NUM_INST + 1;
	end
	*/

	// assign I_MEM_CSN and D_MEM_CSN to invert RSTn
	assign I_MEM_CSN = ~RSTn;
	assign D_MEM_CSN = ~RSTn;

	//TODO

	// variables i made
	reg [11:0] pc;
	wire [11:0] nextpc;

	wire [6:0] opcode;
	wire [2:0] funct3;
	wire [6:0] funct7;

	wire isRtype;
	wire isItype;
	wire isStype;
	wire isBtype;
	wire isUtype;
	wire isJtype;
	wire isALU;

	wire writeToReg;
	wire writeToMem;

	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [4:0] rd;

	// immediates
	wire[11:0] ItypeImm;
	wire[11:0] StypeImm;
	wire[12:0] BtypeImm;
	wire[31:0] UtypeImm;
	wire[20:0] JtypeImm;

	wire[11:0] imm;

	wire [2:0] aluOp1;
	wire [2:0] aluOp2;

	// halt handle
	wire probablyHalt;

	initial begin
		pc = 0;
	end

	
	// synchronize with clock and change pc

	always @(posedge CLK) begin
		if (RSTn) begin
			pc <= nextpc;
			I_MEM_ADDR <= nextpc;
		end
		else begin
			I_MEM_ADDR <= pc;
		end
	end

	// pc Mux control
	wire [2:0] pcSrc;

	reg [31:0] RF_WD_r;
	assign RF_WD = RF_WD_r;
	wire branchTaken;

	/* IF Stage */

	// pc change using pcMux
	wire [31:0] nextPcJAL;
	wire [31:0] nextPcJALR;
	wire [31:0] nextPcBranch;
	wire [31:0] nextPcInc4;

	// The four 'candidates' for the next pc

	adder32 pcAdder1(.src1({20'b0, pc}), .src2(4), .out(nextPcInc4));

	// pc Mux
	pcMux pcMux(.nextPcInc4(nextPcInc4), .nextPcJALR(nextPcJALR), .nextPcJAL(nextPcJAL), .nextPcBranch(nextPcBranch), .pcSrc({pcSrc[2:1], 1'b0}), .nextPc(nextpc));

	// Decode current instruction
	Decoder decoder(.instruction(I_MEM_DI), .opcode(opcode), .rs1(rs1), .rs2(rs2), .rd(rd), .writeToReg(writeToReg), .writeToMem(writeToMem), .isRtype(isRtype), .isItype(isItype), .isStype(isStype), .isBtype(isBtype), .isUtype(isUtype), .isJtype(isJtype), .isALU (isALU), .ItypeImm(ItypeImm), .StypeImm(StypeImm), .BtypeImm(BtypeImm), .UtypeImm(UtypeImm), .JtypeImm(JtypeImm), .funct3(funct3), .funct7(funct7), .halt(probablyHalt), .pcSrc(pcSrc));

	// commit to IF ID register

	wire[2:0] opType;
	wire[2:0] opType_id;
	wire[4:0] rd_id;
	wire[4:0] rs1_id;
	wire[4:0] rs2_id;
	wire[2:0] aluOp1_id;
	wire[2:0] aluOp2_id;
	wire[11:0] imm_id;
	wire isBtype_id;
	wire isItype_id;
	wire isRtype_id;
	wire isStype_id;
	wire isJtype_id;
	wire[6:0] opcode_id;
	wire[6:0] funct7_id;
	wire[11:0] pc_id;
	wire bpr_id;
	wire flush_id;
	wire probablyHalt_id;

	assign imm = isItype ? ItypeImm : isStype ? StypeImm : 0;
	assign opType = isStype ? 3'b000 : funct3;
	assign aluOp1 = 3'b100;
	assign aluOp2 = (isItype || isStype) ? 3'b000 : 3'b100;

	// IF_ID pipeline register commit
	IF_ID PR1(.CLK(CLK), .RSTn(RSTn), .latchn(1'b0), .opType_i(opType), .rd_i(rd), .rs1_i(rs1), .rs2_i(rs2), .aluOp1_i(aluOp1), .aluOp2_i(aluOp2), .imm_i(imm), .isBtype_i(isBtype), .isItype_i(isItype), .isRtype_i(isRtype), .isStype_i(isStype), .isJtype_i(isJtype), .opcode_i(opcode), .funct7_i(funct7), .pc_i(pc), .bpr_i(bpr), .probablyHalt_i(probablyHalt), .flush_i(1'b0), .opType_o(opType_id), .rd_o(rd_id), .rs1_o(rs1_id), .rs2_o(rs2_id), .aluOp1_o(aluOp1_id), .aluOp2_o(aluOp2_id), .imm_o(imm_id), .isBtype_o(isBtype_id), .isItype_o(isItype_id), .isRtype_o(isRtype_id), .isStype_o(isStype_id), .isJtype_o(isJtype_id), .opcode_o(opcode_id), .funct7_o(funct7_id), .pc_o(pc_id), .bpr_o(bpr_id), .flush_o(flush_id), .probablyHalt_o(probablyHalt_id));

	// register file control
	assign RF_RA1 = rs1_id;
	assign RF_RA2 = rs2_id;

	wire[31:0] regVal1_ex;
	wire[31:0] regVal2_ex;
	wire[2:0] opType_ex;
	wire[4:0] rd_ex;
	wire[4:0] rs1_ex;
	wire[4:0] rs2_ex;
	wire[2:0] aluOp1_ex;
	wire[2:0] aluOp2_ex;
	wire[11:0] imm_ex;
	wire isBtype_ex;
	wire isItype_ex;
	wire isRtype_ex;
	wire isStype_ex;
	wire isJtype_ex;
	wire[6:0] opcode_ex;
	wire[6:0] funct7_ex;
	wire[11:0] pc_ex;
	wire bpr_ex;
	wire flush_ex;

	// ID_EX pipeline register commit
	ID_EX PR2(.CLK(CLK), .RSTn(RSTn), .latchn(1'b0), .regVal1_i(RF_RD1), .regVal2_i(RF_RD2), .opType_i(opType_id), .rd_i(rd_id), .rs1_i(rs1_id), .rs2_i(rs2_id), .aluOp1_i(aluOp1_id), .aluOp2_i(aluOp2_id), .imm_i(imm_id), .isBtype_i(isBtype_id), .isItype_i(isItype_id), .isRtype_i(isRtype_id), .isStype_i(isStype_id), .isJtype_i(isJtype_id), .opcode_i(opcode_id), .funct7_i(funct7_id), .pc_i(pc_id), .bpr_i(bpr_id), .flush_i(flush_id), .regVal1_o(regVal1_ex), .regVal2_o(regVal2_ex), .opType_o(opType_ex), .rd_o(rd_ex), .rs1_o(rs1_ex), .rs2_o(rs2_ex), .aluOp1_o(aluOp1_ex), .aluOp2_o(aluOp2_ex), .imm_o(imm_ex), .isBtype_o(isBtype_ex), .isItype_o(isItype_ex), .isRtype_o(isRtype_ex), .isStype_o(isStype_ex), .isJtype_o(isJtype_ex), .opcode_o(opcode_ex), .funct7_o(funct7_ex), .pc_o(pc_ex), .bpr_o(bpr_ex), .flush_o(flush_ex));

	// handle halt
	assign HALT = probablyHalt_id & (RF_RD1 == 32'hc);
	always @(probablyHalt_id) begin
		$display("probablyHalt: %0b", probablyHalt_id);
		$display("RF_RD1: %0x", RF_RD1);
	end

	/* EX Stage */

	// ALU control
	wire[31:0] aluIn1;
	wire[31:0] aluIn2;
	wire[31:0] baluIn1;
	wire[31:0] baluIn2;
	wire[31:0] aluResult;
	wire baluResult;

	wire[2:0] aluOp1_f;
	wire[2:0] aluOp2_f;
	wire[2:0] baluOp1_f;
	wire[2:0] baluOp2_f;

	// Sign Extension
	wire[31:0] signExtendedImm;
	wire[31:0] signExtendedBtypeImm;
	wire[31:0] signExtendedJtypeImm;

	SignExtender12 SE1(.in(imm_ex), .out(signExtendedImm));
	SignExtender13 SE2(.in(BtypeImm), .out(signExtendedBtypeImm));
	SignExtender21 SE3(.in(JtypeImm), .out(signExtendedJtypeImm));

	ALU alu(.opType(opType_ex), .aux(funct7_ex), .useAux(isRtype_ex), .in1(aluIn1), .in2(aluIn2), .out(aluResult));
	branchALU branchALU(.src1(baluIn1), .src2(baluIn2), .funct3(opType_ex), .isBtype(isBtype_ex), .out(baluResult));

	wire[31:0] aluResult_mem;
	wire[4:0] rd_mem;
	wire[4:0] rs1_mem;
	wire[4:0] rs2_mem;
	wire isBtype_mem;
	wire isItype_mem;
	wire isRtype_mem;
	wire isStype_mem;
	wire isJtype_mem;
	wire[6:0] opcode_mem;
	wire[31:0] memWriteValue_mem;
	wire[11:0] pc_mem;
	wire bpr_mem;
	wire flush_mem;

	// EX/MEM pipeline register commit
	EX_MEM PR3(.CLK(CLK), .RSTn(RSTn), .latchn(1'b0), .aluResult_i(aluResult), .rd_i(rd_ex), .rs1_i(rs1_ex), .rs2_i(rs2_ex), .isBtype_i(isBtype_ex), .isItype_i(isItype_ex), .isRtype_i(isRtype_ex), .isStype_i(isStype_ex), isJtype_i(isJtype_ex), .opcode_i(opcode_ex), .memWriteValue_i(regVal2_ex), .pc_i(pc_ex), .bpr_i(bpr_ex), .flush_i(flush_ex), .aluResult_o(aluResult_mem), .rd_o(rd_mem), .rs1_o(rs1_mem), .rs2_o(rs2_mem), .isBtype_o(isBtype_mem), .isItype_o(isItype_mem), .isRtype_o(isRtype_mem), .isStype_o(isStype_mem), .isJtype(isJtype_mem), .opcode_o(opcode_mem), .memWriteValue_o(memWriteValue_mem), .pc_o(pc_mem), .bpr_o(bpr_mem), .flush_o(flush_mem));

	/* MEM stage */
	assign D_MEM_ADDR = (aluResult[11:2] << 2) & 'h3fff;
	assign D_MEM_WEN = ~isStype;
	assign D_MEM_DOUT = memWriteValue_mem;

	wire[31:0] aluResult_wb;
	wire[4:0] rd_wb;
	wire[4:0] rs1_wb;
	wire[4:0] rs2_wb;
	wire isBtype_wb;
	wire isItype_wb;
	wire isRtype_wb;
	wire isStype_wb;
	wire isJtype_wb;
	wire[6:0] opcode_wb;
	wire[31:0] memWriteValue_wb;
	wire[31:0] memReadValue_wb;
	wire[11:0] pc_wb;
	wire bpr_wb;
	wire flush_wb;

	// MEM/WB pipeline register commit 
	MEM_WB PR4(.CLK(CLK), .RSTn(RSTn), .latchn(1'b0), .aluResult_i(aluResult_mem), .rd_i(rd_mem), .rs1_i(rs1_mem), .rs2_i(rs2_mem), .isBtype_i(isBtype_mem), .isItype_i(isItype_mem), .isRtype_i(isRtype_mem), .isStype_i(isStype_mem), .isJtype_i(isJtype_mem), .opcode_i(opcode_mem), .memWriteValue_i(memWriteValue_mem), .memReadValue_i(D_MEM_DI), .pc_i(pc_mem), .bpr_i(bpr_mem), .flush_i(flush_mem), .aluResult_o(aluResult_wb), .rd_o(rd_wb), .rs1_o(rs1_wb), .rs2_o(rs2_wb), .isBtype_o(isBtype_wb), .isItype_o(isItype_wb), .isRtype_o(isRtype_wb), .isStype_o(isStype_wb), .isJtype_o(isJtype_wb), .opcode_o(opcode_wb), .memWriteValue_o(memWriteValue_wb), .memReadValue_o(memReadValue_wb), .pc_o(pc_wb), .bpr_o(bpr_wb), .flush_o(flush_wb));

	/* WB stage */
	assign RF_WE = (isItype_wb | isRtype_wb);
	assign RF_WA1 = rd_wb;

	always @(*) begin
		// alu instruction
		if (opcode_wb == 7'b0010011 || opcode_wb == 7'b0110011) begin
			RF_WD_r = aluResult_wb;
		end

		// store instruction
		else if (opcode_wb == 7'b0100011) begin
			RF_WD_r = memWriteValue_wb;
		end

		// jump (and link)
		else if (opcode_wb == 7'b1101111 || opcode_wb == 7'b1100111) begin
			RF_WD_r = pc_wb + 4;
		end

		// branch
		else if (opcode_wb == 7'b1100011) begin
			RF_WD_r = branchTaken;
		end

		// load instruction
		else begin
			RF_WD_r = memReadValue_wb;
		end
	end

	// NUM_INST commit
	
	always @(negedge CLK) begin
		if (RSTn) begin
			if (~flush_wb) begin
				NUM_INST <= NUM_INST + 1;
			end
		end
	end

	// HALT condition
	always @(posedge CLK) begin
		if (RSTn) begin
			if (~flush_wb) begin

			end
		end
	end

	/* forwarding unit */
	forwardUnit FW(.EX_rs1(rs1_ex), .EX_rs2(rs2_ex), .MEM_rd(rd_mem), .WB_rd(rd_wb), .MEM_writeToReg(isItype_mem | isRtype_mem), .WB_writeToReg(isItype_wb | isRtype_wb | isJtype_wb), .aluOp1(aluOp1_f), .aluOp2(aluOp2_f), .baluOp1(baluOp1_f), .baluOp2(baluOp2_f));

	ALUSrc1Mux ALUSrc1(.sig(aluOp1_ex | aluOp1_f), .regValue(regVal1_ex), .forwardMEM(aluResult_mem), .forwardWB(aluResult_wb), .out(aluIn1));
	ALUSrc2Mux ALUSrc2(.sig(aluOp2_ex | aluOp2_f), .regValue(regVal2_ex), .imm(signExtendedImm), .forwardMEM(aluResult_mem), .forwardWB(aluResult_wb), .out(aluIn2));

	BALUSrcMux BALUSrc1(.sig(3'b000), .regValue(regVal1_ex), .forwardMEM(32'b0), .forwardWB(32'b0), .out(baluIn1));
	BALUSrcMux BALUSrc2(.sig(3'b000), .regValue(regVal2_ex), .forwardMEM(32'b0), .forwardWB(32'b0), .out(baluIn2));

endmodule //
