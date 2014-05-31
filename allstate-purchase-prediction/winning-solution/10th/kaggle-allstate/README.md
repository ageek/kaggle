Predict a purchased policy based on transaction history - a data mining competition that was hosted on Kaggle.com

http://www.kaggle.com/c/allstate-purchase-prediction-challenge

The code uses R ("Warm Puppy") and Harry Southworth's GBM implementation (v2.1-0.5 compiled under mingw32) - https://github.com/harrysouthworth/gbm

### Introduction
Data can be downloaded from http://www.kaggle.com/c/allstate-purchase-prediction-challenge/data

Run prepareData.R with training=T (this will produce the training set), then update currentTrainPath at the beginning of the file and run it again with training=F (to produce the test set). When you have both data sets processed load them together and add auxiliary variables (code is at the end of prepareData.R). Then run doSubmission.R to train models and generate a submission CSV.

### Preprocessing
Conversion of time and day into periods. Proper representation of missing values in the car_value variable. Fixed observations in which there was a married couple and yet the group size was 1.

Extracted the purchase qoutes from the data set. The rest was processed as follows:

New features added to each observation:
- age difference
- mean age
- T/F if a person is a senior
- T/F if clients are suspected to be teen + parents
- T/F if a person is suspected to be a teen
- T/F if a person is suspected to be a student
- T/F if clients are suspected to be a young marriage
- T/F if the car is relatively new
- T/F if the car is relatively old
- T/F if the applicant retained the same C option as she had before
- average cost
- popularity of the selected option
- location popularity
- a few auxiliary variables created as linear combinations of car age, car value and mean age that were selected on the basis on their correlation with coverage options (it wasn't much, but models definitely found these variables helpful)

Time-varying variables:
- gradient of the cost between quotes
- cumulative gradient of the cost
- absolute cumulative gradient of the cost
- number of coverage option changes
- T/F did the client had the coverage option A/B/E/F in any of her previous quotes?
- coverage option A/B/C/D/E/F/G in previous quote
- T/F if an observation is the last known quote of the client

### Models
Data was divided customer-wise into 3 folds. Classificators (GBMs) were trained for each coverage option for each fold (21 models in total). Their task was to assess whether a certain coverage option will differ in the final purchase from the current one. On their predictions on the training data another 21 GBMs were trained on the basis of multinomial distribution - their task was to identify which particular coverage option will be the final purchase.

Therefore, for each coverage option an ensemble of 3 classifiers was assesing whether a customer will change her mind regarding that particular option. If it is decided that she will change that option, then an ensemble of 3 GBMs was deciding which option would it be.

### Result
The 10th place out of 1571. Fortunately there was no overfitting - best submission on 30% of the test data turned out to be also the best on all 100%.

### WARNING !!!
The 2nd step GBMs (predictors of the final coverage option) were trained on the outputs of 1st step GBMs obtained *from the same fold that they were trained on*. This was a serious mistake! According to my knowledge and intuition better performance would surely be obtained if each 2nd step GBM was trained on outputs from an ensembled pair of the 1st step GBMs trained on different folds that they were applied on.

Moreover, since all coverage options are updated independently and models heavily depend on current coverage options the prediction process can be applied several times. It was discovered that 2 updates were enough (after 2 runs the results were stable on both 3fold CV and the test set) and were slightly improving the accuracy on both 3fold CV and the test set. These sequential updates are controlled by 'rep' variable in for-loops in the file doSubmission.R . During the competition however instead of applying this technique to my best entry I decided to use remaining submissions on testing various classification thresholds (with no success).