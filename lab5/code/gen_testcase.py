fmt = "TestID[%d] <= \"%d\";		TestNumInst[%d] <= 16'h0006;		TestAns[%d] <= 16'h00cc;		TestPassed[%d] <= 1'b0;"

for i in range(5,13):
	print(fmt%(i,i+1,i,i,i))
