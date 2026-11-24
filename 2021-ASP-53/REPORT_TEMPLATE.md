# Distinguishing Benign and Malignant Breast Tumours Using Cell Nucleus Measurements in R

Student registration number: 2021/ASP/53  
GitHub username: 2021ASP53

## Abstract

This project investigates whether mean nucleus radius and mean texture can distinguish benign from malignant samples in the Wisconsin Diagnostic Breast Cancer dataset. The analysis uses a stratified training/test split, exploratory plots, Welch two-sample tests and logistic regression.

The training set contains {{TRAIN_N}} samples and the held-out test set contains {{TEST_N}} samples. The dataset contains {{BENIGN_N}} benign and {{MALIGNANT_N}} malignant samples.

On the held-out test set, accuracy was {{ACC}}, sensitivity was {{SENS}}, specificity was {{SPEC}}, and ROC AUC was {{AUC}}. These are results on this particular test split, not evidence of clinical performance in a new population.

## Research question

Can mean nucleus radius and mean texture distinguish samples labelled benign from those labelled malignant in this dataset?

## Data and methods

The project uses the Wisconsin Diagnostic Breast Cancer dataset supplied in `data/wdbc.csv`. The dataset contains 569 observations, one diagnosis column and 30 numerical predictors. The analysis uses two predictors selected in advance: `mean_radius` and `mean_texture`.

The script checks the expected dimensions, diagnosis labels, numeric measurements, finite values and duplicate rows. It then creates a reproducible, stratified 80:20 training/test split using random seed 2026.

Exploratory plots and Welch two-sample comparisons are based on training data. The two p-values are adjusted using the Holm method. A logistic regression model predicts malignancy from mean radius and mean texture. A probability of 0.5 or greater is classified as malignant.

## Training-set summaries

{{SUMMARY_TABLE}}

## Welch two-sample comparisons

The estimated mean difference is benign minus malignant. A negative value indicates a larger mean in the malignant group.

{{TEST_TABLE}}

## Held-out test results

- Accuracy: {{ACC}}
- Exact 95% confidence interval for accuracy: {{CI}}
- Sensitivity: {{SENS}}
- Specificity: {{SPEC}}
- ROC AUC: {{AUC}}
- True positives: {{TP}}
- True negatives: {{TN}}
- False positives: {{FP}}
- False negatives: {{FN}}
- Training-majority baseline accuracy: {{BASE}}

![Training distributions](figures/01_training_distributions.png)

Figure 1. Training-set distributions of mean nucleus radius and mean texture by diagnosis.

![Training scatterplot](figures/02_training_scatter.png)

Figure 2. Mean radius versus mean texture in the training set.

![Test ROC curve](figures/03_test_roc.png)

Figure 3. ROC curve for held-out test predictions.

## Discussion and limitations

The results describe classification performance within one split of a historical benchmark dataset. The model uses only two measurements and assumes a linear relationship between each predictor and the log-odds of malignancy. A random internal test split is not external validation.

This is an educational analysis and must not be used to diagnose patients or guide clinical decisions. Further work could include repeated cross-validation within the training data, calibration assessment and evaluation on a suitably documented independent dataset.

## Reproducibility

Open `2021-ASP-53.Rproj` in RStudio and run:

```r
source("analysis.R")
```

Alternatively, from a terminal opened at the repository root, run:

```sh
Rscript analysis.R
```

The workflow uses base R and standard recommended packages. It regenerates this README, `report.html`, three PNG figures and the CSV/RDS outputs in `results/`. Session and R version information is saved in `results/session_info.txt`.

## Dataset reference

Wolberg, W., Street, W., and Mangasarian, O. Breast Cancer Wisconsin (Diagnostic) [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5DW2B. Dataset licence: CC BY 4.0.
