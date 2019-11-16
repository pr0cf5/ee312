module ALU (
	input wire [2:0] opType,
	input wire [6:0] aux,
	input wire useAux,
	input wire [31:0] in1,
	input wire [31:0] in2,
	input wire inUse,
	output wire [31:0] out
	);

	reg [31:0] result;
	reg [4:0] shamt;

	assign out = result;

	always @(*) begin
		if (inUse) begin
			//$display("opType = %0x, arg1 = %0x, arg2 = %0x", opType, in1, in2);
			case (opType)
				3'b000: begin
					if (useAux) begin
						if (aux == 0) begin
							result = in1 + in2;
						end

						else if (aux == 7'b0100000) begin
							result = in1 - in2;
						end

						else begin
							//$display("oh no 1");
						end
					end

					else begin
						result = in1 + in2;
					end
				end
				3'b001: begin
					shamt = in2[4:0];
					result = in1 << shamt;
				end
				// signed comparison
				3'b010: begin
					// check the order please
					result = $signed(in1) < $signed(in2);
				end
				// unsigned comparisoin
				3'b011: begin
					// check the order please
					result = in1 < in2;
				end

				3'b100: begin
					result = in1 ^ in2;
				end
				3'b101: begin
					if (in2[11:4] == 0) begin
						shamt = in2[4:0];
						result = in1 >> shamt;
					end

					else if (in2[11:4] == 8'b01000000) begin
						shamt = in2[4:0];
						result = in1 >> shamt;
					end

					else begin
						//$display("oh no 2");
					end
				end
				3'b110: begin
					result = in1 | in2;
				end
				3'b111: begin
					result = in1 & in2;
				end
			endcase
		end
	end
	
endmodule 