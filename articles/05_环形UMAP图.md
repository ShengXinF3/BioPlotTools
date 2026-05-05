# 生信绘图工具 | 环形UMAP图

环形UMAP图，改编自 **plot1cell** 包。plot1cell 是由 Haojia Wu 和 The Humphreys Lab 开发的优秀单细胞可视化工具包，发表于 Cell Metabolism 2022，提供了多种创新的单细胞数据可视化方法。

本函数改编了其中的环形图功能，将传统UMAP转换为环形布局，支持密度等高线和多track展示，并适配了 Seurat v5。

**原 plot1cell 包**：https://github.com/TheHumphreysLab/plot1cell

## 效果展示

**基本环形图**

![环形UMAP图-基本](../examples/output/plot_adapted/05_circlize_basic.png)

**多track展示**

![环形UMAP图-多track](../examples/output/plot_adapted/05_circlize_tracks.png)

## 使用方法

三步快速开始：

### 1. 安装依赖

```r
install.packages(c('ggplot2', 'dplyr', 'circlize', 'MASS'))
```

### 2. 加载函数

```r
source("https://cdn.jsdelivr.net/gh/ShengXinF3/BioPlotTools@main/functions/plot_adapted/plot_circlize.R")
```

### 3. 绘图

```r
library(Seurat)

# 准备数据
data_plot <- prepare_circlize_data(pbmc, scale = 0.8)

# 基本环形图
plot_circlize(data_plot)

# 添加track
plot_circlize(data_plot)
add_track(data_plot, group = "condition", track_num = 2)
add_track(data_plot, group = "timepoint", track_num = 3)
```

## 参数说明

### prepare_circlize_data

| 参数          | 说明       | 默认值 |
| ------------- | ---------- | ------ |
| seu_obj       | Seurat对象 | 必需   |
| scale         | 缩放比例   | 0.8    |
| color_palette | 配色方案   | "npg"  |

支持6种科研期刊配色方案：**npg** (Nature)、**aaas** (Science)、**nejm**、**lancet**、**jama**、**jco**

### plot_circlize

| 参数              | 说明         | 默认值      |
| ----------------- | ------------ | ----------- |
| data_plot         | 准备好的数据 | 必需        |
| do.label          | 是否标注     | TRUE        |
| contour.levels    | 等高线水平   | c(0.2, 0.3) |
| pt.size           | 点大小       | 0.5         |
| bg.color          | 背景颜色     | "white"     |
| label.cex         | 标签大小     | 1.2         |
| cluster.label.cex | cluster标签  | 1.0         |

### add_track

| 参数          | 说明         | 默认值 |
| ------------- | ------------ | ------ |
| data_plot     | 准备好的数据 | 必需   |
| group         | 分组变量     | 必需   |
| track_num     | track编号    | 必需   |
| color_palette | 配色方案     | "npg"  |

## 代码获取

函数包含9个核心函数，支持完整的环形图绘制流程。

**GitHub**: https://github.com/ShengXinF3/BioPlotTools

```r
# 直接加载
source("https://cdn.jsdelivr.net/gh/ShengXinF3/BioPlotTools@main/functions/plot_adapted/plot_circlize.R")

# 或克隆仓库
git clone https://github.com/ShengXinF3/BioPlotTools.git
```

---

**分析不是跑代码，而是构建可信的证据链。**

**关注公众号【生信F3】获取更多内容。**

![ShengXinF3_QRcode](https://raw.githubusercontent.com/ShengXinF3/ShengXinF3/master/ShengXinF3_QRcode.jpg)
