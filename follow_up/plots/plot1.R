library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)

ggplot(
  metrics_per_segment |>
    pivot_longer(
      cols = c(old_capital, new_capital),
      names_to = "capital_type",
      values_to = "capital"
    ) |>
    mutate(
      capital_type = factor(
        capital_type,
        levels = c("old_capital", "new_capital")
      )
    ),
  aes(x = sherlock_segment, y = capital, fill = capital_type)
) +
  theme_bw() +
  geom_col(position = "dodge") +
  geom_label(
    data = metrics_per_segment,
    mapping = aes(
      x = sherlock_segment,
      y = 1e6,
      label = round(pct_capital_increase * 100, 1) |> paste0("%")
    ),
    inherit.aes = FALSE,
  ) +
  scale_y_continuous(
    labels = label_currency(prefix = "₱", scale_cut = cut_short_scale())
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = c(1, 1),
    legend.justification = c(1, 1)
  ) +
  labs(
    title = "Capital Distribution per Segment",
    dictionary = c(
      sherlock_segment = "Sherlock Segment",
      capital = "Capital",
      capital_type = "Capital Type"
    ),
  )
