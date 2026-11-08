# Run from the repository root: Rscript code/analysis.R
# Only base R and its standard packages are required.

options(stringsAsFactors = FALSE)
set.seed(2026)
dir.create('results', showWarnings = FALSE)
dir.create('figures', showWarnings = FALSE)
d <- read.csv('data/wdbc.csv', check.names = FALSE)
stopifnot(nrow(d) == 569, ncol(d) == 31,
          all(d$diagnosis %in% c('B', 'M')),
          all(vapply(d[-1], is.numeric, logical(1))),
          all(is.finite(as.matrix(d[-1]))))

# Identical rows would be investigated, not silently removed.
stopifnot(!anyDuplicated(d))
d$diagnosis <- factor(d$diagnosis, levels = c('B', 'M'),
                      labels = c('Benign', 'Malignant'))
d$malignant <- as.integer(d$diagnosis == 'Malignant')
write.csv(data.frame(check = c('rows', 'missing_values', 'duplicate_rows'),
                     value = c(nrow(d), sum(is.na(d)), sum(duplicated(d)))),
          'results/quality_control.csv', row.names = FALSE)

# Stratified split before modelling: the test set stays outside model fitting.
train_id <- unlist(lapply(split(seq_len(nrow(d)), d$diagnosis),
                         function(i) sample(i, floor(0.8 * length(i)))))
train <- d[train_id, ]; test <- d[-train_id, ]
write.csv(data.frame(row = seq_len(nrow(d)),
                     partition = ifelse(seq_len(nrow(d)) %in% train_id, 'train', 'test')),
          'results/split.csv', row.names = FALSE)
features <- c('mean_radius', 'mean_texture')
summary_table <- do.call(rbind, lapply(levels(train$diagnosis), function(g) {
 s <- train[train$diagnosis == g, ]
 data.frame(diagnosis = g, n = nrow(s), radius_mean = mean(s$mean_radius),
            radius_sd = sd(s$mean_radius), texture_mean = mean(s$mean_texture),
            texture_sd = sd(s$mean_texture))
}))
write.csv(summary_table, 'results/training_summary.csv', row.names = FALSE)

# Exploratory figures use training data only.
png('figures/01_training_distributions.png', width = 1400, height = 650, res = 140)
par(mfrow = c(1, 2), mar = c(5, 5, 3, 1))
for (v in features) boxplot(train[[v]] ~ train$diagnosis, col = c('#55B9B0', '#E99A72'),
 xlab = 'Diagnosis', ylab = gsub('_', ' ', v), main = gsub('_', ' ', v))
dev.off()
png('figures/02_training_scatter.png', width = 1000, height = 750, res = 130)
plot(train$mean_radius, train$mean_texture, pch = 19,
 col = ifelse(train$malignant == 1, '#C85E3CAA', '#218A85AA'),
 xlab = 'Mean nucleus radius (dataset units)', ylab = 'Mean texture',
 main = 'Training samples: nucleus size and texture')
legend('topleft', levels(d$diagnosis), col = c('#218A85', '#C85E3C'), pch = 19)
dev.off()

# Two descriptive comparisons, with Holm correction for two tests.
tests <- do.call(rbind, lapply(features, function(v) {
 z <- t.test(train[[v]] ~ train$diagnosis)
 data.frame(feature = v, benign_minus_malignant = unname(diff(rev(z$estimate))),
            ci_lower = z$conf.int[1], ci_upper = z$conf.int[2], p_value = z$p.value)
}))
tests$p_holm <- p.adjust(tests$p_value, method = 'holm')
write.csv(tests, 'results/welch_tests.csv', row.names = FALSE)

# Predetermined predictors, no feature selection on held-out samples.
model <- glm(malignant ~ mean_radius + mean_texture, data = train, family = binomial())
saveRDS(model, 'results/model.rds')
write.csv(coef(summary(model)), 'results/model_coefficients.csv')
prob <- predict(model, newdata = test, type = 'response')
pred <- as.integer(prob >= 0.5)
truth <- test$malignant
TP <- sum(pred == 1 & truth == 1); TN <- sum(pred == 0 & truth == 0)
FP <- sum(pred == 1 & truth == 0); FN <- sum(pred == 0 & truth == 1)

