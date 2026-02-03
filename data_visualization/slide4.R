library(glue)

calculate_seasonal_metrics <- function(
  data,
  old_credit_col,
  new_credit_col,
  december_txn_data,
  year
) {
  data |>
    summarise(
      new_credit_limit = sum(.data[[new_credit_col]], na.rm = TRUE),
      old_credit_limit = sum(.data[[old_credit_col]], na.rm = TRUE)
    ) |>
    mutate(
      total_december_spending = december_txn_data |>
        summarise(total = sum(amount, na.rm = TRUE)) |>
        pull(total),
      normalized_pct = total_december_spending / old_credit_limit,
      current_pct = total_december_spending / new_credit_limit,
      seasonal_year = year
    )
}

# Query 2024 Transactions ----
{
  xmas_seasonal_customer_ids_2024 <- xmas_seasonal_customers_2024 |>
    pull(customer_id)

  query <- glue_sql(
    "
    SELECT pay_later_id
      , customer_id
      , activated_at
      , due_at
      , amount
      , handling_fee
    FROM ksk_pay_later_transactions
    WHERE vendor_id = '5ed13854c703830b3df5502a'
      AND customer_id IN ({xmas_seasonal_customer_ids_2024*})
      -- AND year = 2024
      AND year_month = '2024-12'
    ",
    .con = redshift
  )

  result <- dbGetQuery(redshift, query)
}

metrics_2024 <- calculate_seasonal_metrics(
  data = xmas_seasonal_customers_2024,
  old_credit_col = "original_credit_limit",
  new_credit_col = "credit_limit",
  december_txn_data = result,
  year = "2024"
)

metrics_2025 <- calculate_seasonal_metrics(
  data = sherlock_xmas_customers,
  old_credit_col = "max_credit",
  new_credit_col = "new_capital",
  december_txn_data = pay_later_txns_sherlock |>
    filter(year_month == "2025-12", increase_type == "Seasonal Xmas"),
  year = "2025"
)

bind_rows(metrics_2024, metrics_2025)
