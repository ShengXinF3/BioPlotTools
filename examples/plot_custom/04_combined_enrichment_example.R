# ========== 富集分析组合图简单测试 ==========
# 
# 使用模拟数据测试 plot_combined_enrichment() 函数
# 不需要安装 clusterProfiler

library(ggplot2)
library(dplyr)
library(readxl)

# 本地加载函数
source("functions/plot_combined_enrichment.R")

# 创建输出目录
output_dir <- "examples/output/plot_combined_enrichment"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# ============================================================================
# 步骤1: 生成测试数据（如果还没有）
# ============================================================================

cat("\n========== 步骤1: 准备测试数据 ==========\n")

test_data_file <- "examples/data/test_data_combined_enrichment.xlsx"

if (!file.exists(test_data_file)) {
  cat("测试数据不存在，正在生成...\n")
  source("examples/data/generate_combined_enrichment_test_data.R")
} else {
  cat("测试数据已存在\n")
}

# ============================================================================
# 步骤2: 读取测试数据
# ============================================================================

cat("\n========== 步骤2: 读取测试数据 ==========\n")

go_bp <- read_excel(test_data_file, sheet = "GO_BP")
go_cc <- read_excel(test_data_file, sheet = "GO_CC")
go_mf <- read_excel(test_data_file, sheet = "GO_MF")
kegg <- read_excel(test_data_file, sheet = "KEGG")

cat("  - GO BP:", nrow(go_bp), "条记录\n")
cat("  - GO CC:", nrow(go_cc), "条记录\n")
cat("  - GO MF:", nrow(go_mf), "条记录\n")
cat("  - KEGG:", nrow(kegg), "条记录\n")

# ============================================================================
# 示例1: GO + KEGG 组合图
# ============================================================================

cat("\n========== 示例1: GO + KEGG 组合图 ==========\n")

result1 <- plot_combined_enrichment(
  enrichment_list = list(
    BP = go_bp,
    CC = go_cc,
    MF = go_mf,
    KEGG = kegg
  ),
  top_n = 5,
  max_genes = 8,  # 只显示前8个基因，便于和示例5对比
  title = "GO and KEGG Enrichment Analysis",
  output_name = file.path(output_dir, "01_go_kegg_combined")
)

print(result1$plot)
cat("✓ 已保存:", file.path(output_dir, "01_go_kegg_combined.pdf & .png\n"))
cat("  推荐尺寸: 宽", result1$width, "英寸 × 高", result1$height, "英寸\n")

# ============================================================================
# 示例2: 只展示GO三个类别
# ============================================================================

cat("\n========== 示例2: 只展示GO三个类别 ==========\n")

result2 <- plot_combined_enrichment(
  enrichment_list = list(
    BP = go_bp,
    CC = go_cc,
    MF = go_mf
  ),
  top_n = 6,
  title = "GO Enrichment Analysis (BP/CC/MF)",
  output_name = file.path(output_dir, "02_go_only")
)

print(result2$plot)
cat("✓ 已保存:", file.path(output_dir, "02_go_only.pdf & .png\n"))

# ============================================================================
# 示例3: 只展示KEGG通路
# ============================================================================

cat("\n========== 示例3: 只展示KEGG通路 ==========\n")

result3 <- plot_combined_enrichment(
  enrichment_list = list(
    KEGG = kegg
  ),
  top_n = 10,
  title = "KEGG Pathway Enrichment Analysis",
  output_name = file.path(output_dir, "03_kegg_only")
)

print(result3$plot)
cat("✓ 已保存:", file.path(output_dir, "03_kegg_only.pdf & .png\n"))

# ============================================================================
# 示例4: 不显示基因名（方案1 - 推荐，避免误导）
# ============================================================================

cat("\n========== 示例4: 不显示基因名（只显示基因数量）==========\n")

