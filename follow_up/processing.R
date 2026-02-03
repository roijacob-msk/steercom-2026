library(dplyr)
library(tibble)

source("data_extraction/pay_later_transactions.R")
source("xmas_seasonal_2024/customers.R")

# Pay later transactions ----
plt_xmas_seasonal_2024 <- pay_later_txns |>
  filter(
    customer_id %in% xmas_seasonal_customers_2024$customer_id,
    between(
      activated_at,
      as.POSIXct("2024-11-19 16:01:00"),
      as.POSIXct("2025-01-15 15:59:00")
    )
  )

plt_xmas_seasonal_2025 <- pay_later_txns |>
  filter(
    customer_id %in% sherlock_xmas_customers$customer_id,
    between(
      activated_at,
      as.POSIXct("2025-11-01 08:00:00"),
      as.POSIXct("2026-01-16 08:00:00")
    )
  )

# Processing ----
total_customers_2024 <- nrow(xmas_seasonal_customers_2024)
total_customers_2025 <- nrow(sherlock_xmas_customers)

active_customers_2024 <- plt_xmas_seasonal_2024 |>
  pull(customer_id) |>
  n_distinct()

active_customers_2025 <- plt_xmas_seasonal_2025 |>
  pull(customer_id) |>
  n_distinct()

xmas_seasonal_metrics <- bind_rows(
  tibble(
    metrics = "total_customers",
    year_twenty_four = total_customers_2024,
    year_twenty_five = total_customers_2025
  ),
  tibble(
    metrics = "old_capital",
    year_twenty_four = sum(xmas_seasonal_customers_2024$original_credit_limit),
    year_twenty_five = sum(sherlock_xmas_customers$max_credit)
  ),
  tibble(
    metrics = "new_capital",
    year_twenty_four = sum(xmas_seasonal_customers_2024$credit_limit),
    year_twenty_five = sum(sherlock_xmas_customers$new_capital)
  ),
  tibble(
    metrics = "capital_deployed",
    year_twenty_four = sum(xmas_seasonal_customers_2024$credit_limit) -
      sum(xmas_seasonal_customers_2024$original_credit_limit),
    year_twenty_five = sum(sherlock_xmas_customers$new_capital) -
      sum(sherlock_xmas_customers$max_credit)
  ),
  tibble(
    metrics = "active_customers",
    year_twenty_four = active_customers_2024,
    year_twenty_five = active_customers_2025
  ),
  tibble(
    metrics = "active_customers_pct",
    year_twenty_four = (active_customers_2024 / total_customers_2024) * 100,
    year_twenty_five = (active_customers_2025 / total_customers_2025) * 100
  ),
  tibble(
    metrics = "active_customers_gmv",
    year_twenty_four = sum(plt_xmas_seasonal_2024$amount),
    year_twenty_five = sum(plt_xmas_seasonal_2025$amount)
  ),
  tibble(
    metrics = "median_gmv",
    year_twenty_four = median(plt_xmas_seasonal_2024$amount),
    year_twenty_five = median(plt_xmas_seasonal_2025$amount)
  ),
  tibble(
    metrics = "avg_gmv",
    year_twenty_four = mean(plt_xmas_seasonal_2024$amount),
    year_twenty_five = mean(plt_xmas_seasonal_2025$amount)
  ),
)

metrics_per_segment <- sherlock_xmas_customers |>
  summarize(
    customers = n_distinct(customer_id),
    old_capital = sum(max_credit),
    new_capital = sum(new_capital),
    .by = sherlock_segment
  ) |>
  mutate(
    dispersed_capital = new_capital - old_capital,
    pct_capital_increase = (new_capital / old_capital) - 1,
  )
