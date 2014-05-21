import os
import pandas as pd
import numpy as np
# import matplotlib.pyplot as plt
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

def get_y(letter, data):

    tmp = data.copy()

    return np.array(tmp["real_%s" % letter])


from sklearn import linear_model
from sklearn.externals import joblib
from sklearn import grid_search

l = AllStateDataLoader()
print("Extraction data_2...")
data_2 = l.get_data_2_train()
print("Extraction data_3...")
data_3 = l.get_data_3_train()
print("Extraction data_all...")
data_all = l.get_data_all_train()

def fit_and_save_log(parameters, dataset, letter, filename,verbose=2):
    log = linear_model.LogisticRegression()

    X = get_X_without_scaler(dataset)
    y = get_y(letter, dataset)

    model = grid_search.GridSearchCV(log, parameters, verbose=verbose)
    model.fit(X,y)

    print("sauvegarde model %s dans %s" % (letter, filename))
    joblib.dump(model, filename)

    return model


# fitting models
parameters = {'penalty' : ['l1','l2'], 'C' : [0.1, 0.5, 1, 5]}

model_list = {}
dataset = {'2' : data_2, '3' : data_3, 'all' : data_all}

for letter in ['A','B','C','D','E','F','G']:
    model_list[letter] = {}
    for datasetname in sorted(dataset.keys()):
        model_filename = os.path.join("model_logistic", "model_logistic_data_%s_%s_not_centered.pkl" % (datasetname, letter))

        if not os.path.exists(model_filename):
            print("Calcul model %s sur dataset %s" % (letter, datasetname))
            data = dataset[datasetname]
            model = fit_and_save_log(parameters, data, letter, model_filename)
        
            # model_list[letter][datasetname] = model

