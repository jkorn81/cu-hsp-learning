# - subset variables ----
import pandas as pd
from sklearn import datasets
import numpy as np
iris = datasets.load_iris()
data = iris[, 'Sepal.Length'] # conditionally select the variables to remove from the dataframe. 
print(data.head)
