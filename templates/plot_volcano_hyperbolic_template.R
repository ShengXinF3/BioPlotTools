# ========== 双曲线阈值火山图绘制模板 ==========
# 
# 使用说明：
# 1. 修改"数据准备"部分，加载你自己的数据
# 2. 根据需要选择使用哪个示例（取消注释）
# 3. 调整参数以适应你的数据
# 4. 运行脚本生成火山图

# ============================================================================
# 加载必要的包
# ============================================================================

library(ggplot2)
library(dplyr)
library(readxl)  # 如果读取Excel文件

# ============================================================================
# 加载函数
# ============================================================================

# 方法1：从GitHub加载（推荐，始终使用最新版本）
source("https://cdn.jsdelivr.net/gh/ShengXinF3/BioPlotTools@main/functions/plot_volcano_hyperbolic.R")

# 方法2：本地加载（如果已克隆仓库）
# source("functions/plot_volcano_hyperbolic.R")

# ============================================================================
# 数据准备
# ============================================================================

# 【重要】修改这部分以加载你自己的数据
# 
# 数据要求：
# - 必需列：gene (基因名), pvalue (P值)
# - 效应值列（以下任一）：effect_size, log2FoldChange, logFC, avg_log2FC
# 
# 示例数据格式：
#   gene          log2FoldChange    pvalue
#   TP53          3.5               0.001
#   MYC           -2.8              0.005
#   GAPDH         0.2               0.5

# 读取你的差异分析结果
# 根据你的数据格式选择合适的读取方式：

# CSV文件
# my_data <- read.csv("your_data.csv")

# Excel文件
# my_data <- read_excel("your_data.xlsx")

# DESeq2结果（直接使用，无需重命名列）
# my_data <- read.csv("DESeq2_results.csv")
# 列名：gene, log2FoldChange, pvalue, padj

# edgeR结果（只需重命名pvalue列）
# my_data <- read.csv("edgeR_results.csv")
# my_data <- rename(my_data, pvalue = PValue)
# 列名：gene, logFC, pvalue, FDR

# Seurat结果（只需重命名pvalue列）
# markers <- FindMarkers(seurat_obj, ident.1 = "A", ident.2 = "B")
# my_data <- markers %>%
#   rownames_to_column("gene") %>%
#   rename(pvalue = p_val)
# 列名：gene, avg_log2FC, pvalue, p_val_adj

# 【可选】基因分类数据
# 如果你想给特定基因添加分类标签，准备一个包含两列的数据框：
# - gene: 基因名
# - category: 分类名称
# 
# 示例：
# my_gene_category <- data.frame(
#   gene = c("TP53", "MYC", "BRCA1"),
#   category = c("Tumor suppressor", "Oncogene", "Tumor suppressor")
# )

# ============================================================================
# 设置输出路径
# ============================================================================

# 修改为你想要保存图片的位置
output_dir <- "output"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# ============================================================================
# 示例1：基础用法（最简单）
# ============================================================================

# 适用场景：快速查看差异分析结果
# 
# 使用方法：
# 1. 取消下面代码的注释
# 2. 将 my_data 替换为你的数据变量名
# 3. 根据数据类型调整 threshold 和 x_label

# p1 <- plot_volcano_hyperbolic(
#   data = my_data,
#   threshold = 6,  # RNA-seq/蛋白质组: 6; 单细胞: 4-5
#   x_label = "log2(Fold Change)",  # 根据你的数据调整
#   title = "My Differential Analysis",  # 修改为你的标题
#   output_name = file.path(output_dir, "volcano_basic")
# )
# 
# print(p1)
# cat("✓ 已保存: volcano_basic.pdf & .png\n")

# ============================================================================
# 示例2：添加基因分类（推荐）
# ============================================================================

# 适用场景：想要突出显示特定功能类别的基因
# 
# 使用方法：
# 1. 准备基因分类数据（见上面"数据准备"部分）
# 2. 取消下面代码的注释
# 3. 替换变量名和参数

# p2 <- plot_volcano_hyperbolic(
#   data = my_data,
#   gene_category = my_gene_category,  # 你的基因分类数据
#   threshold = 6,
#   x_label = "log2(Fold Change)",
#   show_legend = TRUE,  # 显示图例
#   title = "Differential Analysis with Gene Categories",
#   output_name = file.path(output_dir, "volcano_with_category")
# )
# 
# print(p2)
# cat("✓ 已保存: volcano_with_category.pdf & .png\n")

# ============================================================================
# 示例3：高亮特定基因
# ============================================================================

# 适用场景：想要标注和高亮你感兴趣的基因
# 
# 使用方法：
# 1. 在 highlight_genes 中列出你想高亮的基因
# 2. 取消下面代码的注释

# p3 <- plot_volcano_hyperbolic(
#   data = my_data,
#   threshold = 6,
#   highlight_genes = c("TP53", "MYC", "BRCA1"),  # 修改为你的基因
#   x_label = "log2(Fold Change)",
#   title = "Differential Analysis with Highlighted Genes",
#   output_name = file.path(output_dir, "volcano_highlight")
# )
# 
# print(p3)
# cat("✓ 已保存: volcano_highlight.pdf & .png\n")

# ============================================================================
# 示例4：标记对照组（适用于CRISPR或有对照的实验）
# ============================================================================

# 适用场景：CRISPR筛选、有对照组的实验
# 
# 使用方法：
# 1. 设置 control_pattern 为你的对照基因名称模式
# 2. 取消下面代码的注释

