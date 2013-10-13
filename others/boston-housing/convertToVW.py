

f=file('./housing.data','rb')
lines = f.readlines()

fileData = ''
for line in lines:
	onerow = ''
	data = line.split()
	label = data[len(data)-1]
	onerow += str(label) + " | f"

	onerow += " CRIM:" + data[0]
	onerow += " ZN:" + data[1]
	onerow += " INDUS:" + data[2]
	onerow += " CHAS:" + data[3]
	onerow += " NOX:" + data[4]
	onerow += " RM:" + data[5]
	onerow += " AGE:" + data[6]
	onerow += " DIS:" + data[7]
	onerow += " RAD:" + data[8]
	onerow += " TAX:" + data[9]
	onerow += " PTRATIO:" + data[10]
	onerow += " B:" + data[11]
	onerow += " LSTAT:" + data[12]

	onerow += "\n"

	fileData += onerow

f = file('./housing-data.vw','w')
f.write(fileData)
