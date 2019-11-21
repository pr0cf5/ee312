module mispredictionDetectionUnit(
	input wire flush_ex, 
	input wire [6:0] opcode_ex,
	input wire bpr_ex,
	input wire baluResult,
	output wire mispredicted
	);

	reg mispredicted_r;
	assign mispredicted = mispredicted_r;


	always @(*) begin
		if (~flush_ex) begin

			// JALR
			if (opcode_ex == 7'b1100111) begin
				mispredicted_r = 1;
			end

			// branch
			else if (opcode_ex == 7'b1100011) begin
				if (bpr_ex == baluResult) begin
					mispredicted_r = 0;
				end

				else begin
					mispredicted_r = 1;
				end
			end

			else begin 
				mispredicted_r = 0;
			end
		end

		else begin
			mispredicted_r = 0;
		end

	end

endmodule