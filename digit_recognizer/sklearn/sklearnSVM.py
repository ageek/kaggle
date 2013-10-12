import csv
import numpy as np
from sklearn import svm,metrics


def images2Vector(filePath):
	imageVector=[]
	labelsVector=[]
	print "Reading csv file..."
	f = file(filePath, 'rb')
	#skip header
	f.readline()
	# we dont hve headers, so no need to skip the first row
	for line in csv.reader(f):
		#print line
		labelsVector.append(line[0])
		imageVector.append(line[1:])

	#convert the data List to np arrary
	imageVector=np.asarray(imageVector, dtype='uint8')
	labelsVector = np.asarray(labelsVector, dtype='uint8')

	return imageVector, labelsVector


filePath = "./../kgg/train.csv"

#initially try on a small set of data
fPath = "./../kgg/train_500.csv"
digits, labels = images2Vector(fPath)
print len(digits)
print len(labels)

# create a SVM classifier
# SVC with default parameters gives weird results -
# Reasons: 1. it uses RBF kernel
#svmclassifier = svm.SVC(gamma=0.001)

#linear SVC is working fine - gives around 84% accuracy-not good but OK
#svmclassifier = svm.LinearSVC()

svmclassifier = svm.SVC(kernel='linear', verbose=True)

n_samples=len(digits)

#train for half of data
print "train on full data...-> 42k samples"
#svmclassifier.fit(digits[:n_samples/2], labels[:n_samples/2])
svmclassifier.fit(digits[:n_samples/2], labels[:n_samples/2])

#now do prediction for the remaining data
print "test on remaining half data..."
expected = labels[n_samples/2:]
predicted = svmclassifier.predict(digits[n_samples/2:])

#display results
print "Classification report for classifier %s:\n%s\n" % ( 
svmclassifier, metrics.classification_report(expected, predicted))

print "Confusion matrix:\n%s" % metrics.confusion_matrix(expected, predicted)

