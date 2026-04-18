# ========== UMAP密度等高线图示例 ==========

# 加载函数
source("functions/plot_umap_density.R")

# 读取Seurat对象
cat("读取Seurat对象...\n")
seu <- readRDS("examples/data/pbmc3k_annotated_test.rds")

cat("\n========== 数据概览 ==========\n")
cat("细胞数:", ncol(seu), "\n")
cat("基因数:", nrow(seu), "\n")
cat("降维方法:", paste(names(seu@reductions), collapse = ", "), "\n")
cat("细胞类型:", paste(unique(seu@meta.data$cell_type), collapse = ", "), "\n\n")

# 创建输出目录
if (!dir.exists("examples/plot_umap_density")) {
  dir.create("examples/plot_umap_density", recursive = TRUE)
}

# ========== 示例1: 单个细胞类型密度图 ==========
cat("========== 示例1: 单个细胞类型密度图 ==========\n")
cat("目标细胞类型: CD4 T\n")

p1 <- plot_umap_density(
  seurat_obj = seu,
  target_group = "CD4 T",
  group_col = "cell_type",
  reduction = "umap",
  title = "CD4 T Cells Density Distribution"
)
p1
ggsave("examples/plot_umap_density/01_single_celltype.pdf", p1, width = 10, height = 8)
ggsave("examples/plot_umap_density/01_single_celltype.png", p1, width = 10, height = 8, dpi = 300)
cat("✓ 已保存: examples/plot_umap_density/01_single_celltype.pdf & .png\n\n")

# ========== 示例2: 多个细胞类型密度图（每个独立等高线）==========
cat("========== 示例2: 多个细胞类型密度图 ==========\n")
target_types <- c("CD4 T", "CD8 T", "B")
cat("目标细胞类型:", paste(target_types, collapse = ", "), "\n")

p2 <- plot_umap_density(
  seurat_obj = seu,
  target_group = target_types,
  group_col = "cell_type",
  reduction = "umap",
  title = "Multiple Cell Types with Independent Contours"
)
p2
ggsave("examples/plot_umap_density/02_multiple_celltypes.pdf", p2, width = 10, height = 8)
ggsave("examples/plot_umap_density/02_multiple_celltypes.png", p2, width = 10, height = 8, dpi = 300)
cat("✓ 已保存: examples/plot_umap_density/02_multiple_celltypes.pdf & .png\n\n")

# ========== 示例3: 筛选特定条件 ==========
cat("========== 示例3: 筛选特定条件 ==========\n")
cat("筛选条件: condition = Treatment\n")
cat("目标细胞类型: CD14 Mono\n")

p3 <- plot_umap_density(
  seurat_obj = seu,
  target_group = "CD14 Mono",
  group_col = "cell_type",
  filter_col = "condition",
  filter_value = "Treatment",
  reduction = "umap",
  title = "CD14 Monocytes in Treatment Group"
)

ggsave("examples/plot_umap_density/03_filtered_condition.pdf", p3, width = 10, height = 8)
ggsave("examples/plot_umap_density/03_filtered_condition.png", p3, width = 10, height = 8, dpi = 300)
cat("✓ 已保存: examples/plot_umap_density/03_filtered_condition.pdf & .png\n\n")

# ========== 示例4: 自定义参数 ==========
cat("========== 示例4: 自定义参数 ==========\n")
cat("目标细胞类型: NK, DC\n")
cat("自定义: 更大的点、更粗的等高线、指定bins数量\n")

p4 <- plot_umap_density(
  seurat_obj = seu,
  target_group = c("NK", "DC"),
  group_col = "cell_type",
  reduction = "umap",
  point_size = 2.0,
  contour_linewidth = 0.8,
  contour_bins = 6,  # 指定等高线数量为6条
  target_alpha = 0.5,
  background_alpha = 0.2,
  title = "NK & DC Cells (Custom Style)"
)

ggsave("examples/plot_umap_density/04_custom_style.pdf", p4, width = 10, height = 8)
ggsave("examples/plot_umap_density/04_custom_style.png", p4, width = 10, height = 8, dpi = 300)
cat("✓ 已保存: examples/plot_umap_density/04_custom_style.pdf & .png\n\n")

# ========== 示例5: 批量生成（不同条件）==========
cat("========== 示例5: 批量生成不同条件的图 ==========\n")

conditions <- unique(seu@meta.data$condition)
cat("分组:", paste(conditions, collapse = ", "), "\n")

for (cond in conditions) {
  tryCatch({
    p <- plot_umap_density(
      seurat_obj = seu,
      target_group = "CD4 T",
      group_col = "cell_type",
      filter_col = "condition",
      filter_value = cond,
      reduction = "umap",
      title = paste("CD4 T Cells -", cond)
    )
    
    filename <- paste0("examples/plot_umap_density/05_batch_", cond, ".pdf")
    ggsave(filename, p, width = 10, height = 8)
    cat("✓ 已保存:", filename, "\n")
  }, error = function(e) {
    cat("✗ 生成", cond, "失败:", e$message, "\n")
  })
}

# ========== 示例6: 小细胞群的bins调整 ==========
cat("\n========== 示例6: 小细胞群的bins调整 ==========\n")
cat("展示小细胞群（Platelet和Megakaryocyte）\n")
cat("这些细胞群数量少，需要调整bins\n")

# Platelet: 32个细胞, Megakaryocyte: 14个细胞
p6 <- plot_umap_density(
  seurat_obj = seu,
  target_group = c("Platelet", "Megakaryocyte"),
  group_col = "cell_type",
  reduction = "umap",
  contour_bins = 3,  # 细胞少，使用较少的bins
  contour_linewidth = 1.0,  # 更粗的线便于观察
  title = "Small Cell Types (Platelet & Megakaryocyte)"
)

ggsave("examples/plot_umap_density/06_small_clusters.pdf", p6, width = 10, height = 8)
cat("✓ 已保存: examples/plot_umap_density/06_small_clusters.pdf\n\n")

cat("\n========== 所有示例完成！ ==========\n")
cat("\n生成的文件:\n")
cat("  - examples/plot_umap_density/01_single_celltype.pdf (单个细胞类型)\n")
cat("  - examples/plot_umap_density/02_multiple_celltypes.pdf (多个细胞类型，独立等高线)\n")
cat("  - examples/plot_umap_density/03_filtered_condition.pdf (筛选条件)\n")
cat("  - examples/plot_umap_density/04_custom_style.pdf (自定义样式)\n")
cat("  - examples/plot_umap_density/05_batch_*.pdf (批量生成)\n")
cat("  - examples/plot_umap_density/06_cell_subtypes.pdf (细胞亚型)\n")

cat("\n✅ 函数功能测试完成！\n")
cat("\n核心功能:\n")
cat("  1. 支持单个或多个target_group\n")
cat("  2. 每个target_group有独立的颜色和等高线\n")
cat("  3. 支持筛选条件（filter_col/filter_value）\n")
cat("  4. 自动使用ggsci D3配色方案\n")
cat("  5. 智能bins调整或手动指定\n")
