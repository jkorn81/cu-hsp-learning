# - Impute Outliers ----
library(datasets)
data(iris)
data = iris 
if (!require("outlieR")) {
  remotes::install_github("rushkin/outlieR")
  library(outlieR)
}
data = data %>% outlieR::impute(flag = NULL, fill = "mean", 
                                level = 0.1, nmax = NULL,
                                side = NULL, crit = "lof", 
                                k = 5, metric = "euclidean", q = 3)
print(str(data))