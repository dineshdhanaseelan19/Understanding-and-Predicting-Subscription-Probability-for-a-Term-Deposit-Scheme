---
title: "README.md"
author: "Dinesh Dhanaseelan"
date: "`r Sys.Date()`"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## R Markdown

# Understanding and Predicting Subscription Probability for a Term Deposit Scheme

## Project Overview

This project focuses on predicting whether a customer will subscribe to a term deposit scheme using **logistic regression in R**. The objective is to identify key drivers of customer behaviour and build a robust predictive model to support **data-driven marketing decisions**.

This is an enhanced version of an earlier academic assignment, with improvements in:

* data cleaning and preprocessing
* feature engineering
* model selection
* threshold tuning
* evaluation metrics
* overfitting diagnostics

---

## Business Objective

Direct marketing campaigns are widely used by financial institutions to promote term deposit products. However, contacting all customers is inefficient.

This project aims to:

* identify customers most likely to subscribe
* improve targeting efficiency
* reduce marketing costs
* support decision-making using predictive analytics

---

## Dataset Overview

The dataset contains customer demographic, financial, and campaign-related information.

### Key Features

* Demographics: age, gender, occupation
* Financial: salary, mortgage, loans
* Banking relationship: savings account, current account, insurance products
* Campaign details: contact method, duration, timing
* History: previous campaign outcome
* Macroeconomic indicators

### Target Variable

* **subscribed** (`yes` / `no`)

### Class Imbalance

* Majority class: **no**
* Minority class: **yes**

This imbalance makes metrics like **recall, F1-score, balanced accuracy, and ROC-AUC** more meaningful than accuracy alone.

---

## Project Structure

```
├── data/
├── outputs/
├── scripts/
│   ├── 01_data_cleaning.R
│   ├── 02_eda.R
│   ├── 03_modeling.R
│   └── 04_evaluation.R
├── analysis.R
├── README.md
└── .Rproj
```

---

## Workflow

### 1. Data Cleaning

* handled missing and inconsistent values
* removed invalid entries (e.g., age = 999)
* standardized categorical variables
* grouped sparse categories
* converted variables into factors

---

### 2. Exploratory Data Analysis (EDA)

* analysed class imbalance
* explored relationships between variables and subscription
* visualised key distributions
* examined correlations

---

### 3. Modeling Approach

Three logistic regression models were built:

#### Baseline Model

* limited predictors (age, salary, gender, etc.)
* simple and interpretable
* weak predictive power

#### Full Model

* includes a wide range of predictors
* significantly improved model fit

#### Stepwise Model (Final Model)

* selected using AIC
* balances performance and interpretability

---

## Model Performance

### Model Comparison

| Model    |   AIC | Residual Deviance |
| -------- | ----: | ----------------: |
| Baseline | 21933 |             21919 |
| Full     | 11723 |             11633 |
| Stepwise | 11716 |             11636 |

---

### Test Set Metrics

| Model                     | Accuracy | Recall | Precision |    F1 | Balanced Accuracy |
| ------------------------- | -------: | -----: | --------: | ----: | ----------------: |
| Baseline (0.50)           |    0.887 |  0.000 |         — |     — |             0.500 |
| Full (0.50)               |    0.926 |  0.558 |     0.725 | 0.631 |             0.766 |
| Stepwise (0.50)           |    0.925 |  0.555 |     0.721 | 0.627 |             0.764 |
| Stepwise (Best Threshold) |    0.861 |  0.927 |     0.445 | 0.602 |             0.890 |

---

### ROC-AUC

| Model    |   AUC |
| -------- | ----: |
| Baseline | 0.660 |
| Full     | 0.950 |
| Stepwise | 0.950 |

---

## Key Insights

* Customer relationship variables (accounts, insurance) are strong predictors
* Previous campaign success significantly increases subscription likelihood
* Campaign timing and duration strongly influence outcomes
* Lower salary groups are less likely to subscribe
* Threshold selection significantly impacts model performance

---

## Threshold Strategy

Two strategies were evaluated:

* **0.50 Threshold**

  * higher accuracy and precision
  * lower recall

* **Optimized Threshold (~0.096)**

  * much higher recall (captures more subscribers)
  * lower precision

👉 Business interpretation:

* use lower threshold when missing a potential customer is costly
* use default threshold when minimizing false positives is important

---

## Overfitting Check

| Dataset |   AUC |
| ------- | ----: |
| Train   | 0.950 |
| Test    | 0.950 |

The nearly identical AUC values indicate:

* strong generalization
* minimal overfitting

---

## Model Diagnostics

### Residual Analysis

* no extreme influential observations (Cook’s distance < 1)
* manageable residual distribution

### Multicollinearity

High correlation observed among macroeconomic variables:

* emp_var_rate
* euribor_3m
* n_employed

👉 These variables should be interpreted cautiously

---

## Important Modeling Consideration

`contact_duration` is one of the strongest predictors.

However:

* it may only be known **after customer interaction**
* not suitable for pre-campaign targeting

👉 This highlights the difference between:

* predictive performance
* real-world deployment

---

## Tools & Technologies

* R
* dplyr
* ggplot2
* caret
* pROC
* MASS
* car

---

## How to Run

Run the full pipeline:

```r
source("analysis.R")
```

Or step-by-step:

```r
source("scripts/01_data_cleaning.R")
source("scripts/02_eda.R")
source("scripts/03_modeling.R")
source("scripts/04_evaluation.R")
```

---

## Conclusion

The improved modeling approach significantly outperforms the earlier version by incorporating richer features and proper evaluation techniques. The final stepwise model demonstrates strong predictive power with excellent ROC-AUC and stable generalization performance.

The project highlights the importance of:

* feature selection
* threshold tuning
* evaluation beyond accuracy
* balancing statistical performance with business applicability

---

## Author

**Dinesh Dhanaseelan**
MSc Business Analytics | Data Analyst | Machine Learning Enthusiast
