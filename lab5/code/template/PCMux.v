module pcMux (
	input wire [31:0] nextPcInc4,
	input wire [31:0] nextPcJALR,
	input wire [31:0] nextPcJAL,
	input wire [31:0] nextPcBranch,
	input wire [2:0] pcSrc,
	output wire [11:0] nextPc
	);

	reg [31:0] nextPc_r;
	assign nextPc = nextPc_r[11:0];

	always @(*) begin
		case (pcSrc)
			3'b000: nextPc_r = nextPcInc4;
			3'b001: nextPc_r = nextPcBranch;
			3'b110: nextPc_r = nextPcJAL;
			3'b100: nextPc_r = nextPcJALR;

		endcase
	end
endmodule 