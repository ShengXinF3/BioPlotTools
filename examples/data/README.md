# 测试数据说明

本目录包含 BioPlotTools 项目的测试数据文件。

## 📁 目录结构

```
examples/data/
├── README.md                                # 本文件
├── DATA_FORMAT_VOLCANO.md                   # 火山图数据格式说明
├── test_data_gsea.xlsx                      # GSEA测试数据
├── test_data_volcano_hyperbolic.xlsx        # 火山图测试数据（Excel）
├── test_data_volcano_hyperbolic.csv         # 火山图测试数据（CSV）
├── test_gene_category.xlsx                  # 基因分类数据（Excel）
├── test_gene_category.csv                   # 基因分类数据（CSV）
├── pbmc3k_annotated_test.rds                # 单细胞测试数据（Seurat对象）
├── generate_volcano_hyperbolic_test_data.R  # 火山图数据生成脚本
└── prepare_pbmc3k_data.R                    # 单细胞数据准备脚本
```

---

## 📊 数据文件说明

### 1. GSEA 测试数据

**文件**: `test_data_gsea.xlsx`

**用途**: 测试 `plot_gsea()` 函数

**格式**:
- `gene_name`: 基因名称
- `log2(fc)`: log2倍数变化
- 其他可选列

**使用示例**:
```r
library(readxl)
gene_data <- read_excel("examples/data/test_data_gsea.xlsx")
```

---

### 2. 火山图测试数据

**文件**: 
- `test_data_volcano_hyperbolic.xlsx` / `test_data_volcano_hyperbolic.csv` - 主数据
- `test_gene_category.xlsx` / `test_gene_category.csv` - 基因分类（可选）

**用途**: 测试 `plot_volcano_hyperbolic()` 函数

**数据场景**: 模拟数据，适用于所有组学数据类型

**主数据格式** (`test_data_volcano_hyperbolic`):
| 列名 | 说明 | 必需 |
|------|------|------|
| gene | 基因名称 | ✅ |
| effect_size | 效应值 | ✅ |
| pvalue | P值 | ✅ |
| log2fc | log2倍数变化（可选） | ❌ |
| fdr | FDR校正后的P值（可选） | ❌ |

**支持的效应值列名**（函数会自动识别）:
- `effect_size` (推荐，通用)
- `log2FoldChange` (DESeq2 输出)
- `logFC` (edgeR, limma 输出)
- `avg_log2FC` (Seurat 输出)
- `log2fc` (常见简写)
- `epsilon` (旧版本)

**分类数据格式** (`test_gene_category`):
| 列名 | 说明 | 必需 |
|------|------|------|
| gene | 基因名称 | ✅ |
| category | 基因分类 | ✅ |

**注意**: 分类文件只需要基因名和分类信息，不需要效应值或P值。

**数据特点**:
- 总基因数: 474
- 对照基因: 20个
- 转录因子: 8个
- 代谢酶: 10个
- 信号转导: 8个
- 细胞周期: 8个
- 膜蛋白: 8个
- 其他基因: 400个

**使用示例**:
```r
library(readxl)

# 读取数据
volcano_data <- read_excel("examples/data/test_data_volcano_hyperbolic.xlsx")
gene_category <- read_excel("examples/data/test_gene_category.xlsx")

# 示例1：使用测试数据（包含 effect_size 列）
source("functions/plot_volcano_hyperbolic.R")
plot_volcano_hyperbolic(
  data = volcano_data,
  gene_category = gene_category,
  threshold = 6,
  control_pattern = "Control",
  x_label = "Effect Size (AU)",
  highlight_genes = "TF1"
)

# 示例2：使用 DESeq2 结果（包含 log2FoldChange 列）
deseq2_results <- read.csv("DESeq2_results.csv")
# 数据格式：gene, log2FoldChange, pvalue, padj
plot_volcano_hyperbolic(
  data = deseq2_results,  # 函数会自动识别 log2FoldChange
  threshold = 6,
  x_label = "log2(Fold Change)"
)

# 示例3：使用 Seurat FindMarkers 结果（包含 avg_log2FC 列）
seurat_markers <- FindMarkers(seurat_obj, ident.1 = "A", ident.2 = "B")
seurat_markers$gene <- rownames(seurat_markers)
# 数据格式：gene, avg_log2FC, p_val, p_val_adj
plot_volcano_hyperbolic(
  data = seurat_markers,  # 函数会自动识别 avg_log2FC
  threshold = 4,
  x_label = "log2(Fold Change)"
)
```

