# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Traditional volcano plot function
- Heatmap function
- PCA plot function
- GO/KEGG enrichment bubble plot

## [0.3.0] - 2026-04-18

### Changed
- **BREAKING**: Renamed `plot_crispr_volcano()` to `plot_volcano_hyperbolic()` for better generalization
- Made volcano plot function universal for all omics data types
- Updated function to auto-calculate axis ranges
- Changed default x_label from "Knockdown Phenotype" to "Effect Size"
- Renamed parameter `ntc_pattern` to `control_pattern` for broader applicability

### Added
- Universal volcano plot support for:
  - RNA-seq differential expression analysis
  - Single-cell differential expression
  - CRISPR screening
  - Proteomics differential analysis
  - Metabolomics differential analysis
- Auto-calculation of x_limits and y_limits based on data
- Optional `title` parameter for plot titles
- Comprehensive documentation for different data types
- New example script `volcano_hyperbolic_example.R` with 8 scenarios
- New tutorial `articles/03_双曲线阈值火山图.md` (universal version)
- Data format guide `examples/data/DATA_FORMAT_VOLCANO.md`

### Removed
- Removed CRISPR-specific files (replaced by universal version):
  - `examples/crispr_volcano_example.R` → `examples/volcano_hyperbolic_example.R`
  - `examples/data/README_CRISPR_DATA.md` → `examples/data/DATA_FORMAT_VOLCANO.md`
  - `examples/data/DATA_FORMAT_QUICK_START.md` → merged into DATA_FORMAT_VOLCANO.md
  - `articles/03_CRISPR筛选火山图.md` → `articles/03_双曲线阈值火山图.md`

### Documentation
- Updated all references from CRISPR-specific to universal terminology
- Added usage examples for RNA-seq, single-cell, proteomics, metabolomics
- Provided recommended thresholds for different data types
- Added data format conversion examples for common tools (DESeq2, edgeR, Seurat, MAGeCK, MaxQuant)
- Renumbered article from 04 to 03 for consistency

## [0.2.0] - 2026-04-18

### Added
- `plot_crispr_volcano()` function for CRISPR screening volcano plots
  - Hyperbolic threshold for hit identification
  - Gene category highlighting with custom colors
  - Automatic gene labeling with ggrepel
  - Support for both simple and categorized styles
  - Reference: Nature 2024 & Cell 2025 designs
  - 20+ customizable parameters
  - Dual format output (PDF + PNG)
- `plot_umap_density()` function for single-cell UMAP density plots
  - Density contour lines for cell populations
  - Support for single or multiple cell types
  - Independent contours for each target group
  - Automatic bins adjustment based on cell count
  - Flexible filtering by metadata columns
  - ggsci D3 color scheme integration
- Complete example scripts
  - `crispr_volcano_example.R` - CRISPR volcano plot examples
  - `umap_density_example.R` - UMAP density plot examples
  - `prepare_pbmc3k_data.R` - Test data preparation
- Documentation
  - `articles/03_CRISPR筛选火山图.md` - CRISPR volcano plot tutorial
  - `articles/02_单细胞UMAP密度图.md` - UMAP density plot tutorial
- Test data
  - `pbmc3k_annotated_test.rds` - Annotated PBMC dataset for testing

### Changed
- Updated `.gitignore` to exclude `.rds` and `.RDS` files
- Reorganized README with function categories (Transcriptomics, Single-cell, Genomics)

## [0.1.0] - 2026-04-12

### Added
- Initial release
- `plot_gsea()` function for GSEA enrichment visualization
  - Automatic gene label selection
  - Custom gene highlighting
  - Three-panel layout (ES curve, barcode, ranked list)
  - 30+ customizable parameters
  - Dual format output (PDF + PNG)
- Complete example scripts
  - `gsea_example.R` - Full GSEA workflow
  - `quick_start.R` - Quick start guide
- Test data
  - `test_data_gsea.xlsx` - Sample differential expression data
  - `test_gsea_result.rds` - Pre-computed GSEA results
- Documentation
  - README.md with usage instructions
  - CONTRIBUTING.md with development guidelines
  - Function and article templates
- MIT License

### Repository Structure
```
BioPlotTools/
├── functions/
│   └── plot_gsea.R
├── examples/
│   ├── gsea_example.R
│   └── quick_start.R
├── data/
│   ├── test_data_gsea.xlsx
│   └── test_gsea_result.rds
├── articles/
│   ├── README.md
│   └── 01_GSEA可视化.md
├── templates/
│   ├── function_template.R
│   └── article_template.md
├── README.md
├── CONTRIBUTING.md
├── CHANGELOG.md
├── LICENSE
└── .gitignore
```

### Documentation
- Added `articles/` directory for Chinese blog posts
- Added first article: GSEA富集分析可视化
- Updated README with repository structure and articles section

---

## Version History Format

### [Version] - YYYY-MM-DD

#### Added
- New features

#### Changed
- Changes in existing functionality

#### Deprecated
- Soon-to-be removed features

#### Removed
- Removed features

#### Fixed
- Bug fixes

#### Security
- Security fixes
