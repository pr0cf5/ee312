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
	input wire [31:0] nextPcBTB,
	input wire [1:0] pcSrc,
	output wire [11:0] nextPc
	);

	reg [31:0] nextPc_r;
	assign nextPc = nextPc_r[11:0];

	always @(*) begin

		if (mispredicted) begin

			// JALR
			if (opcode_ex == 7'b1100111 && (~flush_ex)) begin
				nextPc_r = nextPcJALR;
			end

			// JAL
			else if (opcode_ex == 7'b1101111 && (~flush_ex)) begin
				nextPc_r = nextPcJAL;
			end

			// BRANCH
			else if (opcode_ex == 7'b1100011 && (~flush_ex)) begin
				if (baluResult) begin
					nextPc_r = nextPcBranch;
				end
				else begin
					nextPc_r = recover_pc + 4;
				end
			end
		end

		else begin
			case (pcSrc)

				// bit0: set this bit if it came from BTB
				// bit1: set if it is a control instruction

				2'b00: begin
					nextPc_r = nextPcInc4;
				end

				// should be unreachable
				2'b01: begin
					nextPc_r = nextPcInc4;
				end

				// 'wasted' instruction
				2'b10: begin
					nextPc_r = nextPcInc4;
				end

				// from BTB
				2'b11: begin
					nextPc_r = nextPcBTB;
				end
			endcase
		end
	end
endmodule 