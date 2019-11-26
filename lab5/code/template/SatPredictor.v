module SatPredictor (
	input wire CLK,
	input wire commit,
	input wire baluResult,
	output wire out
);
	
	// each entry is 2 bit
	reg [1:0] Buffer [15:0];
	reg [31:0] index;
	reg bpr_r;

	assign out = bpr_r;

	// global history reigster
	reg [3:0] GHR;

	initial begin
		for (index = 0; index < 16; index = index + 1) begin
			Buffer[index] = 2'b10;
		end

		GHR = 4'b0000;

	end

	// asynchronous read, mode = 0 is for READ
	always @(*) begin

		if (Buffer[GHR] == 2'b10 || Buffer[GHR] == 2'b11) begin
			bpr_r = 1;
		end

		else begin
			bpr_r = 1;
		end
	end

	// synchronous write, mode = 1 is for WRITE
	always @(posedge CLK) begin
		if (commit) begin
			if (Buffer[GHR] == 2'b00 && (~baluResult)) begin
				Buffer[GHR] <= 2'b00;
			end 

			else if (Buffer[GHR] == 2'b11 && baluResult) begin
				Buffer[GHR] <= 2'b11;
			end

			else begin
				if (baluResult) begin
					Buffer[GHR] <= Buffer[GHR] + 1;
				end

				else begin
					Buffer[GHR] <= Buffer[GHR] - 1;
				end
			end 

			GHR <= {GHR[2:0], baluResult};
		end
	end

endmodule
