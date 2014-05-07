import csv

f = file('././../../../cifar-10/test_all_gray_unscaled_int.csv')

#f.readline()


fileData =''
for oneline in csv.reader(f):
	line =''
	#defautl label for all
	label=6
	imgdata=oneline
	for index,value in zip(range(len(imgdata)),imgdata):
		line += str(index)+":"+str(value)+" "

	line = str(label) + " | " + "f " + str(line) + "\n"
	fileData += line 


#write file content to vw file
f = open('./test_all_gray_unscaled_int.vw','w')
f.write(fileData)
