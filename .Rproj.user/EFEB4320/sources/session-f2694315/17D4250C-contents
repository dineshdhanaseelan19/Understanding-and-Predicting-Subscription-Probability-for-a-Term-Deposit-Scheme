# =========================
# 03_modeling.R
# =========================

library(caret)
library(pROC)
library(MASS)

# -------------------------
# 0. Use cleaned data
# -------------------------
if (!exists("clean_data")) {
  stop("clean_data not found. Run scripts/01_data_cleaning.R first.")
}

data <- clean_data

# Ensure target is factor
data$subscribed <- factor(data$subscribed, levels = c("no", "yes"))

# -------------------------
# 1. Train / test split
# -------------------------
set.seed(40457694)

train_index <- createDataPartition(data$subscribed, p = 0.80, list = FALSE)
train <- data[train_index, , drop = FALSE]
test  <- data[-train_index, , drop = FALSE]

train$subscribed <- factor(train$subscribed, levels = c("no", "yes"))
test$subscribed  <- factor(test$subscribed, levels = c("no", "yes"))

train <- droplevels(train)
test  <- droplevels(test)

# -------------------------
# 2. Remove predictors with only one unique value in training data
# -------------------------
one_level_cols <- names(train)[sapply(train, function(x) length(unique(x)) < 2)]

cat("Columns with only one unique value in training data:\n")
print(one_level_cols)

# Never remove target
one_level_cols <- setdiff(one_level_cols, "subscribed")

if (length(one_level_cols) > 0) {
  keep_cols <- setdiff(names(train), one_level_cols)
  train <- train[, keep_cols, drop = FALSE]
  test  <- test[, intersect(names(test), keep_cols), drop = FALSE]
}

train <- droplevels(train)
test  <- droplevels(test)

# -------------------------
# 3. Baseline logistic model
# -------------------------
baseline_vars <- c("age", "salary", "gender", "mortgage", "personal_loan")
baseline_vars <- baseline_vars[baseline_vars %in% names(train)]

if (length(baseline_vars) == 0) {
  stop("No baseline predictors found in training data.")
}

baseline_formula <- as.formula(
  paste("subscribed ~", paste(baseline_vars, collapse = " + "))
)

model_baseline <- glm(
  formula = baseline_formula,
  data = train,
  family = binomial
)

cat("\n================ BASELINE MODEL ================\n")
print(summary(model_baseline))

# -------------------------
# 4. Full logistic model
# -------------------------
excluded_cols <- c(
  "subscribed",
  "ID",
  "prob_baseline", "prob_full", "prob_step",
  "pred_baseline_050", "pred_full_050", "pred_step_050", "pred_step_best"
)

full_predictors <- setdiff(names(train), excluded_cols)

if (length(full_predictors) == 0) {
  stop("No predictors available for full model.")
}

full_formula <- as.formula(
  paste("subscribed ~", paste(full_predictors, collapse = " + "))
)

model_full <- glm(
  formula = full_formula,
  data = train,
  family = binomial
)

cat("\n================ FULL MODEL ================\n")
print(summary(model_full))

# -------------------------
# 5. Stepwise logistic model
# -------------------------
model_step <- stepAIC(model_full, direction = "both", trace = FALSE)

cat("\n================ STEPWISE MODEL ================\n")
print(summary(model_step))

# -------------------------
# 6. Predicted probabilities
# -------------------------
test$prob_baseline <- predict(model_baseline, newdata = test, type = "response")
test$prob_full     <- predict(model_full, newdata = test, type = "response")
test$prob_step     <- predict(model_step, newdata = test, type = "response")

# -------------------------
# 7. Predictions at 0.50 threshold
# -------------------------
test$pred_baseline_050 <- factor(
  ifelse(test$prob_baseline >= 0.50, "yes", "no"),
  levels = c("no", "yes")
)

test$pred_full_050 <- factor(
  ifelse(test$prob_full >= 0.50, "yes", "no"),
  levels = c("no", "yes")
)

test$pred_step_050 <- factor(
  ifelse(test$prob_step >= 0.50, "yes", "no"),
  levels = c("no", "yes")
)