result4 <- plot_combined_enrichment(
  enrichment_list = list(
    BP = go_bp,
    CC = go_cc,
    MF = go_mf,
    KEGG = kegg
  ),
  top_n = 5,
  show_genes = FALSE,  # 不显示具体基因名
  title = "Enrichment Analysis (Gene Count Only)",
  output_name = file.path(output_dir, "04_no_gene_names")
)

print(result4$plot)
cat("✓ 已保存:", file.path(output_dir, "04_no_gene_names.pdf & .png\n"))

# ============================================================================
# 示例5: 显示所有基因（方案2 - 完整信息）
# ============================================================================

cat("\n========== 示例5: 显示所有基因（不截断）==========\n")

result5 <- plot_combined_enrichment(
  enrichment_list = list(
    BP = go_bp,
    CC = go_cc,
    MF = go_mf,
    KEGG = kegg
  ),
  top_n = 5,
  max_genes = 999,  # 显示所有基因
  gene_size = 2.5,  # 稍微减小字号
  title = "Enrichment Analysis (All Genes)",
  output_name = file.path(output_dir, "05_all_genes")
)

print(result5$plot)
cat("✓ 已保存:", file.path(output_dir, "05_all_genes.pdf & .png\n"))

# ============================================================================
# 示例6: SCI风格配色
# ============================================================================

cat("\n========== 示例6: SCI风格配色 ==========\n")

# SCI风格配色（深色，用于左侧标签）- 参考Nature/Science期刊配色
sci_category_colors <- c(
  BP = "#DC0000",      # 深红色 (Nature Red)
  CC = "#3C5488",      # 深蓝色 (Science Blue)
  MF = "#00A087",      # 青绿色 (Teal)
  KEGG = "#F39B7F"     # 珊瑚橙 (Coral)
)

# SCI风格条形图配色（中等深度，用于条形图背景）
sci_bar_colors <- c(
  BP = "#EF9A9A",      # 中红色
  CC = "#90CAF9",      # 中蓝色
  MF = "#80CBC4",      # 中青绿色
  KEGG = "#FFAB91"     # 中珊瑚橙
)

result6 <- plot_combined_enrichment(
  enrichment_list = list(
    BP = go_bp,
    CC = go_cc,
    MF = go_mf,
    KEGG = kegg
  ),
  top_n = 5,
  show_genes = FALSE,  # SCI风格通常不显示所有基因名
  category_colors = sci_category_colors,
  bar_colors = sci_bar_colors,
  title = "SCI Journal Style",
  output_name = file.path(output_dir, "06_sci_style")
)

print(result6$plot)
cat("✓ 已保存:", file.path(output_dir, "06_sci_style.pdf & .png\n"))

# ============================================================================
# 总结
# ============================================================================

cat("\n========== 所有示例完成！ ==========\n")
cat(sprintf("\n生成的文件保存在: %s\n", output_dir))
cat("  - 01_go_kegg_combined.pdf (GO + KEGG 组合图，显示前8个基因)\n")
cat("  - 02_go_only.pdf (只展示GO三个类别)\n")
cat("  - 03_kegg_only.pdf (只展示KEGG通路)\n")
cat("  - 04_no_gene_names.pdf (不显示基因名，只显示数量 - 推荐)\n")
cat("  - 05_all_genes.pdf (显示所有基因，不截断)\n")
cat("  - 06_sci_style.pdf (SCI风格配色)\n")

cat("\n核心功能:\n")
cat("  1. 整合多个富集分析结果到一张图\n")
cat("  2. 左侧类别标签 + 基因数量气泡\n")
cat("  3. 条形图内嵌通路描述和基因名称\n")
cat("  4. 灵活控制基因显示方式（部分/全部/不显示）\n")
cat("  5. 出版级质量输出 (PDF + PNG)\n")

cat("\n基因显示方案:\n")
cat("  - 方案1（推荐）: show_genes = FALSE - 不显示具体基因名，避免误导\n")
cat("  - 方案2（完整）: max_genes = 999 - 显示所有基因，提供完整信息\n")
cat("  - 方案3（默认）: max_genes = 16 - 显示前16个基因\n")

