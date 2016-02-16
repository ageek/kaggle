# https://www.kaggle.com/mpearmain/bnp-paribas-cardif-claims-management/bayesianoptimization-of-random-forest/code
# An Example of using bayesian optimization for tuning optimal parameters for a
# random forest model.

# The simple idea is to add more intelligence to parameter tuning than a grid search
# or a random search. (The Guassian Process is the clever part and something that hyperopt
# doesnt currently have -- though i could be wrong)

# Original library https://github.com/fmfn/BayesianOptimization
# Example using xgboost and optimal parameters https://github.com/mpearmain/BayesBoost

# This script is VERY long due to the need to copy all functions from the original 
# bayesian optimization script.

# The data preparation is a complete steal from trottefox's blending script.
# https://www.kaggle.com/trottefox/bnp-paribas-cardif-claims-management/blending-trees/code
# It just makes life easy to ctrl-c ctrl-v :)

# I strongly advise downoading the libs from git to play around with.

import numpy
import pandas as pd
import random
from datetime import datetime
from sklearn.gaussian_process import GaussianProcess as GP
from sklearn.metrics import log_loss
from scipy.optimize import minimize
from scipy.stats import norm
from math import exp, fabs, sqrt, log, pi
from sklearn.ensemble import RandomForestClassifier as RFC
rnd=57
maxCategories=20

def acq_max(ac, gp, ymax, restarts, bounds):
    """
    A function to find the maximum of the acquisition function using the 'L-BFGS-B' method.

    Parameters
    ----------
    :param ac: The acquisition function object that return its pointwise value.

    :param gp: A gaussian process fitted to the relevant data.

    :param ymax: The current maximum known value of the target function.

    :param restarts: The number of times minimation if to be repeated. Larger number of restarts
                     improves the chances of finding the true maxima.

    :param bounds: The variables bounds to limit the search of the acq max.


    Returns
    -------
    :return: x_max, The arg max of the acquisition function.
    """

    x_max = bounds[:, 0]
    ei_max = 0

    for i in range(restarts):
        #Sample some points at random.
        x_try = numpy.asarray([numpy.random.uniform(x[0], x[1], size=1) for x in bounds]).T

        #Find the minimum of minus the acquisition function
        res = minimize(lambda x: -ac(x.reshape(1, -1), gp=gp, ymax=ymax), x_try, bounds=bounds, method='L-BFGS-B')

        #Store it if better than previous minimum(maximum).
        if -res.fun >= ei_max:
            x_max = res.x
            ei_max = -res.fun

    return x_max

def unique_rows(a):
    """
    A functions to trim repeated rows that may appear when optimizing.
    This is necessary to avoid the sklearn GP object from breaking

    :param a: array to trim repeated rows from

    :return: mask of unique rows
    """

    # Sort array and kep track of where things should go back to
    order = numpy.lexsort(a.T)
    reorder = numpy.argsort(order)

    a = a[order]
    diff = numpy.diff(a, axis=0)
    ui = numpy.ones(len(a), 'bool')
    ui[1:] = (diff != 0).any(axis=1)

    return ui[reorder]