# p4 <- plot_volcano_hyperbolic(
#   data = my_data,
#   threshold = 6,
#   control_pattern = "Control",  # 修改为你的对照模式，如 "NTC", "Ctrl", "NC"
#   x_label = "Effect Size (AU)",
#   title = "CRISPR Screen Results",
#   output_name = file.path(output_dir, "volcano_with_control")
# )
# 
# print(p4)
# cat("✓ 已保存: volcano_with_control.pdf & .png\n")

# ============================================================================
# 示例5：完整功能（基因分类 + 高亮 + 对照组）
# ============================================================================

# 适用场景：需要展示所有信息的出版级图表
# 
# 使用方法：
# 1. 准备好所有数据（主数据、分类数据）
# 2. 取消下面代码的注释
# 3. 根据需要调整所有参数

# p5 <- plot_volcano_hyperbolic(
#   data = my_data,
#   gene_category = my_gene_category,
#   threshold = 6,
#   control_pattern = "Control",  # 如果没有对照组，删除这行
#   highlight_genes = c("TP53", "MYC"),  # 修改为你的基因
#   x_label = "log2(Fold Change)",
#   show_legend = TRUE,
#   title = "Comprehensive Volcano Plot",
#   output_name = file.path(output_dir, "volcano_complete")
# )
# 
# print(p5)
# cat("✓ 已保存: volcano_complete.pdf & .png\n")

# ============================================================================
# 示例6：自定义配色（高级）
# ============================================================================

# 适用场景：需要匹配期刊或实验室的配色方案
# 
# 使用方法：
# 1. 修改下面的颜色代码
# 2. 取消代码的注释

# # 自定义基础配色
# my_base_colors <- c(
#   "Not significant" = "#CCCCCC",  # 灰色
#   "Upregulated" = "#D62728",      # 红色
#   "Downregulated" = "#1F77B4",    # 蓝色
#   "Control" = "#000000"            # 黑色（如果有对照组）
# )
# 
# # 自定义分类配色（如果使用基因分类）
# my_category_colors <- c(
#   "Tumor suppressor" = "#9467BD",  # 紫色
#   "Oncogene" = "#FF7F0E"           # 橙色
#   # 添加更多分类...
# )
# 
# p6 <- plot_volcano_hyperbolic(
#   data = my_data,
#   gene_category = my_gene_category,
#   threshold = 6,
#   base_colors = my_base_colors,
#   category_colors = my_category_colors,
#   x_label = "log2(Fold Change)",
#   show_legend = TRUE,
#   title = "Custom Color Scheme",
#   output_name = file.path(output_dir, "volcano_custom_colors")
# )
# 
# print(p6)
# cat("✓ 已保存: volcano_custom_colors.pdf & .png\n")

# ============================================================================
# 其他可调参数
# ============================================================================

# 如果需要更精细的控制，可以调整以下参数：
# 
# plot_volcano_hyperbolic(
#   data = my_data,
#   threshold = 6,
#   
#   # 图形尺寸
#   plot_width = 6.5,      # 图宽（英寸）
#   plot_height = 4,       # 图高（英寸）
#   dpi = 300,             # PNG分辨率
#   
#   # 点和标签样式
#   point_size = 2.5,      # 点大小
#   point_alpha = 0.3,     # 点透明度
#   label_size = 2.8,      # 标签字号
#   show_labels = TRUE,    # 是否显示标签
#   
#   # 双曲线样式
#   curve_linetype = "dashed",  # 线型
#   curve_linewidth = 0.8,      # 线宽
#   
#   # 坐标轴
#   x_limits = NULL,       # X轴范围（NULL为自动）
#   y_limits = NULL,       # Y轴范围（NULL为自动）
#   x_label = "Effect Size",
#   y_label = expression(-log[10]*P),
#   
#   # 图例
#   show_legend = FALSE,
#   legend_position = "right",
#   
#   output_name = file.path(output_dir, "volcano_custom")
# )

# ============================================================================
# 推荐阈值设置
# ============================================================================

# 根据不同的数据类型，推荐使用以下阈值：
# 
# - RNA-seq (bulk): threshold = 6
# - 单细胞 RNA-seq: threshold = 4-5 (效应值通常较小)
# - CRISPR 筛选: threshold = 6
# - 蛋白质组学: threshold = 6
# - 代谢组学: threshold = 5-7
# 
# 阈值越大，筛选越严格，显著基因越少

# ============================================================================
# 常见问题
# ============================================================================

# Q1: 函数报错说找不到效应值列？
# A: 确保你的数据包含以下列名之一：
#    effect_size, log2FoldChange, logFC, avg_log2FC, log2fc, epsilon

# Q2: 如何调整显著基因的数量？
# A: 调整 threshold 参数。增大阈值会减少显著基因，减小阈值会增加显著基因。

# Q3: 图上的基因标签太多/太少？
# A: 函数会自动选择最显著的基因标注。如果想手动控制，使用 highlight_genes 参数。

# Q4: 如何不显示基因标签？
# A: 设置 show_labels = FALSE

# Q5: 如何修改图片大小？
# A: 调整 plot_width 和 plot_height 参数

# Q6: 生成的图片在哪里？
# A: 在你设置的 output_dir 目录中，同时生成 PDF 和 PNG 两种格式

# ============================================================================
# 完成
# ============================================================================

cat("\n========== 模板使用完成 ==========\n")
cat("请根据你的需求：\n")
cat("1. 修改'数据准备'部分，加载你的数据\n")
cat("2. 选择合适的示例，取消注释\n")
cat("3. 调整参数以适应你的数据\n")
cat("4. 运行脚本生成火山图\n")
cat("\n详细文档: https://github.com/ShengXinF3/BioPlotTools\n")
