import os
import sys
import pandas as pd
sys.path.append("lib")

from AllStatePredictor import AllStatePredictor

p = AllStatePredictor()

def concat_ABCDEFG(x):
    return "%d%d%d%d%d%d%d" % (x['A'], x['B'], x['C'], x['D'], x['E'], x['F'], x['G'])

print "prediction classe 2 linear svc..."
customer_ID_list_2 = p.get_customer_ID_list("2")
a_prediction_2 = p.predict("A", "logistic", "not_centered", "2")
b_prediction_2 = p.predict("B", "logistic", "not_centered", "2")
c_prediction_2 = p.predict("C", "logistic", "not_centered", "2")
d_prediction_2 = p.predict("D", "logistic", "not_centered", "2")
e_prediction_2 = p.predict("E", "logistic", "not_centered", "2")
f_prediction_2 = p.predict("F", "logistic", "not_centered", "2")
g_prediction_2 = p.predict("G", "logistic", "not_centered", "2")

prediction_2_detail = pd.DataFrame(
    {
        'A' : a_prediction_2,
        'B' : b_prediction_2,
        'C' : c_prediction_2,
        'D' : d_prediction_2,
        'E' : e_prediction_2,
        'F' : f_prediction_2,
        'G' : g_prediction_2
    },
    index=customer_ID_list_2
)

prediction_2_synthese = prediction_2_detail.apply(concat_ABCDEFG, axis=1)

print "prediction classe 3 linear svc..."
customer_ID_list_3 = p.get_customer_ID_list("3")
a_prediction_3 = p.predict("A", "logistic", "not_centered", "3")
b_prediction_3 = p.predict("B", "logistic", "not_centered", "3")
c_prediction_3 = p.predict("C", "logistic", "not_centered", "3")
d_prediction_3 = p.predict("D", "logistic", "not_centered", "3")
e_prediction_3 = p.predict("E", "logistic", "not_centered", "3")
f_prediction_3 = p.predict("F", "logistic", "not_centered", "3")
g_prediction_3 = p.predict("G", "logistic", "not_centered", "3")

prediction_3_detail = pd.DataFrame(
    {
        'A' : a_prediction_3,
        'B' : b_prediction_3,
        'C' : c_prediction_3,
        'D' : d_prediction_3,
        'E' : e_prediction_3,
        'F' : f_prediction_3,
        'G' : g_prediction_3
    },
    index=customer_ID_list_3
)

prediction_3_synthese = prediction_3_detail.apply(concat_ABCDEFG, axis=1)

print "prediction classe all linear svc..."
customer_ID_list_all = p.get_customer_ID_list("all")
a_prediction_all = p.predict("A", "logistic", "not_centered", "all")
b_prediction_all = p.predict("B", "logistic", "not_centered", "all")
c_prediction_all = p.predict("C", "logistic", "not_centered", "all")
d_prediction_all = p.predict("D", "logistic", "not_centered", "all")
e_prediction_all = p.predict("E", "logistic", "not_centered", "all")
f_prediction_all = p.predict("F", "logistic", "not_centered", "all")
g_prediction_all = p.predict("G", "logistic", "not_centered", "all")

prediction_all_detail = pd.DataFrame(
    {
        'A' : a_prediction_all,
        'B' : b_prediction_all,
        'C' : c_prediction_all,
        'D' : d_prediction_all,
        'E' : e_prediction_all,
        'F' : f_prediction_all,
        'G' : g_prediction_all
    },
    index=customer_ID_list_all
)

prediction_all_synthese = prediction_all_detail.apply(concat_ABCDEFG, axis=1)


prediction_submission = prediction_2_synthese.append(prediction_3_synthese.append(prediction_all_synthese))
prediction_submission = prediction_submission.sort_index(ascending=True)
prediction_submission = pd.DataFrame(prediction_submission, columns=["plan"])

submission_filename = os.path.join("DATA", "PYTHON", "logistic_python_v1.csv")
prediction_submission.to_csv(submission_filename, header=True, index=True, index_label=["customer_ID"])
