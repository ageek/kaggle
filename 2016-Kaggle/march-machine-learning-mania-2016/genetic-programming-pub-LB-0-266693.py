#https://www.kaggle.com/scirpus/march-machine-learning-mania-2016/genetic-programming/code

import math
import numpy as np
import pandas as pd
from sklearn.metrics import log_loss
from sklearn.preprocessing import StandardScaler


def Outputs(data):
    return 1.-(1./(1.+np.exp(-data)))


def GPIndividual1(data):
    predictions = (np.sinh(((((np.sinh(data["team1Seed"]) - data["team2Seed"]) + ((np.tanh(data["team2Wmax"]) + ((data["team1Lstd"] + np.minimum( (data["team1losses"]),  (data["year"])))/2.0))/2.0)) + ((data["team2Seed"] == (1.0/(1.0 + np.exp(- data["team2wins"])))).astype(float)))/2.0)) +
                    ((np.cos(((np.round(data["team2Wmedian"]) <= data["team1LAverage"]).astype(float))) - np.maximum( ((data["team1Seed"] * data["team2Lstd"])),  (np.round(np.tanh(np.maximum( (np.maximum( (data["team2Lstd"]),  (data["team2Wstd"]))),  (data["team1wins"]))))))) / 2.0) +
                    ((np.floor(np.minimum( (((1.732051 == data["team1Lmax"]).astype(float))),  (np.cos(data["team1WAverage"])))) == ((np.round(((((-(data["team2LAverage"])) <= data["team2losses"]).astype(float)) - 2.212120)) <= (data["team2Wmin"] * data["team2losses"])).astype(float))).astype(float)) +
                    np.minimum( ((np.abs(data["team1Wmedian"]) - ((data["team1Seed"] >= np.abs(data["team1Lmedian"])).astype(float)))),  (np.round(np.sinh(np.minimum( ((((data["team2WAverage"] != data["team1Seed"]).astype(float)) + data["team2WAverage"])),  ((-(((data["team1Wmin"] >= 2.718282).astype(float)))))))))) +
                    ((np.minimum( (-1.0),  (data["team2Lmax"])) > (data["team2Wmax"] - np.minimum( (data["team1Lmax"]),  ((data["team2Wmin"] * (data["team2Wmax"] - np.minimum( (data["team2Wmin"]),  (np.tanh(np.sin((data["team1Lmax"] * 2.0))))))))))).astype(float)) +
                    np.minimum( (((data["team2WAverage"] >= np.floor(data["team2Wmin"])).astype(float))),  (np.abs(((data["team1Seed"] >= np.sinh(((0.693147 > np.minimum( (data["team2Wmedian"]),  (((data["team1Seed"] <= ((data["team1Wmedian"] <= np.cos(0.693147)).astype(float))).astype(float))))).astype(float)))).astype(float))))) +
                    np.sin(np.sinh(((((-((((-(0.367879)) <= data["team1Lmax"]).astype(float)))) + ((data["team1Wmin"] >= np.floor(data["team1Seed"])).astype(float)))/2.0) - ((np.sin(data["team2Wstd"]) > (data["team2Wmax"] + np.abs(data["team2"]))).astype(float))))) +
                    (((((np.sin(data["team1Lmax"]) > data["team1Wstd"]).astype(float)) != ((data["team1Lmax"] == data["team2wins"]).astype(float))).astype(float)) * (((-(data["team2Wmin"])) + ((data["team1Lstd"] + np.minimum( (data["team2wins"]),  (np.minimum( (data["team1Lmax"]),  (data["team2Wmin"])))))/2.0))/2.0)) +
                    np.maximum( (np.minimum( (data["team1Wmin"]),  (np.ceil(np.minimum( (np.minimum( (0.138462),  (((data["team1Seed"] >= data["team2Lmedian"]).astype(float))))),  (data["team2losses"])))))),  ((((-(np.maximum( (data["team2"]),  (data["team2Seed"])))) > ((data["team1losses"] < 1.414214).astype(float))).astype(float)))) +
                    np.minimum( (np.maximum( (data["team1Lmin"]),  ((-(((data["team1wins"] >= np.cos(0.720430)).astype(float))))))),  (np.minimum( (np.ceil((data["team1Wmedian"] / 2.0))),  ((-(((data["team1Wmin"] >= (1.197370 + ((data["team1Wstd"] < 0.094340).astype(float)))).astype(float)))))))) +
                    ((((-(np.abs(np.abs(((data["team1"] + (-(0.138462)))/2.0))))) * ((0.367879 >= data["team2wins"]).astype(float))) > ((data["team1Wmedian"] + np.maximum( (data["team1"]),  (((0.367879 != data["team1"]).astype(float)))))/2.0)).astype(float)) +
                    ((3.0 == np.maximum( (np.round(np.maximum( (np.sinh(data["team2Lmin"])),  (data["team2LAverage"])))),  (np.floor(np.maximum( (np.sinh(np.maximum( ((data["team1"] * 2.0)),  (data["team1Wmedian"])))),  (np.sinh((data["team2Wmedian"] * np.sin(data["team2WAverage"]))))))))).astype(float)) +
                    np.minimum( (np.ceil(((data["team2Wmin"] + ((0.094340 >= data["team2"]).astype(float)))/2.0))),  ((np.minimum( ((data["team1Lmax"] * data["team1Wmedian"])),  (((data["team1Wmedian"] < (data["team1Wmax"] - data["team2Lmedian"])).astype(float)))) * np.maximum( (data["team2Seed"]),  (data["team1Wmax"]))))) +
                    ((-(((data["team2Wmin"] >= ((-((data["team2Wstd"] + 0.318310))) * (1.0/(1.0 + np.exp(- (-((1.0/(1.0 + np.exp(- 0.318310)))))))))).astype(float)))) * (((1.0/(1.0 + np.exp(- data["year"]))) * data["team1Lmin"]) * data["team2Lstd"])) +
                    np.floor(np.cos(((data["team1WAverage"] * np.minimum( ((data["team1WAverage"] * data["team2Lmax"])),  (data["team1Lstd"]))) * ((np.sin(np.round(data["team2Lmax"])) + ((data["team1LAverage"] != data["team2WAverage"]).astype(float)))/2.0)))) +
                    np.ceil(((2.675680 <= np.abs(np.maximum( ((data["team2"] + np.maximum( (np.abs(data["team1Seed"])),  (data["team2LAverage"])))),  ((0.318310 + (np.minimum( (data["team1Wmedian"]),  (((data["team2"] != data["team2LAverage"]).astype(float)))) - data["team2Lmin"])))))).astype(float))) +
                    ((np.sinh(np.sin(data["team2Lstd"])) * np.round(np.minimum( (np.sin(np.sinh(np.round(data["team1Wmin"])))),  ((np.minimum( (data["team1Lstd"]),  (np.sin(data["team2Lstd"]))) * np.sin(data["team2Lstd"])))))) / 2.0) +
                    ((((data["team2"] <= ((((data["team1Lmin"] + 5.428570)/2.0) + (np.cos(np.maximum( (data["team1Lmin"]),  (np.maximum( ((1.0/(1.0 + np.exp(- data["team1Wmin"])))),  (data["team2LAverage"]))))) / 2.0))/2.0)).astype(float)) <= ((((data["team2"] + 5.428570)/2.0) <= data["team1Wmedian"]).astype(float))).astype(float)) +
                    np.floor(np.cos((data["team2Lmin"] * np.minimum( ((data["team1wins"] + ((data["year"] + data["team2Wmedian"])/2.0))),  ((np.minimum( (data["year"]),  (data["team1wins"])) + ((((data["year"] > data["team2Wmin"]).astype(float)) + data["team2Wmedian"])/2.0))))))) +
                    np.minimum( ((((np.minimum( (((data["team1Wmedian"] >= data["team1WAverage"]).astype(float))),  (data["team2losses"])) / 2.0) > data["team1Lmax"]).astype(float))),  (((data["team1Wmedian"] >= (1.0/(1.0 + np.exp(- ((data["team1Wmax"] > ((data["team1WAverage"] < (data["team1Wmedian"] - data["team2Lmin"])).astype(float))).astype(float)))))).astype(float)))) +
                    (((0.602941 <= (data["team2Wmin"] - ((((np.cos(data["team1Wmedian"]) * 2.0) * 2.0) >= 1.570796).astype(float)))).astype(float)) * np.sin(np.sinh(np.sinh(data["team2Wstd"])))) +
                    (data["team1losses"] * ((data["team1Wmedian"] >= (np.tanh((((((-(data["team1Lmin"])) > 0.434294).astype(float)) != ((np.minimum( (data["team1wins"]),  (((0.434294 <= data["team2losses"]).astype(float)))) < data["team1Wmedian"]).astype(float))).astype(float))) * 2.0)).astype(float))) +
                    np.maximum( (((np.minimum( (data["team1Lmedian"]),  (((data["team2"] > np.maximum( (data["team2losses"]),  (0.585714))).astype(float)))) >= (data["team1WAverage"] + ((1.414214 > data["team2Lmin"]).astype(float)))).astype(float))),  (((data["team2Wmin"] < (data["team1wins"] - 3.141593)).astype(float)))) +
                    np.round((np.round(((data["team2Lmedian"] * ((data["year"] > ((2.675680 + ((data["team1LAverage"] <= np.maximum( (data["team1WAverage"]),  (0.094340))).astype(float)))/2.0)).astype(float))) * 2.0)) * 2.0)) +
                    ((np.abs(np.sinh(np.abs(data["team2Lstd"]))) <= (data["team1Lmax"] * ((data["team2losses"] <= (-(((((data["team2Lstd"] <= np.minimum( (data["team2wins"]),  (data["team2losses"]))).astype(float)) < np.maximum( (data["team2Wmedian"]),  (data["team1losses"]))).astype(float))))).astype(float)))).astype(float)) +
                    np.minimum( (np.cos(data["team1"])),  (((((((((((data["team1"] / 2.0) / 2.0) * 9.869604) <= 0.058823).astype(float)) <= data["team1Wstd"]).astype(float)) == np.ceil(((data["team1"] / 2.0) * 9.869604))).astype(float)) - 0.094340))) +
                    np.maximum( (np.round(((2.212120 <= (data["team1Wmax"] - ((data["team2Lmin"] + data["team2Lmedian"])/2.0))).astype(float)))),  (((3.0 < (data["team2losses"] + np.maximum( ((-(((data["team2Lmin"] + data["team2LAverage"])/2.0)))),  (data["team1"])))).astype(float)))) +
                    ((data["team2wins"] - np.sin(data["team2Wmin"])) * ((np.maximum( (data["team2wins"]),  (0.840000)) <= np.minimum( (data["team1Lmax"]),  ((np.maximum( (data["team2Wmax"]),  ((data["team2wins"] * np.floor(data["team2Wmax"])))) - 0.058823)))).astype(float))) +
                    ((math.tanh((-(1.630430))) > np.sin(np.maximum( (data["team2Wmin"]),  (np.minimum( (np.minimum( (data["team2Seed"]),  (((data["team1LAverage"] + data["team1Wstd"])/2.0)))),  ((((data["team2Seed"] <= data["team2Wmin"]).astype(float)) - data["team2Lstd"]))))))).astype(float)) +
                    np.floor(np.cos(((1.570796 + (np.minimum( (data["team1LAverage"]),  (((data["team1WAverage"] <= ((((((data["team1Wmin"] + data["team1WAverage"])/2.0) < ((data["team2Seed"] >= data["team1Seed"]).astype(float))).astype(float)) + (data["team2Lmedian"] * 0.636620))/2.0)).astype(float)))) * 2.0))/2.0))) +
                    ((data["team2Wmin"] > ((0.318310 + (((1.0/(1.0 + np.exp(- (((data["team2Seed"] * np.maximum( (data["team2"]),  (data["team1Lmax"]))) <= ((data["team2losses"] < data["team1Lmax"]).astype(float))).astype(float))))) < data["team2Wmin"]).astype(float))) * 2.0)).astype(float)) +
                    np.sinh(np.floor((0.367879 - (((((np.minimum( (data["team1LAverage"]),  (np.floor(data["team2WAverage"]))) == ((2.409090 < -3.0))).astype(float)) + (data["team2wins"] * np.sin(np.minimum( (data["team1Lmax"]),  (data["team2WAverage"])))))/2.0) / 2.0)))) +
                    (((data["team1Wmax"] < (-2.0 + ((data["team1wins"] < ((data["team1Wstd"] - (((data["team1Wstd"] * data["team1Wstd"]) < data["team2Wstd"]).astype(float))) - np.sinh((((data["team2Wmax"] > data["team2Lstd"]).astype(float)) * 2.0)))).astype(float)))).astype(float)) * 2.0) +
                    np.tanh(np.sin(np.round(np.tanh((data["team2Wmax"] * ((np.round(data["team2LAverage"]) == ((((data["team1Wmin"] < data["team1LAverage"]).astype(float)) > ((data["team2Wmin"] >= np.cos(np.minimum( (data["team2Wmax"]),  (data["team2LAverage"])))).astype(float))).astype(float))).astype(float))))))) +
                    np.minimum( (np.cos(data["team1losses"])),  (((1.197370 < (data["team2"] * ((data["team1Lmax"] + np.round(((data["team1Wstd"] - ((((data["team1Lmax"] / 2.0) > data["team2Wmax"]).astype(float)) / 2.0)) / 2.0)))/2.0))).astype(float)))) +
                    np.abs(((((data["team1WAverage"] > data["team2Wstd"]).astype(float)) * 2.0) * (np.tanh(1.732051) * ((((data["team1wins"] <= 1.732051).astype(float)) < ((np.cos(data["team2Lmedian"]) > np.abs(np.sin((data["team2losses"] * 2.0)))).astype(float))).astype(float))))) +
                    np.minimum( (np.cos((data["team1Wmin"] * data["team2WAverage"]))),  (np.minimum( (((-(((np.abs(data["team1WAverage"]) > 1.414214).astype(float)))) / 2.0)),  (np.cos(np.maximum( (data["team1Wmax"]),  ((data["team1wins"] - data["team2Wmedian"])))))))) +
                    np.abs(np.minimum( (np.minimum( (((np.abs(data["team1Lmax"]) > ((1.732051 > (data["team1Wmedian"] + data["team1"])).astype(float))).astype(float))),  (np.cos(np.minimum( (data["team2wins"]),  ((-(np.abs(data["team1Lmax"]))))))))),  (np.cos(data["team1LAverage"])))) +
                    ((((((data["team1WAverage"] >= ((data["team1Lmax"] < np.sin(1.584910)).astype(float))).astype(float)) < data["team1Wstd"]).astype(float)) * ((2.302585 < data["team2Wmedian"]).astype(float))) * 2.0) +
                    (-(((((((np.ceil(np.minimum( (data["team2Wmax"]),  (data["team2Wstd"]))) >= (-(data["team2Lmin"]))).astype(float)) > ((data["team2Seed"] <= np.ceil((data["team1Seed"] / 2.0))).astype(float))).astype(float)) + ((5.200000 <= np.floor(data["team2Wmax"])).astype(float)))/2.0))) +
                    np.minimum( (((data["year"] > data["team1Lmedian"]).astype(float))),  (np.minimum( (((data["team2Wmedian"] < np.cos(data["team1"])).astype(float))),  ((np.maximum( (data["team1Lmin"]),  ((np.round(data["team2Lmedian"]) + np.round(np.round(data["team2Lmedian"]))))) / 2.0))))) +
                    ((np.minimum( (np.minimum( (((data["team1Lmin"] <= np.cos(data["team2Wmin"])).astype(float))),  (data["team2losses"]))),  (data["team1Seed"])) >= ((((data["team1LAverage"] < np.cos(((data["team2Wmin"] < data["team1LAverage"]).astype(float)))).astype(float)) != ((data["team1Lmin"] <= np.cos(2.675680)).astype(float))).astype(float))).astype(float)) +
                    (np.minimum( (np.cos(data["team2Seed"])),  (np.floor(np.cos((data["team1losses"] * ((1.0/(1.0 + np.exp(- (-(((((data["team1"] <= np.cos(data["team2Seed"])).astype(float)) >= np.maximum( (data["team1Wstd"]),  (data["team1Wmedian"]))).astype(float))))))) * 2.0)))))) * 2.0) +
                    (3.141593 * (3.141593 * ((np.tanh(data["team1Wmin"]) >= (((data["team1losses"] < ((3.141593 + ((np.round(data["team2Wmin"]) <= (data["team1losses"] * data["team2Wmax"])).astype(float)))/2.0)).astype(float)) * 2.0)).astype(float)))) +
                    np.tanh((data["team1Lmax"] * (-(((data["team2Wmax"] > (1.197370 - (((((data["team2LAverage"] > 1.197370).astype(float)) / 2.0) == ((((((data["team2Wmax"] != data["team1Wstd"]).astype(float)) > data["team1"]).astype(float)) > data["team1Lmin"]).astype(float))).astype(float)))).astype(float)))))) +
                    ((np.minimum( (data["team1wins"]),  (np.minimum( (data["team1wins"]),  (data["team1Wmax"])))) > np.abs((((((data["team1Wmax"] + data["team1Wmax"])/2.0) * (data["team2Lmedian"] * data["team1LAverage"])) < np.cos(np.minimum( (data["team2Seed"]),  (data["team1Lmedian"])))).astype(float)))).astype(float)) +
                    (-(np.maximum( (((data["team1WAverage"] > (np.abs(data["team1Lmin"]) + 2.212120)).astype(float))),  (np.minimum( ((((1.0/(1.0 + math.exp(- 0.693147))) <= (-(data["team1Lstd"]))).astype(float))),  ((data["team2Lmin"] * 2.212120))))))) +
                    (np.minimum( (0.585714),  (np.maximum( (data["team2Wmax"]),  (np.ceil(data["team1WAverage"]))))) * ((np.cos(data["team2Lmin"]) < ((((2.0 > data["team2wins"]).astype(float)) <= (data["team1Lmin"] * ((data["team2Lmin"] > data["team2wins"]).astype(float)))).astype(float))).astype(float))) +
                    np.floor(np.cos((data["team1WAverage"] * np.maximum( (data["team2Lmax"]),  (np.maximum( (((data["team1Wstd"] + ((data["team1Lstd"] + data["team2Lstd"])/2.0))/2.0)),  (np.sin(((((data["team2Lstd"] <= data["team1Lstd"]).astype(float)) + -2.0)/2.0))))))))) +
                    (((((np.round(data["team2Lmax"]) >= ((((1.584910 <= data["team1wins"]).astype(float)) >= ((((data["team2Lmax"] <= 2.718282).astype(float)) >= data["team1Lstd"]).astype(float))).astype(float))).astype(float)) < np.minimum( (data["team2Lmax"]),  ((1.630430 + data["team1"])))).astype(float)) / 2.0) +
                    np.sin(np.minimum( ((data["team1Wmedian"] * (3.141593 * np.sinh(np.maximum( (data["team1"]),  (data["team2Lstd"])))))),  ((-3.0 * ((((data["team1"] >= data["team1LAverage"]).astype(float)) >= ((data["team1Wstd"] > data["team1WAverage"]).astype(float))).astype(float)))))) +
                    ((0.094340 >= np.abs(np.cos((data["team1Wmax"] - (((((data["team1Lmedian"] >= ((data["team1"] >= (-(np.ceil(data["team2Lmax"])))).astype(float))).astype(float)) != np.ceil(np.ceil(data["team2Wmin"]))).astype(float)) * data["team1Lmedian"]))))).astype(float)) +
                    ((np.abs(data["team1Wmax"]) <= (data["team1Seed"] - np.maximum( (np.abs(data["year"])),  (((((np.abs(data["year"]) > np.maximum( ((data["team1Wmin"] * 2.0)),  (data["team2wins"]))).astype(float)) < np.ceil(np.abs(data["team2Wmin"]))).astype(float)))))).astype(float)) +
                    (((-2.0 < data["team2"]).astype(float)) * np.abs((((data["team2"] < data["team1Seed"]).astype(float)) * (((data["team2losses"] <= (-2.0 / 2.0)).astype(float)) + ((data["team2Lstd"] * ((1.570796 < data["year"]).astype(float))) * 2.0))))) +
                    np.minimum( ((((data["team2Lstd"] * ((data["team1Wmax"] > 1.0).astype(float))) + (-((((np.maximum( (data["team1Lmin"]),  (data["team1Wmedian"])) <= data["team2Lstd"]).astype(float)) / 2.0))))/2.0)),  (((data["team1LAverage"] < ((data["team1LAverage"] >= 0.602941).astype(float))).astype(float)))) +
                    (-(((((data["team1Lmin"] <= 0.840000).astype(float)) <= (-((data["team2Lmedian"] * (data["team2Wmax"] + (data["team2Lmin"] + ((data["team2Wstd"] < (data["team2Lmedian"] * np.sinh(data["team2Lmin"]))).astype(float)))))))).astype(float)))) +
                    ((np.minimum( (data["team2wins"]),  (data["team1Wstd"])) > ((1.197370 >= (np.minimum( ((data["team1Wmin"] * data["team1Wstd"])),  (data["team1Wstd"])) - np.minimum( (np.minimum( (data["team2Lmax"]),  (data["team1Lmin"]))),  (data["team2Wmax"])))).astype(float))).astype(float)) +
                    (np.cos((-(data["team2Wmin"]))) * (((data["team2losses"] > data["team1Lmedian"]).astype(float)) * np.sin((data["team2Lstd"] * np.minimum( (np.sinh(data["team1"])),  ((8.0 - data["team2losses"]))))))) +
                    (((-(data["team1WAverage"])) >= (3.0 * np.maximum( (np.maximum( (data["team1Lmax"]),  (data["team2Lstd"]))),  (((data["team2"] < ((1.0/(1.0 + np.exp(- np.tanh((1.0/(1.0 + np.exp(- ((data["team2Wstd"] > data["team1LAverage"]).astype(float))))))))) * 2.0)).astype(float)))))).astype(float)) +
                    np.sinh(np.sinh(((np.maximum( (data["team2losses"]),  ((data["team2Wstd"] * data["year"]))) > ((3.0 - np.cos(((((data["team2Wstd"] > 2.409090).astype(float)) <= data["team1Wmin"]).astype(float)))) - ((data["team2Wstd"] > 2.409090).astype(float)))).astype(float)))) +
                    np.sinh((-(((((((-(((((data["team1Seed"] < data["team2Lstd"]).astype(float)) < data["team2Wmin"]).astype(float)))) >= np.cos((-(data["team2"])))).astype(float)) >= ((data["team1Seed"] < (2.0 - data["team1losses"])).astype(float))).astype(float)) / 2.0)))) +
                    (np.minimum( (((data["team2WAverage"] > data["team1Wmax"]).astype(float))),  (((-(((data["team1"] - (-(((data["team1wins"] >= ((0.094340 > data["team1Wmax"]).astype(float))).astype(float))))) - ((0.094340 > data["team1Wmax"]).astype(float))))) / 2.0))) / 2.0) +
                    (((data["team1"] >= (1.0/(1.0 + np.exp(- np.tanh(data["team1Wstd"]))))).astype(float)) * np.tanh(((data["team1Lmin"] > ((1.0/(1.0 + np.exp(- np.tanh(data["team1Lmin"])))) * np.minimum( ((((1.0/(1.0 + np.exp(- data["team1"]))) + data["team1Wstd"])/2.0)),  (data["team2"])))).astype(float)))) +
                    (((((data["team2Wmax"] * data["team2Wmin"]) >= ((np.floor(data["team2Wmin"]) == ((data["team1WAverage"] <= data["team1WAverage"]).astype(float))).astype(float))).astype(float)) + (-(np.round(np.sin((1.0/(1.0 + np.exp(- np.abs((data["team1Wmin"] - np.cos(data["team2Wmin"])))))))))))/2.0))

    return Outputs(predictions)