class BayesianOptimization(object):
    """
    Bayesian global optimization with Gaussian Process.

    See papers: http://papers.nips.cc/paper/4522-practical-bayesian-optimization-of-machine-learning-algorithms.pdf
                http://arxiv.org/pdf/1012.2599v1.pdf
                http://www.gaussianprocess.org/gpml/
    for references.

    """

    def __init__(self, f, pbounds, verbose=1):
        """
        :param f: Function to be maximized.

        :param pbounds: Dictionary with parameters names as keys and a tuple with
                        minimum and maximum values.

        :param verbose: Controls levels of verbosity.

        """
        # Store the original dictionary
        self.pbounds = pbounds

        # Get the name of the parameters
        self.keys = list(pbounds.keys())

        # Find number of parameters
        self.dim = len(pbounds)

        # Create an array with parameters bounds
        self.bounds = []
        for key in self.pbounds.keys():
            self.bounds.append(self.pbounds[key])
        self.bounds = numpy.asarray(self.bounds)

        # Some function to be optimized
        self.f = f

        # Initialization flag
        self.initialized = False

        # Initialization lists --- stores starting points before process begins
        self.init_points = []
        self.x_init = []
        self.y_init = []

        # Verbose
        self.verbose = verbose

    def init(self, init_points):
        """
        Initialization method to kick start the optimization process. It is a combination of
        points passed by the user, and randomly sampled ones.

        :param init_points: Number of random points to probe.
        """

        # Generate random points
        l = [numpy.random.uniform(x[0], x[1], size=init_points) for x in self.bounds]

        # Concatenate new random points to possible existing points from self.explore method.
        self.init_points += list(map(list, zip(*l)))

        # Create empty list to store the new values of the function
        y_init = []

        # Evaluate target function at all initialization points (random + explore)
        for x in self.init_points:

            if self.verbose:
                print('Initializing function at point: ', dict(zip(self.keys, x)), end='')

            y_init.append(self.f(**dict(zip(self.keys, x))))

            if self.verbose:
                print(' | result: %f' % y_init[-1])

        # Append any other points passed by the self.initialize method (these also have
        # a corresponding target value passed by the user).
        self.init_points += self.x_init

        # Append the target value of self.initialize method.
        y_init += self.y_init

        # Turn it into numpy array and store.
        self.X = numpy.asarray(self.init_points)
        self.Y = numpy.asarray(y_init)

        # Updates the flag
        self.initialized = True

    def explore(self, points_dict):
        """ Main optimization method.
            Parameters
            ----------
            points_dict: {p1: [x1, x2...], p2: [y1, y2, ...]}

            Returns
            -------
            Nothing.

        """

        ################################################
        # Consistency check
        param_tup_lens = []

        for key in self.keys:
            param_tup_lens.append(len(list(points_dict[key])))

        if all([e == param_tup_lens[0] for e in param_tup_lens]):
            pass
        else:
            raise ValueError('The same number of initialization points must be entered for every parameter.')

        ################################################
        # Turn into list of lists
        all_points = []
        for key in self.keys:
            all_points.append(points_dict[key])

        # Take transpose of list
        self.init_points = list(map(list, zip(*all_points)))

    def initialize(self, points_dict):
        """
            Main optimization method.
            Parameters
            ----------
            points_dict: {y: {x1: x, ...}}


            Returns
            -------
            Nothing.

        """

        for target in points_dict:

            self.y_init.append(target)

            all_points = []
            for key in self.keys:
                all_points.append(points_dict[target][key])

            self.x_init.append(all_points)

    def set_bounds(self, new_bounds):
        """
        A method that allows changing the lower and upper searching bounds

        :param new_boudns: A dictionary with the parameter name and its new bounds

        """

        # Update the internal object stored dict
        self.pbounds.update(new_bounds)

        # Loop through the all bounds and reset the min-max bound matrix
        for row, key in enumerate(self.pbounds.keys()):

            # Reset all entries, even if the same.
            self.bounds[row] = self.pbounds[key]

    def maximize(self, init_points=5, restarts=50, n_iter=25, acq='ei', **gp_params):
        """
        Main optimization method.

        Parameters
        ----------
        :param init_points: Number of randomly chosen points to sample the target function before fitting the gp.

        :param restarts: The number of times minimation if to be repeated. Larger number of restarts
                         improves the chances of finding the true maxima.

        :param n_iter: Total number of times the process is to reapeated. Note that currently this methods does not have
                       stopping criteria (due to a number of reasons), therefore the total number of points to be sampled
                       must be specified.

        :param acq: Acquisition function to be used, defaults to Expected Improvement.

        :param gp_params: Parameters to be passed to the Scikit-learn Gaussian Process object

        Returns
        -------
        :return: Nothing
        """
        # Start a timer
        total_time = datetime.now()

        # Create instance of printer object
        printI = PrintInfo(self.verbose)

        # Set acquisition function
        AC = AcquisitionFunction()
        ac_types = {'ei': AC.EI, 'pi': AC.PoI, 'ucb': AC.UCB}
        ac = ac_types[acq]

        # Initialize x, y and find current ymax
        if not self.initialized:
            self.init(init_points)

        ymax = self.Y.max()

        # ------------------------------ // ------------------------------ // ------------------------------ #
        # Fitting the gaussian process.
        # Since scipy 0.16 passing lower and upper bound to theta seems to be
        # broken. However, there is a lot of development going on around GP
        # is scikit-learn. So I'll pick the easy route here and simple specify
        # only theta0.
        gp = GP(theta0=numpy.random.uniform(0.001, 0.05, self.dim),
                random_start=25)

        gp.set_params(**gp_params)

        # Find unique rows of X to avoid GP from breaking
        ur = unique_rows(self.X)
        gp.fit(self.X[ur], self.Y[ur])

        # Finding argmax of the acquisition function.
        x_max = acq_max(ac, gp, ymax, restarts, self.bounds)

        # ------------------------------ // ------------------------------ // ------------------------------ #
        # Iterative process of searching for the maximum. At each round the most recent x and y values
        # probed are added to the X and Y arrays used to train the Gaussian Process. Next the maximum
        # known value of the target function is found and passed to the acq_max function. The arg_max
        # of the acquisition function is found and this will be the next probed value of the tharget
        # function in the next round.
        for i in range(n_iter):
            op_start = datetime.now()

            # Append most recently generated values to X and Y arrays
            self.X = numpy.concatenate((self.X, x_max.reshape((1, self.dim))), axis=0)
            self.Y = numpy.append(self.Y, self.f(**dict(zip(self.keys, x_max))))

            # Updating the GP.
            ur = unique_rows(self.X)
            gp.fit(self.X[ur], self.Y[ur])

            # Update maximum value to search for next probe point.
            if self.Y[-1] > ymax:
                ymax = self.Y[-1]

            # Maximize acquisition function to find next probing point
            x_max = acq_max(ac, gp, ymax, restarts, self.bounds)

            # Print stuff
            printI.print_info(op_start, i, x_max, ymax, self.X, self.Y, self.keys)

        # ------------------------------ // ------------------------------ // ------------------------------ #
        # Output dictionary
        self.res = {}
        self.res['max'] = {'max_val': self.Y.max(), 'max_params': dict(zip(self.keys, self.X[self.Y.argmax()]))}
        self.res['all'] = {'values': [], 'params': []}

        # Fill values
        for t, p in zip(self.Y, self.X):
            self.res['all']['values'].append(t)
            self.res['all']['params'].append(dict(zip(self.keys, p)))

        # Print a final report if verbose active.
        if self.verbose:
            tmin, tsec = divmod((datetime.now() - total_time).total_seconds(), 60)
            print('Optimization finished with maximum: %8f, at position: %8s.' % (self.res['max']['max_val'],\
                                                                                  self.res['max']['max_params']))
            print('Time taken: %i minutes and %s seconds.' % (tmin, tsec))


