module ALUSrc1Mux (input wire[2:0] sig, input wire[31:0] regValue, input wire[31:0] forwardMEM, input wire[31:0] forwardWB, output wire[31:0] out);

	reg[31:0] out_r;
	assign out = out_r;

	always @(*) begin

		if (sig == 3'b100) begin
			out_r = regValue;
		end
		
		// MEM forward
		else if (sig[1:0] == 2'b10) begin
			out_r = forwardMEM;
		end

		// WB forward
		else if (sig[1:0] == 2'b01) begin
			out_r = forwardWB;
		end


	end
endmodule

module ALUSrc2Mux (input wire[2:0] sig, input wire[31:0] regValue, input wire[31:0] imm, input wire[31:0] forwardMEM, input wire[31:0] forwardWB, output wire[31:0] out);

	reg[31:0] out_r;
	assign out = out_r;

	always @(*) begin
		if (sig[2] == 0) begin
			out_r = imm;
		end

		else if (sig[1:0] == 2'b00) begin
			if (sig == 3'b100) begin
				out_r = regValue;
			end
		end

		// MEM forward
		else if (sig[1:0] == 2'b10) begin
			out_r = forwardMEM;
		end

		// WB forward
		else begin
			out_r = forwardWB;
		end
		
	end
endmodule

module BALUSrcMux (input wire[2:0] sig, input wire[31:0] regValue, input wire[31:0] forwardMEM, input wire[31:0] forwardWB, output wire[31:0] out);
	assign out = regValue;
endmodule