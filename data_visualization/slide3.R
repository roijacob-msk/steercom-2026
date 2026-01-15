library(ggeasy)
library(ggplot2)
library(ggrounded)
library(patchwork)
library(scales)

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
