module SignExtender #(parameter totalBits=32) (
	input wire [11:0] in,
	output wire [31:0] out
	);

	assign out = in[11] ? {20'b11111111111111111111, in} : in;

endmodule //
