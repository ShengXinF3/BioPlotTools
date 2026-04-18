# ========== 生成双曲线火山图测试数据 ==========
# 
# 本脚本生成两个测试数据文件：
# 1. test_data_volcano_hyperbolic.xlsx - 主数据文件（基因、效应值、P值）
# 2. test_gene_category.xlsx - 基因分类文件（可选）
#
# 这些数据可用于测试 plot_volcano_hyperbolic() 函数
# 数据为模拟数据，适用于所有组学数据类型
# 测试图将输出到: examples/output/test_data_generation/

library(writexl)
library(dplyr)

cat("========== 生成双曲线火山图测试数据 ==========\n\n")

# ============================================================================
# 1. 生成主数据文件
# ============================================================================

cat("步骤1: 生成主数据文件...\n")

set.seed(123)

# 定义基因类别
control_genes <- paste0("Control", 1:20)  # 对照基因

# 转录因子
tf_genes <- c(
  "TF1", "TF2", "TF3", "TF4",
  "TF5", "TF6", "TF7", "TF8"
)

# 代谢酶
enzyme_genes <- c(
  "ENZ1", "ENZ2", "ENZ3", "ENZ4",
  "ENZ5", "ENZ6", "ENZ7", "ENZ8",
  "ENZ9", "ENZ10"
)

# 信号转导
signaling_genes <- c(
  "SIG1", "SIG2", "SIG3", "SIG4",
  "SIG5", "SIG6", "SIG7", "SIG8"
)

# 细胞周期
cell_cycle_genes <- c(
  "CC1", "CC2", "CC3", "CC4",
  "CC5", "CC6", "CC7", "CC8"
)

# 膜蛋白
membrane_genes <- c(
  "MEM1", "MEM2", "MEM3", "MEM4",
  "MEM5", "MEM6", "MEM7", "MEM8"
)

# 其他随机基因
n_other <- 400
other_genes <- paste0("Gene", 1:n_other)

# 合并所有基因
all_genes <- c(
  control_genes,
  tf_genes,
  enzyme_genes,
  signaling_genes,
  cell_cycle_genes,
  membrane_genes,
  other_genes
)

n_total <- length(all_genes)

cat(sprintf("  - 总基因数: %d\n", n_total))
cat(sprintf("  - 对照基因: %d\n", length(control_genes)))
cat(sprintf("  - 转录因子: %d\n", length(tf_genes)))
cat(sprintf("  - 代谢酶: %d\n", length(enzyme_genes)))
cat(sprintf("  - 信号转导: %d\n", length(signaling_genes)))
cat(sprintf("  - 细胞周期: %d\n", length(cell_cycle_genes)))
cat(sprintf("  - 膜蛋白: %d\n", length(membrane_genes)))
cat(sprintf("  - 其他基因: %d\n", n_other))

# 生成effect_size值（效应值）
effect_size <- numeric(n_total)

# 对照基因：接近0
effect_size[1:length(control_genes)] <- rnorm(length(control_genes), mean = 0, sd = 1.5)

# 转录因子：强正效应
idx_tf <- (length(control_genes) + 1):(length(control_genes) + length(tf_genes))
effect_size[idx_tf] <- c(
  15.2, 12.5, -10.3, 8.7,
  6.5, -8.2, 5.3, 4.8
)

# 代谢酶：中等负效应
idx_enzyme <- (max(idx_tf) + 1):(max(idx_tf) + length(enzyme_genes))
effect_size[idx_enzyme] <- rnorm(length(enzyme_genes), mean = -8, sd = 3)

# 信号转导：混合效应
idx_sig <- (max(idx_enzyme) + 1):(max(idx_enzyme) + length(signaling_genes))
effect_size[idx_sig] <- c(
  -12.3, -10.5, -9.8, -8.2,
  7.5, 6.8, 5.9, 5.2
)

# 细胞周期：负效应
idx_cc <- (max(idx_sig) + 1):(max(idx_sig) + length(cell_cycle_genes))
effect_size[idx_cc] <- rnorm(length(cell_cycle_genes), mean = -6, sd = 2.5)

# 膜蛋白：正效应
idx_mem <- (max(idx_cc) + 1):(max(idx_cc) + length(membrane_genes))
effect_size[idx_mem] <- rnorm(length(membrane_genes), mean = 9, sd = 2)

# 其他基因：随机分布
idx_other <- (max(idx_mem) + 1):n_total
effect_size[idx_other] <- rnorm(n_other, mean = 0, sd = 6)

# 生成P值
pvalue <- numeric(n_total)

# 对照基因：高P值（不显著）
pvalue[1:length(control_genes)] <- runif(length(control_genes), 0.3, 1.0)

