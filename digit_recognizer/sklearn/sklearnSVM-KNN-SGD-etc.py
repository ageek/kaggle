import csv
import numpy as np
from sklearn import svm,metrics
from sklearn import neighbors
from sklearn.linear_model.stochastic_gradient import SGDClassifier

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


def getKNNClassifier(X,Y):
	classifier = neighbors.KNeighborsClassifier(n_neighbors=8, weights='distance', algorithm='kd_tree',)

	#train for half of data
	print "[KNN Classifier] train on full data...-> 42k samples"
	#svmclassifier.fit(digits[:n_samples/2], labels[:n_samples/2])
	n_samples = len(X)
	classifier.fit(X[:n_samples/2], Y[:n_samples/2])
	return classifier

def getLinearSVMClassifier(X,Y):
	svmclassifier = svm.SVC(kernel='linear', verbose=True)
	n_samples = len(X)
	print "[LinearSVM Classifier] train on full data...-> 42k samples"
	svmclassifier.fit(X[:n_samples/2], Y[:n_samples/2])

	return svmclassifier

def getSGDClassifier(X,Y):
	sgdclassifier = SGDClassifier(loss='log', penalty='l1', n_iter=10, shuffle=True,random_state=0)
	print "[SGD Classifier] train on full data...-> 42k samples"
	sgdclassifier.fit(X,Y)

	return sgdclassifier


def writePredictions(filePath, predicted):
	f = file(filePath, 'w')
	fileData = ''
	for singlerow in predicted:
		fileData += str(singlerow) + "\n"

	print "writing predictions file..."
	f.write(fileData)

def printStats(classifier, expected, predicted):
	#display results
	print "Classification report for classifier %s:\n%s\n" % ( 
	classifier, metrics.classification_report(expected, predicted))

	print "Confusion matrix:\n%s" % metrics.confusion_matrix(expected, predicted)

def loadTestData(filePath):
	f = file(filePath)
	#skip header
	f.readline()
	testVector=[]
	for line in csv.reader(f):
		testVector.append(line)

	#convert the data List to np arrary
	testVector=np.asarray(testVector, dtype='uint8')
	return testVector


if __name__ == "__main__":


	#initially try on a small set of data
	fPath = "./../kgg/train.csv"
	digits, labels = images2Vector(fPath)

	# create a SVM classifier
	# SVC with default parameters gives weird results -
	# Reasons: 1. it uses RBF kernel
	#svmclassifier = svm.SVC(C=100, kernel='rbf', gamma=0.001)

	#linear SVC is working fine - gives around 84% accuracy-not good but OK
	#svmclassifier = svm.LinearSVC()

	#svmclassifier = svm.SVC(kernel='linear', verbose=True)


	n_samples = len(digits)
	#now do prediction for the remaining data
	#knn_classifier = getKNNClassifier(digits, labels)
	expected = labels[n_samples/2:]
	#predicted = knn_classifier.predict(digits[n_samples/2:])
	#writePredictions('./predictions_knn', predicted)
	
	#printStats(knn_classifier, predicted, expected)

	testdata = loadTestData('./../kgg/test.csv')
	sgd_classifier = getSGDClassifier(digits,labels)

	print "test on remaining half data..."
	predicted = sgd_classifier.predict(testdata)

	#printStats(sgd_classifier, predicted, expected)


	#testdata = loadTestData('./../kgg/test.csv')
	#predicted = sgd_classifier.predict(testdata)
	writePredictions('./predictions_sgd', predicted)
