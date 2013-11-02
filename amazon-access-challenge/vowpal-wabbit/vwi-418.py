# -*- coding: utf-8 -*-
#using or influenced by starter code posted by Foxtrot, Paul Duan, Miroslaw Horbal

from numpy import array
from sklearn import preprocessing 
from itertools import combinations

import math
import numpy as np
import pandas as pd
import copy
import pickle
import os

logfile = "log.txt"
zero_one_counts_fn = "zero_one_counts.pkl"

def printlog(s):
    """
    writes to console and logfile
    """
    try:
        h = open(logfile, 'a')
        print >>h, s
        h.close()
        print s
    finally:
        pass
    
def make_number(u, base_powers): 
    """
    the primary categories are regarded as digits in a reversed number
    
    the resulting numbers are smaller if u is sorted, smallest columns last
    """
    r = 0
    for i in range(len(u)):
       r += (1+u[i]) * base_powers[i]  
    return r
    
def concat_strs(t):
    return '?'.join( [ encode_number(t[i]) for i in range( len( t ) ) ] )
    
namespaceletters = ['d','e','f','g','h','i', 'j']

alph = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s',
        't','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L',
        'M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'
        ,'0','1','2','3','4','5','6','7','8','9'
        ,'^','!','§','$','%','&','/','(',')','{','}','[',']','+','*','~','-','_','.',',',';','<','>','=']

def encode_number(n):
        b = len(alph)
        v = []
        v.append(alph[n%b])
        while n >= b:
            n = int(math.floor(n/b))
            v.append(alph[n%b])
        v.reverse()
        return ''.join(v)
        
PLAIN_NUMBER = 0
CODED_NUMBER = 1
CONCAT_CODED = 3

        
def encode_category(coding, vals, base_powers):
    if PLAIN_NUMBER == coding:
        # OK for max_degree <= 4
        return str(make_number( vals, base_powers))
    elif CODED_NUMBER == coding:
        # OK for max_degree <= 4
        return encode_number(make_number( vals, base_powers) )
    elif CONCAT_CODED == coding:
        # OK for all degrees
        return concat_strs( vals) # calls encode_number 
    else:
        print "use plain_number, coded_number or concat_coded"
 
def dump(fh, vw):
    fh.write( ''.join( [ it for it in vw if '???' != it ] ) )
    
def freverse(minimize_numbers, l):
    if minimize_numbers:
        m = copy.deepcopy(l)
        m.reverse()
        return m
    else:
        return l
    
def process_line(row_data, degree, indicies, ind2ind, coding, base_powers):
    """
    easier to understand if inlined. However, it's called in 2 places
    """
    str_indices = ''.join( [ str(i) for i in indicies ] )
    counted_namespace = ' |' + namespaceletters[degree] + str_indices 
    category = encode_category(coding,  [ row_data[i] for i in ind2ind[ str_indices ]  ], base_powers)
    counted_feature = counted_namespace + " " + category
    return str_indices, counted_namespace, category, counted_feature
    
