# BioPlotTools

生信数据可视化函数集合，主要整理日常分析中常用的绘图代码，方便自己用，也分享给有需要的人。

## 项目说明

这个项目会持续更新，逐步添加各种组学数据的可视化函数。目前包含转录组学相关的绘图工具，后续会扩展到基因组学、蛋白质组学、代谢组学等方向。

所有函数都可以直接从GitHub加载使用，不需要安装。

## 已有函数

### plot_gsea() - GSEA富集分析可视化

生成三面板的GSEA图：ES曲线（带基因标注）、条形码图（带表达量热图）、排序列表。

主要特点：
- 自动选择关键基因进行标注
- 支持自定义基因列表
- 30多个参数可调整
- 同时输出PDF和PNG

**使用方法：**

```r
library(clusterProfiler)
library(msigdbr)

# 从GitHub加载函数
source("https://raw.githubusercontent.com/ShengXinF3/BioPlotTools/main/functions/plot_gsea.R")

# 准备数据
genelist <- setNames(gene_data$log2fc, gene_data$gene_name)
genelist <- sort(genelist, decreasing = TRUE)

# 获取基因集
m_df <- msigdbr(species = "Mus musculus")
kegg_sets <- m_df[m_df$gs_subcollection == 'CP:KEGG_LEGACY', ]
term2gene <- data.frame(term = kegg_sets$gs_name, gene = kegg_sets$gene_symbol)

# 运行GSEA
gsea_result <- GSEA(genelist, TERM2GENE = term2gene, pvalueCutoff = 1)

# 绘图
plot_gsea(gsea_result, "KEGG_OXIDATIVE_PHOSPHORYLATION")
```

**参数说明：**

| 参数 | 说明 | 默认值 |
|------|------|--------|
| gsea_object | GSEA结果对象或rds文件路径 | - |
| pathway_id | 通路ID | - |
| n_genes | 标注基因数量 | 8 |
| custom_genes | 自定义基因列表 | NULL |
| curve_color | ES曲线颜色 | #9370DB |
| vline_color | 标注线颜色 | #DC143C |
| base_size | 基础字号 | 15 |
| plot_width | 图宽（英寸） | 12 |
| plot_height | 图高（英寸） | 9 |
| dpi | PNG分辨率 | 300 |
| output_name | 输出文件名 | pathway_id |

完整参数列表见函数文档。

## 计划添加的函数

### 转录组学
- [ ] plot_volcano - 火山图
- [ ] plot_heatmap - 表达热图
- [ ] plot_pca - PCA降维图
- [ ] plot_go_bubble - GO富集气泡图
- [ ] plot_kegg_bubble - KEGG富集气泡图

### 基因组学
- [ ] plot_manhattan - 曼哈顿图
- [ ] plot_qq - QQ图
- [ ] plot_ld - LD热图

### 蛋白质组学
- [ ] plot_protein_heatmap - 蛋白表达热图
- [ ] plot_protein_network - 蛋白互作网络

### 代谢组学
- [ ] plot_metabolite_pathway - 代谢通路图
- [ ] plot_metabolite_network - 代谢物网络

### 通用工具
- [ ] plot_venn - 韦恩图
- [ ] plot_upset - UpSet图
- [ ] plot_boxplot - 箱线图/小提琴图
- [ ] plot_correlation - 相关性热图

## 目录结构

```
BioPlotTools/
├── functions/       # 绘图函数
├── examples/        # 使用示例
├── data/           # 测试数据
├── articles/       # 公众号推文
├── templates/      # 函数和文章模板
├── README.md
├── CONTRIBUTING.md # 贡献指南
├── CHANGELOG.md    # 更新日志
└── LICENSE
```

## 使用示例

每个函数都有对应的示例脚本，在 `examples/` 目录中：

- `gsea_example.R` - GSEA完整分析流程
- `quick_start.R` - 快速开始指南

## 测试数据

`data/` 目录提供了测试数据：

- `test_gene_data.xlsx` - 差异表达数据
- `test_gsea_result.rds` - GSEA结果

可以用这些数据快速测试函数。

## 公众号推文

`articles/` 目录包含每个函数的详细使用教程：

- [GSEA富集分析可视化](articles/01_GSEA可视化.md)

后续会持续更新。

## 依赖包

核心依赖：
- ggplot2 - 绘图
- dplyr - 数据处理
- patchwork - 图形拼接

特定函数的额外依赖会在函数文档中说明。

## 如何使用

### 方法一：直接加载（推荐）

```r
source("https://raw.githubusercontent.com/ShengXinF3/BioPlotTools/main/functions/plot_xxx.R")
```

### 方法二：克隆仓库

```bash
git clone https://github.com/ShengXinF3/BioPlotTools.git
```

### 方法三：下载单个文件

访问仓库页面，下载需要的文件。

## 贡献

欢迎提交问题和建议。如果想贡献代码，请参考 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 开发规范

- 函数命名：`plot_<分析类型>_<图表类型>.R`
- 参数标准化：颜色、字体、尺寸参数统一
- 输出格式：默认同时生成PDF和PNG
- 文档完整：函数注释、使用示例、测试数据

详见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 更新日志

查看 [CHANGELOG.md](CHANGELOG.md) 了解版本更新历史。

## 许可证

MIT License

## 引用

如果在研究中使用了这些函数，可以引用：

```
ShengXinF3. (2026). BioPlotTools: 生信数据可视化函数集合. 
GitHub: https://github.com/ShengXinF3/BioPlotTools
```

## 联系方式

- GitHub Issues: https://github.com/ShengXinF3/BioPlotTools/issues
- 公众号文章：见 articles/ 目录

## 关注公众号

**分析不是跑代码，而是构建可信的证据链。**

**扫码关注微信公众号【生信F3】获取文章完整内容，分享生物信息学最新知识。**

![ShengXinF3_QRcode](https://raw.githubusercontent.com/ShengXinF3/ShengXinF3/master/ShengXinF3_QRcode.jpg)

## 项目状态

当前版本：v0.1.0

这是一个持续更新的项目，会根据实际需求逐步添加新功能。
