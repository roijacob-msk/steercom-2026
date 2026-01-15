library(DBI)
library(dplyr)
library(ggeasy)
library(ggplot2)
library(ggrounded)
library(patchwork)
library(scales)

# Processing ----
non_sherlock_customers <- pay_later_txns |>
  filter(
    increase_type == "Non-Sherlock",
    year_month == "2025-12"
  ) |>
  pull(customer_id) |>
  unique()

{
  customer_ids_sql <- paste0("'", non_sherlock_customers, "'", collapse = ", ")

  query <- glue::glue(
    "
    WITH pay_later_txn AS (
      SELECT *
        , ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY activated_at ASC) AS rn
      FROM ksk_pay_later_transactions
      WHERE vendor_id = '5ed13854c703830b3df5502a'
        AND customer_id IN ({customer_ids_sql})
    )

    SELECT *
    FROM pay_later_txn
    WHERE rn = 1
    "
  )

  result <- dbGetQuery(redshift, query)
}

non_sherlock_yearly_metrics <- result |>
  select(customer_id, amount, activated_at) |>
  mutate(year = strftime(activated_at, "%Y")) |>
  summarize(
    total_amount = sum(amount),
    customers = n_distinct(customer_id),
    .by = year
  ) |>
  mutate(gdp = total_amount / customers) |>
  arrange(desc(year))

# Visualization ----
p1 <- ggplot(
  non_sherlock_yearly_metrics,
  aes(x = year, y = total_amount)
) +
  geom_col_rounded() +
  geom_text(
    aes(label = peso_format_2dp(total_amount)),
    vjust = -0.5,
    fontface = "bold"
  ) +
  geom_label(
    aes(
      label = percent(total_amount / sum(total_amount), accuracy = 0.1),
      y = 0
    ),
    fontface = "bold"
  ) +
  scale_y_continuous(
    labels = label_currency(prefix = "₱", scale_cut = cut_short_scale())
  ) +
  labs(title = "GMV") +
  easy_remove_axes(what = c("title"))

p2 <- ggplot(
  non_sherlock_yearly_metrics,
  aes(x = year, y = customers)
) +
  geom_col_rounded() +
  geom_text(
    aes(label = customers),
    vjust = -0.5,
    fontface = "bold"
  ) +
  geom_label(
    aes(
      label = percent(customers / sum(customers), accuracy = 0.1),
      y = 0
    ),
    fontface = "bold"
  ) +
  labs(title = "MAU") +
  easy_remove_axes(what = c("title"))

p3 <- ggplot(
  non_sherlock_yearly_metrics,
  aes(x = year, y = gdp)
) +
  geom_col_rounded() +
  geom_text(
    aes(label = peso_format_2dp(gdp)),
    vjust = -0.5,
    fontface = "bold"
  ) +
  scale_y_continuous(
    labels = label_currency(prefix = "₱", scale_cut = cut_short_scale())
  ) +
  labs(title = "Basket Size") +
  easy_remove_axes(what = c("title"))

(p1 + p2 + p3) +
  plot_annotation(
    title = "Non-Sherlock Metrics per Origin Year",
  )
