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
- **plot_umap_density** - 单细胞UMAP密度等高线图（详见 [使用教程](articles/02_单细胞UMAP密度图.md)）

### 通用工具
- **plot_volcano_hyperbolic** - 双曲线阈值火山图（详见 [使用教程](articles/03_双曲线阈值火山图.md)）
  - 适用于：RNA-seq、CRISPR筛选、蛋白质组、代谢组等

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
├── functions/       # 绘图函数
├── examples/        # 使用示例
├── data/           # 测试数据
└── articles/       # 详细教程
```

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
