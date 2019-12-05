module adder32 (
	input wire [31:0] src1,
	input wire [31:0] src2,
	output wire [31:0] out
	);
	assign out = (src1 + src2) & 'hfffffffe;
endmodule 