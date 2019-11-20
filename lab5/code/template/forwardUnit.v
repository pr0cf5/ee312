module forwardUnit(
	input wire[4:0] EX_rs1,
	input wire[4:0] EX_rs2,
	input wire[4:0] MEM_rs2,
	input wire[4:0] MEM_rd,
	input wire[4:0] WB_rd,
	input wire MEM_writeToReg,
	input wire WB_writeToReg,
	output wire[2:0] aluOp1,
	output wire[2:0] aluOp2,
	output wire[2:0] baluOp1,
	output wire[2:0] baluOp2,
	output wire memOp
);

	reg[2:0] aluOp1_r;
	reg[2:0] aluOp2_r;
	reg[2:0] baluOp1_r;
	reg[2:0] baluOp2_r;

	assign aluOp1 = aluOp1_r;
	assign aluOp2 = aluOp2_r;
	assign baluOp1 = baluOp1_r;
	assign baluOp2 = baluOp2_r;

	always @(*) begin
		/* MEM should be prioritized over WB */
		if (MEM_rd == EX_rs1 && MEM_rd !=0 && MEM_writeToReg) begin
			aluOp1_r = 3'b010;
			baluOp1_r = 3'b010;
		end

		/* WB forward */
		else if (WB_rd == EX_rs1 && WB_rd != 0 && WB_writeToReg) begin
			aluOp1_r = 3'b001;
			baluOp1_r = 3'b001;
		end

		/* no forward */
		else begin
			aluOp1_r = 3'b000;
			baluOp1_r = 3'b000;
		end
	end

	always @(*) begin
		/* MEM should be prioritized over WB */
		if (MEM_rd == EX_rs2 && MEM_rd !=0 && MEM_writeToReg) begin
			aluOp2_r = 3'b010;
			baluOp2_r = 3'b010;
		end

		else if (WB_rd == EX_rs2 && WB_rd != 0 && WB_writeToReg) begin
			aluOp2_r = 3'b001;
			baluOp2_r = 3'b001;
		end

		else begin
			aluOp2_r = 3'b000;
			baluOp2_r = 3'b000;
		end
	end

	assign memOp = WB_writeToReg && MEM_rs2 == WB_rd;

endmodule