################################################################################
#' @title 环形UMAP图示例
#' @description 生成文章中使用的环形UMAP图示例
#' @date 2026-05-04
################################################################################

# ==============================================================================
# 加载必需的包
# ==============================================================================

library(Seurat)
library(ggplot2)
library(dplyr)

# ==============================================================================
# 加载环形图函数
# ==============================================================================

source("functions/plot_adapted/plot_circlize.R")

# ==============================================================================
# 加载测试数据
# ==============================================================================

message("加载测试数据...")
pbmc <- readRDS("examples/data/pbmc3k_annotated_test.rds")

# 创建模拟的分组变量
set.seed(123)
pbmc$condition <- sample(c("Control", "Treatment"), ncol(pbmc), replace = TRUE)
pbmc$timepoint <- sample(c("Day0", "Day3", "Day7"), ncol(pbmc), replace = TRUE)
pbmc$timepoint <- factor(pbmc$timepoint, levels = c("Day0", "Day3", "Day7"))

message("数据准备完成")
message("细胞数量: ", ncol(pbmc))
message("细胞类型: ", paste(levels(pbmc), collapse = ", "))

# 创建输出目录
dir.create("examples/output/plot_adapted", showWarnings = FALSE, recursive = TRUE)

# ==============================================================================
# 示例1: 基本环形图
# ==============================================================================

message("\n", paste(rep("=", 80), collapse = ""))
message("示例1: 基本环形图")
message(paste(rep("=", 80), collapse = ""))

tryCatch({
  # 使用NPG配色（Nature风格）
  data_plot <- prepare_circlize_data(pbmc, scale = 0.8, color_palette = "npg")
  
  png("examples/output/plot_adapted/05_circlize_basic.png",
      width = 2400, height = 2400, res = 300)
  
  plot_circlize(
    data_plot,
    do.label = TRUE,
    contour.levels = c(0.2, 0.3),
    pt.size = 0.5,
    label.cex = 1.2,           # 细胞类型标签
    cluster.label.cex = 1.0,   # cluster标签
    track.label.cex = 0.8,     # track标签
    axis.label.cex = 0.6       # 坐标轴标签
  )
  
  dev.off()
  
  message("已保存: 05_circlize_basic.png (NPG配色)")
}, error = function(e) {
  message("环形图生成失败: ", e$message)
})

# ==============================================================================
# 示例2: 带多个track的环形图
# ==============================================================================

message("\n", paste(rep("=", 80), collapse = ""))
message("示例2: 多track环形图")
message(paste(rep("=", 80), collapse = ""))

tryCatch({
  # 使用NPG配色（Nature风格）
  data_plot <- prepare_circlize_data(pbmc, scale = 0.8, color_palette = "npg")
  
  png("examples/output/plot_adapted/05_circlize_tracks.png",
      width = 2400, height = 2400, res = 300)
  
  plot_circlize(
    data_plot, 
    do.label = TRUE,
    label.cex = 1.2,           # 细胞类型标签
    cluster.label.cex = 1.0,   # cluster标签
    track.label.cex = 0.8,     # track标签
    axis.label.cex = 0.6       # 坐标轴标签
  )
  add_track(data_plot, group = "condition", track_num = 2, 
            track_label_cex = 0.8, color_palette = "npg")
  add_track(data_plot, group = "timepoint", track_num = 3, 
            track_label_cex = 0.8, color_palette = "npg")
  
  dev.off()
  
  message("已保存: 05_circlize_tracks.png (NPG配色)")
}, error = function(e) {
  message("多track环形图生成失败: ", e$message)
})

# ==============================================================================
# 总结
# ==============================================================================

message("\n", paste(rep("=", 80), collapse = ""))
message("环形UMAP图生成完成！")
message(paste(rep("=", 80), collapse = ""))
message("\n输出目录: examples/output/plot_adapted/")
message("\n生成的文件:")
message("  05_circlize_basic.png - 环形UMAP图（基本）")
message("  05_circlize_tracks.png - 环形UMAP图（多track）")
