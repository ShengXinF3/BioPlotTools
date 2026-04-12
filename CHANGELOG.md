# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Volcano plot function
- Heatmap function
- PCA plot function
- GO/KEGG enrichment bubble plot

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
  - `test_gene_data.xlsx` - Sample differential expression data
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
│   ├── test_gene_data.xlsx
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
