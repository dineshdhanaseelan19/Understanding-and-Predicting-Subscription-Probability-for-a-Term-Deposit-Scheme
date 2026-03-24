# Understanding-and-Predicting-Subscription-Probability-for-a-Term-Deposit-Scheme
This project focuses on understanding and predicting customer subscription behaviour for a term deposit scheme using logistic regression. The objective is to identify key factors that influence whether a customer subscribes to a financial product and to build a predictive model that supports data-driven marketing decisions.

#Objectives
Predict the likelihood of customer subscription (Yes/No)
Identify significant factors influencing subscription decisions
Evaluate model performance and interpret results
Provide business recommendations based on insights

#Dataset
Dataset contains 40,000+ observations with 15 variables
Includes:
Demographic data (age, gender, marital status)
Financial attributes (salary, loans, mortgage)
Campaign-related features
Target variable: subscribed (binary: yes/no)

#Data Preprocessing

Key steps performed:

Handling missing values using mode imputation
Removing invalid entries (e.g., age = 999)
Replacing "unknown" values with most frequent categories
Standardizing categorical variables (case, format consistency)
Grouping similar categories to reduce sparsity
Converting categorical variables into factors
Encoding target variable into binary numeric format

#Exploratory Data Analysis
Distribution analysis of key variables
Visualizations for:
Age vs Subscription
Salary vs Subscription
Mortgage & Loan impact
Gender differences
Hypothesis-driven exploration (e.g., income and age impact on subscription)

#Model Development
🔹 Model 1 (Baseline)
Features: Age, Salary, Mortgage
Observations:
Age positively influences subscription
Low salary significantly reduces likelihood
Mortgage shows minimal impact
🔹 Model 2 (Improved Model)
Added features: Gender, Personal Loan
Improvements:
Reduced residual deviance
Slight improvement in model fit
Gender emerged as a significant predictor

#Model Evaluation
Metrics used:
Accuracy
Confusion Matrix
Pseudo R² (Hosmer-Lemeshow, Cox & Snell, Nagelkerke)

#Key Insight:

Model shows limited predictive power (~30% accuracy)
Indicates potential underfitting and need for more features

#Business Recommendations
Target high-income and older customers
Design campaigns focused on financially stable segments
Improve model by:
Adding behavioural or interaction data
Using advanced models (e.g., Random Forest, XGBoost)

#Tools & Technologies
R Programming
Libraries:
tidyverse
caret
ggplot2
car
summarytools

#Project Structure
├── data/
├── scripts/
├── outputs/
├── README.md
└── analysis.R

#Future Improvements
Handle class imbalance more effectively
Try advanced ML models
Feature engineering for better predictive power
Hyperparameter tuning

Author
Dinesh Dhanseelan
MSc Business Analytics | Data Analytics Enthusiast

