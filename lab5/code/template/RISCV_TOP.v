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

	// pc Mux control
	wire [1:0] pcSrc;

	reg [31:0] RF_WD_r;
	assign RF_WD = RF_WD_r;
	wire branchTaken;
	wire loadStall;
	wire bpr;

	// synchronize with clock and change pc

	always @(posedge CLK) begin
		if (RSTn) begin
			if ((~loadStall)) begin
				pc <= nextpc;
				I_MEM_ADDR <= nextpc;
			end

		end
		else begin
			I_MEM_ADDR <= pc;
		end
	end

	/* IF Stage */

	// pc change using pcMux
	wire [31:0] nextPcJAL;
	wire [31:0] nextPcBranch;
	wire [31:0] nextPcBTB;
	wire [31:0] nextPcInc4;
	wire btbHit;

	adder32 pcAdder1(.src1({20'b0, pc}), .src2(4), .out(nextPcInc4));

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
	wire[12:0] BtypeImm_id;
	wire[20:0] JtypeImm_id;
	wire isBtype_id;
	wire isItype_id;
	wire isRtype_id;
	wire isStype_id;
	wire isJtype_id;
	wire probablyHalt_id;
	wire[6:0] opcode_id;
	wire[6:0] funct7_id;
	wire[11:0] pc_id;
	wire[31:0] btbOut_id;
	wire bpr_id;
	wire flush_id;
	
	assign imm = isItype ? ItypeImm : isStype ? StypeImm : 0;
	assign opType = (isStype || opcode == 7'b0000011) ? 3'b000 : funct3;
	assign aluOp1 = 3'b100;
	assign aluOp2 = (isItype || isStype) ? 3'b000 : 3'b100;

	// IF_ID pipeline register commit

	wire mispred_flush;
	wire mispredicted;

	assign mispred_flush = mispredicted;

	IF_ID PR1(.CLK(CLK), .RSTn(RSTn), .latchn(loadStall), .opType_i(opType), .rd_i(rd), .rs1_i(rs1), .rs2_i(rs2), .aluOp1_i(aluOp1), .aluOp2_i(aluOp2), .imm_i(imm), .BtypeImm_i(BtypeImm), .JtypeImm_i(JtypeImm), .isBtype_i(isBtype), .isItype_i(isItype), .isRtype_i(isRtype), .isStype_i(isStype), .isJtype_i(isJtype), .probablyHalt_i(probablyHalt), .opcode_i(opcode), .funct7_i(funct7), .pc_i(pc), .bpr_i(bpr & isBtype & btbHit), .btbOut_i(nextPcBTB), .flush_i(mispred_flush), .opType_o(opType_id), .rd_o(rd_id), .rs1_o(rs1_id), .rs2_o(rs2_id), .aluOp1_o(aluOp1_id), .aluOp2_o(aluOp2_id), .imm_o(imm_id), .BtypeImm_o(BtypeImm_id), .JtypeImm_o(JtypeImm_id), .isBtype_o(isBtype_id), .isItype_o(isItype_id), .isRtype_o(isRtype_id), .isStype_o(isStype_id), .isJtype_o(isJtype_id), .probablyHalt_o(probablyHalt_id), .opcode_o(opcode_id), .funct7_o(funct7_id), .pc_o(pc_id), .bpr_o(bpr_id), .btbOut_o(btbOut_id), .flush_o(flush_id));

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
	wire[12:0] BtypeImm_ex;
	wire[20:0] JtypeImm_ex;
	wire isBtype_ex;
	wire isItype_ex;
	wire isRtype_ex;
	wire isStype_ex;
	wire isJtype_ex;
	wire probablyHalt_ex;
	wire[6:0] opcode_ex;
	wire[6:0] funct7_ex;
	wire[11:0] pc_ex;
	wire[31:0] btbOut_ex;
	wire bpr_ex;
	wire flush_ex;

	// ID_EX pipeline register commit
	ID_EX PR2(.CLK(CLK), .RSTn(RSTn), .latchn(1'b0), .regVal1_i(RF_RD1), .regVal2_i(RF_RD2), .opType_i(opType_id), .rd_i(rd_id), .rs1_i(rs1_id), .rs2_i(rs2_id), .aluOp1_i(aluOp1_id), .aluOp2_i(aluOp2_id), .imm_i(imm_id), .BtypeImm_i(BtypeImm_id), .JtypeImm_i(JtypeImm_id), .isBtype_i(isBtype_id), .isItype_i(isItype_id), .isRtype_i(isRtype_id), .isStype_i(isStype_id), .isJtype_i(isJtype_id), .probablyHalt_i(probablyHalt_id), .opcode_i(opcode_id), .funct7_i(funct7_id), .pc_i(pc_id), .bpr_i(bpr_id), .btbOut_i(btbOut_id), .flush_i(flush_id | mispred_flush | loadStall), .regVal1_o(regVal1_ex), .regVal2_o(regVal2_ex), .opType_o(opType_ex), .rd_o(rd_ex), .rs1_o(rs1_ex), .rs2_o(rs2_ex), .aluOp1_o(aluOp1_ex), .aluOp2_o(aluOp2_ex), .imm_o(imm_ex), .BtypeImm_o(BtypeImm_ex), .JtypeImm_o(JtypeImm_ex), .isBtype_o(isBtype_ex), .isItype_o(isItype_ex), .isRtype_o(isRtype_ex), .isStype_o(isStype_ex), .isJtype_o(isJtype_ex), .probablyHalt_o(probablyHalt_ex), .opcode_o(opcode_ex), .funct7_o(funct7_ex), .pc_o(pc_ex), .bpr_o(bpr_ex), .btbOut_o(btbOut_ex), .flush_o(flush_ex));

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
	SignExtender13 SE2(.in(BtypeImm_ex), .out(signExtendedBtypeImm));
	SignExtender21 SE3(.in(JtypeImm_ex), .out(signExtendedJtypeImm));

	ALU alu(.opType(opType_ex), .aux(funct7_ex), .useAux(isRtype_ex), .in1(aluIn1), .in2(aluIn2), .out(aluResult));
	branchALU branchALU(.src1(baluIn1), .src2(baluIn2), .funct3(opType_ex), .isBtype(isBtype_ex), .out(baluResult));

	adder32 JALAdder(.src1({20'b0, pc_ex}), .src2(signExtendedJtypeImm), .out(nextPcJAL));
	adder32 BranchAdde(.src1({20'b0, pc_ex}), .src2(signExtendedBtypeImm), .out(nextPcBranch));

	// Get JAL branch address

	wire[31:0] aluResult_mem;
	wire baluResult_mem;
	wire[4:0] rd_mem;
	wire[4:0] rs1_mem;
	wire[4:0] rs2_mem;
	wire isBtype_mem;
	wire isItype_mem;
	wire isRtype_mem;
	wire isStype_mem;
	wire isJtype_mem;
	wire probablyHalt_mem;
	wire[6:0] opcode_mem;
	wire[31:0] memWriteValue_mem;
	wire[11:0] pc_mem;
	wire bpr_mem;
	wire flush_mem;

	// EX/MEM pipeline register commit
	EX_MEM PR3(.CLK(CLK), .RSTn(RSTn), .latchn(1'b0), .aluResult_i(aluResult), .baluResult_i(baluResult), .rd_i(rd_ex), .rs1_i(rs1_ex), .rs2_i(rs2_ex), .isBtype_i(isBtype_ex), .isItype_i(isItype_ex), .isRtype_i(isRtype_ex), .isStype_i(isStype_ex), .isJtype_i(isJtype_ex), .probablyHalt_i(probablyHalt_ex), .opcode_i(opcode_ex), .memWriteValue_i(regVal2_ex), .pc_i(pc_ex), .bpr_i(bpr_ex), .flush_i(flush_ex), .aluResult_o(aluResult_mem), .baluResult_o(baluResult_mem), .rd_o(rd_mem), .rs1_o(rs1_mem), .rs2_o(rs2_mem), .isBtype_o(isBtype_mem), .isItype_o(isItype_mem), .isRtype_o(isRtype_mem), .isStype_o(isStype_mem), .isJtype_o(isJtype_mem), .probablyHalt_o(probablyHalt_mem), .opcode_o(opcode_mem), .memWriteValue_o(memWriteValue_mem), .pc_o(pc_mem), .bpr_o(bpr_mem), .flush_o(flush_mem));

	/* MEM stage */
	wire memOpForward;
	assign D_MEM_ADDR = (aluResult_mem[11:2] << 2) & 'h3fff;
	assign D_MEM_WEN = ~isStype_mem;
	assign D_MEM_DOUT = memOpForward ? RF_WD : memWriteValue_mem;
	assign D_MEM_BE = 4'b1111;

	wire[31:0] aluResult_wb;
	wire baluResult_wb;
	wire[4:0] rd_wb;
	wire[4:0] rs1_wb;
	wire[4:0] rs2_wb;
	wire isBtype_wb;
	wire isItype_wb;
	wire isRtype_wb;
	wire isStype_wb;
	wire isJtype_wb;
	wire probablyHalt_wb;
	wire[6:0] opcode_wb;
	wire[31:0] memWriteValue_wb;
	wire[31:0] memReadValue_wb;
	wire[11:0] pc_wb;
	wire bpr_wb;
	wire flush_wb;

	// MEM/WB pipeline register commit 
	MEM_WB PR4(.CLK(CLK), .RSTn(RSTn), .latchn(1'b0), .aluResult_i(aluResult_mem), .baluResult_i(baluResult_mem), .rd_i(rd_mem), .rs1_i(rs1_mem), .rs2_i(rs2_mem), .isBtype_i(isBtype_mem), .isItype_i(isItype_mem), .isRtype_i(isRtype_mem), .isStype_i(isStype_mem), .isJtype_i(isJtype_mem), .probablyHalt_i(probablyHalt_mem), .opcode_i(opcode_mem), .memWriteValue_i(D_MEM_DOUT), .memReadValue_i(D_MEM_DI), .pc_i(pc_mem), .bpr_i(bpr_mem), .flush_i(flush_mem), .aluResult_o(aluResult_wb), .baluResult_o(baluResult_wb), .rd_o(rd_wb), .rs1_o(rs1_wb), .rs2_o(rs2_wb), .isBtype_o(isBtype_wb), .isItype_o(isItype_wb), .isRtype_o(isRtype_wb), .isStype_o(isStype_wb), .isJtype_o(isJtype_wb), .probablyHalt_o(probablyHalt_wb), .opcode_o(opcode_wb), .memWriteValue_o(memWriteValue_wb), .memReadValue_o(memReadValue_wb), .pc_o(pc_wb), .bpr_o(bpr_wb), .flush_o(flush_wb));

	/* WB stage */
	assign RF_WE = isItype_wb|isRtype_wb|isJtype_wb;
	assign RF_WA1 = rd_wb;

	always @(*) begin
		// alu instruction
		if (opcode_wb == 7'b0010011 || opcode_wb == 7'b0110011) begin
			RF_WD_r = aluResult_wb;
		end

		// store instruction
		else if (opcode_wb == 7'b0100011) begin
			RF_WD_r = aluResult_wb;
		end

		// jump (and link)
		else if (opcode_wb == 7'b1101111 || opcode_wb == 7'b1100111) begin
			RF_WD_r = pc_wb + 4;
		end

		// branch
		else if (opcode_wb == 7'b1100011) begin
			RF_WD_r = baluResult_wb;
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

	assign HALT = RSTn & (~flush_wb) & probablyHalt_wb && aluResult_wb == 32'hc;

	/* forwarding unit */
	forwardUnit FW(.EX_rs1(rs1_ex), .EX_rs2(rs2_ex), .MEM_rs2(rs2_mem), .MEM_rd(rd_mem), .WB_rd(rd_wb), .MEM_writeToReg(isItype_mem | isRtype_mem | isJtype_mem), .WB_writeToReg(isItype_wb | isRtype_wb | isJtype_wb), .aluOp1(aluOp1_f), .aluOp2(aluOp2_f), .baluOp1(baluOp1_f), .baluOp2(baluOp2_f), .memOp(memOpForward));

	/* LOAD stall detection unit */
	stallDetectionUnit SD(.flush_id(flush_id), .flush_ex(flush_ex), .ID_rs1(rs1_id), .ID_rs2(rs2_id), .EX_rd(rd_ex), .EX_isLoad(opcode_ex == 7'b0000011), .ID_isRtype(isRtype_id), .ID_isBtype(isBtype_id), .ID_isStype(isStype_id), .stall(loadStall));

	ALUSrc1Mux ALUSrc1(.sig(aluOp1_ex | aluOp1_f), .regValue(regVal1_ex), .forwardMEM(aluResult_mem), .forwardWB(RF_WD), .out(aluIn1));
	ALUSrc2Mux ALUSrc2(.sig(aluOp2_ex | aluOp2_f), .regValue(regVal2_ex), .imm(signExtendedImm), .forwardMEM(aluResult_mem), .forwardWB(RF_WD), .out(aluIn2));

	// there may need to be a stall or else for LOAD the address will be used instead of the value in that address
	BALUSrcMux BALUSrc1(.sig(baluOp1_f), .regValue(regVal1_ex), .forwardMEM(aluResult_mem), .forwardWB(RF_WD), .out(baluIn1));
	BALUSrcMux BALUSrc2(.sig(baluOp2_f), .regValue(regVal2_ex), .forwardMEM(aluResult_mem), .forwardWB(RF_WD), .out(baluIn2));

	// control path

	SatPredictor Predictor(.CLK(CLK), .commit(isBtype_ex), .baluResult(baluResult), .out(bpr));

	pcMux pcMux(.opcode_ex(opcode_ex), .flush_ex(flush_ex), .mispredicted(mispredicted), .baluResult(baluResult), .recover_pc({20'b0, pc_ex}), .nextPcInc4(nextPcInc4), .nextPcJALR(aluResult), .nextPcJAL(nextPcJAL), .nextPcBranch(nextPcBranch), .nextPcBTB(nextPcBTB), .pcSrc({pcSrc[1], btbHit & isBtype & bpr}), .nextPc(nextpc));

	BTB BTB(.CLK(CLK), .hash_r(pc[5:0]), .tag_r(pc[11:6]), .hash_w(pc_ex[5:0]), .tag_w(pc_ex[11:6]), .dest_w(nextPcBranch), .commit(isBtype_ex), .found(btbHit), .btbOut(nextPcBTB));

	// flush instructions (IF/ID, ID/EX)
	mispredictionDetectionUnit MDU (.flush_ex(flush_ex), .opcode_ex(opcode_ex), .branchTarget_BTB(btbOut_ex), .branchTarget_real(nextPcBranch), .bpr_ex(bpr_ex), .baluResult(baluResult), .mispredicted(mispredicted));

endmodule //
