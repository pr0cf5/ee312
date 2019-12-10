module cache (
	input wire CLK,
	input wire CSN,
	input wire memRead,
	input wire [11:0] CACHE_ADDR,
	input wire CACHE_WEN,
	input wire [3:0] CACHE_BE,
	input wire [31:0] D_MEM_DI,
	input wire [31:0] WRITE_DATA,
	output wire [11:0] D_MEM_ADDR,
	output wire D_MEM_WEN,
	output wire [3:0] D_MEM_BE,
	output wire [31:0] D_MEM_DOUT,
	output wire freeze,
	output wire [31:0] CACHE_DOUT
);

	reg [31:0] outline;
	reg [133:0] buffer[0:7];
	reg [31:0] temp;
	reg [3:0] idx;
	reg rhit;
	reg whit;
	reg [31:0] stater;
	reg [31:0] statew;
	
	reg [11:0] D_MEM_ADDR_r;
	reg [31:0] D_MEM_DOUT_r;
	reg freeze_r;

	assign CACHE_DOUT = outline;
	assign D_MEM_ADDR = D_MEM_ADDR_r;
	assign D_MEM_DOUT = WRITE_DATA;
	assign D_MEM_WEN = CACHE_WEN ? 1 : (whit ? 0 : 1);
	assign D_MEM_BE = CACHE_BE;

	assign freeze = freeze_r;

	initial begin
		freeze_r = 1'b0;
		stater = 0;
		statew = 0;
		for (idx = 0; idx < 4'b1000; idx = idx + 1) begin
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
		if (CACHE_WEN && memRead && (~CSN) && (~freeze_r)) begin
			// read: cache hit

			if (buffer[index][132:128] == tag && buffer[index][133] == 1'b1) begin
				case(CACHE_ADDR[3:2])
					2'b00: outline <= buffer[index][31:0];
					2'b01: outline <= buffer[index][63:32];
					2'b10: outline <= buffer[index][95:64];
					2'b11: outline <= buffer[index][127:96];
				endcase
				rhit = 1'b1;
				freeze_r = 0;
			end

			else begin
				rhit = 0;
				freeze_r = 1;
				stater = 1;
			end
		end

		else if (~memRead && CACHE_WEN) begin
			freeze_r = 0;
		end
	end

	wire cacheAllocRead;
	assign cacheAllocRead = memRead && (~rhit);

	always @(posedge CLK) begin
		// due to write allocate, waiting mechanism is same with read
		if (freeze_r && (~CSN) && cacheAllocRead) begin
			if (stater >= 1 && stater < 5) begin
				// wait
				if (stater == 1) begin
					// request for first address
					D_MEM_ADDR_r <= CACHE_ADDR[11:4] << 4;
				end

				else if (stater == 2) begin
					// fetch data
					buffer[index][31:0] <= D_MEM_DI;
					// request for second address
					D_MEM_ADDR_r <= (CACHE_ADDR[11:4] << 4) + 4'b0100;
				end

				else if (stater == 3) begin
					// fetch data
					buffer[index][63:32] <= D_MEM_DI;
					// request for second address
					D_MEM_ADDR_r <= (CACHE_ADDR[11:4] << 4) + 4'b1000;
				end

				else if (stater == 4) begin
					// fetch data
					buffer[index][95:64] <= D_MEM_DI;
					// request for second address
					D_MEM_ADDR_r <= (CACHE_ADDR[11:4] << 4) + 4'b1100;
				end
				stater <= stater + 1;
			end

			else if (stater == 5) begin
				// fetch data
				buffer[index][127:96] <= D_MEM_DI;
				buffer[index][133] <= 1;
				buffer[index][132:128] <= tag;
				stater <= 0;
				freeze_r <= 0;
			end
		end
	end

	always @(*) begin
		// on cache hit, write to cache and memory and unfreeze
		if (~CACHE_WEN) begin
			if (statew == 0) begin
				if (buffer[index][132:128] == tag && buffer[index][133] == 1'b1) begin
					whit = 1'b1;
					freeze_r = 0;
				end

				// go to freeze
				else begin
					whit = 0;
					freeze_r = 1;
					statew = 1;
				end

				D_MEM_ADDR_r = CACHE_ADDR;
			end
		end
	end

	always @(negedge CLK) begin
		if (~CACHE_WEN && whit && statew == 0) begin
			case(CACHE_ADDR[3:2])
				2'b00: buffer[index][31:0] <= WRITE_DATA;
				2'b01: buffer[index][63:32] <= WRITE_DATA;
				2'b10: buffer[index][95:64] <= WRITE_DATA;
				2'b11: buffer[index][127:96] <= WRITE_DATA;
			endcase
		end 
	end

	wire cacheAllocWrite;
	assign cacheAllocWrite = (~CACHE_WEN) && (~whit);

	always @(posedge CLK) begin

		if (freeze_r && (~CSN) && cacheAllocWrite) begin
			if (statew >= 1 && statew < 5) begin
				if (statew == 1) begin
					// request for first address
					D_MEM_ADDR_r <= CACHE_ADDR[11:4] << 4;
				end

				else if (statew == 2) begin
					// fetch data
					buffer[index][31:0] <= D_MEM_DI;
					// request for second address
					D_MEM_ADDR_r <= (CACHE_ADDR[11:4] << 4) + 4'b0100;
				end

				else if (statew == 3) begin
					// fetch data
					buffer[index][63:32] <= D_MEM_DI;
					// request for second address
					D_MEM_ADDR_r <= (CACHE_ADDR[11:4] << 4) + 4'b1000;
				end

				else if (statew == 4) begin
					// fetch data
					buffer[index][95:64] <= D_MEM_DI;
					// request for second address
					D_MEM_ADDR_r <= (CACHE_ADDR[11:4] << 4) + 4'b1100;
				end

				statew <= statew + 1;
			end

			else if (statew == 5) begin
				// fetch data
				buffer[index][127:96] <= D_MEM_DI;
				buffer[index][133] <= 1;
				buffer[index][132:128] <= tag;
				statew <= 0;
			end
		end
	end

endmodule