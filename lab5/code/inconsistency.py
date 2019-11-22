single = []
pipeline = []

with open("out_single","r") as f:
	for l in f:
		single.append(l.strip())

with open("out","r") as f:
	for l in f:
		if len(pipeline) == len(single):
			break
		pipeline.append(l.strip())

for i,x in enumerate(single):
	if x != pipeline[i]:
		print("single: "+x)
		print("pipeline: "+pipeline[i])
		break