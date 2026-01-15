library(dplyr)
library(ggplot2)
library(ggrounded)
library(scales)

# Processing ----
monthly_gmv_per_type <- pay_later_txns |>
  filter(year_month %in% c("2025-11", "2025-12")) |>
  summarize(
    total_amount = sum(amount),
    customers = n_distinct(customer_id),
    .by = c(year_month, increase_type)
  )

peso_format_2dp <- label_currency(
  prefix = "₱",
  scale_cut = cut_short_scale(),
  accuracy = 0.01
)

# Visualization ----
add_pct_increase <- geom_label(
  data = monthly_gmv_per_type |>
    arrange(increase_type, year_month) |>
    summarize(
      pct_change = (last(total_amount) / first(total_amount) - 1) * 100,
      .by = increase_type
    ),
  aes(x = 1.5, y = 10000000, label = sprintf("%+.1f%%", pct_change)),
  inherit.aes = FALSE,
  color = "darkgreen",
  fontface = "bold",
  size = 4
)

add_dec_customer_base <- geom_label(
  data = monthly_gmv_per_type |> filter(year_month == "2025-12"),
  aes(x = 1.5, y = 0, label = paste0(customers, " Dec. Customers")),
  inherit.aes = FALSE,
  color = "darkgreen"
)

ggplot(
  monthly_gmv_per_type,
  aes(x = year_month, y = total_amount)
) +
  geom_col_rounded() +
  geom_text(aes(label = peso_format_2dp(total_amount)), vjust = -0.5) +
  add_pct_increase +
  add_dec_customer_base +
  facet_wrap(vars(increase_type)) +
  scale_y_continuous(labels = peso_format_2dp) +
  labs(
    title = "December Growth per Kasuki Group",
    dictionary = c(year_month = "Year Month", total_amount = "Total Amount"),
  )
