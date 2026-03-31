# Load libraries
library(readxl)
library(dplyr)
library(stringr)
library(forcats)

# -------------------------
# 1. Read raw data
# -------------------------
data_raw <- read_excel("data/termsv.xlsx")

# Make a working copy
data <- data_raw

# -------------------------
# 2. Initial inspection
# -------------------------
str(data)
summary(data)
colSums(is.na(data))

# Save missing value summary
missing_summary <- data.frame(
  column = names(data),
  missing_count = colSums(is.na(data)),
  missing_pct = round(colSums(is.na(data)) / nrow(data) * 100, 2)
)

write.csv(missing_summary, "outputs/missing_values_summary.csv", row.names = FALSE)

# 3. Standardize text values
# -------------------------
# Convert character columns to lowercase and trim spaces
data <- data %>%
  mutate(across(where(is.character), ~ str_trim(str_to_lower(.))))

# 4. Fix invalid values
# -------------------------
# Remove invalid age values (999)
data <- data %>%
  filter(age != 999)

#keep only sensible ages if needed
data <- data %>%
  filter(age >= 17, age <= 95)

data <- data %>%
  mutate(across(where(is.character), ~ na_if(., "unknown")))

# 6. Helper function for mode
# -------------------------
get_mode <- function(x) {
  x <- x[!is.na(x)]
  names(sort(table(x), decreasing = TRUE))[1]
}

# 7. Impute missing categorical values
categorical_cols <- c(
  "gender", "occupation", "salary", "marital_status",
  "education_level", "credit_default", "mortgage",
  "personal_loan", "car_insurance", "life_insurance",
  "savings_account", "current_account", "credit_card",
  "contact_method", "month", "day_of_week",
  "previous_campaign_outcome"
)

for (col in categorical_cols) {
  if (col %in% names(data)) {
    data[[col]][is.na(data[[col]])] <- get_mode(data[[col]])
  }
}

# 8. Fix known inconsistencies
# -------------------------
# gender
if ("gender" %in% names(data)) {
  data$gender[data$gender == "m"] <- "male"
  data$gender[data$gender == "f"] <- "female"
}

# day_of_week
if ("day_of_week" %in% names(data)) {
  data$day_of_week <- recode(
    data$day_of_week,
    "monday" = "mon",
    "tuesday" = "tue",
    "wednesday" = "wed",
    "thursday" = "thu",
    "friday" = "fri"
  )
}

# month
if ("month" %in% names(data)) {
  data$month <- recode(data$month, "march" = "mar")
}

# yes/no fields
yes_no_cols <- c(
  "credit_default", "mortgage", "personal_loan",
  "car_insurance", "life_insurance", "savings_account",
  "current_account", "credit_card"
)

for (col in yes_no_cols) {
  if (col %in% names(data)) {
    data[[col]] <- recode(data[[col]], "yes" = "yes", "no" = "no")
  }
}

# 9. Group sparse categories
# -------------------------
if ("education_level" %in% names(data)) {
  data$education_level <- recode(
    data$education_level,
    "high_school" = "school",
    "six_year" = "school",
    "nine_year" = "school",
    "four_year" = "school",
    "university_degree" = "university",
    "professional_course" = "course"
  )
}

if ("occupation" %in% names(data)) {
  data$occupation <- recode(
    data$occupation,
    "administrative" = "professional",
    "entrepreneur" = "professional",
    "management" = "professional",
    "self-employed" = "professional",
    "blue-collar" = "technical",
    "technician" = "technical",
    "domestic" = "services",
    "services" = "services",
    "student" = "unemployed",
    "retired" = "unemployed",
    "unemployed" = "unemployed"
  )
}

# 10. Convert to factors
# -------------------------
factor_cols <- c(
  "gender", "occupation", "salary", "marital_status",
  "education_level", "credit_default", "mortgage",
  "personal_loan", "car_insurance", "life_insurance",
  "savings_account", "current_account", "credit_card",
  "contact_method", "month", "day_of_week",
  "previous_campaign_outcome"
)

for (col in factor_cols) {
  if (col %in% names(data)) {
    data[[col]] <- as.factor(data[[col]])
  }
}

# Keep target as factor for classification
if ("subscribed" %in% names(data)) {
  data$subscribed <- factor(data$subscribed, levels = c("no", "yes"))
}

# 11. Remove unused factor levels
# -------------------------
data <- droplevels(data)

# 12. Final checks
# -------------------------
str(data)
summary(data)
colSums(is.na(data))

# Class balance
class_balance <- as.data.frame(table(data$subscribed))
colnames(class_balance) <- c("subscribed", "count")
class_balance$percentage <- round(class_balance$count / sum(class_balance$count) * 100, 2)

write.csv(class_balance, "outputs/class_balance.csv", row.names = FALSE)

# -------------------------
# 13. Save cleaned data
# -------------------------
write.csv(data, "outputs/cleaned_data.csv", row.names = FALSE)

# Optional: keep object in environment for later scripts
clean_data <- data

View(clean_data)
table(clean_data$subscribed)
summary(clean_data$age)
levels(clean_data$occupation)
levels(clean_data$education_level)
colSums(is.na(clean_data))