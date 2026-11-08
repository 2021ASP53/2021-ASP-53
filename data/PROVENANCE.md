# Dataset provenance

Original: Wolberg, Street and Mangasarian, Wisconsin Diagnostic Breast Cancer, UCI, DOI 10.24432/C5DW2B. Original dataset licence: CC BY 4.0.

The bundled wdbc.csv is a CSV export of sklearn.datasets.load_breast_cancer().data and .target, containing all 569 rows and 30 measurements without scaling or sampling. Target 0 was mapped to M and target 1 to B. Spaces in feature names were replaced by underscores. No original UCI patient/sample ID is included in this distribution. The Python export was only a file-packaging step; all project analyses are in code/analysis.R.

Features are supplied as mean, standard error and worst summaries of ten image characteristics. See the UCI dataset documentation for definitions. Mean radius and mean texture are the two predictors used here. The CSV column order is scikit-learn's order, which is not a promise about the original UCI file schema. Do not substitute a raw UCI file without mapping its headers and target.

The dataset is historical and already processed. Missingness checks in the R script apply to the supplied measurements, not to the original recruitment or imaging process.
