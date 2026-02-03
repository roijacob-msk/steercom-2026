library(dplyr)
library(ggplot2)

sherlock_xmas_customers |>
  mutate(is_active = customer_id %in% plt_xmas_seasonal_2025$customer_id) |>
  summarize(
    active_customers = sum(is_active),
    inactive_customers = sum(!is_active),
    .by = sherlock_segment
  ) |>
  pivot_longer(
    cols = c(active_customers, inactive_customers),
    names_to = "status",
    values_to = "count"
  ) |>
  ggplot(aes(x = sherlock_segment, y = count, fill = status)) +
  geom_col(position = position_fill(reverse = TRUE)) +
  geom_label(
    data = metrics_per_segment,
    mapping = aes(x = sherlock_segment, y = 0, label = customers),
    inherit.aes = FALSE
  ) +
  labs(
    title = "Customer Participation Rate per Sherlock Segment",
    x = "Segment",
    y = "Number of Customers",
    fill = "Status"
  ) +
  theme_bw()
