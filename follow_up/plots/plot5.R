create_metric_plot <- function(data, metric_name, is_currency = TRUE) {
  plot_title <- str_to_title(str_replace_all(metric_name, "_", " "))

  peso_format_0dp <- label_currency(prefix = "₱", scale_cut = cut_short_scale())
  peso_format_2dp <- label_currency(
    prefix = "₱",
    scale_cut = cut_short_scale(),
    accuracy = 0.01
  )

  # Choose formatter based on metric type
  label_formatter <- if (is_currency) peso_format_2dp else label_comma()
  axis_formatter <- if (is_currency) peso_format_0dp else label_comma()

  # Get the filtered data for this metric
  plot_data <- data |> filter(metrics == metric_name)

  # Extract values for the segment
  value_2024 <- plot_data |> filter(year == "2024") |> pull(value)
  value_2025 <- plot_data |> filter(year == "2025") |> pull(value)

  # Calculate difference and percentage
  difference <- value_2025 - value_2024
  pct_change <- (difference / value_2024) * 100

  # Use 10% of the 2024 value as margin
  margin <- value_2024 * 0.10

  # Create label
  label_text <- paste0(
    label_formatter(difference),
    "\n(",
    round(pct_change, 1),
    "%)"
  )

  ggplot(plot_data, aes(x = year, y = value)) +
    geom_col() +
    geom_text(aes(label = label_formatter(value), vjust = -0.5)) +
    geom_segment(
      aes(
        x = "2024",
        y = value_2024 + margin,
        xend = "2024",
        yend = value_2025
      ),
      arrow = arrow(length = unit(0.3, "cm"), type = "closed"),
      alpha = 0.5,
      color = "red",
      inherit.aes = FALSE
    ) +
    geom_label(
      aes(x = "2024", y = (value_2024 + margin + value_2025) / 2),
      label = label_text,
      color = "red",
      fill = "white",
      size = 3,
      inherit.aes = FALSE
    ) +
    easy_remove_axes(what = "title") +
    scale_y_continuous(labels = axis_formatter) +
    labs(title = plot_title) +
    theme(axis.text.x = element_text(face = "bold"))
}

p5 <- create_metric_plot(
  xmas_seasonal_metrics_pivoted,
  "total_customers",
  is_currency = FALSE
)

p6 <- create_metric_plot(
  xmas_seasonal_metrics_pivoted,
  "active_customers",
  is_currency = FALSE
)

p7 <- ggplot(
  xmas_seasonal_metrics_pivoted |> filter(metrics == "active_customers_pct"),
  aes(x = year, y = value)
) +
  geom_col() +
  labs(
    title = "Participation Rate"
  )

p5 + p6 + p7
