import sys
import unittest

from AllStateDataLoader import AllStateDataLoader

class AllStateDataLoaderTest(unittest.TestCase):

    def setUp(self):
        self.data_loader = AllStateDataLoader()


    def testColumnsData2Train(self):
        self.data_2_train = self.data_loader.get_data_2_train()
        self.assertTrue("real_A" in self.data_2_train.columns)
        self.assertFalse("value_A_pt_2" in self.data_2_train.columns)
        self.assertFalse("value_A_pt_2_0" in self.data_2_train.columns)
        self.assertFalse("value_A_pt_3_0" in self.data_2_train.columns)
        

if __name__ == "__main__":
    unittest.main()