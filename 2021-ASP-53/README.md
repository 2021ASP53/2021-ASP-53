# Distinguishing Benign and Malignant Breast Tumours Using Cell Nucleus Measurements in R

Student registration number: 2021/ASP/53  
GitHub username: 2021ASP53

This project uses the Wisconsin Diagnostic Breast Cancer dataset to explore whether mean nucleus radius and mean texture can distinguish samples labelled benign from those labelled malignant.

## Project structure

- `analysis.R` — main entry point for running the analysis from the project root.
- `code/analysis_sequences.R` — data checks, exploratory plots, statistical tests, logistic regression and report generation.
- `REPORT_TEMPLATE.md` — report template populated by the analysis script.
- `data/wdbc.csv` — bundled dataset.
- `figures/` — generated PNG figures.
- `results/` — generated tables, model and session information.
- `report.html` — generated HTML report.

## Run in RStudio

1. Download and extract this repository.
2. Open `2021-ASP-53.Rproj` in RStudio.
3. Confirm the RStudio working directory is the project root.
4. Run:

```r
source("analysis.R")
```

Alternatively, from a terminal opened at the repository root:

```sh
Rscript analysis.R
```

The project uses base R and standard recommended packages; no additional package installation should be required.

## Expected outputs

The script creates three figures:

1. `figures/01_training_distributions.png`
2. `figures/02_training_scatter.png`
3. `figures/03_test_roc.png`

It also writes quality-control, data-split, training-summary, Welch-test, model, coefficient, confusion-matrix, prediction and session-information files into `results/`, and generates `README.md` and `report.html`.

## Important interpretation

This is an educational analysis of a historical public dataset. Its results do not establish clinical usefulness and must not be used to diagnose patients or guide clinical decisions. The held-out test results describe only the particular split used in this project.

## Dataset reference

Wolberg, W., Street, W., and Mangasarian, O. Breast Cancer Wisconsin (Diagnostic) [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5DW2B. Dataset licence: CC BY 4.0.
