module pcMux (
	input wire [6:0] opcode_ex,
	input wire flush_ex,
	input wire baluResult,
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
			3'b000: begin
				nextPc_r = nextPcInc4;
				//$display("default");
			end
			3'b001: begin
				nextPc_r = nextPcBranch;
				//$display("branch");
			end
			3'b110: begin
				nextPc_r = nextPcJAL;
				//$display("JUMP IMM");
			end
			3'b100: begin
				if ((~flush_ex) & opcode_ex == 7'b1100111) begin
					nextPc_r = nextPcJALR;
				end

				else begin
					nextPc_r = nextPcInc4;
				end
			end

		endcase
	end
endmodule 