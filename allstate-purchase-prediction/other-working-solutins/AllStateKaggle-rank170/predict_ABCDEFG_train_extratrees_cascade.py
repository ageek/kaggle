import sys
sys.path.append("lib")

from AllStateDataLoader import AllStateDataLoader
from AllStatePredictor import AllStatePredictor
from sklearn import linear_model
from sklearn import grid_search
import numpy as np


def score(y_predict, y_real):
    n = float(y_predict.shape[0])

    n_ok = float(np.sum(y_predict == y_real))

    return (n_ok/n)

l = AllStateDataLoader()
p = AllStatePredictor()

# X_2 = l.get_X_train("2", "")
y_2 = l.get_y("2", "ABCDEFG")
y_2_predict = p.predict_cascade("2", "extratrees", "ABCDEFG", kind="train")

# X_3 = l.get_X_train("3", "")
y_3 = l.get_y("3", "ABCDEFG")
y_3_predict = p.predict_cascade("3", "extratrees", "ABCDEFG", kind="train")

# X_4 = l.get_X_train("4", "")
y_4 = l.get_y("4", "ABCDEFG")
y_4_predict = p.predict_cascade("4", "extratrees", "ABCDEFG", kind="train")

# X_all = l.get_X_train("all", "")
y_all = l.get_y("all", "ABCDEFG")
y_all_predict = p.predict_cascade("all", "extratrees", "ABCDEFG", kind="train")

print "score 2   extratrees cascade : %.4f" % (score(y_2, y_2_predict))
print "score 3   extratrees cascade : %.4f" % (score(y_3, y_3_predict))
print "score 4   extratrees cascade : %.4f" % (score(y_4, y_4_predict))
print "score all extratrees cascade : %.4f" % (score(y_all, y_all_predict))
