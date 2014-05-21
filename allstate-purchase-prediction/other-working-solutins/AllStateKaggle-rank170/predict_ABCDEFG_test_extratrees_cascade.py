import sys
sys.path.append("lib")

from AllStateDataLoader import AllStateDataLoader
from AllStatePredictor import AllStatePredictor
from sklearn import linear_model
from sklearn import grid_search
import numpy as np
import pandas as pd

p = AllStatePredictor()

y_2_predict = p.predict_cascade("2", "extratrees", "ABCDEFG", kind="test")
y_3_predict = p.predict_cascade("3", "extratrees", "ABCDEFG", kind="test")
y_4_predict = p.predict_cascade("4", "extratrees", "ABCDEFG", kind="test")
y_all_predict = p.predict_cascade("all", "extratrees", "ABCDEFG", kind="test")

y_submission = y_2_predict.append([
    y_3_predict,
    y_4_predict,
    y_all_predict
])

y_submission = y_submission.sort_index()

df = pd.DataFrame(data={'plan':y_submission}, index=y_submission.index)

df.to_csv("extratrees_cascade_sans_location.csv")
