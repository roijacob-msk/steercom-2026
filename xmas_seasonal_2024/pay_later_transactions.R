library(DBI)
library(dplyr)

source("xmas_seasonal_2024/customers.R")

query <- "
  SELECT pay_later_id
    , customer_id
    , activated_at
    , due_at
    , amount
    , handling_fee
  FROM ksk_pay_later_transactions
  WHERE vendor_id = '5ed13854c703830b3df5502a'
    AND year = 2024
    AND year_month IN ('2024-11', '2024-12')
"

seasonal_pay_later_txns_2024 <- dbGetQuery(redshift, query) |>
  mutate(year_month = strftime(activated_at, '%Y-%m')) |>
  filter(customer_id %in% xmas_seasonal_customers_2024$customer_id)
