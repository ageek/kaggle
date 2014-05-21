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

# # X_2 = l.get_X_train("2", "")
# y_2 = l.get_y("2", "ABCDEFG")
# y_2_predict = p.predict_simple("2", "logistic", "ABCDEFG", kind="train")

# # X_3 = l.get_X_train("3", "")
# y_3 = l.get_y("3", "ABCDEFG")
# y_3_predict = p.predict_simple("3", "logistic", "ABCDEFG", kind="train")

# # X_all = l.get_X_train("all", "")
# y_all = l.get_y("all", "ABCDEFG")
# y_all_predict = p.predict_simple("all", "logistic", "ABCDEFG", kind="train")


# print "score 2   logistic : %.4f" % (score(y_2, y_2_predict))
# print "score 3   logistic : %.4f" % (score(y_3, y_3_predict))
# print "score all logistic : %.4f" % (score(y_all, y_all_predict))

# X_2 = l.get_X_train("2", "")
y_2 = l.get_y("2", "ABCDEFG")
y_2_predict = p.predict_simple("2", "linearsvc", "ABCDEFG", kind="train")

# X_3 = l.get_X_train("3", "")
y_3 = l.get_y("3", "ABCDEFG")
y_3_predict = p.predict_simple("3", "linearsvc", "ABCDEFG", kind="train")

# X_4 = l.get_X_train("4", "")
y_4 = l.get_y("4", "ABCDEFG")
y_4_predict = p.predict_simple("4", "linearsvc", "ABCDEFG", kind="train")

# X_all = l.get_X_train("all", "")
y_all = l.get_y("all", "ABCDEFG")
y_all_predict = p.predict_simple("all", "linearsvc", "ABCDEFG", kind="train")

print "score 2   linearsvc : %.4f" % (score(y_2, y_2_predict))
print "score 3   linearsvc : %.4f" % (score(y_3, y_3_predict))
print "score 4   linearsvc : %.4f" % (score(y_4, y_4_predict))
print "score all linearsvc : %.4f" % (score(y_all, y_all_predict))
