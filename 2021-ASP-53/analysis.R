# 2021/ASP/53
# Run this file from the repository root in RStudio.
# It calls the single analysis script; it does not call itself.
if (!file.exists("code/analysis_sequences.R")) {
  stop("Cannot find code/analysis_sequences.R. Open the 2021-ASP-53 project folder first.")
}
source("code/analysis_sequences.R")
