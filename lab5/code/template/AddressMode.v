module setAddressMode (
	input wire [2:0] funct3,
	output wire [3:0] mode
	);

	reg [3:0] mode_r;
	assign mode = mode_r;

	always @(*) begin
		if (funct3 == 3'b010) begin
			mode_r = 4'b1111;
		end

		else if (funct3 == 3'b100 || funct3 == 3'b000) begin
			mode_r = 4'b0001;
		end

		else if (funct3 == 3'b101 || funct3 == 3'b001) begin
			mode_r = 4'b0011;
		end
	end

endmodule 