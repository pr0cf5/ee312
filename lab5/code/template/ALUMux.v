module ALUSrc1Mux (input wire[2:0] sig, input wire[31:0] regValue, input wire[31:0] forwardMEM, input wire[31:0] forwardWB, output wire[31:0] out);

	reg[31:0] out_r;
	assign out = out_r;

	always @(*) begin
		if (sig == 3'b100) begin
			out_r = regValue;
		end
	end
endmodule

module ALUSrc2Mux (input wire[2:0] sig, input wire[31:0] regValue, input wire[31:0] imm, input wire[31:0] forwardMEM, input wire[31:0] forwardWB, output wire[31:0] out);

	reg[31:0] out_r;
	assign out = out_r;

	always @(*) begin
		if (sig == 3'b100) begin
			out_r = regValue;
		end

		else if (sig == 3'b000) begin
			out_r = imm;
		end
	end
endmodule

module BALUSrcMux (input wire[2:0] sig, input wire[31:0] regValue, input wire[31:0] forwardMEM, input wire[31:0] forwardWB, output wire[31:0] out);
	assign out = regValue;
endmodule