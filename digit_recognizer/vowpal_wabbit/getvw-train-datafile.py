import csv

imagelists=[]
f = file('./../kgg/train.csv', 'rb')

#skip first line
f.readline()
fileData =''

for oneline in csv.reader(f):
	line =''
	label=oneline[0]
	if(int(label)==0):
		label=10
	imgdata=oneline[1:]
	for index,value in zip(range(len(imgdata)),imgdata):
		if int(value)!=0:
			#print "value-->"+str(value)
			line += str(index)+":"+str(value)+" "
		else:
			continue

	line = str(label) + " | " + "f " + str(line) + "\n"
	fileData += line 


#write file content to vw file
f = open('./vw-train-all-42k.vw','w')
f.write(fileData)
