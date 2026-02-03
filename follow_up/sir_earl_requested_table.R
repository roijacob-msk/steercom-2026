library(dplyr)

high_risk_customers <- read_sheet(
  "https://docs.google.com/spreadsheets/d/1MTUB1X2V6naRvBa6EZB0ahHIfHqB4g73Tyc4haEu4E8/edit",
  sheet = "Borrower List"
) |>
  filter(sherlock_segment == "90 to 100 %") |>
  select(customer_id, sherlock_segment, old_capital = capital_line, new_capital)

compute_metrics <- function(data) {
  data |>
    summarize(
      customers = n_distinct(customer_id),
      old_capital = sum(max_credit),
      new_capital = sum(new_capital),
      .by = sherlock_segment
    ) |>
    arrange(sherlock_segment) |>
    mutate(
      capital_difference = new_capital - old_capital
    )
}

bind_rows(
  sherlock_xmas_customers |> compute_metrics(),
  high_risk_customers |> rename(max_credit = old_capital) |> compute_metrics()
) |>
  write_csv('test.csv')
