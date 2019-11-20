module SignExtender12 (
	input wire [11:0] in,
	output wire [31:0] out
	);

	assign out = in[11] ? {20'b11111111111111111111, in} : in;
endmodule

module SignExtender13 (
	input wire [12:0] in,
	output wire [31:0] out
	);

	assign out = in[12] ? {19'b1111111111111111111, in} : in;
endmodule


module SignExtender21 (
	input wire [20:0] in,
	output wire [31:0] out
	);

	assign out = in[20] ? {11'b11111111111, in} : in;
endmodule
