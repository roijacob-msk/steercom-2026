library(DBI)

rds <- dbConnect(
  RPostgres::Postgres(),
  host = Sys.getenv("RDS_HOST"),
  dbname = Sys.getenv("RDS_NAME"),
  user = Sys.getenv("RDS_USER"),
  password = Sys.getenv("RDS_PASSWORD"),
  port = as.integer(Sys.getenv("RDS_PORT"))
)

query <- "
  SELECT *
  FROM prg_scoring.customer_selections_list

  -- Christmas Seasonal Increase (2024)
  WHERE campaign_id = 'd21d81c5-94df-49b6-a5cb-269c1be48876'
"

xmas_seasonal_customers_2024 <- dbGetQuery(rds, query)
