# Distributed Machine Learning System ---- {main script}
#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
# Set Working Directory ----
setwd("C:/Users/Jonathan Korn/Desktop/cu_hsp-learning/10_project")
# - Parallel Process ----
library(doParallel)
cl = makeCluster(detectCores() - 1)
registerDoParallel(cl)

files <- list.files(path = "sim/.", recursive = TRUE,
                    pattern = "\\.r$", 
                    full.names = TRUE)

foreach(i = 1:length(files)) %dopar%
  {
    source(files[i])
  }

stopCluster(cl)
#######################################################################################
#######################################################################################
#######################################################################################
#######################################################################################
library(readr)
# - Predictions...
df_total_pred <- read_csv("outputs/df_total_pred.csv")
df_total_pred1 <- read_csv("outputs/df_total_pred1.csv")