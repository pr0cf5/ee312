module Decoder (
	input wire[31:0] instruction,
	output wire[6:0] opcode,
	output wire[4:0] rs1,
	output wire[4:0] rs2,
	output wire[4:0] rd,
	output wire writeToReg,
	output wire writeToMem,
	output wire isRtype,
	output wire isItype,
	output wire isStype,
	output wire isBtype,
	output wire isUtype,
	output wire isJtype,
	output wire isALU,
	output wire[11:0] ItypeImm,
	output wire[11:0] StypeImm,
	output wire[12:0] BtypeImm,
	output wire[31:0] UtypeImm,
	output wire[20:0] JtypeImm,
	output wire[2:0] funct3,
	output wire[6:0] funct7,
	output wire halt,
	output wire [2:0] pcSrc
	);

	reg [2:0] pcSrc_r;
	assign pcSrc = pcSrc_r;

	assign opcode = instruction[6:0];

	assign rs1 = instruction[19:15];
	assign rs2 = instruction[24:20];
	// jump instructions must write to ra register
	//assign rd = (opcode == 7'b1100111 || opcode == 7'b1101111) ? 1 : instruction[11:7];
	assign rd = instruction[11:7];

	assign writeToReg = (opcode == 7'b0000011 | opcode == 7'b0110011 | opcode == 7'b0010011 | opcode == 7'b1101111 | opcode == 7'b1100111 | opcode == 7'b110111 | opcode == 7'b10111);

	assign writeToMem = (opcode == 7'b0100011);

	assign isRtype = (opcode == 7'b0110011);
	assign isItype = (opcode == 7'b0000011) | (opcode == 7'b0010011) | (opcode == 7'b1100111);
	assign isStype = (opcode == 7'b0100011);
	assign isBtype = (opcode == 7'b1100011);
	assign isUtype = (opcode == 7'b110111) | (opcode == 7'b10111);
	assign isJtype = (opcode == 7'b1101111);
	assign isALU = (opcode == 7'b0010011) | (opcode == 7'b0110011);

	assign ItypeImm = instruction[31:20];
	assign StypeImm = {instruction[31:25], instruction[11:7]};
	assign BtypeImm = {instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
	assign UtypeImm = {instruction[31:12], 12'b0};
	assign JtypeImm = {instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};

	assign funct3 = instruction[14:12];
	assign funct7 = instruction[31:25];

	assign halt = (instruction == 32'h8067) ? 1 : 0;

	always @(*) begin
		case (opcode)

			// JAL 
			7'b1101111: begin
				pcSrc_r = 2'b11;
			end

			// JALR
			7'b1100111: begin
				pcSrc_r = 2'b10;
			end

			// Branch
			7'b1100011: begin
				pcSrc_r = 2'b01;
			end

			// all else
			default: begin
				pcSrc_r = 2'b00;
			end
		endcase
	end

endmodule //