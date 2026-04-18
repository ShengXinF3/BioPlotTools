# 生信绘图工具 | 单细胞UMAP密度等高线图

这是生信绘图工具系列的第二篇，今天分享单细胞数据的UMAP密度等高线图绘制函数。

在单细胞分析中，我们经常需要展示不同细胞群的空间分布。传统的UMAP散点图虽然直观，但密度信息不够明显。这个函数可以为每个细胞群绘制独立的密度等高线，让分布模式一目了然。

## 先看效果

这个函数提供了灵活的可视化方式：

### 1. 单个细胞群高亮显示

![单个cluster密度图](https://cdn.jsdelivr.net/gh/ShengXinF3/DDD@main/Pics/01_single_celltype.png)

- 目标细胞群用彩色显示，带有密度等高线
- 其他细胞群作为背景
- 适合研究某个特定细胞群的分布

### 2. 多个细胞群同时展示

![多个cluster密度图](https://cdn.jsdelivr.net/gh/ShengXinF3/DDD@main/Pics/02_multiple_celltypes.png)

- 多个细胞群在同一张图上
- 每个群有独立的颜色和等高线
- 适合比较不同细胞群的空间关系

### 3. 筛选特定条件

![筛选条件密度图](https://cdn.jsdelivr.net/gh/ShengXinF3/DDD@main/Pics/03_filtered_condition.png)

- 可以按任意metadata列筛选
- 比较不同处理条件、时间点等
- 灵活的数据子集分析

## 核心功能

### 功能1：单个细胞群密度图

突出显示某个特定细胞群的分布：

```r
# 基本用法
plot_umap_density(
  seurat_obj = seu,
  target_group = "CD4 T",
  group_col = "cell_type"
)
```

### 功能2：多个细胞群密度图

在同一张图上展示多个细胞群，每个都有独立的等高线：

```r
# 展示多个细胞类型
plot_umap_density(
  seurat_obj = seu,
  target_group = c("CD4 T", "CD8 T", "B"),
  group_col = "cell_type"
)
```

### 功能3：条件筛选比较

比较不同条件下的细胞分布：

```r
# 筛选特定分组
plot_umap_density(
  seurat_obj = seu,
  target_group = "CD4 T",
  group_col = "cell_type",
  filter_col = "condition",
  filter_value = "Treatment"
)
```

## 数据准备

### 从头准备测试数据（推荐学习）

如果你想完整复现数据准备过程，可以运行数据准备脚本：

```r
# 从GitHub获取数据准备脚本
source("https://cdn.jsdelivr.net/gh/ShengXinF3/BioPlotTools@main/examples/prepare_pbmc3k_data.R")

# 这个脚本会自动完成：
# 1. 下载PBMC3k数据集（约2600个细胞）
# 2. 质控和标准化
# 3. PCA和UMAP降维
# 4. 聚类分析（生成9个clusters）
# 5. 添加模拟的实验条件（Treatment/Control）
# 6. 保存为pbmc3k_annotated_test.rds

# 运行后会生成：
# - pbmc3k_annotated_test.rds（测试数据）
# - test_plot_functions.R（测试脚本）
```

**生成的数据包含：**
- 9种细胞类型：CD4 T, CD14 Mono, B, CD8 T, NK, FCGR3A Mono, DC, Platelet, Megakaryocyte
- 2638个细胞
- metadata列：cell_type, condition, timepoint, sample_id, genotype, group
- 完整的UMAP降维结果

## 使用流程

### 完整示例

```r
library(Seurat)
library(tidyverse)
library(ggplot2)
library(ggsci)
library(ggnewscale)

# 从GitHub加载函数
source("https://cdn.jsdelivr.net/gh/ShengXinF3/BioPlotTools@main/functions/plot_umap_density.R")

# 1. 准备数据（选择上面的任一方式）
seu <- readRDS("pbmc3k_annotated_test.rds")

# 2. 查看数据结构
print(seu)
colnames(seu@meta.data)  # 查看可用的metadata列
table(seu$cell_type)     # 查看细胞类型分布

# 3. 绘制单个细胞群密度图
p1 <- plot_umap_density(
  seurat_obj = seu,
  target_group = "CD4 T",
  group_col = "cell_type",
  reduction = "umap"
)

# 4. 绘制多个细胞群密度图
p2 <- plot_umap_density(
  seurat_obj = seu,
  target_group = c("CD4 T", "CD8 T", "B"),
  group_col = "cell_type",
  reduction = "umap"
)

# 5. 筛选特定条件
p3 <- plot_umap_density(
  seurat_obj = seu,
  target_group = "CD14 Mono",
  group_col = "cell_type",
  filter_col = "condition",
  filter_value = "Treatment",
  reduction = "umap"
)

# 6. 自定义样式
p4 <- plot_umap_density(
  seurat_obj = seu,
  target_group = c("NK", "DC"),
  group_col = "cell_type",
  reduction = "umap",
  point_size = 2.0,
  contour_linewidth = 0.8,
  contour_bins = 6,
  target_alpha = 0.5,
  background_alpha = 0.2
)

# 7. 保存图片
ggsave("umap_density.pdf", p1, width = 10, height = 8)
```

## 一些设计细节

### 智能等高线调整

函数会根据细胞数量自动调整等高线数量（bins）：

- **细胞数 < 100**：bins = 3（适合B cells等少量细胞）
- **细胞数 < 500**：bins = 5（适合T cells等中等数量）
- **细胞数 ≥ 500**：bins = 8（适合Fibroblasts等大量细胞）

你也可以手动指定bins数量：

```r
plot_umap_density(
  seu, "CD4 T",
  group_col = "cell_type",
  contour_bins = 10  # 强制使用10条等高线
)
```

### 多群独立等高线

当指定多个target_group时，每个群都有：
- 独立的颜色（自动从ggsci D3配色方案选择）
- 独立的等高线（颜色与细胞点一致）
- 独立的bins调整（根据各自细胞数量）

```r
# 每个细胞类型都有自己的颜色和等高线
plot_umap_density(
  seu,
  target_group = c("CD4 T", "CD8 T", "B"),
  group_col = "cell_type"
)
```

## 参数说明

### plot_umap_density() 完整参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| seurat_obj | Seurat对象 | 必需 |
| target_group | 目标细胞群名称（可以是向量） | 必需 |
| group_col | 细胞分组列名 | "cell_type" |
| filter_col | 筛选条件列名 | NULL |
| filter_value | 筛选条件值 | NULL |
| reduction | 降维方法名称 | "umap" |
| dim_names | 降维坐标列名（长度为2的向量） | NULL（自动提取） |
| background_colors | 背景细胞亚群配色 | NULL（自动） |
| target_color | 目标亚群颜色（单个群时） | "#B1B4D4" |
| background_alpha | 背景细胞透明度 | 0.3 |
| target_alpha | 目标细胞透明度 | 0.3 |
| point_size | 细胞点大小 | 1.5 |
| contour_colors | 等高线配色 | NULL（灰色渐变） |
| contour_linewidth | 等高线宽度 | 0.5 |
| contour_bins | 等高线数量 | NULL（自动调整） |
| title | 图表标题 | NULL（自动生成） |
| expand_limits | 坐标轴扩展比例 | 0.1 |
| show_legend | 是否显示图例 | TRUE |
| legend_position | 图例位置 | "right" |

## 常见问题

### Q1: 等高线不显示怎么办？

**原因**：细胞数量太少，默认bins可能无法生成等高线。

**解决方案**：
```r
# 方案1：手动指定更少的bins
plot_umap_density(
  seu, "B cells",  # 假设B cells只有57个
  group_col = "celltype",
  contour_bins = 3  # 使用3条等高线
)

# 方案2：增加等高线粗细
plot_umap_density(
  seu, "B cells",
  group_col = "celltype",
  contour_linewidth = 1.5,  # 更粗的线
  contour_bins = 3
)
```

### Q2: 如何自定义配色？

```r
# 方案1：自定义背景群颜色
custom_colors <- c(
  "Type1" = "#FF6B6B",
  "Type2" = "#4ECDC4",
  "Type3" = "#45B7D1"
)

plot_umap_density(
  seu, "Type1",
  group_col = "celltype",
  background_colors = custom_colors
)

# 方案2：只改变目标群颜色（单个群时）
plot_umap_density(
  seu, "Fibroblasts",
  group_col = "celltype",
  target_color = "#FFA07A"
)
```

### Q3: 多个target_group时如何控制bins？

```r
# 所有群使用相同的bins
plot_umap_density(
  seu,
  target_group = c("T cells", "B cells", "NK cells"),
  group_col = "celltype",
  contour_bins = 5  # 所有群都用5条等高线
)

# 让函数自动调整（推荐）
# 每个群根据自己的细胞数量自动选择合适的bins
plot_umap_density(
  seu,
  target_group = c("Fibroblasts", "T cells", "B cells"),
  group_col = "celltype"
  # 不指定contour_bins，自动调整
)
```

## 代码获取

**GitHub仓库：** https://github.com/ShengXinF3/BioPlotTools

1. **直接从GitHub加载（最简单）**
```r
source("https://cdn.jsdelivr.net/gh/ShengXinF3/BioPlotTools@main/functions/plot_umap_density.R")
```

2. **克隆整个仓库**
```bash
git clone https://github.com/ShengXinF3/BioPlotTools.git
cd BioPlotTools
```

3. **查看完整示例**
```r
# 仓库中的examples/umap_density_example.R包含了所有使用示例
source("examples/umap_density_example.R")
```

## 总结

这个函数的优点：

- **灵活的可视化**：支持单个或多个细胞群，每个都有独立等高线
- **智能bins调整**：根据细胞数量自动优化等高线数量
- **高度可定制**：支持任意metadata列筛选和样式调整
- **自动配色**：使用ggsci D3配色方案，支持10-20+个细胞群
- **出版级质量**：矢量图输出，所有参数可调
- **易于使用**：一行代码即可生成复杂图表
- **完整文档**：详细的参数说明和使用示例

---

**分析不是跑代码，而是构建可信的证据链。**

**扫码关注微信公众号【生信F3】获取文章完整内容，分享生物信息学最新知识。**

![ShengXinF3_QRcode](https://raw.githubusercontent.com/ShengXinF3/ShengXinF3/master/ShengXinF3_QRcode.jpg)
