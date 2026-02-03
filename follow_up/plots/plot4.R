library(patchwork)
library(ggeasy)
library(scales)

xmas_seasonal_metrics_pivoted <- xmas_seasonal_metrics |>
  pivot_longer(
    cols = c(year_twenty_four, year_twenty_five),
    names_to = "year",
    values_to = "value"
  ) |>
  mutate(
    year = case_when(
      year == "year_twenty_four" ~ "2024",
      year == "year_twenty_five" ~ "2025"
    )
  )

create_metric_plot <- function(data, metric_name) {
  plot_title <- str_to_title(str_replace_all(metric_name, "_", " "))

  peso_format_0dp <- label_currency(prefix = "₱", scale_cut = cut_short_scale())
  peso_format_2dp <- label_currency(
    prefix = "₱",
    scale_cut = cut_short_scale(),
    accuracy = 0.01
  )

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
    peso_format_2dp(difference),
    "\n(",
    round(pct_change, 1),
    "%)"
  )

  ggplot(plot_data, aes(x = year, y = value)) +
    geom_col() +
    geom_text(aes(label = peso_format_2dp(value), vjust = -0.5)) +
    geom_segment(
      aes(
        x = "2024",
        y = value_2024 + margin,
        xend = "2024",
        yend = value_2025
      ),
      arrow = arrow(length = unit(0.3, "cm"), type = "closed"),
      alpha = 0.25,
      color = "red",
      inherit.aes = FALSE
    ) +
    geom_label(
      aes(x = "2024", y = (value_2024 + margin + value_2025) / 2),
      label = label_text,
      color = "gray50",

      fill = "white",
      size = 3.75,
      fontface = "bold",
      inherit.aes = FALSE
    ) +
    easy_remove_axes(what = "title") +
    scale_y_continuous(labels = peso_format_0dp) +
    labs(title = plot_title) +
    theme(axis.text.x = element_text(face = "bold"))
}

p1 <- create_metric_plot(xmas_seasonal_metrics_pivoted, "old_capital")
p2 <- create_metric_plot(xmas_seasonal_metrics_pivoted, "new_capital")
p3 <- create_metric_plot(xmas_seasonal_metrics_pivoted, "capital_deployed")

p1 + p2 + p3