class AcquisitionFunction(object):
    '''An object to compute the acquisition functions.'''


    def __init__(self, k=1):
        '''If UCB is to be used, a constant kappa is needed.'''
        self.kappa = k

    # ------------------------------ // ------------------------------ #
    # Methods for single sample calculation.
    def UCB(self, x, gp, ymax):
        mean, var = gp.predict(x, eval_MSE=True)
        return mean + self.kappa * sqrt(var)

    def EI(self, x, gp, ymax):
        mean, var = gp.predict(x, eval_MSE=True)
        if var == 0:
            return 0
        else:
            Z = (mean - ymax)/sqrt(var)
            return (mean - ymax) * norm.cdf(Z) + sqrt(var) * norm.pdf(Z)

    def PoI(self, x, gp, ymax):
        mean, var = gp.predict(x, eval_MSE=True)
        if var == 0:
            return 1
        else:
            Z = (mean - ymax)/sqrt(var)
            return norm.cdf(Z)

    # ------------------------------ // ------------------------------ #
    # Methods for bulk calculation.
    def full_UCB(self, mean, var):
        mean = mean.reshape(len(mean))
        
        return (mean + self.kappa * numpy.sqrt(var)).reshape(len(mean))


    def full_EI(self, ymax, mean, var, verbose = False):
        '''
        Function to calculate the expected improvement. Robust agains noiseless
        systems.
        '''
        if verbose:
            print('EI was called with ymax: %f' % ymax)

        ei = numpy.zeros(len(mean))

        mean = mean.reshape(len(mean))
        var = numpy.sqrt(var)

        Z = (mean[var > 0] - ymax)/var[var > 0]

        ei[var > 0] = (mean[var > 0] - ymax) * norm.cdf(Z) + var[var > 0] * norm.pdf(Z)

        return ei

    def full_PoI(self, ymax, mean, var):
        '''
        Function to calculate the probability of improvement. In the current implementation
        it breaks down in the system has no noise (even though it shouldn't!). It can easily
        be fixed and I will do it later...
        '''
        mean = mean.reshape(len(mean))
        var = numpy.sqrt(var)

        gamma = (mean - ymax)/var
    
        return norm.cdf(gamma)

