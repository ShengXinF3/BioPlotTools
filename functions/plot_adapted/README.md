# plot1cell 改编函数集 (Seurat v5 Compatible)

本目录包含改编自 [plot1cell](https://github.com/TheHumphreysLab/plot1cell) 包的单细胞可视化函数，已适配 Seurat v5。

## 📚 关于 plot1cell

**plot1cell** 是由 **Haojia Wu** 和 **The Humphreys Lab** 开发的优秀单细胞可视化工具包。

- **原始仓库**: https://github.com/TheHumphreysLab/plot1cell
- **原始论文**: Wu H, et al. (2022). Cell Metabolism, 34(7), 1064-1078.e6.
- **原始许可**: MIT License

## ⚠️ 为什么需要改编？

plot1cell 开发于 Seurat v4 时期，使用的数据访问方法在 Seurat v5 中已不兼容。本项目将其核心功能改编为 Seurat v5 兼容版本。

## ✅ 改编内容

- ✅ **Seurat v5 兼容性**：更新数据访问方法（`slot=` → `layer=`）
- ✅ **保留核心算法**：完整保留原始算法和可视化样式
- ✅ **完整归属信息**：清晰标注原作者和来源
- ✅ **中文文档**：提供完整的中英文双语文档
- ✅ **增强功能**：改进的参数验证和错误处理

**改编日期**: 2026-05-04  
**改编版本**: v1.0.0 (Seurat v5 compatible)  
**许可**: MIT License (与原始 plot1cell 保持一致)

---

## 📦 包含的函数

### 1. plot_cell_fraction.R
**细胞比例图**

展示不同条件下细胞类型的比例变化，支持显示生物学重复。

```r
plot_cell_fraction(
  seu_obj = pbmc,
  celltypes = c("CD4 T", "CD8 T", "B", "NK"),
  groupby = "condition",
  show_replicate = TRUE,
  rep_colname = "sample_id"
)
```

**适用场景**:
- 比较病例 vs 对照的细胞组成
- 展示治疗前后的细胞比例变化
- 时间序列中的细胞动态

---

### 2. plot_complex_dotplot.R
**复杂点图**

展示基因表达模式，点大小=表达比例，颜色=表达量。

包含2个主函数：
- `complex_dotplot_single()` - 单基因点图
- `complex_dotplot_multiple()` - 多基因点图

```r
# 单基因
complex_dotplot_single(
  seu_obj = pbmc,
  feature = "CD3D",
  groups = "condition"
)

# 多基因
complex_dotplot_multiple(
  seu_obj = pbmc,
  features = c("CD3D", "CD4", "CD8A"),
  groups = "treatment"
)
```

**适用场景**:
- Marker基因表达验证
- 跨条件的基因表达对比
- 文章Figure中的基因表达图

---

### 3. plot_complex_upset.R
**Upset图**

展示DEG的交集和并集，比韦恩图更清晰，支持多组对比。

```r
complex_upset_plot(
  seu_obj = pbmc,
  celltype = "CD4 T",
  group = "condition",
  logfc = 0.5
)
```

**适用场景**:
- 多条件DEG对比
- 识别共享和特异性基因
- 替代传统韦恩图（特别是3组以上）

---

### 4. plot_complex_heatmap.R
**组特异性基因热图**

自动识别并展示每组的特异性高表达/低表达基因。

```r
complex_heatmap_unique(
  seu_obj = pbmc,
  celltype = "CD4 T",
  group = "condition",
  gene_highlight = c("CD3D", "CD8A", "GZMB")
)
```

**适用场景**:
- 识别组特异性基因
- 展示不同条件下的基因变化
- 补充DEG分析结果

---

### 5. plot_circlize.R
**环形UMAP图**

将UMAP转换为环形布局，添加密度等高线和多track展示。

包含9个函数的完整功能集：
- `prepare_circlize_data()` - 准备数据
- `plot_circlize()` - 绘制环形图
- `add_track()` - 添加track
- 以及6个辅助函数

```r
# 准备数据
data_plot <- prepare_circlize_data(pbmc, scale = 0.8)

# 绘制基础图
plot_circlize(data_plot)

# 添加额外track
add_track(data_plot, group = "condition", track_num = 2)
add_track(data_plot, group = "timepoint", track_num = 3)
```

**适用场景**:
- 文章首图（非常吸引眼球）
- 展示复杂的多条件数据
- 多时间点单细胞数据

**灵感来源**: Linnarsson Lab, Nature 2018

---

## 🚀 快速开始

### 1. 安装依赖

```r
# 基础包
install.packages(c('ggplot2', 'dplyr', 'tidyr', 'scales'))

# 特定功能依赖
install.packages(c('RColorBrewer', 'ggbeeswarm'))  # plot_cell_fraction
install.packages(c('circlize', 'MASS'))            # plot_circlize
install.packages('purrr')                          # plot_complex_upset

# Bioconductor包
BiocManager::install('ComplexHeatmap')             # plot_complex_heatmap

# GitHub包
devtools::install_github('krassowski/complex-upset')  # plot_complex_upset
```

### 2. 加载函数

```r
# 从GitHub直接加载（推荐）
source("https://cdn.jsdelivr.net/gh/ShengXinF3/BioPlotTools@main/functions/plot_adapted/plot_cell_fraction.R")

# 或克隆仓库后加载
source("functions/plot_adapted/plot_cell_fraction.R")
```

### 3. 使用函数

```r
library(Seurat)

# 确保你的Seurat对象：
# 1. 已完成降维（UMAP/tSNE）
# 2. 已完成细胞类型注释
# 3. 包含分组信息（在meta.data中）

# 开始绘图
plot_cell_fraction(pbmc, groupby = "condition")
```

---

## 📖 详细文档

每个函数都包含完整的Roxygen2文档，包括：
- 详细的参数说明
- 使用示例
- 原作者归属信息
- 改编说明

查看函数文档：
```r
?plot_cell_fraction
?complex_dotplot_single
?complex_upset_plot
?complex_heatmap_unique
?plot_circlize
```

---

## 🙏 归属说明

### 原作者

所有函数均改编自 **plot1cell** 包：

- **原作者**: Haojia Wu (The Humphreys Lab)
- **原始仓库**: https://github.com/TheHumphreysLab/plot1cell
- **原始论文**: Wu H, et al. (2022). Cell Metabolism, 34(7), 1064-1078.e6.
- **原始许可**: MIT License

### 改编说明

每个函数文件都包含三层归属标注：

1. **文件头部**：完整的原作者信息和改编说明
2. **函数内部**：归属声明注释
3. **核心算法**：标注来源的代码段

### 引用指南

如果您在研究中使用了这些函数，请引用：

1. **原始 plot1cell 论文**（必须）:
```
Wu H, et al. (2022). Mapping the single-cell transcriptomic response 
of murine diabetic kidney disease to therapies. 
Cell Metabolism, 34(7), 1064-1078.e6.
```

2. **本项目**（可选）:
```
BioPlotTools: Seurat v5 adapted functions from plot1cell. 
GitHub: https://github.com/ShengXinF3/BioPlotTools
```

---

## 📋 功能对比

| 特性 | 原始plot1cell | 改编版本 |
|------|--------------|---------|
| Seurat版本 | v4 | v5.5.0 ✅ |
| 数据访问 | `slot=` | `layer=` ✅ |
| 文档语言 | 英文 | 中英双语 ✅ |
| 错误提示 | 英文 | 中英双语 ✅ |
| 参数验证 | 基础 | 增强 ✅ |
| 核心算法 | 原始 | 保留 ✅ |
| 归属信息 | - | 完整 ✅ |

---

## ❓ 常见问题

### Q: 为什么不直接用原版plot1cell？

**A**: 原版plot1cell使用Seurat v4的API，在Seurat v5中会报错。改编版本使用Seurat v5的现代化API，确保完全兼容。

### Q: 改编版本和原版有什么区别？

**A**: 
- **兼容性**：Seurat v5 vs v4
- **文档**：中英双语 vs 纯英文
- **错误处理**：增强 vs 基础
- **核心算法**：完全保留，无变化

### Q: 可以用于发表吗？

**A**: 可以！但请务必引用原始plot1cell论文。改编版本只是提供了Seurat v5兼容性。

### Q: 如何报告问题？

**A**: 
- 原始算法问题 → plot1cell原始仓库
- Seurat v5兼容性问题 → 本项目仓库

---

## 🔗 相关链接

- **本项目仓库**: https://github.com/ShengXinF3/BioPlotTools
- **plot1cell原始仓库**: https://github.com/TheHumphreysLab/plot1cell
- **plot1cell开发仓库**: https://github.com/HaojiaWu/plot1cell
- **Seurat官方网站**: https://satijalab.org/seurat/
- **完整教程**: [articles/05_plot1cell改编函数集.md](../../articles/05_plot1cell改编函数集.md)

---

## 📝 更新日志

### v1.0.0 (2026-05-04)
- ✅ 完成所有5个功能的改编
- ✅ Seurat v5 完全兼容
- ✅ 完整的归属标注
- ✅ 中英文双语文档

---

**许可**: MIT License (与原始 plot1cell 保持一致)  
**最后更新**: 2026-05-04
