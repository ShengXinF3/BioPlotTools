# Complete GSEA Analysis and Plotting Workflow
# This example demonstrates how to perform GSEA analysis and create publication-quality plots

# Load required libraries
library(readxl)
library(dplyr)
library(clusterProfiler)
library(msigdbr)

# Load the plot_gsea function from GitHub
source("https://raw.githubusercontent.com/ShengXinF3/BioPlotTools/main/functions/plot_gsea.R")

# Or load from local file if you have downloaded it
# source("../functions/plot_gsea.R")

# ============================================================================
# Step 1: Load and prepare gene expression data
# ============================================================================

# Load test data (you can replace this with your own data)
gene_data <- read_excel("../data/test_gene_data.xlsx", na = "---")

# Convert log2FC to numeric and remove invalid values
gene_data$`log2(fc)` <- as.numeric(gene_data$`log2(fc)`)
gene_data <- gene_data[!is.na(gene_data$`log2(fc)`) & 
                       !gene_data$`log2(fc)` %in% c(-Inf, Inf), ]

# ============================================================================
# Step 2: Prepare gene list for GSEA
# ============================================================================

# Aggregate duplicated genes by taking mean log2FC
genelist_df <- aggregate(gene_data$`log2(fc)`, 
                        by = list(gene_name = gene_data$gene_name), 
                        FUN = mean)

# Create named vector and sort by log2FC (descending)
genelist <- setNames(genelist_df$x, genelist_df$gene_name)
genelist <- sort(genelist, decreasing = TRUE)

# Check the gene list
head(genelist)
tail(genelist)

# ============================================================================
# Step 3: Get KEGG gene sets
# ============================================================================

# Get gene sets for your species (change species as needed)
species <- "Mus musculus"  # Mouse
# species <- "Homo sapiens"  # Human
# species <- "Rattus norvegicus"  # Rat

m_df <- msigdbr(species = species)
kegg_sets <- m_df[m_df$gs_subcollection == 'CP:KEGG_LEGACY', ]

# Prepare term2gene data frame
term2gene <- data.frame(term = kegg_sets$gs_name, 
                       gene = kegg_sets$gene_symbol)

# ============================================================================
# Step 4: Run GSEA
# ============================================================================

gsea_result <- GSEA(genelist, 
                   TERM2GENE = term2gene, 
                   pvalueCutoff = 1,
                   verbose = TRUE)

# View results
head(gsea_result@result)

# ============================================================================
# Step 5: Plot single pathway
# ============================================================================

# Basic usage - plot a specific pathway
plot_gsea(gsea_result, "KEGG_OXIDATIVE_PHOSPHORYLATION")

# Custom styling
plot_gsea(gsea_result, "KEGG_OXIDATIVE_PHOSPHORYLATION",
         n_genes = 10,
         curve_color = "#9370DB",
         base_size = 16,
         plot_width = 14,
         output_name = "OxPhos_custom")

# Custom gene selection
plot_gsea(gsea_result, "KEGG_OXIDATIVE_PHOSPHORYLATION",
         custom_genes = c("Ndufa1", "Ndufa2", "Cox5a", "Atp5a1"))

# ============================================================================
# Step 6: Batch plotting for significant pathways
# ============================================================================

# Filter significant pathways (p.adjust < 0.05)
sig_pathways <- gsea_result@result[gsea_result@result$p.adjust < 0.05, ]

message(sprintf("Found %d significant pathways", nrow(sig_pathways)))

# Create output directory
output_dir <- "GSEA_Plots"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# Plot all significant pathways
for (i in 1:nrow(sig_pathways)) {
  pathway_id <- sig_pathways$ID[i]
  clean_name <- gsub("[^A-Za-z0-9_]", "_", pathway_id)
  
  message(sprintf("[%d/%d] Plotting %s", i, nrow(sig_pathways), 
                 sig_pathways$Description[i]))
  
  plot_gsea(gsea_result, pathway_id, 
           output_name = file.path(output_dir, clean_name),
           n_genes = 8)
}

message(sprintf("Done! %d plots saved to %s", nrow(sig_pathways), output_dir))

# ============================================================================
# Additional tips
# ============================================================================

# Tip 1: Adjust gene label count based on pathway size
pathway_size <- sum(gsea_result@geneSets[["KEGG_OXIDATIVE_PHOSPHORYLATION"]] %in% names(genelist))
n_labels <- min(max(5, round(pathway_size / 10)), 15)
plot_gsea(gsea_result, "KEGG_OXIDATIVE_PHOSPHORYLATION", n_genes = n_labels)

# Tip 2: Separate upregulated and downregulated pathways
up_pathways <- sig_pathways %>% filter(NES > 0)
down_pathways <- sig_pathways %>% filter(NES < 0)

# Tip 3: Save GSEA result for later use
saveRDS(gsea_result, "my_gsea_result.rds")

# Load saved result
# gsea_result <- readRDS("my_gsea_result.rds")
