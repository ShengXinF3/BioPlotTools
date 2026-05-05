# ========== 单细胞UMAP密度可视化函数 ==========

# 加载必要的包
required_packages <- c("tidyverse", "Seurat", "ggplot2", "ggsci", 
                       "RColorBrewer", "ggnewscale", "reshape2")

lapply(required_packages, function(pkg) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
})

#' 绘制UMAP密度等高线图
#' 
#' @description 在UMAP空间中绘制细胞密度等高线图，突出显示目标细胞亚群
#' 
#' @param seurat_obj Seurat对象，必须包含UMAP降维结果
#' @param target_group 目标亚群名称，可以是单个或多个（如"Fibroblast"或c("Fibroblast", "T_cell")）
#' @param group_col 细胞分组/亚群注释列名（默认："cell_type"）
#' @param filter_col 筛选条件列名（可选，如"condition"）
#' @param filter_value 筛选条件值（可选，如"treatment"）
#' @param reduction 降维方法名称（默认："umap"）
#' @param dim_names 降维坐标列名，长度为2的向量（默认：NULL，自动提取）
#' @param background_colors 背景细胞亚群配色（命名向量或颜色向量）
#' @param target_color 目标亚群颜色（默认："#B1B4D4"）
#' @param background_alpha 背景细胞透明度（默认：0.3）
#' @param target_alpha 目标细胞透明度（默认：0.3）
#' @param point_size 细胞点大小（默认：1.5）
#' @param contour_colors 等高线配色（默认：灰色渐变）
#' @param contour_linewidth 等高线宽度（默认：0.5）
#' @param contour_bins 等高线数量（默认：NULL，自动根据细胞数量调整）
#' @param title 图表标题（默认：自动生成）
#' @param expand_limits 坐标轴扩展比例（默认：0.1）
#' @param show_legend 是否显示图例（默认：TRUE）
#' @param legend_position 图例位置（默认："right"）
#' 
#' @return ggplot对象
#' 
#' @examples
#' # 示例1：基本用法
#' plot_umap_density(
#'   seurat_obj = seu,
#'   target_group = "Fibroblast",
#'   group_col = "cell_type"
#' )
#' 
#' # 示例2：筛选特定条件
#' plot_umap_density(
#'   seurat_obj = seu,
#'   target_group = "T_cell",
#'   group_col = "cell_type",
#'   filter_col = "treatment",
#'   filter_value = "Drug_A"
#' )
#' 
#' # 示例3：自定义配色
#' plot_umap_density(
#'   seurat_obj = seu,
#'   target_group = "CAF",
#'   background_colors = c("Type1" = "#FF0000", "Type2" = "#00FF00"),
#'   target_color = "#0000FF"
#' )
#' 
#' @export
plot_umap_density <- function(seurat_obj,
                              target_group,
                              group_col = "cell_type",
                              filter_col = NULL,
                              filter_value = NULL,
                              reduction = "umap",
                              dim_names = NULL,
                              background_colors = NULL,
                              target_color = "#B1B4D4",
                              background_alpha = 0.3,
                              target_alpha = 0.3,
                              point_size = 1.5,
                              contour_colors = NULL,
                              contour_linewidth = 0.5,
                              contour_bins = NULL,
                              title = NULL,
                              expand_limits = 0.1,
                              show_legend = TRUE,
                              legend_position = "right") {
  
  # 参数验证
  if (!inherits(seurat_obj, "Seurat")) {
    stop("seurat_obj must be a Seurat object")
  }
  
  if (!reduction %in% names(seurat_obj@reductions)) {
    stop(paste("Reduction", reduction, "not found in Seurat object"))
  }
  
  if (!group_col %in% colnames(seurat_obj@meta.data)) {
    stop(paste("Column", group_col, "not found in metadata"))
  }
  
  # 提取降维坐标
  if (is.null(dim_names)) {
    coords <- as.data.frame(seurat_obj@reductions[[reduction]]@cell.embeddings)
    if (ncol(coords) < 2) {
      stop("Reduction must have at least 2 dimensions")
    }
    dim_names <- colnames(coords)[1:2]
  } else {
    coords <- as.data.frame(seurat_obj@reductions[[reduction]]@cell.embeddings)
    if (!all(dim_names %in% colnames(coords))) {
      stop(paste("Dimension names not found:", paste(dim_names, collapse = ", ")))
    }
    coords <- coords[, dim_names]
  }
  
  # 重命名坐标列为标准名称
  colnames(coords) <- c("dim_1", "dim_2")
  
  # 合并元数据
  meta_data <- seurat_obj@meta.data
  plot_data <- cbind(coords, meta_data)
  
  # 将factor转换为character，避免subset时的level不匹配错误
  if (is.factor(plot_data[[group_col]])) {
    plot_data[[group_col]] <- as.character(plot_data[[group_col]])
  }
  
  # 应用筛选条件
  if (!is.null(filter_col) && !is.null(filter_value)) {
    if (!filter_col %in% colnames(plot_data)) {
      stop(paste("Filter column", filter_col, "not found in metadata"))
    }
    plot_data <- subset(plot_data, plot_data[[filter_col]] == filter_value)
    
    if (nrow(plot_data) == 0) {
      stop(paste("No cells found for filter:", filter_col, "=", filter_value))
    }
  }
  
  # 检查目标亚群是否存在（支持多个）
  all_groups <- unique(plot_data[[group_col]])
  target_groups <- target_group  # 支持向量
  
  missing_groups <- setdiff(target_groups, all_groups)
  if (length(missing_groups) > 0) {
    stop(paste("Target group(s) not found:", paste(missing_groups, collapse = ", ")))
  }
  
  # 定义背景亚群
  background_groups <- setdiff(all_groups, target_groups)
  n_background <- length(background_groups)
  n_targets <- length(target_groups)
  
  # 设置所有群的配色 - 使用ggsci的D3配色方案
  total_groups <- length(all_groups)
  if (total_groups <= 10) {
    all_colors <- pal_d3("category10")(total_groups)
  } else if (total_groups <= 20) {
    all_colors <- pal_d3("category20")(total_groups)
  } else {
    all_colors <- colorRampPalette(pal_d3("category20")(20))(total_groups)
  }
  names(all_colors) <- all_groups
  
  # 提取目标群和背景群的颜色
  target_colors <- all_colors[target_groups]
  
  if (is.null(background_colors)) {
    background_colors <- all_colors[background_groups]
  } else if (is.null(names(background_colors))) {
    if (length(background_colors) < n_background) {
      background_colors <- colorRampPalette(background_colors)(n_background)
    }
    names(background_colors) <- background_groups
  }
  
  # 设置等高线配色
  if (is.null(contour_colors)) {
    contour_colors <- colorRampPalette(brewer.pal(name = "Greys", n = 9)[3:9])(200)
  }
  
  # 生成标题
  if (is.null(title)) {
    if (!is.null(filter_value)) {
      title <- paste(filter_value, "-", target_group)
    } else {
      title <- paste("Density Plot:", target_group)
    }
  }
  
  # 计算坐标轴范围
  x_range <- range(plot_data$dim_1)
  y_range <- range(plot_data$dim_2)
  x_expand <- expand_limits * diff(x_range)
  y_expand <- expand_limits * diff(y_range)
  
  # 绘制图形
  p <- ggplot(plot_data, aes(x = dim_1, y = dim_2)) +
    
    # 绘制背景亚群
    geom_point(data = subset(plot_data, plot_data[[group_col]] %in% background_groups),
               aes(color = !!sym(group_col)), 
               size = point_size, 
               alpha = background_alpha) +
    scale_color_manual(values = background_colors,
                      name = group_col) +
    
    # 添加新的颜色标度用于目标亚群
    new_scale_color()
  
  # 绘制目标亚群（支持多个，每个用不同颜色）
  p <- p + geom_point(data = subset(plot_data, plot_data[[group_col]] %in% target_groups),
                      aes(color = !!sym(group_col)), 
                      size = point_size,
                      alpha = target_alpha) +
    scale_color_manual(values = target_colors,
                      name = "Target Groups")
  
  # 为每个目标群添加独立的等高线
  for (i in seq_along(target_groups)) {
    target <- target_groups[i]
    target_data <- subset(plot_data, plot_data[[group_col]] == target)
    
    if (nrow(target_data) > 0) {
      # 确定bins数量：优先使用用户指定值，否则根据细胞数量自动调整
      if (!is.null(contour_bins)) {
        bins <- contour_bins
      } else {
        n_cells <- nrow(target_data)
        bins <- if (n_cells < 100) 3 else if (n_cells < 500) 5 else 8
      }
      
      p <- p + stat_density_2d(
        data = target_data,
        aes(x = dim_1, y = dim_2),
        color = target_colors[target],
        linewidth = contour_linewidth,
        alpha = 0.8,
        bins = bins,
        inherit.aes = FALSE
      )
    }
  }
  
  # 主题设置
  p <- p +
    theme_void() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      legend.position = if(show_legend) legend_position else "none"
    ) +
    labs(title = title,
         x = dim_names[1],
         y = dim_names[2]) +
    
    # 调整坐标轴范围
    scale_x_continuous(limits = c(x_range[1] - x_expand, x_range[2] + x_expand)) +
    scale_y_continuous(limits = c(y_range[1] - y_expand, y_range[2] + y_expand))
  
  return(p)
}
