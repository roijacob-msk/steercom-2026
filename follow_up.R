library(dplyr)

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

# 1. Seasonal Increase Campaign Dates

# 2. How many users received the Seasonan Credit Line Increase
nrow(xmas_seasonal_customers_2024)
nrow(sherlock_xmas_customers)

# 3. Total Capital Line before the Increase
sum(xmas_seasonal_customers_2024$original_credit_limit)
sum(sherlock_xmas_customers$max_credit)

# 4. Additional Credit Line Deployed

# 5. Total Capital Line after the increase
sum(xmas_seasonal_customers_2024$credit_limit)
sum(sherlock_xmas_customers$new_capital)

# 6. Percentage Increase from Previous Credit Line

# 7. Total users who used the Seasonal Credit Line
plt_xmas_seasonal_2024 |>
  pull(customer_id) |>
  n_distinct()

plt_xmas_seasonal_2025 |>
  pull(customer_id) |>
  n_distinct()

# 8. Utilization Rate of the Seasonal Credit Line given to the users
sum(plt_xmas_seasonal_2024$amount)
sum(plt_xmas_seasonal_2025$amount)
