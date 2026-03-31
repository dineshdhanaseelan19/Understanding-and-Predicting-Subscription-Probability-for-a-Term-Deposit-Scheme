# =========================
# 04_evaluation.R
# =========================

library(caret)
library(pROC)
library(car)

# -------------------------
# 0. Checks
# -------------------------
if (!exists("train_data")) stop("train_data not found. Run 03_modeling.R first.")
if (!exists("test_data")) stop("test_data not found. Run 03_modeling.R first.")
if (!exists("model_baseline_obj")) stop("model_baseline_obj not found.")
if (!exists("model_full_obj")) stop("model_full_obj not found.")
if (!exists("model_step_obj")) stop("model_step_obj not found.")
if (!exists("best_threshold")) stop("best_threshold not found.")
if (!exists("roc_object_step")) stop("roc_object_step not found.")

train <- train_data
test <- test_data

model_baseline <- model_baseline_obj
model_full <- model_full_obj
model_step <- model_step_obj

# -------------------------
# 1. Confusion matrices
# -------------------------
cm_baseline <- confusionMatrix(test$pred_baseline_050, test$subscribed, positive = "yes")
cm_full <- confusionMatrix(test$pred_full_050, test$subscribed, positive = "yes")
cm_step_050 <- confusionMatrix(test$pred_step_050, test$subscribed, positive = "yes")
cm_step_best <- confusionMatrix(test$pred_step_best, test$subscribed, positive = "yes")

print(cm_baseline)
print(cm_full)
print(cm_step_050)
print(cm_step_best)

capture.output(cm_baseline, file = "outputs/confusion_matrix_baseline.txt")
capture.output(cm_full, file = "outputs/confusion_matrix_full.txt")
capture.output(cm_step_050, file = "outputs/confusion_matrix_step_050.txt")
capture.output(cm_step_best, file = "outputs/confusion_matrix_step_best.txt")

# -------------------------
# 2. Function to calculate precision / recall / F1
# -------------------------
get_class_metrics <- function(cm_obj, model_name) {
  data.frame(
    Model = model_name,
    Accuracy = as.numeric(cm_obj$overall["Accuracy"]),
    Kappa = as.numeric(cm_obj$overall["Kappa"]),
    Sensitivity = as.numeric(cm_obj$byClass["Sensitivity"]),
    Specificity = as.numeric(cm_obj$byClass["Specificity"]),
    Precision = as.numeric(cm_obj$byClass["Pos Pred Value"]),
    Recall = as.numeric(cm_obj$byClass["Sensitivity"]),
    F1 = as.numeric(cm_obj$byClass["F1"]),
    Balanced_Accuracy = as.numeric(cm_obj$byClass["Balanced Accuracy"])
  )
}

metrics_baseline <- get_class_metrics(cm_baseline, "Baseline_0.50")
metrics_full <- get_class_metrics(cm_full, "Full_0.50")
metrics_step_050 <- get_class_metrics(cm_step_050, "Stepwise_0.50")
metrics_step_best <- get_class_metrics(cm_step_best, "Stepwise_Best_Threshold")

metrics_table <- rbind(
  metrics_baseline,
  metrics_full,
  metrics_step_050,
  metrics_step_best
)

print(metrics_table)
write.csv(metrics_table, "outputs/evaluation_metrics.csv", row.names = FALSE)

# -------------------------
# 3. ROC and AUC
# -------------------------
roc_baseline <- roc(test$subscribed, test$prob_baseline, levels = c("no", "yes"), direction = "<")
roc_full <- roc(test$subscribed, test$prob_full, levels = c("no", "yes"), direction = "<")
roc_step <- roc(test$subscribed, test$prob_step, levels = c("no", "yes"), direction = "<")

auc_table <- data.frame(
  Model = c("Baseline", "Full", "Stepwise"),
  AUC = c(
    as.numeric(auc(roc_baseline)),
    as.numeric(auc(roc_full)),
    as.numeric(auc(roc_step))
  )
)

print(auc_table)
write.csv(auc_table, "outputs/auc_table.csv", row.names = FALSE)

png("outputs/roc_curve.png", width = 900, height = 700)
plot(roc_baseline, main = "ROC Curves for Logistic Models")
plot(roc_full, add = TRUE)
plot(roc_step, add = TRUE)
legend(
  "bottomright",
  legend = c(
    paste("Baseline AUC =", round(auc(roc_baseline), 3)),
    paste("Full AUC =", round(auc(roc_full), 3)),
    paste("Stepwise AUC =", round(auc(roc_step), 3))
  ),
  col = c("black", "red", "green"),
  lwd = 2
)
dev.off()

