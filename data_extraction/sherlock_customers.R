library(readr)
library(dplyr)
library(googledrive)
library(googlesheets4)
library(purrr)
library(stringr)

{
  sherlock_run_august <- read_sheet(
    "https://docs.google.com/spreadsheets/d/1qwTYn2Pvh4txtF1x0SkyOB1cweXtykDTrLY4Vp7i7qY/edit",
    sheet = "Borrower Details"
  ) |>
    select(customer_id, sherlock_segment = proba_group) |>
    mutate(
      sherlock_segment = str_replace_all(sherlock_segment, "percent", "%")
    )

  read_csv_gdrive <- function(file_id) {
    drive_read_string(file_id) |> read_csv()
  }

  sherlock_experimental_customers <- drive_ls(
    "kasuki/2025-08-sherlock-experimental",
    type = "csv"
  ) |>
    pull(id) |>
    map(read_csv_gdrive) |>
    bind_rows() |>
    left_join(sherlock_run_august, by = "customer_id")
}

{
  sherlock_run_november <- read_sheet(
    "https://docs.google.com/spreadsheets/d/1MTUB1X2V6naRvBa6EZB0ahHIfHqB4g73Tyc4haEu4E8/edit",
    sheet = "Borrower List"
  ) |>
    select(customer_id, sherlock_segment)

  sherlock_xmas_customers <- drive_ls(
    "kasuki/2025-11-sherlock-seasonal-xmas",
    type = "csv"
  ) |>
    pull(id) |>
    drive_read_string() |>
    read_csv() |>
    left_join(sherlock_run_november, by = "customer_id")
}

sherlock_customers <- bind_rows(
  sherlock_experimental_customers |>
    select(customer_id, sherlock_segment) |>
    mutate(source = "permanent_experimental"),

  sherlock_xmas_customers |>
    select(customer_id, sherlock_segment) |>
    mutate(source = "seasonal_xmas")
)
