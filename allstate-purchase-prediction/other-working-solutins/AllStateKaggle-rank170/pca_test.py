import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
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

def duplicate_data(data):

    tmp = data.copy()

    def concat_letter_12(x):
        return x[variable_1]*x[variable_2]

    for letter_1 in ['A','B','C','D','E','F','G']:
        for letter_2 in ['A','B','C','D','E','F','G']:
            if letter_1 < letter_2:
                for variable_1 in [x for x in list(tmp.columns) if x.startswith("value_%s_last" % letter_1)]:
                    for variable_2 in [x for x in list(tmp.columns) if x.startswith("value_%s_last" % letter_2)]:
                        print "Eval %s => %s" % (variable_1, variable_2)
                        variable_12 = "dup_%s_%s" % (variable_1, variable_2)
                        tmp[variable_12] = tmp.apply(concat_letter_12, axis=1)
                        
    tmp = tmp.reindex(columns=sorted(list(tmp.columns)))

    return tmp


from sklearn import decomposition

l = AllStateDataLoader()
print("Extraction data_2...")
data_2 = l.get_data_2_train()
print("Extraction data_3...")
data_3 = l.get_data_3_train()
print("Extraction data_all...")
data_all = l.get_data_all_train()

data_all_reindexed = duplicate_data(data_all)

pca = decomposition.SparsePCA(n_components=3, verbose=True)

X = get_X_without_scaler(data_all_reindexed)
pca.fit(X)
X_pca = pca.transform(X)

x1 = -600
x2 = 400
y1 = -80
y2 = 80

plt.figure()
plt.subplot(311)
plt.plot(X_pca[data_all["real_A"] == 1,2], X_pca[data_all["real_A"] == 1,1], "b+")
#plt.axis((x1,x2,y1,y2))
plt.subplot(312)
plt.plot(X_pca[data_all["real_A"] == 2,2], X_pca[data_all["real_A"] == 2,1], "g+")
#plt.axis((x1,x2,y1,y2))
plt.subplot(313)
plt.plot(X_pca[data_all["real_A"] == 0,2], X_pca[data_all["real_A"] == 0,1], "r+")
#plt.axis((x1,x2,y1,y2))
plt.show()