# -------------------------
# 8. Tune threshold using ROC for stepwise model
# -------------------------
roc_step <- roc(
  response = test$subscribed,
  predictor = test$prob_step,
  levels = c("no", "yes"),
  direction = "<"
)

best_thresh <- coords(
  roc_step,
  x = "best",
  best.method = "youden",
  ret = "threshold"
)

best_thresh <- as.numeric(best_thresh)

cat("\nBest threshold from ROC (Youden Index):", best_thresh, "\n")

test$pred_step_best <- factor(
  ifelse(test$prob_step >= best_thresh, "yes", "no"),
  levels = c("no", "yes")
)

# -------------------------
# 9. Model comparison table
# -------------------------
model_comparison <- data.frame(
  Model = c("Baseline", "Full", "Stepwise"),
  AIC = c(AIC(model_baseline), AIC(model_full), AIC(model_step)),
  Null_Deviance = c(
    model_baseline$null.deviance,
    model_full$null.deviance,
    model_step$null.deviance
  ),
  Residual_Deviance = c(
    model_baseline$deviance,
    model_full$deviance,
    model_step$deviance
  )
)

cat("\n================ MODEL COMPARISON ================\n")
print(model_comparison)

write.csv(model_comparison, "outputs/model_comparison.csv", row.names = FALSE)

# -------------------------
# 10. Save coefficients
# -------------------------
baseline_coef <- as.data.frame(summary(model_baseline)$coefficients)
baseline_coef$term <- rownames(baseline_coef)
rownames(baseline_coef) <- NULL

full_coef <- as.data.frame(summary(model_full)$coefficients)
full_coef$term <- rownames(full_coef)
rownames(full_coef) <- NULL

step_coef <- as.data.frame(summary(model_step)$coefficients)
step_coef$term <- rownames(step_coef)
rownames(step_coef) <- NULL

write.csv(baseline_coef, "outputs/baseline_model_coefficients.csv", row.names = FALSE)
write.csv(full_coef, "outputs/full_model_coefficients.csv", row.names = FALSE)
write.csv(step_coef, "outputs/stepwise_model_coefficients.csv", row.names = FALSE)

# -------------------------
# 11. Odds ratios for stepwise model
# -------------------------
step_odds_ratios <- exp(coef(model_step))
step_or_ci <- exp(confint(model_step))

odds_ratio_table <- data.frame(
  term = names(step_odds_ratios),
  odds_ratio = as.numeric(step_odds_ratios),
  ci_lower = step_or_ci[, 1],
  ci_upper = step_or_ci[, 2]
)

cat("\n================ STEPWISE ODDS RATIOS ================\n")
print(odds_ratio_table)

write.csv(odds_ratio_table, "outputs/stepwise_odds_ratios.csv", row.names = FALSE)

# -------------------------
# 12. Save scored test data
# -------------------------
write.csv(test, "outputs/test_scored_data.csv", row.names = FALSE)

# -------------------------
# 13. Store objects for evaluation script
# -------------------------
train_data <- train
test_data <- test
roc_object_step <- roc_step
best_threshold <- best_thresh
model_baseline_obj <- model_baseline
model_full_obj <- model_full
model_step_obj <- model_step

# -------------------------
# 14. Quick performance preview
# -------------------------
cm_baseline <- confusionMatrix(test$pred_baseline_050, test$subscribed, positive = "yes")
cm_full     <- confusionMatrix(test$pred_full_050, test$subscribed, positive = "yes")
cm_step_050 <- confusionMatrix(test$pred_step_050, test$subscribed, positive = "yes")
cm_step_best <- confusionMatrix(test$pred_step_best, test$subscribed, positive = "yes")

cat("\n================ QUICK METRICS ================\n")
cat("\nBaseline model accuracy:", as.numeric(cm_baseline$overall["Accuracy"]), "\n")
cat("Full model accuracy:", as.numeric(cm_full$overall["Accuracy"]), "\n")
cat("Stepwise model accuracy at 0.50:", as.numeric(cm_step_050$overall["Accuracy"]), "\n")
cat("Stepwise model accuracy at best threshold:", as.numeric(cm_step_best$overall["Accuracy"]), "\n")
cat("Stepwise ROC-AUC:", as.numeric(auc(roc_step)), "\n")