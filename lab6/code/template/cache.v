module cache (
	input wire CLK,
	input wire CSN,
	input wire [11:0] CACHE_ADDR,
	input wire CACHE_WEN,
	input wire [3:0] CACHE_BE,
	input wire [31:0] D_MEM_DI,
	output wire [11:0] D_MEM_ADDR,
	output wire D_MEM_WEN,
	output wire [3:0] D_MEM_BE,
	output wire [31:0] D_MEM_DOUT,
	output wire freeze,
	output wire [31:0] CACHE_DOUT // data out
);

	reg [31:0] outline;
	reg [133:0] buffer[0:7];
	reg [31:0] temp;
	reg [2:0] idx;
	reg hit;
	reg [31:0] waitcnt;
	
	reg [11:0] D_MEM_ADDR_r;
	reg [31:0] D_MEM_DOUT_r;
	reg freeze_r;

	assign CACHE_DOUT = outline;
	assign D_MEM_ADDR = D_MEM_ADDR_r;
	assign D_MEM_WEN = CACHE_WEN;
	assign D_MEM_BE = CACHE_BE;

	assign freeze = freeze_r;

	initial begin
		freeze_r <= 1'b0;
		for (idx = 0; idx <= 3'b111; idx = idx + 1) begin
			buffer[idx] = 0;
		end
	end

	// tag: 11~7, index: 6~4, bo: 3~2 g: 1~0
	// buffer entry: valid bit: 133, tag: 132~128, data: 127~0
	wire [3:0] index;
	wire [2:0] bo;
	wire [5:0] tag;

	assign index = CACHE_ADDR[6:4];
	assign bo = CACHE_ADDR[3:2];
	assign tag = CACHE_ADDR[11:7];

	// asynchronous read
	always @ (*) begin
		// read: cache hit
		hit = 0;
		if (buffer[index][132:128] == tag && buffer[index][133] == 1'b1) begin
			case(CACHE_ADDR[3:2])
				2'b00: outline <= buffer[index][31:0];
				2'b01: outline <= buffer[index][63:32];
				2'b10: outline <= buffer[index][95:64];
				2'b11: outline <= buffer[index][127:96];
			endcase
			hit = hit | 1'b1;
		end
		
		if (hit) begin
			freeze_r = 0;
		end

		else begin
			freeze_r = 1;
			waitcnt = 0;
		end
	end

	always @(posedge CLK) begin
		if (freeze_r) begin
			if (waitcnt >= 0 && waitcnt < 5) begin
				// wait
				if (waitcnt == 1) begin
					// request for first address
					D_MEM_ADDR_r <= CACHE_ADDR[11:4] << 4;
				end

				else if (waitcnt == 2) begin
					// fetch data
					buffer[index][31:0] <= D_MEM_DI;
					// request for second address
					D_MEM_ADDR_r <= (CACHE_ADDR[11:4] << 4) + 4'b0100;
				end

				else if (waitcnt == 3) begin
					// fetch data
					buffer[index][63:32] <= D_MEM_DI;
					// request for second address
					D_MEM_ADDR_r <= (CACHE_ADDR[11:4] << 4) + 4'b1000;
				end

				else if (waitcnt == 4) begin
					// fetch data
					buffer[index][95:64] <= D_MEM_DI;
					// request for second address
					D_MEM_ADDR_r <= (CACHE_ADDR[11:4] << 4) + 4'b1100;
				end

				waitcnt <= waitcnt + 1;
			end

			else if (waitcnt == 5) begin
				// fetch data
				buffer[index][127:96] <= D_MEM_DI;
				waitcnt <= 0;
				freeze_r <= 0;
			end
		end

	end


endmodule