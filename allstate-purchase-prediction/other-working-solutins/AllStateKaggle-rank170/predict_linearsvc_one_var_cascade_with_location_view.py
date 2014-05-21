import os
import pandas as pd
import numpy as np
from sklearn import preprocessing
import sys
sys.path.append(os.path.join("lib"))

from AllStateDataLoader import AllStateDataLoader

from sklearn import svm
from sklearn.externals import joblib
from sklearn import grid_search

def fit_and_save_log(parameters, X, y , filename, verbose=2):
    log = svm.LinearSVC(class_weight="auto")

    model = grid_search.GridSearchCV(log, parameters, verbose=verbose)
    model.fit(X,y)

    joblib.dump(model, filename)

    return model


# fitting models
parameters = {'C' : [0.1, 0.5, 1.0], 'loss' : ['l2'], 'penalty' : ['l1','l2'], 'dual' : [False]}
l = AllStateDataLoader()


def get_model_filename(type_dataset, objective_letter, real_letters):
    if real_letters == "":
        return os.path.join("model_linearsvc", "model_linearsvc_data_%s_%s_without_real_cascade_with_location_view.pkl" % (type_dataset, objective_letter))
    else:
        return os.path.join("model_linearsvc", "model_linearsvc_data_%s_%s_with_real_%s_cascade_with_location_view.pkl" % (type_dataset, objective_letter, real_letters))

for datasetname in ["2", "3", "4", "all"]:
    # Model D sans rien
    model_filename = get_model_filename(datasetname, "D", "")
    if not os.path.exists(model_filename):
        print("Calcul model %s sur dataset %s (%s)" % ("D", datasetname, model_filename))
        X = l.get_X_train(datasetname, "")
        y = l.get_y(datasetname, "D")
        model = fit_and_save_log(parameters, np.array(X), np.array(y), model_filename)
        
    # Model C avec info D
    model_filename = get_model_filename(datasetname, "C", "D")
    if not os.path.exists(model_filename):
        print("Calcul model %s sur dataset %s (%s)" % ("C", datasetname, model_filename))
        X = l.get_X_train(datasetname, "D")
        y = l.get_y(datasetname, "C")
        model = fit_and_save_log(parameters, np.array(X), np.array(y), model_filename)

    # Model E sans rien
    model_filename = get_model_filename(datasetname, "E", "")
    if not os.path.exists(model_filename):
        print("Calcul model %s sur dataset %s (%s)" % ("E", datasetname, model_filename))
        X = l.get_X_train(datasetname, "")
        y = l.get_y(datasetname, "E")
        model = fit_and_save_log(parameters, np.array(X), np.array(y), model_filename)

    # Model B avec info E
    model_filename = get_model_filename(datasetname, "B", "E")
    if not os.path.exists(model_filename):
        print("Calcul model %s sur dataset %s" % ("B", datasetname))
        X = l.get_X_train(datasetname, "E")
        y = l.get_y(datasetname, "B")
        model = fit_and_save_log(parameters, np.array(X), np.array(y), model_filename)

    # Model F avec info E
    model_filename = get_model_filename(datasetname, "F", "E")
    if not os.path.exists(model_filename):
        print("Calcul model %s sur dataset %s (%s)" % ("F", datasetname, model_filename))
        X = l.get_X_train(datasetname, "E")
        y = l.get_y(datasetname, "F")
        model = fit_and_save_log(parameters, np.array(X), np.array(y), model_filename)

    # Model A avec info EF
    model_filename = get_model_filename(datasetname, "A", "EF")
    if not os.path.exists(model_filename):
        print("Calcul model %s sur dataset %s (%s)" % ("A", datasetname, model_filename))
        X = l.get_X_train(datasetname, "EF")
        y = l.get_y(datasetname, "A")
        model = fit_and_save_log(parameters, np.array(X), np.array(y), model_filename)

    # Model G avec A
    model_filename = get_model_filename(datasetname, "G", "A")
    if not os.path.exists(model_filename):
        print("Calcul model %s sur dataset %s (%s)" % ("G", datasetname, model_filename))
        X = l.get_X_train(datasetname, "A")
        y = l.get_y(datasetname, "G")
        model = fit_and_save_log(parameters, np.array(X), np.array(y), model_filename)
        
