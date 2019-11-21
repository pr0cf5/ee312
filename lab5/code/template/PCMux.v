module pcMux (
	input wire [6:0] opcode_ex,
	input wire flush_ex,
	input wire baluResult,
	input wire mispredicted,
	input wire [31:0] recover_pc,
	input wire [31:0] nextPcInc4,
	input wire [31:0] nextPcJALR,
	input wire [31:0] nextPcJAL,
	input wire [31:0] nextPcBranch,
	input wire [31:0] branchPc_ex,
	input wire [2:0] pcSrc,
	output wire [11:0] nextPc
	);

	reg [31:0] nextPc_r;
	assign nextPc = nextPc_r[11:0];

	always @(*) begin
		if (mispredicted) begin

			// JALR
			if (opcode_ex == 7'b1100111 & (~flush_ex)) begin
				nextPc_r = nextPcJALR;
			end

			// BRANCH
			else if (opcode_ex == 7'b1100011) begin
				if (baluResult) begin
					nextPc_r = branchPc_ex;
				end
				else begin

					nextPc_r = recover_pc + 4;
				end
			end
		end

		else begin
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
					nextPc_r = nextPcInc4;
				end
			endcase
		end
	end
endmodule 