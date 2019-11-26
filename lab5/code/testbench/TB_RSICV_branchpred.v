`timescale 1ns/10ps
`define NUM_TEST 17
`define TESTID_SIZE 5

module TB_RISCV ();
	//General Signals
	wire CLK;
	wire RSTn;
	//Memory Signals
	wire I_MEM_CSN;
	wire [31:0] I_MEM_DOUT;
	wire [11:0] I_MEM_ADDR;
	wire D_MEM_CSN;
	wire D_MEM_WEN;
	wire [3:0] D_MEM_BE;
	wire [31:0] D_MEM_DOUT;
	wire [31:0] D_MEM_DI;
	wire [11:0] D_MEM_ADDR;
	wire RF_WE;
	wire [4:0] RF_RA1;
	wire [4:0] RF_RA2;
	wire [4:0] RF_WA;
	wire [31:0] RF_RD1;
	wire [31:0] RF_RD2;
	wire [31:0] RF_WD;
	wire HALT;
	wire [31:0] NUM_INST;
	wire [31:0] OUTPUT_PORT;

	//Clock Reset Generator
	RISCV_CLKRST riscv_clkrst1 (
		.CLK           (CLK),
		.RSTn          (RSTn)
	);

	//CPU Core top
	RISCV_TOP riscv_top1 (
		//General Signals
		.CLK          (CLK),
		.RSTn         (RSTn),
		//I-Memory Signals
		.I_MEM_CSN    (I_MEM_CSN),
		.I_MEM_DI     (I_MEM_DOUT),
		.I_MEM_ADDR   (I_MEM_ADDR),
		//D-Memory Signals
		.D_MEM_CSN    (D_MEM_CSN),
		.D_MEM_DI     (D_MEM_DOUT),
		.D_MEM_DOUT   (D_MEM_DI),
		.D_MEM_ADDR   (D_MEM_ADDR),
		.D_MEM_WEN    (D_MEM_WEN),
		.D_MEM_BE     (D_MEM_BE),
		//RegFile Signals
		.RF_WE        (RF_WE),
		.RF_RA1       (RF_RA1),
		.RF_RA2       (RF_RA2),
		.RF_WA1       (RF_WA),
		.RF_RD1       (RF_RD1),
		.RF_RD2       (RF_RD2),
		.RF_WD       (RF_WD),
		.HALT		(HALT),
		.NUM_INST (NUM_INST),
		.OUTPUT_PORT (OUTPUT_PORT)
	);

	//I-Memory
	SP_SRAM #(
		.ROMDATA ("/home/procfs/ee312/lab5/code/testcase/hex/branchpred.hex"), //Initialize I-Memory
		.AWIDTH  (10),
		.SIZE    (1024)
	) i_mem1 (
		.CLK    (CLK),
		.CSN    (I_MEM_CSN),
		.DI		(32'bz),
		.DOUT   (I_MEM_DOUT),
		.ADDR   (I_MEM_ADDR[11:2]),
		.WEN    (1'b1),
		.BE     (4'b0000)
	);

	//D-Memory
	SP_SRAM #(
		.AWIDTH  (12),
		.SIZE    (4096)
	) d_mem1 (
		.CLK    (CLK),
		.CSN    (D_MEM_CSN),
		.DI     (D_MEM_DI),
		.DOUT   (D_MEM_DOUT),
		.ADDR   (D_MEM_ADDR),
		.WEN    (D_MEM_WEN),
		.BE     (D_MEM_BE)
	);

	//Reg File
	REG_FILE #(
		.DWIDTH (32),
		.MDEPTH (32),
		.AWIDTH (5)
	) reg_file1 (
		.RSTn	(RSTn),
		.CLK    (CLK),
		.WE     (RF_WE),
		.RA1    (RF_RA1),
		.RA2    (RF_RA2),
		.WA     (RF_WA),
		.RD1    (RF_RD1),
		.RD2    (RF_RD2),
		.WD     (RF_WD)
	);

	reg [31:0] cycle;
	reg verify;

	initial begin
		cycle <= 0;
		#1000000 $finish();
	end

	reg [`TESTID_SIZE*8-1:0] TestID[`NUM_TEST-1:0];
	reg [31:0] TestNumInst [`NUM_TEST-1:0];
	reg [31:0] TestAns[`NUM_TEST-1:0];
	reg TestPassed[`NUM_TEST-1:0];
	reg [31:0] i;

	always @ (posedge CLK) begin
		if (RSTn) begin
			cycle <= cycle + 1;

			if (HALT == 1) begin
				$display("Finish: %d cycle", cycle);
				$display("Success.");
				$finish();
			end
		end
	end

endmodule
