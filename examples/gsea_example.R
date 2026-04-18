# Complete GSEA Analysis and Plotting Workflow
# This example demonstrates how to perform GSEA analysis and create publication-quality plots

# Load required libraries
library(readxl)
library(dplyr)
library(clusterProfiler)
library(msigdbr)

# Load the plot_gsea function from GitHub
# Method 1: Use jsdelivr CDN (recommended, fast in China)
source("https://cdn.jsdelivr.net/gh/ShengXinF3/BioPlotTools@main/functions/plot_gsea.R")

# Method 2: GitHub official source
# source("https://raw.githubusercontent.com/ShengXinF3/BioPlotTools/main/functions/plot_gsea.R")

# Method 3: If network doesn't work, clone repo and use locally
# In terminal: git clone https://github.com/ShengXinF3/BioPlotTools.git
# Then: source("../functions/plot_gsea.R")

# ============================================================================
# Step 1: Load and prepare gene expression data
# ============================================================================

# Load test data (you can replace this with your own data)
gene_data <- read_excel("./data/test_data_gsea.xlsx", na = "---")

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

# Create output directory
output_dir <- "examples/output/plot_gsea"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# Basic usage - plot a specific pathway
plot_gsea(gsea_result, "KEGG_OXIDATIVE_PHOSPHORYLATION",
         output_name = file.path(output_dir, "01_basic"))

# Custom styling
plot_gsea(gsea_result, "KEGG_OXIDATIVE_PHOSPHORYLATION",
         n_genes = 10,
         curve_color = "#9370DB",
         base_size = 16,
         plot_width = 14,
         output_name = file.path(output_dir, "02_custom_style"))

# Custom gene selection
plot_gsea(gsea_result, "KEGG_OXIDATIVE_PHOSPHORYLATION",
         custom_genes = c("Ndufa1", "Ndufa2", "Cox5a", "Atp5a1"),
         output_name = file.path(output_dir, "03_custom_genes"))

# ============================================================================
# Step 6: Batch plotting for significant pathways
# ============================================================================

# Filter significant pathways (p.adjust < 0.05)
sig_pathways <- gsea_result@result[gsea_result@result$p.adjust < 0.05, ]

message(sprintf("Found %d significant pathways", nrow(sig_pathways)))

# Create output directory for batch plots
batch_output_dir <- "examples/output/plot_gsea/batch"
dir.create(batch_output_dir, showWarnings = FALSE, recursive = TRUE)

# Plot all significant pathways
for (i in 1:nrow(sig_pathways)) {
  pathway_id <- sig_pathways$ID[i]
  clean_name <- gsub("[^A-Za-z0-9_]", "_", pathway_id)
  
  message(sprintf("[%d/%d] Plotting %s", i, nrow(sig_pathways), 
                 sig_pathways$Description[i]))
  
  plot_gsea(gsea_result, pathway_id, 
           output_name = file.path(batch_output_dir, clean_name),
           n_genes = 8)
}

message(sprintf("Done! %d plots saved to %s", nrow(sig_pathways), batch_output_dir))

# ============================================================================
# Additional tips
# ============================================================================

# Tip 1: Adjust gene label count based on pathway size
pathway_size <- sum(gsea_result@geneSets[["KEGG_OXIDATIVE_PHOSPHORYLATION"]] %in% names(genelist))
n_labels <- min(max(5, round(pathway_size / 10)), 15)
plot_gsea(gsea_result, "KEGG_OXIDATIVE_PHOSPHORYLATION", 
         n_genes = n_labels,
         output_name = file.path(output_dir, "04_auto_labels"))

# Tip 2: Separate upregulated and downregulated pathways
up_pathways <- sig_pathways %>% filter(NES > 0)
down_pathways <- sig_pathways %>% filter(NES < 0)

cat(sprintf("\nUpregulated pathways: %d\n", nrow(up_pathways)))
cat(sprintf("Downregulated pathways: %d\n", nrow(down_pathways)))

# Tip 3: Save GSEA result for later use
saveRDS(gsea_result, file.path(output_dir, "gsea_result.rds"))
cat(sprintf("\n✓ GSEA result saved to %s\n", file.path(output_dir, "gsea_result.rds")))

cat("\n========== 所有示例完成！ ==========\n")
cat(sprintf("\n生成的文件保存在: %s\n", output_dir))
cat("  - 01_basic.pdf (基础用法)\n")
cat("  - 02_custom_style.pdf (自定义样式)\n")
cat("  - 03_custom_genes.pdf (自定义基因标注)\n")
cat("  - 04_auto_labels.pdf (自动调整标签数量)\n")
cat(sprintf("  - batch/ 目录下有 %d 个显著通路的图\n", nrow(sig_pathways)))