################################## Print Info ##################################

class PrintInfo(object):
    '''A class to take care of the verbosity of the other classes.'''
    '''Under construction!'''

    def __init__(self, level=0):

        self.lvl = level
        self.timer = 0


    def print_info(self, op_start, i, x_max, ymax, xtrain, ytrain, keys):

        if self.lvl:
            numpy.set_printoptions(precision=4, suppress=True)
            print('Iteration: %3i | Last sampled value: %11f' % ((i+1), ytrain[-1]), '| with parameters: ', dict(zip(keys, xtrain[-1])))
            print('               | Current maximum: %14f | with parameters: ' % ymax, dict(zip(keys, xtrain[numpy.argmax(ytrain)])))
            
            minutes, seconds = divmod((datetime.now() - op_start).total_seconds(), 60)
            print('               | Time taken: %i minutes and %s seconds' % (minutes, seconds))
            print('')

        else:
            pass


    def print_log(self, op_start, i, x_max, xmins, min_max_ratio, ymax, xtrain, ytrain, keys):

        def return_log(x):
            return xmins * (10 ** (x * min_max_ratio))

        dict_len = len(keys)

        if self.lvl:
                
            numpy.set_printoptions(precision=4, suppress=True)
            print('Iteration: %3i | Last sampled value: %8f' % ((i+1), ytrain[-1]), '| with parameters: ',  dict(zip(keys, return_log(xtrain[-1])) ))
            print('               | Current maximum: %11f | with parameters: ' % ymax, dict(zip(keys, return_log( xtrain[numpy.argmax(ytrain)]))))

            minutes, seconds = divmod((datetime.now() - op_start).total_seconds(), 60)
            print('               | Time taken: %i minutes and %s seconds' % (minutes, seconds))
            print('')

        else:
            pass
        
########################### Define Random Forest Optimization ###################
def rfccv(n_estimators, min_samples_split, max_features):
    rf = RFC(n_estimators=int(n_estimators),
             min_samples_split=int(min_samples_split),
             max_features=min(max_features, 0.999),
             random_state=2,
             n_jobs=-1)
    rf.fit(X, Xtarget)
    return -log_loss(Ytarget, rf.predict_proba(Y)[:,1])

################################## Actual Run Code ##################################

train=pd.read_csv('../input/train.csv')
test=pd.read_csv('../input/test.csv')
random.seed(rnd)
train.index=train.ID
test.index=test.ID
del train['ID'], test['ID']
target=train.target
del train['target']

#prepare data
traindummies=pd.DataFrame()
testdummies=pd.DataFrame()

