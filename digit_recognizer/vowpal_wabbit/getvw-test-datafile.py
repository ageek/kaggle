import csv

f = file('./../kgg/test.csv')
f.readline()


fileData =''
for oneline in csv.reader(f):
	line =''
	#defautl label for all
	label=6
	imgdata=oneline
	for index,value in zip(range(len(imgdata)),imgdata):
		if int(value)!=0:
			#print "value-->"+str(value)
			line += str(index)+":"+str(value)+" "
		else:
			continue

	line = str(label) + " | " + "Data " + str(line) + "\n"
	fileData += line 


#write file content to vw file
f = open('./vw-test-28k.vw','w')
f.write(fileData)
