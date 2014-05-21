import sys
sys.path.append("lib")

from AllStateDataLoader import AllStateDataLoader
from AllStatePredictor import AllStatePredictor
from sklearn import linear_model
from sklearn import grid_search
import numpy as np
import pandas as pd

p = AllStatePredictor()

y_2_predict = p.predict_simple("2", "linearsvc", "ABCDEFG", kind="test")
y_3_predict = p.predict_simple("3", "linearsvc", "ABCDEFG", kind="test")
y_4_predict = p.predict_simple("4", "linearsvc", "ABCDEFG", kind="test")
y_all_predict = p.predict_simple("all", "linearsvc", "ABCDEFG", kind="test")

y_submission = y_2_predict.append([
    y_3_predict,
    y_4_predict,
    y_all_predict
])

y_submission = y_submission.sort_index()

df = pd.DataFrame(data={'plan':y_submission}, index=y_submission.index)

df.to_csv("linearsvc_simple_sans_location.csv")
