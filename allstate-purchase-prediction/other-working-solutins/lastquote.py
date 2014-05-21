import pandas as pd
import numpy as np

def combo(x): 
b=""
for i in ['A','B','C','D','E']:
b=b+str(x[i])
return(b)

data=pd.read_csv("train-2.csv")


data['combo']=data.apply(combo,axis=1)

group=data.groupby('customer_ID')

def replicate_benchmark(x,n=.3):
B=geometric(n)
val=0
if B+1 >=max(x['shopping_pt']):
E=max(x['shopping_pt'])-1
if B >=max(x['shopping_pt']):
E=max(x['shopping_pt'])-1
else:
E=B
c=list(x['combo'][x['shopping_pt']==E])[0]
b=list(x['combo'][x['shopping_pt']==max(x['shopping_pt'])])[0]
if c==b:
return(1)
else:
return(0)

Results=group.apply(replicate_benchmark)

print Results.mean()
