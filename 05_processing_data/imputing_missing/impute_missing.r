# Impute Missing/Na Values ----
library(datasets)
data(iris)
data = iris 
if (!require("mice")) {
  install.packages("mice")
  library(mice)
}
missing = data %>% mice::mice(m=5,maxit=50,meth="sample",seed=500,print = FALSE)
missing <- mice::complete(missing, action=as.numeric(2))
data = na.omit(missing)
print(str(data))