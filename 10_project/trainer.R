# Train Models ---- {main script}
#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# Set Working Directory ----
setwd("C:/Users/Jonathan Korn/Desktop/cu_hsp-learning/10_project")
#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# - Import Libraries ----
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
# - Import and Save Data ----
# Asset 1...
start <- as.Date(Sys.Date()-(365*5))
end <- as.Date(Sys.Date())
getSymbols("GOOG", src = "yahoo", from = start, to = end)
data = GOOG
colnames(data) = c("Open", "High", "Low", "Close", "Volume", "Adjusted")
date = index(data)
original = data.frame(date = date, data.frame(data))
write.csv(original,"data/asset1.csv", row.names = FALSE)
# Asset 2...
start <- as.Date(Sys.Date()-(365*5))
end <- as.Date(Sys.Date())
getSymbols("MMM", src = "yahoo", from = start, to = end)
data = MMM
colnames(data) = c("Open", "High", "Low", "Close", "Volume", "Adjusted")
date = index(data)
original = data.frame(date = date, data.frame(data))
write.csv(original,"data/asset2.csv", row.names = FALSE)
#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# - Parallel Process ----
library(doParallel)
cl = makeCluster(detectCores() - 1)
registerDoParallel(cl)

files <- list.files(path = "models/.", recursive = TRUE,
                    pattern = "\\.r$", 
                    full.names = TRUE)

foreach(i = 1:length(files)) %dopar%
  {
    source(files[i])
  }

stopCluster(cl)