def write_feats(fn, raw_data, data, maxes, num_train, y, max_degree, cutoffs, min_zeros, max_ones, z_o_factor, z_o_diff, z_fract, z_scale_col, \
                z_weight_row, coding, use_raw, sort_columns, minimize_numbers, recount):
    """
    creates combined features,
    counts their occurrences,
    writes
    """
    
    maxmax = max(maxes)
    base = maxmax + 1
    
    base_powers = []
    for i in range(4):
        base_powers.append(base**i)
    m,n = data.shape

    ind2ind = {}
    for degree in range(max_degree):
        for indicies in combinations(range(n), degree+1):
            if sort_columns:
                # smallest columns last,
                # will be multiplied by highest powers of base in make_number
                sorted_indices = freverse( minimize_numbers, [ p[ 1 ] for p in sorted( [ ( maxes[ i ], i ) for i in indicies ] ) ] )
                ind2ind[''.join( [ str(i) for i in indicies ] ) ] = sorted_indices
            else:
                ind2ind[''.join( [ str(i) for i in indicies ] ) ] = indicies
                    
    if os.path.exists(zero_one_counts_fn) and not recount:
        fh = open(zero_one_counts_fn, "r")
        (occs, zeros, ones)  =  pickle.load(fh)   
        fh.close() 
    else:
        # count
        zeros = {}
        ones = {}
        occs = {}
        for r in range(m):
            if r%1000 == 0:
                print('1:  ' + str(r))
                
            for degree in range(max_degree):
                for indicies in combinations(range(n), degree+1):
                    str_indices, counted_namespace, category, counted_feature = process_line(data[r, :], degree, indicies, ind2ind, coding, base_powers)
                    
                    if r < num_train:
                        hhash = [ zeros, ones ] [ y[ r ] == 1 ]
                        if not hhash.has_key(counted_feature):
                            hhash [counted_feature] = 0
                        hhash[ counted_feature ] += 1
                    
                    if not occs.has_key(counted_feature):
                        occs [counted_feature] = 0
                    occs[ counted_feature ] += 1

        fh = open(zero_one_counts_fn, "wb")
        pickle.dump((occs, zeros, ones), fh)
        fh.close()
 
    # write
    fh = open(fn + "-train.vw", 'w')
    vw_input = []
    others = []
    for degree in range(max_degree):
        others.append(str(base**(degree+1)))
                
    for r in range(m):
        
        importance_written = False
        if r == num_train:
            dump(fh, vw_input)
            vw_input = []
            fh.close()
            fh = open(fn + "-test.vw", 'w')
            
        if r%100 == 0:
            dump(fh, vw_input)
            vw_input = []
            if r%1000 == 0:
                print('2:  ' + str(r))
            
        vw_input.append([ "-1 ", "1 " ] [ r >= num_train or y[r] == 1 ] )
        vw_input.append('???')
        
        if use_raw:
            for col in range(n):
                for thr in cutoffs:
                    vw_input.append(" |a" + str(thr) + str(col) + " 1:" + str(raw_data[r, col] ) )
                      
        col_fact = []
        for i in range(len(z_scale_col)):
            col_fact.append( [ "", ":" + str(z_scale_col[i])] [ z_scale_col[i] != 1 ] )
        for degree in range(max_degree):
            #other = " " + str(base**(degree+1) - 1)
            for indicies in combinations(range(n), degree+1):
                str_indices, counted_namespace, category, counted_feature = process_line(data[r, :], degree, indicies, ind2ind, coding, base_powers)
                
                n_ones = 0
                n_zeros = 0
                occurences_all = 0
                if ones.has_key(counted_feature):
                    n_ones = ones[counted_feature] 
                if zeros.has_key(counted_feature):
                    n_zeros = zeros[counted_feature] 
                if occs.has_key(counted_feature):
                    occurences_all = occs[counted_feature] 
                                            
                f = max(num_train, r) / m
                for i in range(len(min_zeros)):
                    if n_zeros >= min_zeros[i]  and n_ones <= max_ones[i] and n_zeros >= z_o_factor[i] * n_ones and n_zeros - n_ones >= z_o_diff[i] and \
                    n_zeros * f >= z_fract[i] * occurences_all:
                        if not importance_written:
                            importance_written = True
                            if z_weight_row[i] > 0 and z_weight_row[i] != 1:
                                vw_input = [ [ it, str( z_weight_row[ i ] ) ] [ it == '???' ] for it in vw_input ] 
                        vw_input.append(' |z' + ["", str(min_zeros[i] ) ] [ i > 0] + str_indices + col_fact[i] + " " + '?') # + category 
                    else:
                        pass
                   
                lc = len(cutoffs)     
                for t in range(lc): # thr in cutoffs:
                    thr = cutoffs[t]
                    namespace = ' |' + namespaceletters[degree] + str(thr) + str_indices
                    if occurences_all >= thr or degree <= 0:
                        vw_input.append(namespace + " " + category)
                    else:
                        vw_input.append(namespace + " ?")
                    
        vw_input.append("\n")
        dump(fh, vw_input)
        vw_input = []
    fh.close()    
           
