#!/usr/bin/env python 
#coding:utf-8

import numpy as np
import csv 
import pandas as pd
from pandas import *
import datetime
from sklearn.linear_model import LinearRegression
from sklearn.neighbors import KNeighborsClassifier
from sklearn.neighbors import KNeighborsRegressor
from sklearn.ensemble import RandomForestRegressor
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.ensemble import ExtraTreesRegressor
from sklearn.svm import SVR

'''
进行数据的预处理，对于训练集中缺少markdown信息的
数据删去，由于测试集中存在确实失业率和消费指数，
所以将这两个特征删去
'''
def prodata():
    train = pd.read_csv('./data/train.csv')
    feature = pd.read_csv('./data/features.csv')

	# read a csv where NA are set to column.mean()
    #feature = pd.read_csv('./data/features_noNA.csv')
    test = pd.read_csv('./data/test.csv')
    
    #对测试数据进行处理，删除缺少markdown信息的记录
    #feature = del_lack_markdown(feature)
	#fill na in markdowns and unemployment
    #对训练数据进行处理，删除消费指数和失业率信息
    feature = del_unemployment(feature)
    
    #对测试数据进行处理，删除2011-11-11日之前的记录
    train = del_train_markdown(train)
    
    return (train,test,feature)

#对测试数据进行处理
def del_lack_markdown(feature):
    '''
    a = notnull(feature.MarkDown1)
    b = notnull(feature.MarkDown2)
    c = notnull(feature.MarkDown3)
    d = notnull(feature.MarkDown4)
    e = notnull(feature.MarkDown5)
    train = feature[a|b|c|d|e]
    '''
    feature = feature[feature.Date >= '2011-11-04']
    return feature

#对数据进行处理，删除消费指数和失业率两个特征信息
def del_unemployment(feature):
    feature = feature[['Store','Date','Temperature','Fuel_Price','MarkDown1','MarkDown2','MarkDown3','MarkDown4','MarkDown5','IsHoliday']]
    return feature

#对训练数据进行处理，删除2011-11-11日之前的记录
def del_train_markdown(train):
    train = train[train.Date >= '2011-11-11']
    return train

#将特征集合中的特征融合到训练集中
def combi_train_feature(train,test,feature,markdown):
    train = np.array(train)
    test = np.array(test)
    feature = np.array(feature)
    train_x,train_y,test_x,dates=[],[],[],[]
    j=0
    for i in range(len(train)):
        train_x.append([])
        store,dept,date,sales,isholiday = train[i]
        #从特征集合中找出此日期的温度，燃油价格Markdown信息
        f = find_from_feature(store,date,feature,markdown)
        train_y.append(sales)
        train_x[j] =list(f)
        #抽取出假日特征，这一周是否是假日信息
        temp = date.split('-')
        y,m,d =int(temp[0]),int(temp[1]),int(temp[2])
        ymd = datetime.date(y,m,d)
        week = datetime.timedelta(days=7)
        preweek = ymd-week
        preweek = str(preweek)
        pre2week = ymd-week-week
        pre2week = str(pre2week)
        nextweek = ymd+week
        nextweek = str(nextweek)
        next2week = ymd+week+week
        next2week = str(next2week)
        preweek = get_holiday_feature(preweek)
        pre2week = get_holiday_feature(pre2week)
        thisweek = get_holiday_feature(date)
        nextweek = get_holiday_feature(nextweek)
        next2week = get_holiday_feature(next2week)
        train_x[j] =train_x[j]+preweek+thisweek+nextweek+pre2week+next2week
        j += 1
    j = 0
    for i in range(len(test)):
        test_x.append([])
        store,dept,date,isholiday = test[i]
        f = find_from_feature(store,date,feature,markdown)
        test_x[j] = list(f)
        #抽取出假日特征，这一周是否为假日信息
        temp = date.split('-')
        y,m,d = int(temp[0]),int(temp[1]),int(temp[2])
        ymd = datetime.date(y,m,d)
        week = datetime.timedelta(days=7)
        preweek = ymd-week
        preweek = str(preweek)
        nextweek = ymd+week
        nextweek = str(nextweek)
        preweek = get_holiday_feature(preweek)
        thisweek = get_holiday_feature(date)
        nextweek = get_holiday_feature(nextweek)
        pre2week = ymd-week-week
        pre2week = str(pre2week)
        next2week = ymd+week+week
        next2week = str(next2week)
        pre2week = get_holiday_feature(pre2week)
        next2week = get_holiday_feature(next2week)
        test_x[j] =test_x[j]+ preweek+thisweek+nextweek+pre2week+next2week
        dates.append(date)
        j += 1
    return (train_x,train_y,test_x,dates)

