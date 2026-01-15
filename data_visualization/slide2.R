library(dplyr)
library(ggplot2)
library(ggrounded)
library(tidyr)

# Processing ----
monthly_gmv_per_xmas_segment <- pay_later_txns_sherlock |>
  filter(
    increase_type == "Seasonal Xmas",
    year_month %in% c("2025-11", "2025-12")
  ) |>
  summarize(
    total_amount = sum(amount),
    .by = c(year_month, sherlock_segment)
  ) |>
  arrange(sherlock_segment, year_month)

arrow_data <- monthly_gmv_per_xmas_segment |>
  pivot_wider(
    names_from = year_month,
    values_from = total_amount
  ) |>
  rename(
    nov_2025 = `2025-11`,
    dec_2025 = `2025-12`
  ) |>
  mutate(
    pct_change = round(((dec_2025 / nov_2025) - 1) * 100, 1),
    midpoint = (nov_2025 + dec_2025) / 2,
    margin = (dec_2025 - nov_2025) * 0.10,
    start_adj = nov_2025 + margin,
    end_adj = dec_2025 - margin
  )

# Visualization ----
plot_gmv <- list(
  geom_point(size = 3),
  geom_line(
    data = subset(monthly_gmv_per_xmas_segment, year_month == "2025-11"),
    alpha = 0.05,
    linewidth = 0.5
  ),
  geom_line(
    data = subset(monthly_gmv_per_xmas_segment, year_month == "2025-12"),
    alpha = 0.1,
    linewidth = 0.5
  )
)

draw_arrows <- geom_segment(
  data = arrow_data,
  aes(
    # Arrow tail
    x = sherlock_segment,
    y = start_adj,

    # Arrow head
    xend = sherlock_segment,
    yend = end_adj
  ),
  arrow = arrow(length = unit(0.3, "cm"), type = "closed"),
  color = "gray50",
  alpha = 0.5,
  inherit.aes = FALSE
)

add_pct_increase <- geom_text(
  data = arrow_data,
  aes(x = sherlock_segment, y = midpoint, label = paste0(pct_change, "%")),
  color = "black",
  size = 3,
  fontface = "bold",
  inherit.aes = FALSE
)

ggplot(
  monthly_gmv_per_xmas_segment,
  aes(
    x = sherlock_segment,
    y = total_amount,
    color = year_month,
    group = year_month
  )
) +
  plot_gmv +
  draw_arrows +
  add_pct_increase +
  scale_y_continuous(
    labels = label_currency(prefix = "₱", scale_cut = cut_short_scale())
  ) +
  theme(
    legend.position = c(0.01, 0.99),
    legend.justification = c(0, 1),
    panel.border = element_rect(linetype = "dashed"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  labs(
    title = "December Purchasing Increase per Segment",
    dictionary = c(
      total_amount = "Total Amount",
      sherlock_segment = "Sherlock Segment",
      year_month = "Year Month"
    )
  )