# -------------------------
# 4. Overfitting check
# Compare train vs test AUC
# -------------------------
train$prob_step <- predict(model_step, newdata = train, type = "response")
test$prob_step <- predict(model_step, newdata = test, type = "response")

roc_step_train <- roc(train$subscribed, train$prob_step, levels = c("no", "yes"), direction = "<")
roc_step_test <- roc(test$subscribed, test$prob_step, levels = c("no", "yes"), direction = "<")

overfitting_table <- data.frame(
  Dataset = c("Train", "Test"),
  AUC = c(as.numeric(auc(roc_step_train)), as.numeric(auc(roc_step_test)))
)

print(overfitting_table)
write.csv(overfitting_table, "outputs/overfitting_check_auc.csv", row.names = FALSE)

# -------------------------
# 5. Calibration-style check by deciles
# -------------------------
test$decile <- ntile(test$prob_step, 10)

calibration_table <- aggregate(
  cbind(actual_yes = as.numeric(test$subscribed == "yes"), predicted_prob = test$prob_step),
  by = list(decile = test$decile),
  FUN = mean
)

print(calibration_table)
write.csv(calibration_table, "outputs/calibration_table.csv", row.names = FALSE)

# -------------------------
# 6. Pseudo R-squared
# -------------------------
pseudo_r2 <- function(model) {
  ll_null <- logLik(update(model, . ~ 1))
  ll_model <- logLik(model)
  n <- length(model$fitted.values)
  
  mcfadden <- 1 - (as.numeric(ll_model) / as.numeric(ll_null))
  cox_snell <- 1 - exp((2 / n) * (as.numeric(ll_null) - as.numeric(ll_model)))
  nagelkerke <- cox_snell / (1 - exp((2 / n) * as.numeric(ll_null)))
  
  data.frame(
    McFadden = mcfadden,
    Cox_Snell = cox_snell,
    Nagelkerke = nagelkerke
  )
}

pseudo_baseline <- pseudo_r2(model_baseline)
pseudo_full <- pseudo_r2(model_full)
pseudo_step <- pseudo_r2(model_step)

pseudo_table <- rbind(
  cbind(Model = "Baseline", pseudo_baseline),
  cbind(Model = "Full", pseudo_full),
  cbind(Model = "Stepwise", pseudo_step)
)

print(pseudo_table)
write.csv(pseudo_table, "outputs/pseudo_r2_table.csv", row.names = FALSE)

# -------------------------
# 7. Residual diagnostics
# -------------------------
train$std_resid <- rstandard(model_step)
train$stud_resid <- rstudent(model_step)
train$cooks_d <- cooks.distance(model_step)
train$leverage <- hatvalues(model_step)

residual_summary <- data.frame(
  Metric = c(
    "Std residuals > |1.96|",
    "Studentized residuals > |1.96|",
    "Cooks distance > 1",
    "Leverage > 2*(p+1)/n"
  ),
  Count = c(
    sum(abs(train$std_resid) > 1.96),
    sum(abs(train$stud_resid) > 1.96),
    sum(train$cooks_d > 1),
    sum(train$leverage > (2 * (length(coef(model_step)) + 1) / nrow(train)))
  )
)

print(residual_summary)
write.csv(residual_summary, "outputs/residual_summary.csv", row.names = FALSE)

# -------------------------
# 8. Multicollinearity
# -------------------------
vif_values <- car::vif(model_step)
print(vif_values)

capture.output(vif_values, file = "outputs/vif_values.txt")

# -------------------------
# 9. Save final threshold
# -------------------------
threshold_table <- data.frame(
  Best_Threshold = best_threshold
)

write.csv(threshold_table, "outputs/best_threshold.csv", row.names = FALSE)

# -------------------------
# 10. Save train/test probability summaries
# -------------------------
probability_summary <- data.frame(
  Dataset = c("Train", "Test"),
  Mean_Probability = c(mean(train$prob_step), mean(test$prob_step)),
  Min_Probability = c(min(train$prob_step), min(test$prob_step)),
  Max_Probability = c(max(train$prob_step), max(test$prob_step))
)

print(probability_summary)
write.csv(probability_summary, "outputs/probability_summary.csv", row.names = FALSE)