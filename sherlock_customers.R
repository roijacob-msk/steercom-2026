library(readr)
library(dplyr)
library(googledrive)
library(purrr)

sherlock_experimental_customers <- drive_ls("kasuki/2025-08-sherlock-experimental", type = "csv") |>
  pull(id) |> 
  map(
    function(file_id) { drive_read_string(file_id) |> read_csv() }    
  ) |> 
  bind_rows()

sherlock_xmas_customers <- drive_ls("kasuki/2025-11-sherlock-seasonal-xmas", type = "csv") |>
    pull(id) |> 
    drive_read_string() |> 
    read_csv()

sherlock_customers <- c(
  sherlock_experimental_customers$customer_id,
  sherlock_xmas_customers$customer_id
)
