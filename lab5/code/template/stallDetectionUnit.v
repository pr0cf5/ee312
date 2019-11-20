module stallDetectionUnit(
	input wire[4:0] EX_rs1,
	input wire[4:0] EX_rs2,
	input wire[4:0] MEM_rd,
	input wire MEM_isLoad,
	output wire stall
);

	assign stall = (MEM_rd == EX_rs1 && MEM_rd !=0 && MEM_isLoad) || (MEM_rd == EX_rs2 && MEM_rd !=0 && MEM_isLoad);

endmodule