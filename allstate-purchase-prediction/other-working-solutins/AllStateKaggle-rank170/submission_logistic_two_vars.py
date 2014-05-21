import os
import sys
import pandas as pd
from sklearn.externals import joblib
sys.path.append("lib")

from AllStateDataLoader import AllStateDataLoader

l = AllStateDataLoader()

data_train_all = l.get_data_all_train()

data_train_all_np = l.get_X_without_scaler(data_train_all)

def predict_AB(data, letter_1, letter_2):
    model_name = os.path.join("model_logistic", "model_logistic_data_all_%s%s_not_centered.pkl" % (letter_1, letter_2))
    model = joblib.load(model_name)
    list_classes = model.best_estimator_.classes_

    prediction = model.predict_proba(data)
    prediction_cumsum = np.cumsum(prediction, axis=1)
    prediction_classes = np.apply_along_axis(
        lambda x : np.searchsorted(x, np.random.uniform()),
        axis=1,
        arr=prediction_cumsum
    )

    prediction_real_classes = list_classes[prediction_classes]

    return prediction_real_classes


for letter_1 in ['A','B','C','D','E','F','G']:
    for letter_2 in ['A','B','C','D','E','F','G']:
        if letter_1 < letter_2:
            print "prediction %s%s..." % (letter_1, letter_2)
            tmp = predict_AB(data_train_all_np, letter_1, letter_2)
            data_train_all["prediction_%s%s" % (letter_1, letter_2)] = tmp



def votes_A(x):
    tmp = {"0":0, "1":0, "2":0}

    tmp[x["prediction_AB"][0]] += 1
    tmp[x["prediction_AC"][0]] += 1
    tmp[x["prediction_AD"][0]] += 1
    tmp[x["prediction_AE"][0]] += 1
    tmp[x["prediction_AF"][0]] += 1
    tmp[x["prediction_AG"][0]] += 1

    a = np.array([tmp["0"], tmp["1"], tmp["2"]])/6.0

    return np.searchsorted(np.cumsum(a), np.random.uniform())

    

data_train_all["prediction_A"] = data_train_all.apply(votes_A, axis=1)

