# Quick Start Example - Using Pre-computed GSEA Results
# This example shows how to quickly plot GSEA results using test data

# Load required libraries
library(ggplot2)
library(dplyr)
library(patchwork)

# Load the plot_gsea function from GitHub
source("https://raw.githubusercontent.com/ShengXinF3/BioPlotTools/main/functions/plot_gsea.R")

# Load pre-computed GSEA results
gsea_result <- readRDS("../data/test_gsea_result.rds")

# View available pathways
head(gsea_result@result)

# Plot a single pathway with default settings
plot_gsea(gsea_result, "KEGG_OXIDATIVE_PHOSPHORYLATION")

# That's it! The plot is saved as PDF and PNG in your working directory.