# AUC as the probability that a malignant sample ranks above a benign one.
n1 <- sum(truth == 1); n0 <- sum(truth == 0)
auc <- (sum(rank(prob)[truth == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
acc_ci <- binom.test(TP + TN, length(truth))$conf.int
metrics <- data.frame(metric = c('test_n', 'accuracy', 'accuracy_ci_lower',
 'accuracy_ci_upper', 'sensitivity', 'specificity', 'auc', 'majority_baseline_accuracy'),
 value = c(length(truth), mean(pred == truth), acc_ci, TP/(TP+FN), TN/(TN+FP),
 auc, mean(truth == as.integer(mean(train$malignant) >= 0.5))))
write.csv(metrics, 'results/test_metrics.csv', row.names = FALSE)
cm <- table(Actual = factor(truth, levels = 0:1, labels = levels(d$diagnosis)),
 Predicted = factor(pred, levels = 0:1, labels = levels(d$diagnosis)))
write.csv(as.data.frame(cm), 'results/confusion_matrix.csv', row.names = FALSE)

# Original sample identifiers are absent from this redistributed copy.
write.csv(data.frame(source_row = which(!seq_len(nrow(d)) %in% train_id),
 actual = test$diagnosis, malignant_probability = prob,
 predicted = ifelse(pred == 1, 'Malignant', 'Benign')),
 'results/test_predictions.csv', row.names = FALSE)
thresholds <- c(Inf, sort(unique(prob), decreasing = TRUE), -Inf)
tpr <- vapply(thresholds, function(t) mean(prob[truth == 1] >= t), numeric(1))
fpr <- vapply(thresholds, function(t) mean(prob[truth == 0] >= t), numeric(1))
png('figures/03_test_roc.png', width = 850, height = 800, res = 130)
plot(fpr, tpr, type = 's', col = '#218A85', lwd = 3,
 xlab = 'False positive rate (1 - specificity)', ylab = 'True positive rate (sensitivity)',
 main = sprintf('Held-out test ROC; AUC = %.3f', auc), xlim = c(0,1), ylim = c(0,1))
abline(0, 1, lty = 2, col = 'grey60'); dev.off()
capture.output(sessionInfo(), file = 'results/session_info.txt')

# Populate the written report with actual R results only.
report <- paste(readLines('REPORT_TEMPLATE.md', warn = FALSE), collapse = '\n')
values <- c(TRAIN_N = nrow(train), TEST_N = nrow(test), BENIGN_N = sum(d$malignant == 0),
 MALIGNANT_N = sum(d$malignant == 1), ACC = sprintf('%.1f%%', 100*mean(pred == truth)),
 SENS = sprintf('%.1f%%', 100*TP/(TP+FN)), SPEC = sprintf('%.1f%%', 100*TN/(TN+FP)),
 AUC = sprintf('%.3f', auc), TP = TP, TN = TN, FP = FP, FN = FN,
 CI = sprintf('%.1f%% to %.1f%%', 100*acc_ci[1], 100*acc_ci[2]),
 BASE = sprintf('%.1f%%', 100*tail(metrics$value, 1)))

#Embed actual statistical tables in the root report.
markdown_table <- function(x) {
  x[] <- lapply(x, function(v) if (is.numeric(v)) format(signif(v, 4), trim = TRUE) else as.character(v))
  rows <- apply(x, 1, function(v) paste0('| ', paste(v, collapse = ' | '), ' |'))
  paste(c(paste0('| ', paste(names(x), collapse = ' | '), ' |'),
          paste0('| ', paste(rep('---', ncol(x)), collapse = ' | '), ' |'), rows), collapse = '\n')
}
values <- c(values, SUMMARY_TABLE = markdown_table(summary_table), TEST_TABLE = markdown_table(tests))
for (nm in names(values)) report <- gsub(paste0('{{', nm, '}}'), values[[nm]], report, fixed = TRUE)
writeLines(report, 'README.md')

# Standalone HTML report without extra package installation.
lines <- strsplit(report, '\n', fixed = TRUE)[[1]]
escape <- function(x) { x <- gsub('&', '&amp;', x, fixed=TRUE); x <- gsub('<','&lt;',x,fixed=TRUE); gsub('>','&gt;',x,fixed=TRUE) }
html <- vapply(lines, function(s) {
 if (grepl('^!\\[', s)) {
  src <- sub('.*\\((.*)\\).*', '\\1', s)
  return(paste0('<img style="max-width:100%" src="', src, '" alt="Analysis figure">'))
 }
 if (grepl('^# ', s)) return(paste0('<h1>', escape(sub('^# ', '', s)), '</h1>'))
 if (grepl('^## ', s)) return(paste0('<h2>', escape(sub('^## ', '', s)), '</h2>'))
 paste0('<p>', escape(s), '</p>')
}, character(1))
writeLines(c('<!doctype html><html lang="en"><meta charset="utf-8"><title>Breast cancer R project</title><style>body{font:17px/1.65 system-ui;max-width:960px;margin:40px auto;padding:20px;color:#18333c}h1,h2{color:#147b77}p{white-space:pre-wrap}</style><body>', html, '</body></html>'), 'report.html')
cat('Completed: README.md, report.html, figures/ and results/\n')
print(metrics)

source("code/analysis.R")
source("analysis.R")
