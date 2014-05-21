import sys
sys.path.append("lib")

from AllStateDataLoader import AllStateDataLoader
from sklearn import linear_model
from sklearn import grid_search
import numpy as np

l = AllStateDataLoader()

# Model C sans rien
X_all = l.get_X_train("all", "")
y_all = l.get_y("all", "C")

parameters = {'penalty' : ['l2'], 'C' : np.logspace(-3, 0, 3)}
model_C = grid_search.GridSearchCV(
    linear_model.LogisticRegression(),
    parameters,
    verbose=2
)
model_D.fit(np.array(X_all), np.array(y_all))

# Model D sans rien
X_all = l.get_X_train("all", "")
y_all = l.get_y("all", "D")

parameters = {'penalty' : ['l2'], 'C' : np.logspace(-3, 0, 3)}
model_D = grid_search.GridSearchCV(
    linear_model.LogisticRegression(),
    parameters,
    verbose=2
)
model_D.fit(np.array(X_all), np.array(y_all))

# Model C avec D
X_all = l.get_X_train("all", "D")
y_all = l.get_y("all", "C")

parameters = {'penalty' : ['l2'], 'C' : np.logspace(-3, 0, 3)}
model_C_avec_D = grid_search.GridSearchCV(
    linear_model.LogisticRegression(),
    parameters,
    verbose=2
)
model_C_avec_D.fit(np.array(X_all), np.array(y_all))

# Model D avec C
X_all = l.get_X_train("all", "C")
y_all = l.get_y("all", "D")

parameters = {'penalty' : ['l2'], 'C' : np.logspace(-3, 0, 5)}
model_C_avec_D = grid_search.GridSearchCV(
    linear_model.LogisticRegression(),
    parameters,
    verbose=2
)
model_C_avec_D.fit(np.array(X_all), np.array(y_all))

# A => E, F
# B => E
# C => D
# D => C
# E => A, B, F
# F => A, E
# G(2) => A(2)
# G(3) => A(3)