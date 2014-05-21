

import os
import numpy as np
import pandas as pd
from sklearn.externals import joblib
from AllStateDataLoader import AllStateDataLoader


class AllStatePredictor():
    """Object de prediction"""
    def __init__(self):
        self.__datasets = {}
        self.__dataloader = AllStateDataLoader()
        self.debug = True


    def __get_dataset(self, type_dataset, kind="test"):
        """Recuperation du dataset (lazy)"""

        if type_dataset == "2":
            if not self.__datasets.has_key("2"):
                if kind == "test":
                    self.__datasets["2"] = self.__dataloader.get_data_2_test()
                else:
                    self.__datasets["2"] = self.__dataloader.get_X_train("2", "")                    
            return self.__datasets["2"]
        elif type_dataset == "3":
            if not self.__datasets.has_key("3"):
                if kind == "test":
                    self.__datasets["3"] = self.__dataloader.get_data_3_test()
                else:
                    self.__datasets["3"] = self.__dataloader.get_X_train("3", "")
            return self.__datasets["3"]
        elif type_dataset == "4":
            if not self.__datasets.has_key("4"):
                if kind == "test":
                    self.__datasets["4"] = self.__dataloader.get_data_4_test()
                else:
                    self.__datasets["4"] = self.__dataloader.get_X_train("4", "")
            return self.__datasets["4"]
        elif type_dataset == "all":
            if not self.__datasets.has_key("all"):
                if kind == "test":
                    self.__datasets["all"] = self.__dataloader.get_data_all_test()
                else:
                    self.__datasets["all"] = self.__dataloader.get_X_train("all", "")
            return self.__datasets["all"]

    def get_X_columns(self, type_dataset):
        """Recuperation de la liste des colonnes d'un dataset particulier"""
        dataset = self.__get_dataset(type_dataset)

        return [x for x in dataset.columns if x not in ["real_%s" % letter for letter in ['A','B','C','D','E','F','G']]]


    def get_X(self, type_dataset, kind="test"):
        """Recuperation de X"""
        dataset = self.__get_dataset(type_dataset, kind=kind)
        tmp = dataset.copy()

        for variable in ["real_%s" % x for x in ['A','B','C','D','E','F','G'] if "real_%s" % x in self.get_X_columns(type_dataset)]:
            del tmp[variable]

        tmp = tmp.reindex(columns=sorted(list(tmp.columns)))

        return tmp

    def get_customer_ID_list(self, type_dataset):
        """Recuperation de la liste des customer_ID"""
        dataset = self.__get_dataset(type_dataset)
        tmp = dataset.copy()
  
        return np.array(tmp.index)

    def get_model_filename(self, letter, type_prediction, centered_or_not, type_dataset):
        """Retourne le nom du fichier modele"""
        return(os.path.join("model_%s" % type_prediction, "model_%s_data_%s_%s_%s.pkl" % (type_prediction, type_dataset, letter, centered_or_not)))

    def __get_model(self, letter, type_prediction, centered_or_not, type_dataset):
        filename = self.get_model_filename(letter, type_prediction, centered_or_not, type_dataset)

        model = joblib.load(filename)

        return model

    def predict(self, letter, type_prediction, centered_or_not, type_dataset):
        """Fonction prediction"""

        X = self.get_X(type_dataset)

        model = self.__get_model(letter, type_prediction, centered_or_not, type_dataset)

        return(model.predict(X), model.predict_proba(X), model)

    def get_model(self, letter, type_prediction, centered_or_not, type_dataset):
        """Recuperation modele"""
        model = self.__get_model(letter, type_prediction, centered_or_not, type_dataset)
        return model

    def predict_simple(self, type_data, type_model, letter, kind="test"):
        """prediction"""
        def concat_ABCDEFG(x):
            return "%d%d%d%d%d%d%d" % (x['real_A'], x['real_B'], x['real_C'], x['real_D'], x['real_E'], x['real_F'], x['real_G'])

        data = self.__get_dataset(type_data, kind=kind)
        tmp = data.copy()

        if letter == "ABCDEFG":
            for letter_unique in letter:
                model_filename = os.path.join("model_%s" % type_model, "model_%s_data_%s_%s_not_centered.pkl" % (type_model, type_data, letter_unique))
                model = joblib.load(model_filename)
                tmp["real_%s" % letter_unique] = model.predict(data)

            return tmp.apply(concat_ABCDEFG, axis=1)
        else:
            model_filename = os.path.join("model_%s" % type_model, "model_%s_data_%s_%s_not_centered.pkl" % (type_model, type_data, letter))
            model = joblib.load(model_filename)
            return model.predict(data)

    def __get_cascade_model_filename(self, type_dataset, objective_letter, real_letters):
        if real_letters == "":
            return os.path.join("model_linearsvc", "model_linearsvc_data_%s_%s_without_real_cascade.pkl" % (type_dataset, objective_letter))
        else:
            return os.path.join("model_linearsvc", "model_linearsvc_data_%s_%s_with_real_%s_cascade.pkl" % (type_dataset, objective_letter, real_letters))


    def predict_cascade(self, type_data, type_model, letter, kind="test"):
        """prediction"""
        def concat_ABCDEFG(x):
            return "%d%d%d%d%d%d%d" % (x['real_A'], x['real_B'], x['real_C'], x['real_D'], x['real_E'], x['real_F'], x['real_G'])

        data = self.get_X(type_data, kind=kind)
        tmp_final = data.copy()

        # D
        tmp = data.copy()
        model_D_filename = self.__get_cascade_model_filename(type_data, "D", "")
        model_D = joblib.load(model_D_filename)
        tmp_final["real_D"] = model_D.predict(tmp)

        # C avec info D
        tmp = data.copy()
        tmp["real_D"] = tmp_final["real_D"].copy()
        tmp_bis = pd.DataFrame(pd.get_dummies(tmp["real_D"], prefix="real_D"), index=tmp.index)
        tmp = pd.merge(tmp, tmp_bis, left_index=True, right_index=True)
        del tmp["real_D"]
        tmp = tmp.reindex(columns=sorted(list(tmp.columns)))
        model_C_with_D_filename = self.__get_cascade_model_filename(type_data, "C", "D")
        model_C_with_D = joblib.load(model_C_with_D_filename)
        tmp_final["real_C"] = model_C_with_D.predict(tmp)
        
        # E
        tmp = data.copy()
        model_E_filename = self.__get_cascade_model_filename(type_data, "E", "")
        model_E = joblib.load(model_E_filename)
        tmp_final["real_E"] = model_E.predict(tmp)

        # B avec info E
        tmp = data.copy()
        tmp["real_E"] = tmp_final["real_E"].copy()
        tmp_bis = pd.DataFrame(pd.get_dummies(tmp["real_E"], prefix="real_E"), index=tmp.index)
        tmp = pd.merge(tmp, tmp_bis, left_index=True, right_index=True)
        del tmp["real_E"]
        tmp = tmp.reindex(columns=sorted(list(tmp.columns)))
        model_B_with_E_filename = self.__get_cascade_model_filename(type_data, "B", "E")
        model_B_with_E = joblib.load(model_B_with_E_filename)
        tmp_final["real_B"] = model_B_with_E.predict(tmp)

        # F avec info E
        tmp = data.copy()
        tmp["real_E"] = tmp_final["real_E"].copy()
        tmp_bis = pd.DataFrame(pd.get_dummies(tmp["real_E"], prefix="real_E"), index=tmp.index)
        tmp = pd.merge(tmp, tmp_bis, left_index=True, right_index=True)
        del tmp["real_E"]
        tmp = tmp.reindex(columns=sorted(list(tmp.columns)))
        model_F_with_E_filename = self.__get_cascade_model_filename(type_data, "F", "E")
        model_F_with_E = joblib.load(model_F_with_E_filename)
        tmp_final["real_F"] = model_F_with_E.predict(tmp)


        # A avec info EF
        tmp = data.copy()
        tmp["real_E"] = tmp_final["real_E"].copy()
        tmp_bis = pd.DataFrame(pd.get_dummies(tmp["real_E"], prefix="real_E"), index=tmp.index)
        tmp = pd.merge(tmp, tmp_bis, left_index=True, right_index=True)
        del tmp["real_E"]
        tmp["real_F"] = tmp_final["real_F"].copy()
        tmp_bis = pd.DataFrame(pd.get_dummies(tmp["real_F"], prefix="real_F"), index=tmp.index)
        tmp = pd.merge(tmp, tmp_bis, left_index=True, right_index=True)
        del tmp["real_F"]
        tmp = tmp.reindex(columns=sorted(list(tmp.columns)))
        model_A_with_EF_filename = self.__get_cascade_model_filename(type_data, "A", "EF")
        model_A_with_EF = joblib.load(model_A_with_EF_filename)
        tmp_final["real_A"] = model_A_with_EF.predict(tmp)

        # G avec info A
        tmp = data.copy()
        tmp["real_A"] = tmp_final["real_A"].copy()
        tmp_bis = pd.DataFrame(pd.get_dummies(tmp["real_A"], prefix="real_A"), index=tmp.index)
        tmp = pd.merge(tmp, tmp_bis, left_index=True, right_index=True)
        del tmp["real_A"]
        tmp = tmp.reindex(columns=sorted(list(tmp.columns)))
        model_G_with_A_filename = self.__get_cascade_model_filename(type_data, "G", "A")
        model_G_with_A = joblib.load(model_G_with_A_filename)
        tmp_final["real_G"] = model_G_with_A.predict(tmp)

        return tmp_final.apply(concat_ABCDEFG, axis=1)

