from sys import argv

if len(argv) != 3:
	print("usage: ./converter.py <in> <out>")
	exit(-1)

data = []

with open(argv[1], "r") as f:
	for l in f:
		data.append(int(l, 16))

with open(argv[2], "w") as f:
	for x in data[2:]:
		f.write("%08x\n"%x)
	f.write("00c00093\n")
	f.write("00008067\n")


