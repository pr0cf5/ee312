module BTB (
	input wire CLK,
	input wire[5:0] hash_r,
	input wire[5:0] tag_r,
	input wire[5:0] hash_w,
	input wire[5:0] tag_w,
	input wire[31:0] dest_w,
	input wire commit,
	output wire found,
	output wire[31:0] btbOut
);
	
	// each entry is 12(11:0) (btbOut) + 1(12) (validBit) + 5(17:13) (tag) = 18 bits
	reg [17:0] Buffer [5:0];
	reg [31:0] index;

	initial begin
		for (index = 0; index < 32; index = index + 1) begin
			Buffer[index] = 18'b0;
		end

	end

	// asynchronous read, mode = 0 is for READ
	assign found = (tag_r == Buffer[hash_r][17:13]) & Buffer[hash_r][12];
	assign btbOut = {20'b0, Buffer[hash_r][11:0]};

	// synchronous write, mode = 1 is for WRITE
	always @(posedge CLK) begin
		if (commit) begin
			Buffer[hash_w] <= {tag_w, 1'b1, dest_w[11:0]};
		end
	end

endmodule
