#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# - [-] - Set Working Directory ----
dir = getwd()
setwd(dir)
#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# - [-] - Load Libraries ----
if (!require("readr")) {
  install.packages("readr")
  library(readr)
}
if (!require("dplyr")) {
  install.packages("dplyr")
  library(dplyr)
}
if (!require("quantmod")) {
  install.packages("quantmod")
  library(quantmod)
}
if (!require("mice")) {
  install.packages("mice")
  library(mice)
}
if (!require("outlieR")) {
  remotes::install_github("rushkin/outlieR")
  library(outlieR)
}
if (!require("dplyr")) {
  install.packages("dplyr")
  library(dplyr)
}
if (!require("magrittr")) {
  install.packages("magrittr")
  library(magrittr)
}
if (!require("TTR")) {
  install.packages("TTR")
  library(TTR)
}
if (!require('caret')) {
  install.packages("caret", dependencies = TRUE)
  library(caret)
}
if (!require("caretEnsemble")) {
  install.packages("caretEnsemble")
  library(caretEnsemble)
}
if (!require("parallel")) {
  install.packages("parallel")
  library(parallel)
}
if (!require("foreach")) {
  install.packages("foreach")
  library(foreach)
}
if (!require("pipeR")) {
  install.packages("pipeR")
  library(pipeR)
}
#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# - [-] - Import Data Source ----
start <- as.Date(Sys.Date()-(365*5))
end <- as.Date(Sys.Date())
getSymbols("GOOG", src = "yahoo", from = start, to = end)
data = GOOG
colnames(data) = c("Open", "High", "Low", "Close", "Volume", "Adjusted")
date = index(data)
original = data.frame(date = date, data.frame(data))
#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# - [-] - Create Features ----
original = original %<>% dplyr::mutate(.,
                                       Med = (High + Low)/2,
                                       Typ = (High + Low + Close)/3,
                                       Wg  = (High + Low + 2 * Close)/4,
                                       CO  = Close - Open,
                                       HO  = High - Open,
                                       LO  = Low - Open,
                                       dH  = c(NA, diff(High)),
                                       dL  = c(NA, diff(Low))
)
original %<>% cbind(., sig = sign(original$CO))
original = original %>% dplyr::mutate(sig = replace(.$sig, sig == 0, 1))
original = original %>% mutate(., sig = lead(sig, 1))
#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# - [-] Subset Variables ----
remove = c("date", "Open", "High", "Low", "Close", "Volume", "Adjusted")
original = original[, !colnames(original) %in% c(remove)]
#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# - Impute Missing ----
missing = original %>% mice::mice(m=5,maxit=50,meth="sample",seed=500,print = FALSE)
missing <- mice::complete(missing, action=as.numeric(2))
original = na.omit(missing)
#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# - Impute Outliers ----
original = original %>% outlieR::impute(flag = NULL, fill = "mean", 
                                        level = 0.1, nmax = NULL,
                                        side = NULL, crit = "lof", 
                                        k = 5, metric = "euclidean", q = 3)
str(original)
#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# - Normalize Data ----
preProClean <- preProcess(x = original, method = c("scale", "center"))
original <- predict(preProClean, original %>% na.omit)
#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# - Correct Classes ----
original$sig = round(original$sig,0)
#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# - [-] - Balance the Class Distribution ----
split_s <- original %>% filter(sig == -1)
split_b <- original %>% filter(sig == 1)
mn <- min(nrow(split_s), nrow(split_b)) 
original <-
  rbind(
    split_s %>% sample_n(mn),
    split_b %>% sample_n(mn)) %>%
  sample_n(mn * 2)
original = data.frame(original)
#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# - [-] - Shape Classes ----
original$sig = factor(original$sig, levels = c("-1","1"), labels = c(1,2))
original = original %>% mutate(sig = factor(sig, labels = make.names(levels(sig))))
#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# - [-] - Load the Trained Model ----
model <- readRDS("./final_model3.rds") # Load Model State ----
for(i in 1:1000){ # Loop Through Data to simulate Instances...
  original_window = original[(0+i):(99+i),]
  original_window = first(original_window, 100-1)
  write.csv(original_window,"data/original_window3.csv", row.names = FALSE) # save rolling slice of data 
  # - [-] - Subset Irrelevant Variables ----
  sub = original_window
  sub = data.frame(sub)
  #######################################################################################
  #######################################################################################
  #######################################################################################
  #######################################################################################
  pred = predict(model, newdata = sub)
  pred = factor(pred, levels = c("X1","X2"), labels = c(-1,1))
  pred = as.numeric(pred)
  pred = data.frame(last(pred,1))
  colnames(pred) = c("signal")
  #######################################################################################
  #######################################################################################
  #######################################################################################
  #######################################################################################
  # - [-] - Produce Predictions ----
  if(i==1) df_total_window = pred
  df_total_window[i,] = pred
  str(df_total_window)
  write.csv(df_total_window,"data/df_total_pred3.csv", row.names = FALSE)
  print("this is the end of loop")
}


