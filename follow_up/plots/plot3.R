ggplot(
  plt_xmas_seasonal_2025 |>
    summarize(
      total_amount = sum(amount),
      avg_amount = mean(amount),
      median_amount = median(amount),
      .by = c(sherlock_segment, year_month)
    ) |>
    pivot_longer(
      cols = c(total_amount, avg_amount, median_amount),
      names_to = "metrics",
      values_to = "value"
    ) |>
    filter(metrics %in% c("avg_amount", "median_amount")),
  aes(x = sherlock_segment, y = value, color = metrics, group = metrics)
) +
  geom_point() +
  facet_wrap(vars(year_month)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(
    title = "Monthly Customer Spending per Segment"
  )
