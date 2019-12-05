module branchALU (
	input wire [31:0] src1,
	input wire [31:0] src2,
	input wire [2:0] funct3,
	input wire isBtype,
	output wire out
	);

	reg branchTaken;
	assign out = branchTaken & isBtype;

	always @(*) begin
		case (funct3)
			3'b000: branchTaken = src1 == src2;
			3'b001: branchTaken = src1 != src2;
			3'b100: branchTaken = $signed(src1) < $signed(src2);
			3'b101: branchTaken = $signed(src1) >= $signed(src2);
			3'b110: branchTaken = src1 < src2;
			3'b111: branchTaken = src1 >= src2;
		endcase
		
	end
endmodule 