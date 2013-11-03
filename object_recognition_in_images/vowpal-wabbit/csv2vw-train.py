import csv

imagelists=[]
f = file('./train_all_int_label.csv', 'rb')

#skip first line
#f.readline()
fileData =''

for oneline in csv.reader(f):
	line =''
	label=oneline[0]
	if(int(label)==0):
		label=10
	imgdata=oneline[1:]
	for index,value in enumerate(imgdata):
	#	if int(float(value))!=0:
			#print "value-->"+str(value)
		line += str(index)+":"+str(value)+" "
	#	else:
	#		print skipping line
	#		continue

	line = str(label) + " | " + "f " + str(line) + "\n"
	fileData += line 


#write file content to vw file
f = open('./vw-train-all.vw','w')
f.write(fileData)
