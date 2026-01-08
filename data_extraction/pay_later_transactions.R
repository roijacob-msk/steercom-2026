library(DBI)

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

pay_later_txns <- dbGetQuery(redshift, query)
