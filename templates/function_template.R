# Template for BioPlotTools Functions
# Copy this template when creating a new plotting function

library(ggplot2)
library(dplyr)
# Add other required libraries

#' Plot [Function Name]
#'
#' [Detailed description of what this function does and what problem it solves]
#'
#' @param data [Description of input data format and requirements]
#' @param output_name Character. Output file name without extension (default: "[default_name]")
#' @param main_param [Description of main parameter]
#' @param main_color Character. Main color (default: "#[hex_code]")
#' @param base_size Numeric. Base font size (default: 15)
#' @param title_size Numeric. Title font size (default: 18)
#' @param plot_width Numeric. Plot width in inches (default: 10)
#' @param plot_height Numeric. Plot height in inches (default: 8)
#' @param dpi Numeric. PNG resolution (default: 300)
#'
#' @return A ggplot object
#'
#' @examples
#' # Basic usage
#' plot_function(data)
#'
#' # Custom styling
#' plot_function(data,
#'              main_color = "#FF6347",
#'              base_size = 16,
#'              plot_width = 12)
#'
#' @export
plot_function_name <- function(data,
                               output_name = NULL,
                               # Main parameters
                               main_param = "default",
                               # Colors
                               main_color = "#9370DB",
                               # Font sizes
                               base_size = 15,
                               title_size = 18,
                               label_size = 12,
                               # Plot dimensions
                               plot_width = 10,
                               plot_height = 8,
                               dpi = 300) {
  
  # ============================================================================
  # Input validation
  # ============================================================================
  
  if (missing(data)) {
    stop("data is required")
  }
  
  # Check data format
  # Add your validation logic here
  
  # ============================================================================
  # Data preparation
  # ============================================================================
  
  # Process input data
  # Add your data processing logic here
  
  # ============================================================================
  # Create plot
  # ============================================================================
  
  p <- ggplot(data, aes(x = x, y = y)) +
    # Add your plot layers here
    theme_classic(base_size = base_size) +
    theme(
      plot.title = element_text(size = title_size, face = "bold", hjust = 0.5),
      axis.text = element_text(size = label_size)
    )
  
  # ============================================================================
  # Save plot
  # ============================================================================
  
  if (is.null(output_name)) {
    output_name <- "plot_output"
  }
  
  # Create output directory if needed
  if (grepl("/", output_name)) {
    dir.create(dirname(output_name), showWarnings = FALSE, recursive = TRUE)
  }
  
  # Save as PDF and PNG
  ggsave(paste0(output_name, ".pdf"), p, 
         width = plot_width, height = plot_height)
  ggsave(paste0(output_name, ".png"), p, 
         width = plot_width, height = plot_height, dpi = dpi)
  
  message("Saved: ", output_name, ".pdf/png")
  
  return(p)
}
