// calculate the state based on the current state and emit signals to control components
module SM (
	input wire[3:0] current_state,
	input wire[6:0] opcode,
	input wire writeToReg,
	input wire writeToMem,
	input wire isRtype,
	input wire isItype,
	input wire isStype,
	input wire isBtype,
	input wire isUtype,
	input wire isJtype,

	output wire[3:0] next_state,
	output wire PVSWriteEnable
	);

	reg[3:0] next_state_r;
	reg PVSWriteEnable_r;

	assign next_state = next_state_r;
	assign PVSWriteEnable = PVSWriteEnable_r;

	always @(*) begin
		case (current_state) 
			3'b000: begin
				next_state_r = 3'b001;
				PVSWriteEnable_r = 0;
			end

			3'b001: begin
				// if jump instruction, emit PVSWriteEnable signal 
				if (isJtype) begin
					next_state_r = 3'b000;
					PVSWriteEnable_r = 1;
				end

				else begin
					next_state_r = 3'b010;
					PVSWriteEnable_r = 0;
				end
			end

			3'b010: begin
				// if load or store instruction, go to the mem stage
				if (opcode == 7'b0100011 || opcode == 7'b0000011) begin
					next_state_r = 3'b011;
					PVSWriteEnable_r = 0;
				end

				// else go to the writeback stage
				else begin
					next_state_r = 3'b100;
					PVSWriteEnable_r = 0;
				end
			end

			3'b011: begin
				// if store instruction, emit PVSWriteEnable and go to state 0
				if (opcode == 7'b0100011) begin
					next_state_r = 3'b000;
					PVSWriteEnable_r = 1;
				end

				// for loads, go to WB stage
				else begin
					next_state_r = 3'b100;
					PVSWriteEnable_r = 0;
				end
			end

			3'b100: begin
				next_state_r = 3'b000;
				PVSWriteEnable_r = 1;
			end


		endcase
	end
	

endmodule //