def Aggregate(teamcompactresults1,
              teamcompactresults2,
              merged_results,
              regularseasoncompactresults):
    winningteam1compactresults = pd.merge(how='left',
                                          left=teamcompactresults1,
                                          right=regularseasoncompactresults,
                                          left_on=['year', 'team1'],
                                          right_on=['Season', 'Wteam'])
    winningteam1compactresults.drop(['Season',
                                     'Daynum',
                                     'Wteam',
                                     'Lteam',
                                     'Lscore',
                                     'Wloc',
                                     'Numot'],
                                    inplace=True,
                                    axis=1)
    grpwinningteam1resultsaverage =  \
        winningteam1compactresults.groupby(['year', 'team1']).mean()
    winningteam1resultsaverage = grpwinningteam1resultsaverage.reset_index()
    winningteam1resultsaverage.rename(columns={'Wscore': 'team1WAverage'},
                                      inplace=True)
    grpwinningteam1resultsmin =  \
        winningteam1compactresults.groupby(['year', 'team1']).min()
    winningteam1resultsmin = grpwinningteam1resultsmin.reset_index()
    winningteam1resultsmin.rename(columns={'Wscore': 'team1Wmin'},
                                  inplace=True)
    grpwinningteam1resultsmax =  \
        winningteam1compactresults.groupby(['year', 'team1']).max()
    winningteam1resultsmax = grpwinningteam1resultsmax.reset_index()
    winningteam1resultsmax.rename(columns={'Wscore': 'team1Wmax'},
                                  inplace=True)
    grpwinningteam1resultsmedian =  \
        winningteam1compactresults.groupby(['year', 'team1']).median()
    winningteam1resultsmedian = grpwinningteam1resultsmedian.reset_index()
    winningteam1resultsmedian.rename(columns={'Wscore': 'team1Wmedian'},
                                     inplace=True)
    grpwinningteam1resultsstd =  \
        winningteam1compactresults.groupby(['year', 'team1']).std()
    winningteam1resultsstd = grpwinningteam1resultsstd.reset_index()
    winningteam1resultsstd.rename(columns={'Wscore': 'team1Wstd'},
                                  inplace=True)
    losingteam1compactresults = pd.merge(how='left',
                                         left=teamcompactresults1,
                                         right=regularseasoncompactresults,
                                         left_on=['year', 'team1'],
                                         right_on=['Season', 'Lteam'])
    losingteam1compactresults.drop(['Season',
                                    'Daynum',
                                    'Wteam',
                                    'Lteam',
                                    'Wscore',
                                    'Wloc',
                                    'Numot'],
                                   inplace=True,
                                   axis=1)
    grplosingteam1resultsaverage = \
        losingteam1compactresults.groupby(['year', 'team1']).mean()
    losingteam1resultsaverage = grplosingteam1resultsaverage.reset_index()
    losingteam1resultsaverage.rename(columns={'Lscore': 'team1LAverage'},
                                     inplace=True)
    grplosingteam1resultsmin = \
        losingteam1compactresults.groupby(['year', 'team1']).min()
    losingteam1resultsmin = grplosingteam1resultsmin.reset_index()
    losingteam1resultsmin.rename(columns={'Lscore': 'team1Lmin'},
                                 inplace=True)
    grplosingteam1resultsmax = \
        losingteam1compactresults.groupby(['year', 'team1']).max()
    losingteam1resultsmax = grplosingteam1resultsmax.reset_index()
    losingteam1resultsmax.rename(columns={'Lscore': 'team1Lmax'},
                                 inplace=True)
    grplosingteam1resultsmedian = \
        losingteam1compactresults.groupby(['year', 'team1']).median()
    losingteam1resultsmedian = grplosingteam1resultsmedian.reset_index()
    losingteam1resultsmedian.rename(columns={'Lscore': 'team1Lmedian'},
                                    inplace=True)
    grplosingteam1resultsstd = \
        losingteam1compactresults.groupby(['year', 'team1']).std()
    losingteam1resultsstd = grplosingteam1resultsstd.reset_index()
    losingteam1resultsstd.rename(columns={'Lscore': 'team1Lstd'},
                                 inplace=True)
    winningteam2compactresults = pd.merge(how='left',
                                          left=teamcompactresults2,
                                          right=regularseasoncompactresults,
                                          left_on=['year', 'team2'],
                                          right_on=['Season', 'Wteam'])
    winningteam2compactresults.drop(['Season',
                                     'Daynum',
                                     'Wteam',
                                     'Lteam',
                                     'Lscore',
                                     'Wloc',
                                     'Numot'],
                                    inplace=True,
                                    axis=1)
    grpwinningteam2resultsaverage = \
        winningteam2compactresults.groupby(['year', 'team2']).mean()
    winningteam2resultsaverage = grpwinningteam2resultsaverage.reset_index()
    winningteam2resultsaverage.rename(columns={'Wscore': 'team2WAverage'},
                                      inplace=True)
    grpwinningteam2resultsmin = \
        winningteam2compactresults.groupby(['year', 'team2']).min()
    winningteam2resultsmin = grpwinningteam2resultsmin.reset_index()
    winningteam2resultsmin.rename(columns={'Wscore': 'team2Wmin'},
                                  inplace=True)
    grpwinningteam2resultsmax = \
        winningteam2compactresults.groupby(['year', 'team2']).max()
    winningteam2resultsmax = grpwinningteam2resultsmax.reset_index()
    winningteam2resultsmax.rename(columns={'Wscore': 'team2Wmax'},
                                  inplace=True)
    grpwinningteam2resultsmedian = \
        winningteam2compactresults.groupby(['year', 'team2']).median()
    winningteam2resultsmedian = grpwinningteam2resultsmedian.reset_index()
    winningteam2resultsmedian.rename(columns={'Wscore': 'team2Wmedian'},
                                     inplace=True)
    grpwinningteam2resultsstd = \
        winningteam2compactresults.groupby(['year', 'team2']).std()
    winningteam2resultsstd = grpwinningteam2resultsstd.reset_index()
    winningteam2resultsstd.rename(columns={'Wscore': 'team2Wstd'},
                                  inplace=True)
    losingteam2compactresults = pd.merge(how='left',
                                         left=teamcompactresults2,
                                         right=regularseasoncompactresults,
                                         left_on=['year', 'team2'],
                                         right_on=['Season', 'Lteam'])
    losingteam2compactresults.drop(['Season',
                                    'Daynum',
                                    'Wteam',
                                    'Lteam',
                                    'Wscore',
                                    'Wloc',
                                    'Numot'],
                                   inplace=True,
                                   axis=1)
    grplosingteam2resultsaverage = \
        losingteam2compactresults.groupby(['year', 'team2']).mean()
    losingteam2resultsaverage = grplosingteam2resultsaverage.reset_index()
    losingteam2resultsaverage.rename(columns={'Lscore': 'team2LAverage'},
                                     inplace=True)
    grplosingteam2resultsmin = \
        losingteam2compactresults.groupby(['year', 'team2']).min()
    losingteam2resultsmin = grplosingteam2resultsmin.reset_index()
    losingteam2resultsmin.rename(columns={'Lscore': 'team2Lmin'},
                                 inplace=True)
    grplosingteam2resultsmax = \
        losingteam2compactresults.groupby(['year', 'team2']).max()
    losingteam2resultsmax = grplosingteam2resultsmax.reset_index()
    losingteam2resultsmax.rename(columns={'Lscore': 'team2Lmax'},
                                 inplace=True)
    grplosingteam2resultsmedian = \
        losingteam2compactresults.groupby(['year', 'team2']).median()
    losingteam2resultsmedian = grplosingteam2resultsmedian.reset_index()
    losingteam2resultsmedian.rename(columns={'Lscore': 'team2Lmedian'},
                                    inplace=True)
    grplosingteam2resultsstd = \
        losingteam2compactresults.groupby(['year', 'team2']).std()
    losingteam2resultsstd = grplosingteam2resultsstd.reset_index()
    losingteam2resultsstd.rename(columns={'Lscore': 'team2Lstd'},
                                 inplace=True)
    agg_results = pd.merge(how='left',
                           left=merged_results,
                           right=winningteam1resultsaverage,
                           left_on=['year', 'team1'],
                           right_on=['year', 'team1'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=losingteam1resultsaverage,
                           left_on=['year', 'team1'],
                           right_on=['year', 'team1'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=winningteam1resultsmin,
                           left_on=['year', 'team1'],
                           right_on=['year', 'team1'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=losingteam1resultsmin,
                           left_on=['year', 'team1'],
                           right_on=['year', 'team1'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=winningteam1resultsmax,
                           left_on=['year', 'team1'],
                           right_on=['year', 'team1'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=losingteam1resultsmax,
                           left_on=['year', 'team1'],
                           right_on=['year', 'team1'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=winningteam1resultsmedian,
                           left_on=['year', 'team1'],
                           right_on=['year', 'team1'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=losingteam1resultsmedian,
                           left_on=['year', 'team1'],
                           right_on=['year', 'team1'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=winningteam1resultsstd,
                           left_on=['year', 'team1'],
                           right_on=['year', 'team1'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=losingteam1resultsstd,
                           left_on=['year', 'team1'],
                           right_on=['year', 'team1'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=winningteam2resultsaverage,
                           left_on=['year', 'team2'],
                           right_on=['year', 'team2'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=losingteam2resultsaverage,
                           left_on=['year', 'team2'],
                           right_on=['year', 'team2'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=winningteam2resultsmin,
                           left_on=['year', 'team2'],
                           right_on=['year', 'team2'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=losingteam2resultsmin,
                           left_on=['year', 'team2'],
                           right_on=['year', 'team2'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=winningteam2resultsmax,
                           left_on=['year', 'team2'],
                           right_on=['year', 'team2'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=losingteam2resultsmax,
                           left_on=['year', 'team2'],
                           right_on=['year', 'team2'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=winningteam2resultsmedian,
                           left_on=['year', 'team2'],
                           right_on=['year', 'team2'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=losingteam2resultsmedian,
                           left_on=['year', 'team2'],
                           right_on=['year', 'team2'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=winningteam2resultsstd,
                           left_on=['year', 'team2'],
                           right_on=['year', 'team2'])
    agg_results = pd.merge(how='left',
                           left=agg_results,
                           right=losingteam2resultsstd,
                           left_on=['year', 'team2'],
                           right_on=['year', 'team2'])
    return agg_results


def GrabData():
    tourneyresults = pd.read_csv('../input/TourneyCompactResults.csv')
    tourneyseeds = pd.read_csv('../input/TourneySeeds.csv')
    regularseasoncompactresults = \
        pd.read_csv('../input/RegularSeasonCompactResults.csv')
    sample = pd.read_csv('../input/SampleSubmission.csv')
    results = pd.DataFrame()
    results['year'] = tourneyresults.Season
    results['team1'] = np.minimum(tourneyresults.Wteam, tourneyresults.Lteam)
    results['team2'] = np.maximum(tourneyresults.Wteam, tourneyresults.Lteam)
    results['result'] = (tourneyresults.Wteam <
                         tourneyresults.Lteam).astype(int)
    merged_results = pd.merge(left=results,
                              right=tourneyseeds,
                              left_on=['year', 'team1'],
                              right_on=['Season', 'Team'])
    merged_results.drop(['Season', 'Team'], inplace=True, axis=1)
    merged_results.rename(columns={'Seed': 'team1Seed'}, inplace=True)
    merged_results = pd.merge(left=merged_results,
                              right=tourneyseeds,
                              left_on=['year', 'team2'],
                              right_on=['Season', 'Team'])
    merged_results.drop(['Season', 'Team'], inplace=True, axis=1)
    merged_results.rename(columns={'Seed': 'team2Seed'}, inplace=True)
    merged_results['team1Seed'] = \
        merged_results['team1Seed'].apply(lambda x: str(x)[1:3])
    merged_results['team2Seed'] = \
        merged_results['team2Seed'].apply(lambda x: str(x)[1:3])
    merged_results = merged_results.astype(int)
    winsbyyear = regularseasoncompactresults[['Season', 'Wteam']].copy()
    winsbyyear['wins'] = 1
    wins = winsbyyear.groupby(['Season', 'Wteam']).sum()
    wins = wins.reset_index()
    lossesbyyear = regularseasoncompactresults[['Season', 'Lteam']].copy()
    lossesbyyear['losses'] = 1
    losses = lossesbyyear.groupby(['Season', 'Lteam']).sum()
    losses = losses.reset_index()
    winsteam1 = wins.copy()
    winsteam1.rename(columns={'Season': 'year',
                              'Wteam': 'team1',
                              'wins': 'team1wins'}, inplace=True)
    winsteam2 = wins.copy()
    winsteam2.rename(columns={'Season': 'year',
                              'Wteam': 'team2',
                              'wins': 'team2wins'}, inplace=True)
    lossesteam1 = losses.copy()
    lossesteam1.rename(columns={'Season': 'year',
                                'Lteam': 'team1',
                                'losses': 'team1losses'}, inplace=True)
    lossesteam2 = losses.copy()
    lossesteam2.rename(columns={'Season': 'year',
                                'Lteam': 'team2',
                                'losses': 'team2losses'}, inplace=True)
    merged_results = pd.merge(how='left',
                              left=merged_results,
                              right=winsteam1,
                              left_on=['year', 'team1'],
                              right_on=['year', 'team1'])
    merged_results = pd.merge(how='left',
                              left=merged_results,
                              right=lossesteam1,
                              left_on=['year', 'team1'],
                              right_on=['year', 'team1'])
    merged_results = pd.merge(how='left',
                              left=merged_results,
                              right=winsteam2,
                              left_on=['year', 'team2'],
                              right_on=['year', 'team2'])
    merged_results = pd.merge(how='left',
                              left=merged_results,
                              right=lossesteam2,
                              left_on=['year', 'team2'],
                              right_on=['year', 'team2'])
    teamcompactresults1 = merged_results[['year', 'team1']].copy()
    teamcompactresults2 = merged_results[['year', 'team2']].copy()

    train = Aggregate(teamcompactresults1,
                      teamcompactresults2,
                      merged_results,
                      regularseasoncompactresults)

    sample['year'] = sample.Id.apply(lambda x: str(x)[:4]).astype(int)
    sample['team1'] = sample.Id.apply(lambda x: str(x)[5:9]).astype(int)
    sample['team2'] = sample.Id.apply(lambda x: str(x)[10:14]).astype(int)

    merged_results = pd.merge(how='left',
                              left=sample,
                              right=tourneyseeds,
                              left_on=['year', 'team1'],
                              right_on=['Season', 'Team'])
    merged_results.drop(['Season', 'Team'], inplace=True, axis=1)
    merged_results.rename(columns={'Seed': 'team1Seed'}, inplace=True)
    merged_results = pd.merge(how='left',
                              left=merged_results,
                              right=tourneyseeds,
                              left_on=['year', 'team2'],
                              right_on=['Season', 'Team'])
    merged_results.drop(['Season', 'Team'], inplace=True, axis=1)
    merged_results.rename(columns={'Seed': 'team2Seed'}, inplace=True)
    merged_results['team1Seed'] = \
        merged_results['team1Seed'].apply(lambda x: str(x)[1:3]).astype(int)
    merged_results['team2Seed'] = \
        merged_results['team2Seed'].apply(lambda x: str(x)[1:3]).astype(int)
    merged_results = pd.merge(how='left',
                              left=merged_results,
                              right=winsteam1,
                              left_on=['year', 'team1'],
                              right_on=['year', 'team1'])
    merged_results = pd.merge(how='left',
                              left=merged_results,
                              right=lossesteam1,
                              left_on=['year', 'team1'],
                              right_on=['year', 'team1'])
    merged_results = pd.merge(how='left',
                              left=merged_results,
                              right=winsteam2,
                              left_on=['year', 'team2'],
                              right_on=['year', 'team2'])
    merged_results = pd.merge(how='left',
                              left=merged_results,
                              right=lossesteam2,
                              left_on=['year', 'team2'],
                              right_on=['year', 'team2'])

    teamcompactresults1 = merged_results[['year', 'team1']].copy()
    teamcompactresults2 = merged_results[['year', 'team2']].copy()

    test = Aggregate(teamcompactresults1,
                     teamcompactresults2,
                     merged_results,
                     regularseasoncompactresults)

    return train, test


if __name__ == "__main__":
    train, test = GrabData()
    trainlabels = train.result.values
    train.drop('result', inplace=True, axis=1)
    train.fillna(-1, inplace=True)
    testids = test.Id.values
    test.drop(['Id', 'Pred'], inplace=True, axis=1)
    test.fillna(-1, inplace=True)
    ss = StandardScaler()
    train[train.columns] = np.round(ss.fit_transform(train), 6)
    predictions = GPIndividual1(train)
    predictions.fillna(1, inplace=True)
    print(log_loss(trainlabels, np.clip(predictions.values, .01, .99)))
    test[test.columns] = np.round(ss.transform(test), 6)
    predictions = GPIndividual1(test)
    predictions.fillna(1, inplace=True)
    submission = pd.DataFrame({'Id': testids,
                               'Pred': np.clip(predictions.values, .01, .99)})
    submission.to_csv('submission.csv', index=False)
    print('Finished')
