# 生信绘图工具 | GSEA富集分析可视化

这是生信绘图工具系列的第一篇，主要整理一些日常分析中常用的绘图函数，方便自己用，也分享给有需要的人。

今天分享的是GSEA富集分析的可视化函数。clusterProfiler的gseaplot2()比较基础，想要更好的效果需要自己调整。这个函数可以自动标注关键基因，生成出版级的三面板图表。

代码已上传GitHub：https://github.com/ShengXinF3/BioPlotTools

## 先看效果

这个函数生成的图包含三个部分：

![GSEA示例图](../examples/Output_Plots/GSEA_All_Pathways/KEGG_OXIDATIVE_PHOSPHORYLATION.png)

- 上面是ES曲线，会自动标注通路中的关键基因
- 中间是条形码图，叠加了表达量的热图
- 下面是排序列表，显示所有基因的log2FC分布

NES、P值、校正P值这些统计信息会自动显示在图上。

## 主要功能

### 自动选择基因标注

函数会在通路基因中均匀选择几个进行标注，避免标签挤在一起：

```r
# 默认标注8个基因
plot_gsea(gsea_result, "KEGG_OXIDATIVE_PHOSPHORYLATION")

# 标注更多基因(随机)
plot_gsea(gsea_result, "KEGG_WNT_SIGNALING_PATHWAY", n_genes = 12)
```

也可以指定想要标注的基因：

```r
plot_gsea(gsea_result, "KEGG_CALCIUM_SIGNALING_PATHWAY",
         custom_genes = c("Calm1", "Camk2a", "Prkca", "Itpr1"))
```

### 参数可调

颜色、字号、图片尺寸这些都可以调整：

```r
# 调整颜色
plot_gsea(gsea_result, pathway_id,
         curve_color = "#FF6347",    # ES曲线
         vline_color = "#DC143C",    # 标注线
         pos_color = "#FFB6C1",      # 正向区域
         neg_color = "#87CEEB")      # 负向区域

# 调整尺寸
plot_gsea(gsea_result, pathway_id,
         base_size = 18,             # 基础字号
         plot_width = 14,            # 图宽
         plot_height = 10)           # 图高

# 调整面板比例
plot_gsea(gsea_result, pathway_id,
         panel_heights = c(4, 0.5, 1.5))  # 三个面板的高度比
```

### 批量绘图

如果有很多显著通路需要画图，可以用循环：

```r
sig_pathways <- gsea_result@result[gsea_result@result$p.adjust < 0.05, ]

for (i in 1:nrow(sig_pathways)) {
  pathway_id <- sig_pathways$ID[i]
  plot_gsea(gsea_result, pathway_id, 
           output_name = paste0("Output/", pathway_id))
}
```

### 输出格式

每次运行会同时生成PDF和PNG两种格式，PDF是矢量图适合投稿，PNG适合做PPT。

## 使用流程

### 从GitHub直接加载

```r
library(readxl)
library(dplyr)
library(clusterProfiler)
library(msigdbr)

# 从GitHub加载函数
#  使用 jsdelivr CDN（推荐，国内访问快）
source("https://cdn.jsdelivr.net/gh/ShengXinF3/BioPlotTools@main/functions/plot_gsea.R")


# 1. 加载差异表达数据
# 方式1：直接从GitHub加载测试数据（最简单）
url <- "https://github.com/ShengXinF3/BioPlotTools/raw/main/data/test_data_gsea.xlsx"
temp_file <- tempfile(fileext = ".xlsx")
download.file(url, temp_file, mode = "wb")
gene_data <- read_excel(temp_file, na = "---")

# 方式2：用你自己的数据
# 数据格式要求：至少包含两列
#   - 基因名列（gene_name、gene_symbol等）
#   - log2FC列（log2(fc)、log2FoldChange等）
# 示例：
#   gene_name    log2(fc)    pvalue
#   Ndufa1       2.5         0.001
#   Cox5a        1.8         0.005
#   ...
# gene_data <- read_excel("your_data.xlsx")
# gene_data <- read.csv("your_data.csv")

# 2. 准备基因列表（按log2FC排序）
# 处理重复基因，取平均值
genelist_df <- aggregate(gene_data$`log2(fc)`, 
                        by = list(gene_name = gene_data$gene_name), 
                        FUN = mean)
genelist <- setNames(genelist_df$x, genelist_df$gene_name)
genelist <- sort(genelist, decreasing = TRUE)

# 查看基因列表
head(genelist)  # 上调基因
tail(genelist)  # 下调基因

# 3. 获取KEGG基因集
m_df <- msigdbr(species = "Mus musculus")  # 小鼠
# m_df <- msigdbr(species = "Homo sapiens")  # 人类
kegg_sets <- m_df[m_df$gs_subcollection == 'CP:KEGG_LEGACY', ]
term2gene <- data.frame(term = kegg_sets$gs_name, 
                       gene = kegg_sets$gene_symbol)

# 4. 运行GSEA
gsea_result <- GSEA(genelist, TERM2GENE = term2gene, 
                   pvalueCutoff = 1, verbose = TRUE)

# 查看结果
head(gsea_result@result)

# 5. 绘图 - 基础用法
plot_gsea(gsea_result, "KEGG_OXIDATIVE_PHOSPHORYLATION")

# 6. 绘图 - 自定义参数
plot_gsea(gsea_result, "KEGG_OXIDATIVE_PHOSPHORYLATION",
         n_genes = 10,
         curve_color = "#9370DB",
         base_size = 16,
         plot_width = 14,
         output_name = "Output/OxPhos")
```

一些设计细节

标注的基因在ES曲线和条形码图中都用红色标出，这样能一眼看出这些基因在通路中的位置。

基因标签采用交错排列，用箭头指向对应的位置，不会产生歧义。

条形码面板不只是简单的黑线，背景还叠加了表达量的渐变色，信息更丰富。

## 参数说明

主要参数：

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

## 代码获取

**GitHub仓库：** https://github.com/ShengXinF3/BioPlotTools

1. **直接从GitHub加载（最简单）**
```r
source("https://cdn.jsdelivr.net/gh/ShengXinF3/BioPlotTools@main/functions/plot_gsea.R")
```

2. **克隆整个仓库**
```bash
git clone https://github.com/ShengXinF3/BioPlotTools.git
```

## 总结

这个函数的优点：

- 一行代码就能生成复杂的图表
- 图片质量达到出版要求
- 参数丰富，可以灵活调整
- 自动标注基因，省去手动调整的麻烦
- 支持批量处理

对于经常做GSEA分析的人来说，这个函数能节省不少时间。

---

**分析不是跑代码，而是构建可信的证据链。**

**扫码关注微信公众号【生信F3】获取文章完整内容，分享生物信息学最新知识。**

![ShengXinF3_QRcode](https://raw.githubusercontent.com/ShengXinF3/ShengXinF3/master/ShengXinF3_QRcode.jpg)