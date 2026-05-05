# BioPlotTools

生信绘图函数集合，整理日常分析中常用的可视化代码。

## 简介

做生信分析时，经常需要画各种图。这个项目把常用的绘图代码整理成函数，方便直接调用。

目前主要是转录组相关的图，后面会慢慢加入基因组、蛋白组、代谢组等其他方向的内容。

## 快速开始

所有函数都可以直接从 GitHub 加载使用：

```r
# 加载函数（推荐使用 jsdelivr CDN，国内访问快）
source("https://cdn.jsdelivr.net/gh/ShengXinF3/BioPlotTools@main/functions/plot_gsea.R")

# 使用函数
plot_gsea(gsea_result, "KEGG_OXIDATIVE_PHOSPHORYLATION")
```

## 已有函数

### 转录组学
- **plot_gsea** - GSEA 可视化（详见 [使用教程](articles/01_GSEA可视化.md)）

### 单细胞分析

#### 原创函数
- **plot_umap_density** - 单细胞UMAP密度等高线图（详见 [使用教程](articles/02_单细胞UMAP密度图.md)）

#### 改编函数（来自 plot1cell）
- **plot_cell_fraction** - 细胞比例图 ✅
  - 展示不同条件下细胞类型的比例变化
  - 支持显示生物学重复
  - 原作者: Haojia Wu (plot1cell)
  
- **plot_complex_dotplot** - 复杂点图 ✅
  - 单基因和多基因点图
  - 点大小=表达比例，颜色=表达量
  - 支持跨组对比和分面展示
  - 原作者: Haojia Wu (plot1cell)
  
- **plot_complex_upset** - Upset图 ✅
  - DEG交集和并集分析
  - 比韦恩图更清晰，支持多组
  - 原作者: Haojia Wu (plot1cell)
  
- **plot_complex_heatmap** - 组特异性热图 ✅
  - 自动识别组特异性基因
  - ComplexHeatmap展示
  - 原作者: Haojia Wu (plot1cell)
  
- **plot_circlize** - 环形UMAP图 ✅
  - 环形布局的UMAP/tSNE图
  - 密度等高线 + 多track展示
  - 包含9个函数的完整功能集
  - 原作者: Haojia Wu (plot1cell)
  - 灵感来源: Linnarsson Lab, Nature 2018

> 改编函数已适配 Seurat v5，保留原作者归属信息。详见 [ATTRIBUTION.md](ATTRIBUTION.md)

### 通用工具
- **plot_volcano_hyperbolic** - 双曲线阈值火山图（详见 [使用教程](articles/03_双曲线阈值火山图.md)）
  - 适用于：RNA-seq、CRISPR筛选、蛋白质组、代谢组等
- **plot_combined_enrichment** - 富集分析组合图（详见 [使用教程](articles/04_富集分析组合图.md)）
  - 整合多个富集分析结果（GO BP/CC/MF, KEGG等）到一张图中展示

## 计划添加

**转录组**
- 传统火山图、热图、PCA 图
- GO/KEGG 富集气泡图

**基因组**
- 曼哈顿图、QQ 图、LD 热图

**蛋白组/代谢组**
- 表达热图、网络图、通路图

**通用工具**
- 韦恩图、UpSet 图、箱线图、相关性热图

## 目录说明

```
BioPlotTools/
├── functions/
│   ├── plot_custom/      # 原创函数
│   └── plot_adapted/     # 改编函数（来自 plot1cell）
├── examples/             # 使用示例
├── data/                # 测试数据
├── articles/            # 详细教程
└── ATTRIBUTION.md       # 函数归属说明
```

### 函数分类

本项目包含两类函数：

1. **原创函数** (`functions/plot_custom/`)
   - 本项目原创开发
   - 完全自主设计和实现
   - 许可: MIT License

2. **改编函数** (`functions/plot_adapted/`)
   - 改编自 [plot1cell](https://github.com/TheHumphreysLab/plot1cell) 包
   - 已适配 Seurat v5
   - 保留原作者归属信息
   - 许可: MIT License (与原始 plot1cell 保持一致)

详细归属信息请查看 [ATTRIBUTION.md](ATTRIBUTION.md)。

## 使用方式

**方法 1：直接加载（推荐）**
```r
source("https://raw.githubusercontent.com/ShengXinF3/BioPlotTools/main/functions/plot_xxx.R")
```

**方法 2：克隆仓库**
```bash
git clone https://github.com/ShengXinF3/BioPlotTools.git
```

## 依赖包

主要依赖：ggplot2、dplyr、patchwork

具体函数的额外依赖会在函数文档中说明。

## 贡献

欢迎提 issue 和 PR，详见 [CONTRIBUTING.md](CONTRIBUTING.md)

## 更新日志

查看 [CHANGELOG.md](CHANGELOG.md)

## 许可证

MIT License

**分析不是跑代码，而是构建可信的证据链。**

![ShengXinF3_QRcode](https://raw.githubusercontent.com/ShengXinF3/ShengXinF3/master/ShengXinF3_QRcode.jpg)