def main(vw_input, trainfile, testfile, max_degree, cutoffs, min_zeros, max_ones, z_o_factor, z_o_diff, z_fract, z_scale_col, z_weight_row, coding, raw, sort_columns, minimize_numbers, recount):
    """
    vw_input: prefix of the output file names. The two output files are input for vw
    max_degree: max tuple length 
    cutoffs: list of cutoffs, only used for higher order features. categories ocurring less than cutoff times in
    the train + test data (semi-superwised) are treated as one 'others'-category
    min_zeros, max_ones, z_o_factor, z_o_diff, z_fract, z_scale_col: lists with same length, describing additional features, in namespaces beginning with z for zero
    z_weight_row: weight of examples containig z features
    coding: irepresentation of the features
    raw: include numerical features
    sort_columns: by size
    minimize_numbers: sort columns to minimize or maximize the category encodings
    recount: should be True if coding, sort_columns or minimize_numbers or the implementation have changed since the last run
    """
                    
    printlog("Reading dataset...")
    train_data = pd.read_csv(trainfile)
    test_data = pd.read_csv(testfile)
    all_data = np.vstack((train_data.ix[:,1:-1], test_data.ix[:,1:-1]))
    
    y = array(train_data.ACTION)
    
    #fh = open("y", 'w')
    #fh.write("\n".join([str(x) for x in y ] ) )
    num_train = np.shape(train_data)[0]
    printlog(num_train)
    
    raw_data =copy.deepcopy(all_data)
    
    printlog("Using LabelEncoder...")    
    le = preprocessing.LabelEncoder()
    for i in range(np.shape(all_data)[1]):
        le.fit(all_data[:, i])
        all_data[:,i] = le.transform(all_data[:, i])
    
    fh = open("train-le.vw", 'w')
    for i in range(num_train):
        fh.write(','.join([str(j) for j in all_data[i,:] ] ) + "\n" )
    fh.close()

    maxes = []
    for i in range(np.shape(all_data)[1]):
        maxes.append(max(all_data[:, i]))
    
    printlog(maxes)
    
    write_feats(vw_input, raw_data, all_data, maxes, num_train, y,max_degree, cutoffs, min_zeros, max_ones, \
                z_o_factor, z_o_diff, z_fract, z_scale_col, \
                z_weight_row, coding, raw, sort_columns, minimize_numbers, recount)
    
            
if __name__ == "__main__":
    args = {'vw_input':   'i418', 
            'trainfile':  'train.csv',
            'testfile':   'test.csv',
            'max_degree':  3, 
            'cutoffs': [2, 9], 
            
            # same length
            'min_zeros':   [2, 3, 4, 5, 6],
            'max_ones':    [0]*5,
            'z_o_factor':  [0]*5,
            'z_o_diff':    [0]*5,
            'z_fract':     [0]*5,
            'z_scale_col': [1]*5,

            'z_weight_row': [0.8],
            'coding': CONCAT_CODED, # PLAIN_NUMBER, CODED_NUMBER (for smaller files), CONCAT_CODED (for degree > 4)
            'raw': False,
            'sort_columns': True,
            'minimize_numbers': False,
            'recount': False}   
    main(**args)



#  vw  -d   i418-train.vw --nn 1 -b26 -c -k -f modelb  --loss_function logistic  --passes 11 -l 0.41  --decay_learning_rate 0.53  --l1 5e-9
#  vw  -t -d i418-test.vw --nn 1 -b26 -c -k -i modelb -p predvwb.txt --loss_function logistic 