**生成新数据**:
```r
# 运行数据生成脚本
source("examples/data/generate_volcano_hyperbolic_test_data.R")

# 测试图将保存到: examples/output/test_data_generation/
```

---

### 3. 单细胞测试数据

**文件**: `pbmc3k_annotated_test.rds`

**用途**: 测试 `plot_umap_density()` 函数

**数据来源**: Seurat 官方 PBMC3k 数据集（经过注释和处理）

**数据特点**:
- 细胞数: ~2,700
- 基因数: ~13,000
- 细胞类型: CD4 T, CD8 T, B, NK, Monocytes, DC, Platelet等
- 包含模拟的实验条件:
  - `condition`: Treatment vs Control
  - `timepoint`: Day0, Day7, Day14
  - `genotype`: WT vs KO
  - `cell_type`: 主要细胞类型
  - `cell_subtype`: 细胞亚型

**使用示例**:
```r
# 读取数据
seu <- readRDS("examples/data/pbmc3k_annotated_test.rds")

# 绘图
source("functions/plot_umap_density.R")
plot_umap_density(
  seurat_obj = seu,
  target_group = "CD4 T",
  group_col = "cell_type",
  reduction = "umap"
)
```

**重新生成数据**:
```r
# 运行数据准备脚本（需要网络连接）
source("examples/data/prepare_pbmc3k_data.R")
```

---

## 🔧 数据生成脚本

### generate_volcano_hyperbolic_test_data.R

**功能**: 生成双曲线火山图测试数据

**生成文件**:
- `test_data_volcano_hyperbolic.xlsx` / `.csv`
- `test_gene_category.xlsx` / `.csv`
- 测试图（保存到 `examples/output/test_data_generation/`）

**运行方法**:
```r
source("examples/data/generate_volcano_hyperbolic_test_data.R")
```

**依赖包**:
- writexl
- dplyr
- ggplot2

**说明**: 虽然数据基于 CRISPR 筛选场景生成，但可用于测试所有组学数据类型

---

### prepare_pbmc3k_data.R

**功能**: 从 Seurat 官方数据集准备单细胞测试数据

**生成文件**:
- `pbmc3k_annotated_test.rds`

**运行方法**:
```r
source("examples/data/prepare_pbmc3k_data.R")
```

**依赖包**:
- Seurat
- SeuratData
- tidyverse
- ggplot2

**注意**: 需要网络连接下载数据

---

## 📖 数据格式详细说明

### 火山图通用数据格式

详见: [`DATA_FORMAT_VOLCANO.md`](DATA_FORMAT_VOLCANO.md)

支持的数据类型:
- RNA-seq 差异分析
- 单细胞差异分析
- CRISPR 筛选
- 蛋白质组学
- 代谢组学

---

## 💡 使用建议

### 快速测试

```r
# 1. GSEA
source("examples/gsea_example.R")

# 2. UMAP密度图
source("examples/umap_density_example.R")

# 3. 火山图
source("examples/volcano_hyperbolic_example.R")
```

### 使用自己的数据

1. **准备数据格式**: 参考测试数据的格式
2. **查看格式说明**: 阅读 `DATA_FORMAT_VOLCANO.md`
3. **运行示例脚本**: 修改示例脚本中的数据路径

---

## 🔗 相关链接

- **项目主页**: https://github.com/ShengXinF3/BioPlotTools
- **函数文档**: `functions/`
- **使用示例**: `examples/`
- **教程文章**: `articles/`

---

## ❓ 常见问题

### Q: 如何生成自己的测试数据？

A: 参考 `generate_crispr_test_data.R` 脚本，修改参数生成符合你需求的数据。

### Q: 测试数据可以用于发表吗？

A: 这些是模拟数据，仅用于测试和学习。发表请使用真实的实验数据。

### Q: 如何更新单细胞测试数据？

A: 运行 `source("examples/data/prepare_pbmc3k_data.R")` 重新下载和处理数据。

### Q: 数据文件太大怎么办？

A: 
- `.rds` 文件已在 `.gitignore` 中排除
- 可以使用 Git LFS 管理大文件
- 或者提供数据生成脚本而不是数据文件本身

---

**最后更新**: 2026-04-18
