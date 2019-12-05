module cache (
	input wire CLK,
	input wire CSN,
	input wire [11:0] ADDR,
	input wire WEN,
	input wire [3:0] BE,//byte enable
	input wire [31:0] DI, //data in
	output wire [11:0] ADDR_o,
	output wire WEN_o,
	output wire [3:0] BE_o,
	output wire [31:0] DO,
	output wire CLK_o,
	output wire CSN_o,
	output wire freze,
	output wire [31:0] DOUT // data out
);

	reg [31:0] outline;
	reg [133:0] buffer[0: 7];
	reg [31:0] temp;
	reg [2:0] idx;
	reg hit;
	reg [31:0] state;
	reg freeze_r;

	assign DOUT = outline;
	assign freeze = freeze_r;

	initial begin
		freeze_r <= 1'b0;
		state <= 0;
	end

	// tag: 11~7, index: 6~4, bo: 3~2 g: 1~0
	// buffer entry: valid bit: 133, tag: 132~128, data: 127~0

	always @ (posedge CLK) begin
		// read: cache hit
		if (state == 0) begin
			hit <= 0;
			for (idx = 0; idx <= 3'b111; idx = idx + 1) begin
				if (buffer[idx][132:128] == ADDR[11:7] && buffer[i][133] == 1'b1) begin
					case(ADDR[3:2]) begin
						2'b00: outline <= buffer[idx][31:0];
						2'b01: outline <= buffer[idx][63:32];
						2'b10: outline <= buffer[idx][95:64];
						2'b11: outline <= buffer[idx][127:96];
					endcase
					freeze_r <= 1'b0
					hit <= hit | 1'b1
				end
			end
		end

		// cache miss
		if (state == 0 && (~hit)) begin
			// start to wait 6 cycles
			freeze_r <= 1'b1;
			state <= state + 1;
		end

		else if (state == 5) begin
			// load from memory
		end

		else begin
			freeze_r <= 1'b1;
			state <= state + 1;
		end
		
	end


endmodule