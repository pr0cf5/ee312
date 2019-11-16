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
	always @ (negedge CLK) begin
		if (RSTn) NUM_INST <= NUM_INST + 1;
	end

	// assign I_MEM_CSN and D_MEM_CSN to invert RSTn
	assign I_MEM_CSN = ~RSTn;
	assign D_MEM_CSN = ~RSTn;

	//TODO

	// variables i made
	reg [11:0] pc;
	reg [11:0] nextpc;

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

	// there are 12bit immediates and 20bit immediates, so to include them both we make it 20bit size

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
	wire[31:0] signExtendedImm;

	// effective address
	wire [31:0] EA;

	// ALU
	wire [31:0] aluOp1;
	wire [31:0] aluOp2;
	wire [31:0] aluResult;

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

	
	// decode instruction
	Decoder decoder(.instruction(I_MEM_DI), .opcode(opcode), .rs1(rs1), .rs2(rs2), .rd(rd), .writeToReg(writeToReg), .writeToMem(writeToMem), .isRtype(isRtype), .isItype(isItype), .isStype(isStype), .isBtype(isBtype), .isUtype(isUtype), .isJtype(isJtype), .isALU (isALU), .ItypeImm(ItypeImm), .StypeImm(StypeImm), .BtypeImm(BtypeImm), .UtypeImm(UtypeImm), .JtypeImm(JtypeImm), .funct3(funct3), .funct7(funct7), .halt(probablyHalt));

	ALU alu(.opType(funct3), .aux(funct7), .useAux(isRtype), .inUse(isALU), .in1(aluOp1), .in2(aluOp2), .out(aluResult));
	SignExtender SE(.in(imm), .out(signExtendedImm));

	// register file control
	assign RF_RA1 = rs1;
	assign RF_RA2 = rs2;
	assign RF_WA1 = rd;

	reg [31:0] RF_WD_r;
	assign RF_WD = RF_WD_r;
	reg branchTaken;
	reg [31:0] signExtendedBtypeImm;
	reg [31:0] signExtendedJtypeImm;

	always @(*) begin
		if (BtypeImm[12] == 1) begin
			signExtendedBtypeImm = {19'b1111111111111111111, BtypeImm};
		end
		else begin
			signExtendedBtypeImm = BtypeImm;
		end
	end

	always @(*) begin
		if (JtypeImm[20] == 1) begin
			signExtendedJtypeImm = {11'b11111111111, JtypeImm};
		end
		else begin
			signExtendedJtypeImm = JtypeImm;
		end
	end


	always @(*) begin

		// alu instruction
		if (isALU) begin
			RF_WD_r = aluResult;
		end

		// store instruction
		else if (opcode == 7'b0100011) begin
			RF_WD_r = D_MEM_ADDR << 2;
		end

		// jump
		else if (opcode == 7'b1101111 || opcode == 7'b1100111) begin
			RF_WD_r = pc + 4;
		end

		// branch
		else if (opcode == 7'b1100011) begin
			RF_WD_r = branchTaken;
		end

		// u type instruction - LUI
		else if (opcode == 7'b110111) begin
			RF_WD_r = UtypeImm;
		end

		// u type instruction - AUIPC
		else if (opcode == 7'b10111) begin
			RF_WD_r = UtypeImm + pc;
		end

		// load instruction.acts differently based on the addressing mode

		else if (opcode == 7'b0000011) begin
			// different based on the mode
			case (funct3)
				// LB
				3'b000: begin
					if (D_MEM_DI[7]) begin
						RF_WD_r = {24'b111111111111111111111111, D_MEM_DI[7:0]};
					end

					else begin
						RF_WD_r = {24'b000000000000000000000000, D_MEM_DI[7:0]};
					end
				end

				// LH
				3'b001: begin
					if (D_MEM_DI[15]) begin
						RF_WD_r = {16'b1111111111111111, D_MEM_DI[15:0]};
					end

					else begin
						RF_WD_r = {16'b0000000000000000, D_MEM_DI[15:0]};
					end
				end

				// LW
				3'b010: begin
					RF_WD_r = D_MEM_DI;
				end

				// LBU
				3'b100: begin
					RF_WD_r = {24'b000000000000000000000000, D_MEM_DI[7:0]};
				end


				// LHU
				3'b101: begin
					RF_WD_r = {16'b0000000000000000, D_MEM_DI[15:0]};
				end
			endcase
		end
	end

	assign RF_WE = writeToReg;

	// ALU control
	assign aluOp1 = RF_RD1;
	assign aluOp2 = isItype ? signExtendedImm : RF_RD2;

	// memory control
	assign imm = isItype ? ItypeImm : isStype ? StypeImm : 0;

	// this value is different based on what addressing mode
	reg [3:0] D_MEM_BE_r;
	assign D_MEM_BE = D_MEM_BE_r;

	always @(*) begin
		if (funct3 == 3'b010) begin
			D_MEM_BE_r = 4'b1111;
		end

		else if (funct3 == 3'b100 || funct3 == 3'b000) begin
			D_MEM_BE_r = 4'b0001;
		end

		else if (funct3 == 3'b101 || funct3 == 3'b001) begin
			D_MEM_BE_r = 4'b0011;
		end
	end

	assign EA = RF_RD1 + signExtendedImm;
	assign D_MEM_ADDR = EA[31:2];

	// D_MEM_DOUT is only used when opcode = 7'b0100011 (SW)
	assign D_MEM_DOUT = RF_RD2;
	assign D_MEM_WEN = ~writeToMem;

	// pc increment
	// must sign extend for Jtype
	always @(*) begin
		if (opcode == 7'b1101111) begin
			nextpc = pc + signExtendedJtypeImm;
		end
			
		else if (opcode == 7'b1100111) begin
			nextpc = (signExtendedImm + RF_RD1) & 'hfffffffe;
		end

		else if (opcode == 7'b1100011) begin
			if (branchTaken) begin
				nextpc = pc + signExtendedBtypeImm;
			end
			else begin
				nextpc = pc + 4;
			end
		end

		else begin
			nextpc = pc + 4;
		end
	end

	// calculate branchTaken
	always @(*) begin
		if (isBtype) begin
			case (funct3) 
				3'b000: branchTaken = RF_RD1 == RF_RD2;
				3'b001: branchTaken = RF_RD1 != RF_RD2;
				3'b100: branchTaken = $signed(RF_RD1) < $signed(RF_RD2);
				3'b101: branchTaken = $signed(RF_RD1) >= $signed(RF_RD2);
				3'b110: branchTaken = RF_RD1 < RF_RD2;
				3'b111: branchTaken = RF_RD1 >= RF_RD2;
			endcase
		end
	end

	// halt handle
	assign HALT = probablyHalt & (RF_RD1 == 32'hc);

endmodule //