for elt in train.columns:
    vector=pd.concat([train[elt],test[elt]], axis=0)

    #count as categorial if number of unique values is less than maxCategories
    if len(vector.unique())<maxCategories:
        traindummies=pd.concat([traindummies, pd.get_dummies(train[elt],prefix=elt,dummy_na=True)], axis=1).astype('int8')
        testdummies=pd.concat([testdummies, pd.get_dummies(test[elt],prefix=elt,dummy_na=True)], axis=1).astype('int8')
        del train[elt], test[elt]
    else:
        typ=str(train[elt].dtype)[:3]
        if (typ=='flo') or (typ=='int'):
            minimum=vector.min()
            maximum=vector.max()
            train[elt]=train[elt].fillna(int(minimum)-2)
            test[elt]=test[elt].fillna(int(minimum)-2)
            minimum=int(minimum)-2
            traindummies[elt+'_na']=train[elt].apply(lambda x: 1 if x==minimum else 0)
            testdummies[elt+'_na']=test[elt].apply(lambda x: 1 if x==minimum else 0)
            

            #resize between 0 and 1 linearly ax+b
            a=1/(maximum-minimum)
            b=-a*minimum
            train[elt]=a*train[elt]+b
            test[elt]=a*test[elt]+b
        else:
            if (typ=='obj'):
                list2keep=vector.value_counts()[:maxCategories].index
                train[elt]=train[elt].apply(lambda x: x if x in list2keep else numpy.nan)
                test[elt]=test[elt].apply(lambda x: x if x in list2keep else numpy.nan)                
                traindummies=pd.concat([traindummies, pd.get_dummies(train[elt],prefix=elt,dummy_na=True)], axis=1).astype('int8')
                testdummies=pd.concat([testdummies, pd.get_dummies(test[elt],prefix=elt,dummy_na=True)], axis=1).astype('int8')
                
                #Replace categories by their weights
                tempTable=pd.concat([train[elt], target], axis=1)
                tempTable=tempTable.groupby(by=elt, axis=0).agg(['sum','count']).target
                tempTable['weight']=tempTable.apply(lambda x: .5+.5*x['sum']/x['count'] if (x['sum']>x['count']-x['sum']) else .5+.5*(x['sum']-x['count'])/x['count'], axis=1)
                tempTable.reset_index(inplace=True)
                train[elt+'weight']=pd.merge(train, tempTable, how='left', on=elt)['weight']
                test[elt+'weight']=pd.merge(test, tempTable, how='left', on=elt)['weight']
                train[elt+'weight']=train[elt+'weight'].fillna(.5)
                test[elt+'weight']=test[elt+'weight'].fillna(.5)
                del train[elt], test[elt]
            else:
                print('error', typ)

#remove na values too similar to v2_na
from sklearn import metrics
for elt in train.columns:
    if (elt[-2:]=='na') & (elt!='v2_na'):
        dist=metrics.pairwise_distances(train.v2_na.reshape(1, -1),train[elt].reshape(1, -1))
        if dist<8:
            del train[elt],test[elt]
        else:
            print(elt, dist)
            
            
train=pd.concat([train,traindummies, target], axis=1)
test=pd.concat([test,testdummies], axis=1)
del traindummies,testdummies

#remove features only present in train or test
for elt in list(set(train.columns)-set(test.columns)):
    del train[elt]
for elt in list(set(test.columns)-set(train.columns)):
    del test[elt]
    
#run cross validation
from sklearn import cross_validation
X, Y, Xtarget, Ytarget=cross_validation.train_test_split(train, target, test_size=0.1)
del train

rfcBO = BayesianOptimization(rfccv, {'n_estimators': (10, 25),
                                     'min_samples_split': (2, 20),
                                     'max_features': (0.1, 0.999)})

print('-'*53)

# Change the values below to run for longer and getting better results.
rfcBO.maximize(init_points=2, restarts=50, n_iter=3)

print('-'*53)
print('Final Results')
print('RFC: %f' % rfcBO.res['max']['max_val'])
