import csv

imagelists=[]
f_train = file('./train.csv', 'rb')
f_label = file('./trainLabels.csv','rb')

#skip first line
fileData =''

for onetrain,label in zip(csv.reader(f_train), f_label.readlines()) :
	line =''
	label = label[0].split()[0]
	if(int(label)==0):
		label = -1
	for index,value in zip(range(len(onetrain)),onetrain):
		#print "value-->"+str(value)
		line += str(index)+":"+str(value)+" "

	line = str(label) + " | " + "f " + str(line) + "\n"
	fileData += line 


#write file content to vw file
f = open('./vw-train-all.vw','w')
f.write(fileData)
