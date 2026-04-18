# ========== [Function Name] Example Template ==========
# 
# Template for creating example scripts for BioPlotTools functions
# Copy this template when creating a new example script
#
# Usage:
# 1. Replace [Function Name] with actual function name
# 2. Replace [function_name] with lowercase function name
# 3. Update data loading section
# 4. Modify examples to demonstrate key features
# 5. Save as: examples/[function_name]_example.R

library(ggplot2)
library(dplyr)
library(readxl)  # If reading Excel files
# Add other required libraries

# ============================================================================
# Load function
# ============================================================================

# Method 1: Load from GitHub (recommended for users)
# source("https://cdn.jsdelivr.net/gh/ShengXinF3/BioPlotTools@main/functions/[function_name].R")

# Method 2: Load locally (for development/testing)
source("functions/[function_name].R")

# ============================================================================
# Setup output directory
# ============================================================================

output_dir <- "examples/output/[function_name]"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# ============================================================================
# Load test data
# ============================================================================

# Load main data
test_data <- read_excel("examples/data/test_data_[function_name].xlsx")

# Load optional data (if applicable)
# category_data <- read_excel("examples/data/test_category_[function_name].xlsx")

# ============================================================================
# Example 1: Basic usage
# ============================================================================

cat("\n========== Example 1: Basic Usage ==========\n")

# Demonstrate the simplest way to use the function
# Focus on required parameters only

p1 <- [function_name](
  data = test_data,
  # Add required parameters
  output_name = file.path(output_dir, "01_basic")
)

print(p1)
cat("✓ Saved:", file.path(output_dir, "01_basic.pdf & .png\n"))

# ============================================================================
# Example 2: [Key Feature 1]
# ============================================================================

cat("\n========== Example 2: [Key Feature 1] ==========\n")

# Demonstrate the first key feature
# Explain what this feature does and when to use it

p2 <- [function_name](
  data = test_data,
  # Add parameters for key feature 1
  output_name = file.path(output_dir, "02_feature1")
)

print(p2)
cat("✓ Saved:", file.path(output_dir, "02_feature1.pdf & .png\n"))

# ============================================================================
# Example 3: [Key Feature 2]
# ============================================================================

cat("\n========== Example 3: [Key Feature 2] ==========\n")

# Demonstrate the second key feature
# Show how to combine multiple features if applicable

p3 <- [function_name](
  data = test_data,
  # Add parameters for key feature 2
  output_name = file.path(output_dir, "03_feature2")
)

print(p3)
cat("✓ Saved:", file.path(output_dir, "03_feature2.pdf & .png\n"))

# ============================================================================
# Example 4: Custom styling (optional)
# ============================================================================

cat("\n========== Example 4: Custom Styling ==========\n")

# Demonstrate customization options
# Show how to adjust colors, sizes, etc.

# Custom colors
custom_colors <- c(
  "Group1" = "#E74C3C",
  "Group2" = "#3498DB"
  # Add more as needed
)

p4 <- [function_name](
  data = test_data,
  colors = custom_colors,
  # Add other styling parameters
  output_name = file.path(output_dir, "04_custom_style")
)

print(p4)
cat("✓ Saved:", file.path(output_dir, "04_custom_style.pdf & .png\n"))

# ============================================================================
# Summary
# ============================================================================

cat("\n========== All Examples Completed! ==========\n")
cat(sprintf("\nOutput files saved in: %s\n", output_dir))
cat("  - 01_basic.pdf (Basic usage)\n")
cat("  - 02_feature1.pdf ([Key Feature 1])\n")
cat("  - 03_feature2.pdf ([Key Feature 2])\n")
cat("  - 04_custom_style.pdf (Custom styling)\n")

cat("\nKey Features:\n")
cat("  1. [Feature 1 description]\n")
cat("  2. [Feature 2 description]\n")
cat("  3. [Feature 3 description]\n")
cat("  4. Publication-quality output (PDF + PNG)\n")

cat("\nRecommended Settings:\n")
cat("  - [Data Type 1]: [parameter settings]\n")
cat("  - [Data Type 2]: [parameter settings]\n")
cat("  - [Data Type 3]: [parameter settings]\n")

cat("\nFunction automatically recognizes:\n")
cat("  - [Column name 1] (recommended)\n")
cat("  - [Column name 2] (alternative)\n")
cat("  - [Column name 3] (alternative)\n")

# ============================================================================
# Notes for template users
# ============================================================================

# When creating a new example script:
# 
# 1. Keep examples focused and concise (3-4 examples is ideal)
# 2. Each example should demonstrate ONE key feature
# 3. Use descriptive output file names
# 4. Include print() to show plots in interactive sessions
# 5. Add informative cat() messages for user feedback
# 6. Test with actual data before committing
# 7. Ensure all file paths use file.path() for cross-platform compatibility
# 8. Create output directory with recursive = TRUE
# 9. Use consistent naming: 01_basic, 02_feature1, etc.
# 10. Add summary section at the end

# Example structure guidelines:
# - Example 1: Always basic usage (minimal parameters)
# - Example 2-3: Key features (one feature per example)
# - Example 4: Customization (colors, styling, advanced options)
# - Keep total examples to 3-4 to avoid overwhelming users
# - Each example should be runnable independently

# Output file naming convention:
# - Use numbers: 01, 02, 03, etc.
# - Use descriptive names: basic, with_category, highlight, etc.
# - Keep names short and clear
# - Use underscores, not spaces

# Documentation in summary:
# - List all output files with descriptions
# - Highlight key features
# - Provide recommended settings for different data types
# - Mention automatic column name recognition if applicable
