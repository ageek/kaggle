from __future__ import division
import csv

f_pred = file('./prediction', 'rb')

f_benchmark = file('./knn_benchmark.csv', 'rb')
f_benchmark.readline()

hits =0 
miss = 0

for pred,bench in zip(csv.reader(f_pred), csv.reader(f_benchmark)):
    predicted = int(float(pred[0]))
    if predicted==10:
        predicted =0
    benchmark =  int(bench[1])
    if(benchmark==predicted):
        hits +=1
    else:
        miss +=1


print "hits="+str( hits)
print "miss="+ str(miss)

accuracy =  hits/(hits+miss)

print "Accuracy = %f" %accuracy
