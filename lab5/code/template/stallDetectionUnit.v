module stallDetectionUnit(
	input wire flush_id,
	input wire flush_ex,
	input wire[4:0] ID_rs1,
	input wire[4:0] ID_rs2,
	input wire[4:0] EX_rd,
	input wire EX_isLoad,
	input wire ID_isRtype,
	input wire ID_isBtype,
	output wire stall
);

	assign working = (flush_ex == 0) & (flush_id== 0);
	assign stall = ((EX_rd == ID_rs1 && EX_rd !=0 && EX_isLoad) || (EX_rd == ID_rs2 && EX_rd != 0 && EX_isLoad && (ID_isRtype || ID_isBtype))) & working;

endmodule