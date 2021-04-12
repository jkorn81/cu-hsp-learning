# Automaticall Filter Noise From Data and Balance ----
library(datasets)
data(iris)
data = iris 
target = c("set variable name of your choosing...") # choose the target variable...
data[,c(target)] = as.factor(data[,c(target)])
formula = make.formula(target, ".")
noise = GE(formula, data = data, k = 5, kk = ceiling(5/2))
data = noise$cleanData
print(str(data))