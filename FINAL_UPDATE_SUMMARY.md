# 🎉 项目更新完成：双曲线火山图通用化 + 示例输出统一

## 📅 更新日期：2026-04-18
## 🏷️ 版本：v0.3.1

---

## ✨ 核心变更

### 1. 统一为通用组学工具（v0.3.0）

```r
# ✅ 新版本 - 适用所有组学
plot_volcano_hyperbolic(data, control_pattern = "NTC")  # CRISPR
plot_volcano_hyperbolic(data, x_label = "log2(FC)")     # RNA-seq
plot_volcano_hyperbolic(data, threshold = 4)            # 单细胞
```

### 2. 统一示例输出路径（v0.3.1）

```r
# ✅ 所有示例统一输出到 examples/output/
output_dir <- "examples/output/plot_gsea"
output_dir <- "examples/output/plot_umap_density"
output_dir <- "examples/output/plot_volcano_hyperbolic"
```

---

## 🎯 支持的数据类型

| 数据类型 | 推荐threshold | X轴标签 | 示例 |
|---------|--------------|---------|------|
| **RNA-seq** | 6 | log2(Fold Change) | Bulk转录组差异分析 |
| **单细胞** | 4-5 | log2(Fold Change) | scRNA-seq差异分析 |
| **CRISPR** | 6 | Knockdown Phenotype | 基因筛选 |
| **蛋白质组** | 6 | log2(Protein Change) | 差异蛋白分析 |
| **代谢组** | 5-7 | log2(Metabolite Change) | 差异代谢物分析 |

---

## 📁 项目文件结构

### 核心文件

```
functions/
├── plot_gsea.R                        ← GSEA可视化
├── plot_umap_density.R                ← UMAP密度图
└── plot_volcano_hyperbolic.R          ← 通用火山图

examples/
├── gsea_example.R                     ← GSEA示例
├── umap_density_example.R             ← UMAP密度图示例
├── volcano_hyperbolic_example.R       ← 火山图示例（8个场景）
├── data/                              ← 测试数据
│   ├── test_data_gsea.xlsx
│   ├── test_data_volcano_hyperbolic.xlsx
│   ├── test_data_volcano_hyperbolic.csv
│   ├── test_gene_category.xlsx
│   ├── test_gene_category.csv
│   ├── pbmc3k_annotated_test.rds
│   ├── generate_volcano_hyperbolic_test_data.R
│   ├── prepare_pbmc3k_data.R
│   └── DATA_FORMAT_VOLCANO.md
└── output/                            ← 统一输出目录（v0.3.1）
    ├── plot_gsea/
    │   ├── 01_basic.pdf & .png
    │   ├── 02_custom_style.pdf & .png
    │   ├── 03_custom_genes.pdf & .png
    │   ├── 04_auto_labels.pdf & .png
    │   ├── gsea_result.rds
    │   └── batch/
    ├── plot_umap_density/
    │   ├── 01_single_celltype.pdf & .png
    │   ├── 02_multiple_celltypes.pdf & .png
    │   ├── 03_filtered_condition.pdf & .png
    │   ├── 04_custom_style.pdf & .png
    │   ├── 05_batch_*.pdf
    │   └── 06_small_clusters.pdf
    └── plot_volcano_hyperbolic/
        ├── 01_rnaseq.pdf & .png
        ├── 02_rnaseq_category.pdf & .png
        ├── 03_crispr.pdf & .png
        ├── 04_singlecell.pdf & .png
        ├── 05_proteomics.pdf & .png
        ├── 06_threshold_*.pdf & .png
        ├── 07_custom_colors.pdf & .png
        └── 08_batch_*.pdf & .png

articles/
├── 01_GSEA可视化.md
├── 02_单细胞UMAP密度图.md
├── 03_双曲线阈值火山图.md             ← 通用教程
└── README.md

EXAMPLES_UPDATE_SUMMARY.md             ← 示例输出统一说明
FINAL_UPDATE_SUMMARY.md                ← 本文件
```

