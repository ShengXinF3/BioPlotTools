# ========== 双曲线阈值火山图示例 ==========
# 
# 本示例展示 plot_volcano_hyperbolic() 函数的核心功能
# 适用场景：RNA-seq、单细胞、CRISPR、蛋白质组、代谢组等

library(ggplot2)
library(dplyr)
library(readxl)

# 从GitHub加载函数（如果网络可用）
# source("https://cdn.jsdelivr.net/gh/ShengXinF3/BioPlotTools@main/functions/plot_volcano_hyperbolic.R")

# 本地加载
source("functions/plot_volcano_hyperbolic.R")

# 创建输出目录
output_dir <- "examples/output/plot_volcano_hyperbolic"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# 读取测试数据
volcano_data <- read_excel("examples/data/test_data_volcano_hyperbolic.xlsx")
gene_category <- read_excel("examples/data/test_gene_category.xlsx")

# ============================================================================
# 示例1：基础用法 + 基因分类
# ============================================================================

cat("\n========== 示例1: 基础用法 + 基因分类 ==========\n")

p1 <- plot_volcano_hyperbolic(
  data = volcano_data,
  gene_category = gene_category,
  threshold = 6,
  x_label = "Effect Size (AU)",
  show_legend = TRUE,
  title = "Volcano Plot with Gene Categories",
  output_name = file.path(output_dir, "01_basic_with_category")
)

print(p1)
cat("✓ 已保存:", file.path(output_dir, "01_basic_with_category.pdf & .png\n"))

# ============================================================================
# 示例2：高亮基因 + 标记对照组
# ============================================================================

cat("\n========== 示例2: 高亮基因 + 标记对照组 ==========\n")

p2 <- plot_volcano_hyperbolic(
  data = volcano_data,
  gene_category = gene_category,
  threshold = 6,
  control_pattern = "Control",  # 标记对照基因
  highlight_genes = c("TF1", "TF2", "ENZ1"),  # 高亮特定基因
  x_label = "Effect Size (AU)",
  show_legend = TRUE,
  title = "Volcano Plot with Highlights and Controls",
  output_name = file.path(output_dir, "02_highlight_control")
)

print(p2)
cat("✓ 已保存:", file.path(output_dir, "02_highlight_control.pdf & .png\n"))

# ============================================================================
# 示例3：自定义配色
# ============================================================================

cat("\n========== 示例3: 自定义配色 ==========\n")

# 自定义配色方案
custom_colors <- c(
  "Not significant" = "#CCCCCC",
  "Upregulated" = "#D62728",
  "Downregulated" = "#1F77B4",
  "Control" = "#000000"
)

custom_category_colors <- c(
  "Transcription factor" = "#9467BD",
  "Metabolic enzyme" = "#FF7F0E",
  "Signal transduction" = "#2CA02C",
  "Cell cycle" = "#E377C2",
  "Membrane protein" = "#8C564B"
)

p3 <- plot_volcano_hyperbolic(
  data = volcano_data,
  gene_category = gene_category,
  threshold = 6,
  control_pattern = "Control",
  base_colors = custom_colors,
  category_colors = custom_category_colors,
  x_label = "Effect Size (AU)",
  show_legend = TRUE,
  title = "Custom Color Scheme",
  output_name = file.path(output_dir, "03_custom_colors")
)

print(p3)
cat("✓ 已保存:", file.path(output_dir, "03_custom_colors.pdf & .png\n"))

# ============================================================================
# 总结
# ============================================================================

cat("\n========== 所有示例完成！ ==========\n")
cat(sprintf("\n生成的文件保存在: %s\n", output_dir))
cat("  - 01_basic_with_category.pdf (基础用法 + 基因分类)\n")
cat("  - 02_highlight_control.pdf (高亮基因 + 标记对照组)\n")
cat("  - 03_custom_colors.pdf (自定义配色)\n")

cat("\n核心功能:\n")
cat("  1. 双曲线阈值自动识别显著基因\n")
cat("  2. 支持基因分类和自定义配色\n")
cat("  3. 可高亮特定基因和标记对照组\n")
cat("  4. 出版级质量输出 (PDF + PNG)\n")

cat("\n适用数据类型:\n")
cat("  - RNA-seq差异分析 (threshold = 6)\n")
cat("  - 单细胞差异分析 (threshold = 4-5)\n")
cat("  - CRISPR筛选 (threshold = 6, control_pattern = 'Control')\n")
cat("  - 蛋白质组学 (threshold = 6)\n")
cat("  - 代谢组学 (threshold = 5-7)\n")

cat("\n函数会自动识别以下列名:\n")
cat("  - effect_size (推荐)\n")
cat("  - log2FoldChange (DESeq2)\n")
cat("  - logFC (edgeR, limma)\n")
cat("  - avg_log2FC (Seurat)\n")
