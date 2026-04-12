# BioPlotTools

A collection of practical R functions for bioinformatics data visualization.

## Features

- 📊 Publication-quality plots
- 🎨 Highly customizable parameters  
- 🚀 Easy to use with one-line commands
- 📦 Load directly from GitHub
- 🔬 Designed for omics data analysis

## Available Functions

### plot_gsea()

Generate publication-quality GSEA plots with three panels: ES curve with gene labels, barcode plot with expression heatmap, and ranked list visualization.

**Features:**
- Automatic gene label selection
- Custom gene highlighting
- 30+ customizable parameters
- Dual format output (PDF + PNG)

## Quick Start

```r
library(clusterProfiler)
library(msigdbr)

# Load function from GitHub
source("https://raw.githubusercontent.com/ShengXinF3/BioPlotTools/main/functions/plot_gsea.R")

# Prepare gene list
genelist <- setNames(gene_data$log2fc, gene_data$gene_name)
genelist <- sort(genelist, decreasing = TRUE)

# Get KEGG gene sets
m_df <- msigdbr(species = "Mus musculus")
kegg_sets <- m_df[m_df$gs_subcollection == 'CP:KEGG_LEGACY', ]
term2gene <- data.frame(term = kegg_sets$gs_name, 
                       gene = kegg_sets$gene_symbol)

# Run GSEA
gsea_result <- GSEA(genelist, TERM2GENE = term2gene, pvalueCutoff = 1)

# Plot
plot_gsea(gsea_result, "KEGG_OXIDATIVE_PHOSPHORYLATION")
```

## Examples

See the [examples](examples/) directory for complete workflows:
- `gsea_example.R` - Complete GSEA analysis and plotting workflow
- `gsea_batch_plot.R` - Batch plotting for multiple pathways

## Test Data

Test data is available in the [data](data/) directory:
- `test_gene_data.xlsx` - Sample differential expression data
- `test_gsea_result.rds` - Pre-computed GSEA results

## Function Documentation

### plot_gsea()

```r
plot_gsea(gsea_object, pathway_id, 
         n_genes = 8,
         custom_genes = NULL,
         output_name = NULL,
         curve_color = "#9370DB",
         vline_color = "#DC143C",
         pos_color = "#FFB6C1",
         neg_color = "#87CEEB",
         base_size = 15,
         plot_width = 12,
         plot_height = 9,
         dpi = 300)
```

**Parameters:**
- `gsea_object`: GSEA result object or path to .rds file
- `pathway_id`: KEGG pathway ID (e.g., "KEGG_OXIDATIVE_PHOSPHORYLATION")
- `n_genes`: Number of genes to label (default: 8)
- `custom_genes`: Custom gene list to label (default: NULL)
- `output_name`: Output file name without extension
- `curve_color`: ES curve color (default: "#9370DB")
- `vline_color`: Vertical line color (default: "#DC143C")
- `pos_color`: Positive area color (default: "#FFB6C1")
- `neg_color`: Negative area color (default: "#87CEEB")
- `base_size`: Base font size (default: 15)
- `plot_width`: Plot width in inches (default: 12)
- `plot_height`: Plot height in inches (default: 9)
- `dpi`: PNG resolution (default: 300)

**Returns:** A patchwork combined plot object

## Dependencies

```r
library(ggplot2)
library(dplyr)
library(patchwork)
library(clusterProfiler)
library(msigdbr)
```

## Installation

No installation needed! Just load the functions directly from GitHub:

```r
source("https://raw.githubusercontent.com/ShengXinF3/BioPlotTools/main/functions/plot_gsea.R")
```

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests.

## License

MIT License

## Citation

If you use BioPlotTools in your research, please cite:

```
ShengXinF3. (2026). BioPlotTools: R functions for bioinformatics data visualization. 
GitHub repository: https://github.com/ShengXinF3/BioPlotTools
```

## Contact

For questions or suggestions, please open an issue on GitHub.

## More Functions Coming Soon

- Volcano plots
- Heatmaps
- GO enrichment plots
- And more...

Stay tuned!