### 已删除的CRISPR专用文件

```
❌ examples/crispr_volcano_example.R
❌ examples/data/README_CRISPR_DATA.md
❌ examples/data/DATA_FORMAT_QUICK_START.md
❌ articles/03_CRISPR筛选火山图.md (旧版)
❌ PROJECT_UPDATE_SUMMARY.md
❌ UPDATE_TO_UNIVERSAL_VOLCANO.md
```

---

## 🚀 快速开始

### 1. RNA-seq差异分析

```r
library(readxl)
library(dplyr)

# 加载函数
source("https://cdn.jsdelivr.net/gh/ShengXinF3/BioPlotTools@main/functions/plot_volcano_hyperbolic.R")

# 方法1：使用 DESeq2 结果（自动识别 log2FoldChange 列）
deseq2_results <- read.csv("DESeq2_results.csv")
# 数据格式：gene, log2FoldChange, pvalue, padj

plot_volcano_hyperbolic(
  data = deseq2_results,
  threshold = 6,
  x_label = "log2(Fold Change)",
  title = "RNA-seq Differential Expression",
  output_name = "examples/output/plot_volcano_hyperbolic/my_rnaseq_volcano"
)

# 方法2：手动准备数据（使用 effect_size 列名）
rnaseq_data <- deseq2_results %>%
  rename(effect_size = log2FoldChange)

plot_volcano_hyperbolic(
  data = rnaseq_data,
  threshold = 6,
  x_label = "log2(Fold Change)",
  title = "RNA-seq Differential Expression",
  output_name = "examples/output/plot_volcano_hyperbolic/my_rnaseq_volcano"
)
```

### 2. CRISPR筛选

```r
# 使用CRISPR测试数据
volcano_data <- read_excel("examples/data/test_data_volcano_hyperbolic.xlsx")
gene_category <- read_excel("examples/data/test_gene_category.xlsx")

# 绘图
plot_volcano_hyperbolic(
  data = volcano_data,
  gene_category = gene_category,
  threshold = 6,
  control_pattern = "NTC",  # 标记非靶向对照
  x_label = "Knockdown Phenotype",
  highlight_genes = "MAPT",
  show_legend = TRUE,
  output_name = "examples/output/plot_volcano_hyperbolic/my_crispr_volcano"
)
```

### 3. 单细胞差异分析

```r
# Seurat FindMarkers 结果（自动识别 avg_log2FC 列）
seurat_markers <- FindMarkers(seurat_obj, ident.1 = "CellTypeA", ident.2 = "CellTypeB")
seurat_markers$gene <- rownames(seurat_markers)
# 数据格式：gene, avg_log2FC, p_val, p_val_adj

# 重命名列以匹配函数要求
sc_data <- seurat_markers %>%
  rename(pvalue = p_val)

# 单细胞用较低阈值
plot_volcano_hyperbolic(
  data = sc_data,  # 函数会自动识别 avg_log2FC
  threshold = 4,
  x_label = "log2(Fold Change)",
  title = "Single-cell Differential Expression",
  output_name = "examples/output/plot_volcano_hyperbolic/my_sc_volcano"
)
```

---

## 📊 主要改进

### 1. 火山图通用化（v0.3.0）

```r
# ✅ 自动计算坐标轴范围
plot_volcano_hyperbolic(data)  # 自动适配数据范围
```

### 2. 灵活的对照组

```r
# CRISPR筛选
plot_volcano_hyperbolic(data, control_pattern = "NTC")

# 实验对照
plot_volcano_hyperbolic(data, control_pattern = "Control")

# 不标记对照
plot_volcano_hyperbolic(data)  # 默认NULL
```

### 3. 通用的分组名称

| 分组名称 | 适用场景 |
|---------|---------|
| Upregulated | 所有数据类型 |
| Downregulated | 所有数据类型 |
| Control | 仅当指定control_pattern |
| Not significant | 所有数据类型 |