# 显著基因：低P值
# 转录因子
pvalue[idx_tf] <- c(
  0.00123, 0.00456, 0.00089, 0.01234,
  0.02345, 0.00234, 0.03456, 0.04567
)

# 代谢酶：根据效应值大小设置P值
pvalue[idx_enzyme] <- 10^(-abs(effect_size[idx_enzyme]) / 3 - runif(length(enzyme_genes), 0, 1))

# 信号转导：显著
pvalue[idx_sig] <- 10^(-abs(effect_size[idx_sig]) / 3.5 - runif(length(signaling_genes), 0, 0.5))

# 细胞周期：中等显著
pvalue[idx_cc] <- 10^(-abs(effect_size[idx_cc]) / 4 - runif(length(cell_cycle_genes), 0, 1))

# 膜蛋白：显著
pvalue[idx_mem] <- 10^(-abs(effect_size[idx_mem]) / 3 - runif(length(membrane_genes), 0, 0.8))

# 其他基因：随机P值，大部分不显著
pvalue[idx_other] <- 10^(-runif(n_other, 0, 4))

# 确保P值在合理范围内
pvalue[pvalue < 1e-10] <- 1e-10
pvalue[pvalue > 1] <- 0.99

# 创建数据框
data_main <- data.frame(
  gene = all_genes,
  effect_size = round(effect_size, 3),
  pvalue = pvalue,
  stringsAsFactors = FALSE
)

# 添加一些额外的列（可选，展示可以有其他列）
data_main$log2fc <- round(data_main$effect_size * 0.5, 3)  # 模拟log2FC
data_main$fdr <- round(p.adjust(data_main$pvalue, method = "BH"), 4)  # FDR校正

# 查看数据摘要
cat("\n主数据文件摘要:\n")
cat(sprintf("  - Effect size范围: [%.2f, %.2f]\n", min(effect_size), max(effect_size)))
cat(sprintf("  - P值范围: [%.2e, %.2f]\n", min(pvalue), max(pvalue)))
cat(sprintf("  - 显著基因数 (p < 0.05): %d\n", sum(pvalue < 0.05)))

# 保存主数据文件
write_xlsx(data_main, "examples/data/test_data_volcano_hyperbolic.xlsx")

cat("\n✓ 已保存: examples/data/test_data_volcano_hyperbolic.xlsx\n")
# ============================================================================
# 2. 生成基因分类文件
# ============================================================================

cat("\n步骤2: 生成基因分类文件...\n")

# 创建分类数据
gene_category <- data.frame(
  gene = c(
    # 转录因子
    "TF1", "TF2", "TF3", "TF4",
    # 代谢酶（选择部分）
    "ENZ1", "ENZ2", "ENZ3", "ENZ4",
    # 信号转导（选择部分）
    "SIG1", "SIG2", "SIG3", "SIG4",
    # 细胞周期（选择部分）
    "CC1", "CC2", "CC3", "CC4",
    # 膜蛋白（选择部分）
    "MEM1", "MEM2", "MEM3", "MEM4"
  ),
  category = c(
    # 转录因子
    rep("Transcription factor", 4),
    # 代谢酶
    rep("Metabolic enzyme", 4),
    # 信号转导
    rep("Signal transduction", 4),
    # 细胞周期
    rep("Cell cycle", 4),
    # 膜蛋白
    rep("Membrane protein", 4)
  ),
  stringsAsFactors = FALSE
)

cat(sprintf("  - 分类基因数: %d\n", nrow(gene_category)))
cat("  - 分类:\n")
for (cat_name in unique(gene_category$category)) {
  n_genes <- sum(gene_category$category == cat_name)
  cat(sprintf("    * %s: %d genes\n", cat_name, n_genes))
}

# 保存分类文件
write_xlsx(gene_category, "examples/data/test_gene_category.xlsx")

cat("\n✓ 已保存: examples/data/test_gene_category.xlsx\n")

# ============================================================================
# 3. 数据预览
# ============================================================================

cat("\n========== 数据预览 ==========\n")

cat("\n主数据文件前10行:\n")
print(head(data_main, 10))

cat("\n基因分类文件:\n")
print(gene_category)

cat("\n显著基因统计:\n")
threshold <- 6
data_main$product <- abs(data_main$effect_size * -log10(data_main$pvalue))
data_main$is_hit <- data_main$product > threshold

cat(sprintf("  - 使用阈值: %d\n", threshold))
cat(sprintf("  - Positive hits: %d\n", 
            sum(data_main$is_hit & data_main$effect_size > 0)))
cat(sprintf("  - Negative hits: %d\n", 
            sum(data_main$is_hit & data_main$effect_size < 0)))
cat(sprintf("  - Total hits: %d\n", sum(data_main$is_hit)))