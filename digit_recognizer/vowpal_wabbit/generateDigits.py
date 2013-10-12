import csv
from scipy import misc
import numpy as np
import cv2

# Use this cript to convert the raw data to actual image files
# for some data only, and see how the data actually looks like
# blah .. :-)

imagelists=[]
print "Reading csv file..."
#with open('./digits_2000.csv','rb') as csvfile:
f = file('./train_10.csv')
#skip the header
f.next()
for line in csv.reader(f):
	#print line
	imagelists.append(line)

for i,counter in zip(imagelists,xrange(len(imagelists))):
	# image is 28x28 pixels
	# and the value starts from i[1] to i[785] , total of 28x28 = 784 pixesl
    rawimg = i[1:]
    imgclass = int(i[0])
	# convert list to arrya using numpy
    img=np.asarray(rawimg,dtype='uint8')
    #print img.shape
	# image is 28x28 pixels
	# and the value starts from i[1] to i[785] , total of 28x28 = 784 pixesl
    im=img.reshape((28,28))
    print "Writing image file.."+str(counter)
    #misc.imsave('random_%02d.png' %counter, im)
    cv2.imwrite('./digits/%d/random_%02d.png' %(imgclass, counter), im)