### 4. 统一示例输出路径（v0.3.1）

**变更前：**
```r
# 不同函数输出到不同位置
plot_gsea(..., output_name = "GSEA_Plots/pathway")
plot_umap_density(..., output_name = "examples/plot_umap_density/plot")
plot_volcano_hyperbolic(..., output_name = "examples/plot_volcano_hyperbolic/plot")
```

**变更后：**
```r
# 统一输出到 examples/output/
output_dir <- "examples/output/plot_gsea"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
plot_gsea(..., output_name = file.path(output_dir, "pathway"))

output_dir <- "examples/output/plot_umap_density"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
plot_umap_density(..., output_name = file.path(output_dir, "plot"))

output_dir <- "examples/output/plot_volcano_hyperbolic"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
plot_volcano_hyperbolic(..., output_name = file.path(output_dir, "plot"))
```

**优势：**
- ✅ 结构清晰：输入数据在 `data/`，输出结果在 `output/`
- ✅ 易于管理：所有输出集中在一个目录
- ✅ 便于清理：`rm -rf examples/output/`
- ✅ 符合规范：输入输出分离
- ✅ 跨平台兼容：使用 `file.path()` 构建路径

---

## 📖 完整文档

### 核心文档

1. **通用教程**：`articles/03_双曲线阈值火山图.md`
   - 适用场景说明
   - 5种数据类型的使用示例
   - 推荐参数设置
   - 常见问题解答

2. **数据格式说明**：`examples/data/DATA_FORMAT_VOLCANO.md`
   - 通用数据格式要求
   - epsilon在不同场景下的含义
   - DESeq2、edgeR、Seurat、MAGeCK、MaxQuant数据转换

3. **示例脚本**：
   - `examples/gsea_example.R` - GSEA完整流程
   - `examples/umap_density_example.R` - UMAP密度图6个示例
   - `examples/volcano_hyperbolic_example.R` - 火山图8个场景

4. **示例输出统一说明**：`EXAMPLES_UPDATE_SUMMARY.md`
   - 新的输出目录结构
   - 路径变更对比
   - 使用方法和清理命令

---

## 💡 使用建议

### 不同数据类型的最佳实践

#### RNA-seq

```r
plot_volcano_hyperbolic(
  data = rnaseq_data,
  threshold = 6,
  x_label = "log2(Fold Change)",
  title = "Treatment vs Control"
)
```

#### 单细胞

```r
# 效应值通常较小，用较低阈值
plot_volcano_hyperbolic(
  data = sc_data,
  threshold = 4,  # 或 5
  x_label = "log2(Fold Change)",
  title = "Cell Type A vs B"
)
```

#### CRISPR

```r
plot_volcano_hyperbolic(
  data = crispr_data,
  threshold = 6,
  control_pattern = "NTC",
  x_label = "Knockdown Phenotype",
  title = "CRISPR Screen"
)
```

#### 蛋白质组

```r
plot_volcano_hyperbolic(
  data = proteomics_data,
  threshold = 6,
  x_label = "log2(Protein Abundance Change)",
  title = "Proteomics Analysis"
)
```

---

## 📈 项目进展

### 已完成的函数（v0.3.1）

1. ✅ `plot_gsea` - GSEA可视化
2. ✅ `plot_umap_density` - 单细胞UMAP密度图
3. ✅ `plot_volcano_hyperbolic` - 双曲线阈值火山图（通用版）

### 已完成的优化

- ✅ 火山图通用化（适用所有组学数据）
- ✅ 统一示例输出路径（`examples/output/`）
- ✅ 跨平台路径兼容（使用 `file.path()`）
- ✅ 自动创建输出目录
- ✅ 完善的文档体系
- ✅ 文件名统一（volcano 替代 crispr）

### 计划添加

- 传统火山图
- 表达热图
- PCA降维图
- GO/KEGG富集气泡图

---

## 🎓 设计理念

### 为什么要通用化？

1. **双曲线阈值是通用的统计方法**
   - 不应该局限于某一种数据类型
   - 适用于任何有效应值和P值的数据

