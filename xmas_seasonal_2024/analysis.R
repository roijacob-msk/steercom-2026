library(dplyr)
library(ggplot2)
library(glue)
library(scales)

# Total Transactions Comparison ----
bind_rows(
  seasonal_pay_later_txns_2024 |>
    summarize(total_txn = n_distinct(pay_later_id), .by = year_month) |>
    filter(year_month %in% c("2024-11", "2024-12")) |>
    mutate(source = "xmas_seasonal_2024"),

  pay_later_txns_sherlock |>
    filter(increase_type == "Seasonal Xmas") |>
    summarize(total_txn = n_distinct(pay_later_id), .by = year_month) |>
    filter(year_month %in% c("2025-11", "2025-12")) |>
    mutate(source = "xmas_seasonal_2025")
)

# Total Amount Comparison ----
bind_rows(
  seasonal_pay_later_txns_2024 |>
    summarize(total_amount = sum(amount), .by = year_month) |>
    filter(year_month %in% c("2024-11", "2024-12")) |>
    mutate(source = "xmas_seasonal_2024"),

  pay_later_txns_sherlock |>
    filter(increase_type == "Seasonal Xmas") |>
    summarize(total_amount = sum(amount), .by = year_month) |>
    filter(year_month %in% c("2025-11", "2025-12")) |>
    mutate(source = "xmas_seasonal_2025")
)

# Participation Rate ----
{
  xmas_participation_2024_numerator <- seasonal_pay_later_txns_2024 |>
    filter(year_month == "2024-12") |>
    distinct(customer_id) |>
    nrow()

  xmas_participation_2024 <- xmas_participation_2024_numerator /
    nrow(xmas_seasonal_customers_2024)

  glue(
    "Xmas 2024 Participation: {round(xmas_participation_2024 * 100, 2)}% ({xmas_participation_2024_numerator})"
  )
}

{
  xmas_participation_2025_numerator <- pay_later_txns_sherlock |>
    filter(increase_type == "Seasonal Xmas", year_month == "2025-12") |>
    distinct(customer_id) |>
    nrow()

  xmas_participation_2025 <- xmas_participation_2025_numerator /
    nrow(sherlock_xmas_customers)

  glue(
    "Xmas 2025 Participation: {round(xmas_participation_2025 * 100, 2)}% ({xmas_participation_2025_numerator})"
  )
}

# What are the risk segments of those that did not participated? ----
sherlock_xmas_customers |>
  anti_join(
    pay_later_txns_sherlock |>
      filter(increase_type == "Seasonal Xmas", year_month == "2025-12") |>
      distinct(customer_id),
    by = "customer_id"
  ) |>
  select(customer_id, sherlock_segment) |>
  summarize(
    count = n_distinct(customer_id),
    .by = sherlock_segment
  ) |>
  arrange(sherlock_segment)
