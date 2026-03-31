# =========================
# 02_eda.R
# =========================

library(ggplot2)
library(dplyr)

# Use cleaned data
data <- clean_data

# -------------------------
# 1. Class balance
# -------------------------
class_dist <- data %>%
  count(subscribed) %>%
  mutate(percentage = n / sum(n) * 100)

print(class_dist)

ggplot(data, aes(x = subscribed, fill = subscribed)) +
  geom_bar() +
  labs(title = "Class Distribution", y = "Count") +
  theme_minimal()

ggsave("outputs/class_distribution.png")

# -------------------------
# 2. Age vs Subscription
# -------------------------
ggplot(data, aes(x = age, fill = subscribed)) +
  geom_histogram(binwidth = 5, alpha = 0.6, position = "identity") +
  theme_minimal() +
  labs(title = "Age vs Subscription")

ggsave("outputs/age_vs_subscription.png")

# -------------------------
# 3. Salary vs Subscription
# -------------------------
ggplot(data, aes(x = salary, fill = subscribed)) +
  geom_bar(position = "fill") +
  labs(title = "Salary vs Subscription", y = "Proportion") +
  theme_minimal()

ggsave("outputs/salary_vs_subscription.png")

# -------------------------
# 4. Gender vs Subscription
# -------------------------
ggplot(data, aes(x = gender, fill = subscribed)) +
  geom_bar(position = "fill") +
  labs(title = "Gender vs Subscription", y = "Proportion") +
  theme_minimal()

ggsave("outputs/gender_vs_subscription.png")

# -------------------------
# 5. Mortgage vs Subscription
# -------------------------
ggplot(data, aes(x = mortgage, fill = subscribed)) +
  geom_bar(position = "fill") +
  labs(title = "Mortgage vs Subscription", y = "Proportion") +
  theme_minimal()

ggsave("outputs/mortgage_vs_subscription.png")

# -------------------------
# 6. Personal Loan vs Subscription
# -------------------------
ggplot(data, aes(x = personal_loan, fill = subscribed)) +
  geom_bar(position = "fill") +
  labs(title = "Personal Loan vs Subscription", y = "Proportion") +
  theme_minimal()

ggsave("outputs/personal_loan_vs_subscription.png")

# -------------------------
# 7. Contact Duration (VERY IMPORTANT FEATURE)
# -------------------------
ggplot(data, aes(x = contact_duration, fill = subscribed)) +
  geom_histogram(bins = 50, alpha = 0.6, position = "identity") +
  theme_minimal() +
  labs(title = "Contact Duration vs Subscription")

ggsave("outputs/contact_duration_vs_subscription.png")

# -------------------------
# 8. Previous Campaign Outcome
# -------------------------
ggplot(data, aes(x = previous_campaign_outcome, fill = subscribed)) +
  geom_bar(position = "fill") +
  labs(title = "Previous Campaign Outcome", y = "Proportion") +
  theme_minimal()

ggsave("outputs/previous_campaign_outcome.png")

# -------------------------
# 9. Correlation (numeric only)
# -------------------------
numeric_data <- data %>% select(where(is.numeric))

cor_matrix <- cor(numeric_data)

print(cor_matrix)

write.csv(cor_matrix, "outputs/correlation_matrix.csv")

# -------------------------
# 10. Save summary stats
# -------------------------
summary_stats <- data %>%
  select(where(is.numeric)) %>%
  summarise_all(list(
    mean = mean,
    sd = sd,
    median = median,
    min = min,
    max = max
  ))

write.csv(summary_stats, "outputs/summary_statistics.csv")