def find_from_feature(store,date,feature,markdown):
    for i in range(len(feature)):
        if feature[i][0] == store and feature[i][1] == date:
            #查看markdown特征里是否有空值，如果有，进行替换
            for j in range(4,9):
                if isnull(feature[i][j]):
                    feature[i][j] = markdown[j-4]
            return feature[i][2:-1]
#训练线性模型
def linear_model(train_x,train_y,test_x):
    clf = LinearRegression()
    clf.fit(train_x,train_y)
    test_y = clf.predict(test_x)
    return test_y
#用knn模型训练
def knn_model(train_x,train_y,test_x,k):
    #clf = KNeighborsClassifier(n_neighbors=k,algorithm='auto')
    #clf = KNeighborsRegressor(n_neighbors=k,algorithm='auto')
    #clf = RandomForestRegressor(n_estimators=50)
    #clf = GradientBoostingRegressor(loss='ls', n_estimators=200, max_features=None, verbose=1)
    clf = ExtraTreesRegressor(n_estimators=200,max_features='log2')
    clf.fit(train_x,train_y)
    test_y = clf.predict(test_x)
    return test_y
#用SVM模型训练
#def knn_model(train_x,tran_y,test_x,k)
#对训练集中的markdown中的空值进行处理
def nan_rep(trains):
    md = []
    md.append(list(trains.MarkDown1))
    md.append(list(trains.MarkDown2))
    md.append(list(trains.MarkDown3))
    md.append(list(trains.MarkDown4))
    md.append(list(trains.MarkDown5))
    result = []
    for m in md:
        temp = np.array([i for i in m if notnull(i)])
        result.append(temp.mean())
    return result
        
#获取假日特征
def get_holiday_feature(date):
    super_bowl = ['2010-02-12','2011-02-11','2012-02-10','2013-02-08']
    labor = ['2010-09-10','2011-09-09','2012-09-07','2013-09-06']
    thx = ['2010-11-26','2011-11-25','2012-11-23','2013-11-29']
    chris = ['2010-12-31','2011-12-30','2012-12-28','2013-12-27']
    if date in super_bowl:
        return [0,0,0,1]
    elif date in labor:
        return [0,0,1,0]
    elif date in thx:
        return [0,1,0,0]
    elif date in chris:
        return [1,0,0,0]
    else:
        return [0,0,0,0]
#写入结果信息
def write(y,store,dept,dates):
    f = open('./data/result.csv','a')
    for i in range(len(y)):
        Id = str(store)+'_'+str(dept)+'_'+str(dates[i])
        sales = y[i]
        f.write('%s,%s\n'%(Id,sales))
    f.close()
if __name__=="__main__":
    #对45个商场分别构建模型
    f = open('./data/result.csv','wb')
    f.write('Id,Weekly_Sales\n')
    f.close()
    train,test,feature = prodata()
    for i in range(1,46):
        traindata = train[train.Store == i]
        testdata = test[test.Store == i]
        featuredata = feature[feature.Store == i]
        dept_train = list(set(traindata.Dept.values))
        dept_test = list(set(testdata.Dept.values))
        for dept in dept_test:
            if dept not in dept_train:
                print i,dept
                tests = testdata[testdata.Dept == dept]
                dates = list(tests.Date)
                y=[0 for j in range(len(tests))]
                write(y,i,dept,dates)
        
        for dept in dept_train:
            trains = traindata[traindata.Dept == dept]
            tests = testdata[testdata.Dept == dept]
            #训练集中markdwon存在空元素，用平均值进行替换
            markdown = nan_rep(featuredata)
            #print '构建第',i,'个商场第',dept,'个部门模型'
            print 'store=',i,' and dept ',dept
            train_x,train_y,test_x,dates = combi_train_feature(trains,tests,featuredata,markdown)
            #设定knn的k值
            k = 3
            #print len(train_x),len(test_x)
            if len(test_x) > 0:
                if len(train_x) <k:
                    test_y = knn_model(train_x,train_y,test_x,len(train_x))
                    write(test_y,i,dept,dates)
                else:
                    test_y = knn_model(train_x,train_y,test_x,k)
                    write(test_y,i,dept,dates)
        

            
