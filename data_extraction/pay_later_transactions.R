library(DBI)
library(dplyr)
library(tidyr)

source("data_extraction/sherlock_customers.R")

# Extraction ----
redshift <- dbConnect(
  RPostgres::Postgres(),
  host = Sys.getenv("REDSHIFT_HOST"),
  dbname = Sys.getenv("REDSHIFT_NAME"),
  user = Sys.getenv("REDSHIFT_USER"),
  password = Sys.getenv("REDSHIFT_PASSWORD"),
  port = as.integer(Sys.getenv("REDSHIFT_PORT"))
)

query <- "
  SELECT pay_later_id
    , customer_id
    , activated_at
    , due_at
    , amount
    , handling_fee
  FROM ksk_pay_later_transactions
  WHERE vendor_id = '5ed13854c703830b3df5502a'
    AND year = 2025
"

# Processing ----
pay_later_txns <- dbGetQuery(redshift, query) |>
  mutate(
    is_sherlock = if_else(
      customer_id %in% sherlock_customers$customer_id,
      "Sherlock",
      "Non-Sherlock"
    ),
    year_month = strftime(activated_at, "%Y-%m")
  ) |>
  left_join(sherlock_customers, by = join_by(customer_id)) |>
  mutate(increase_type = replace_na(increase_type, "Non-Sherlock"))

pay_later_txns_sherlock <- pay_later_txns |>
  filter(is_sherlock == "Sherlock")
