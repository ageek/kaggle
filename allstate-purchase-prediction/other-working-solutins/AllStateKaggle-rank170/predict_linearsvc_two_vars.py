import os
import pandas as pd
import numpy as np
from sklearn import preprocessing
import sys
sys.path.append(os.path.join("lib"))

from AllStateDataLoader import AllStateDataLoader


def get_X_columns(data):

    return [x for x in data.columns if x not in ["real_%s" % letter for letter in ['A','B','C','D','E','F','G']]]


def get_X_with_scaler(data):
    tmp = data.copy()

    for variable in ["real_%s" % x for x in ['A','B','C','D','E','F','G']]:
        del tmp[variable]

    scaler = preprocessing.StandardScaler()
    scaler.fit(tmp)

    return (scaler, scaler.transform(tmp))

def get_X_without_scaler(data):
    tmp = data.copy()

    for variable in ["real_%s" % x for x in ['A','B','C','D','E','F','G']]:
        del tmp[variable]

    # scaler = preprocessing.StandardScaler()
    # scaler.fit(tmp)

    return np.array(tmp)

def get_y_value(letter, value, data):

    tmp = data.copy()

    return np.array(np.where(tmp["real_%s" % letter] == value, 1, 0))

def get_y(letter_1, letter_2, data):

    def concat_12(x):
        return "%d%d" % (x["real_%s" % letter_1], x["real_%s" % letter_2])

    tmp = data.copy()

    return np.array(tmp.apply(concat_12, axis=1)).astype(str)


from sklearn import svm
from sklearn.externals import joblib
from sklearn import grid_search

l = AllStateDataLoader()
print("Extraction data_2...")
data_2 = l.get_data_2_train()
print("Extraction data_3...")
data_3 = l.get_data_3_train()
print("Extraction data_all...")
data_all = l.get_data_all_train()

def fit_and_save_log(parameters, dataset, letter_1, letter_2, filename,verbose=2):
    log = svm.LinearSVC(class_weight='auto')

    X = get_X_without_scaler(dataset)
    y = get_y(letter_1, letter_2, dataset)

    model = grid_search.GridSearchCV(log, parameters, verbose=verbose)
    model.fit(X,y)

    print("sauvegarde model %s%s dans %s" % (letter_1, letter_2, filename))
    joblib.dump(model, filename)

    return model


# fitting models
parameters = {'C' : [0.1, 0.5, 1.0], 'loss' : ['l2'], 'penalty' : ['l1', 'l2'], 'dual' : [False]}

dataset = {'2' : data_2, '3' : data_3, 'all' : data_all}

for letter_1 in ['A','B','C','D','E','F','G']:
    for letter_2 in ['A','B','C','D','E','F','G']:
        if letter_1 < letter_2:
            for datasetname in sorted(dataset.keys()):
                model_filename = os.path.join("model_linearsvc", "model_linearsvc_data_%s_%s%s_not_centered.pkl" % (datasetname, letter_1, letter_2))

                if not os.path.exists(model_filename):
                    print("Calcul model %s%s sur dataset %s" % (letter_1, letter_2, datasetname))
                    data = dataset[datasetname]
                    model = fit_and_save_log(parameters, data, letter_1, letter_2, model_filename)
        