2. **提高代码复用性**
   - 一个函数解决多种场景
   - 减少学习和维护成本

3. **更符合实际需求**
   - 研究者可能同时做多种组学分析
   - 统一的接口更易学习和使用

### 为什么要统一输出路径？

1. **清晰的项目结构**
   - 输入数据：`examples/data/`
   - 输出结果：`examples/output/`
   - 示例脚本：`examples/*.R`

2. **便于管理和清理**
   - 所有输出集中在一个位置
   - 一条命令清理所有输出：`rm -rf examples/output/`

3. **符合最佳实践**
   - 输入输出分离
   - 便于版本控制（.gitignore）
   - 跨平台兼容

---

## 🔗 相关链接

- **GitHub仓库**：https://github.com/ShengXinF3/BioPlotTools
- **通用教程**：`articles/03_双曲线阈值火山图.md`
- **数据格式**：`examples/data/DATA_FORMAT_VOLCANO.md`
- **示例脚本**：`examples/volcano_hyperbolic_example.R`
- **输出统一说明**：`EXAMPLES_UPDATE_SUMMARY.md`

---

## 📝 Git提交建议

```bash
git add .
git commit -m "refactor: unify example output paths and rename test data files (v0.3.1)

Changes:
- Unify all example output paths to examples/output/
- Rename test data files for consistency:
  * test_data_crispr.* → test_data_volcano.*
  * generate_crispr_test_data.R → generate_volcano_test_data.R
- Update all references to renamed files
- Update gsea_example.R to output to examples/output/plot_gsea/
- Update umap_density_example.R to output to examples/output/plot_umap_density/
- Update volcano_hyperbolic_example.R to output to examples/output/plot_volcano_hyperbolic/
- Use file.path() for cross-platform compatibility
- Auto-create output directories in all examples
- Update FINAL_UPDATE_SUMMARY.md with v0.3.1 changes
- Update EXAMPLES_UPDATE_SUMMARY.md documenting all changes
- Add examples/data/README.md with comprehensive documentation

Files renamed:
- test_data_crispr.xlsx → test_data_volcano.xlsx
- test_data_crispr.csv → test_data_volcano.csv
- generate_crispr_test_data.R → generate_volcano_test_data.R

Files removed from examples/data/:
- test_crispr_basic.pdf/png
- test_crispr_category.pdf/png

Benefits:
- Clear project structure (data/ for input, output/ for results)
- Consistent naming (volcano instead of crispr)
- Easy to manage and clean up
- Cross-platform compatible
- Follows best practices"

git push
```

---

## ✅ 总结

### 完成的工作

✨ **v0.3.0 - 火山图通用化**
- 删除所有CRISPR专用文件
- 统一使用 `plot_volcano_hyperbolic()`
- 文章编号从04改为03
- 适用于所有组学数据类型

✨ **v0.3.1 - 示例输出统一 + 文件名规范化**
- 统一所有示例输出到 `examples/output/`
- 重命名测试数据文件（volcano 替代 crispr）
- 使用 `file.path()` 确保跨平台兼容
- 自动创建输出目录
- 清晰的项目结构

📚 **完善的文档**
- 通用教程（articles/03）
- 数据格式说明
- 8个使用示例
- 输出统一说明

### 现在可以：

1. ✅ 查看通用教程：`articles/03_双曲线阈值火山图.md`
2. ✅ 运行示例脚本：
   - `Rscript examples/gsea_example.R`
   - `Rscript examples/umap_density_example.R`
   - `Rscript examples/volcano_hyperbolic_example.R`
3. ✅ 查看输出：`ls examples/output/`
4. ✅ 清理输出：`rm -rf examples/output/`
5. ✅ 提交到Git

---

**更新完成！** 🎉

现在项目结构更清晰，所有功能统一使用通用的 `plot_volcano_hyperbolic()` 函数，所有示例输出统一到 `examples/output/` 目录！
