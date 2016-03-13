#https://www.kaggle.com/thodime/march-machine-learning-mania-2016/mlmmlm/run/179962/code
import pandas as pd
import numpy as np
import csv
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import ExtraTreesClassifier
from sklearn import ensemble
from sklearn.metrics import log_loss
from sklearn.preprocessing import StandardScaler


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



train, test = GrabData()
trainlabels = train.result.values
train.drop('result', inplace=True, axis=1)
train.fillna(-1, inplace=True)
testids = test.Id.values
test.drop(['Id', 'Pred'], inplace=True, axis=1)
test.fillna(1, inplace=True)
ss = StandardScaler()
train[train.columns] = np.round(ss.fit_transform(train), 4)
test[test.columns] = np.round(ss.transform(test), 4)
X_train = train
X_test = test
target = trainlabels
print('Training...')
extc = ExtraTreesClassifier(n_estimators=1200,max_features= 26,criterion= 'entropy',min_samples_split= 1,
                            max_depth= 47, min_samples_leaf= 1, n_jobs = -1)      

extc.fit(X_train,target) 
x_pred = extc.predict_proba(X_train)
print(log_loss(trainlabels, np.clip(x_pred[:,1]*1.691, 1e-6, 1-1e-6)))
print('Predict...')
y_pred = extc.predict_proba(X_test)
#print y_pred

submission = pd.DataFrame({'Id': testids,
                           'Pred': np.clip(y_pred[:,1]*1.0691, 1e-6, 1-1e-6)})
submission.to_csv('submission.csv', index=False)
print('Finished')
