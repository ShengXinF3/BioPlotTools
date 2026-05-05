# ========== 双曲线阈值火山图可视化函数（通用版）==========

library(ggplot2)
library(dplyr)
library(ggrepel)

#' 绘制双曲线阈值火山图
#'
#' @description 使用双曲线阈值绘制火山图，自动识别显著基因/特征
#' 
#' **适用场景：**
#' - CRISPR筛选分析
#' - Bulk RNA-seq差异表达分析  
#' - 单细胞差异表达分析
#' - 蛋白质组学差异分析
#' - 代谢组学差异分析
#' - 任何有效应值和P值的组学数据
#' 
#' **双曲线阈值原理：**
#' 传统火山图使用固定阈值（如P<0.05, |log2FC|>1），但这种方法可能遗漏重要基因。
#' 双曲线阈值使用公式：|effect × -log10(P)| > threshold
#' 这样效应值大的基因P值可以稍宽松，效应值小的基因需要更显著的P值。
#' 
#' 参考文献：
#' - Nature 2024: https://www.nature.com/articles/s41586-024-07698-1
#' - Cell 2025: https://www.cell.com/cell/fulltext/S0092-8674(25)01487-4
#'
#' @param data 数据框，必须包含以下列：
#'   - gene: 基因/特征名称
#'   - effect_size (或其他效应值列名): 效应值，支持以下列名：
#'     * effect_size (推荐)
#'     * log2FoldChange (DESeq2)
#'     * logFC (edgeR, limma)
#'     * avg_log2FC (Seurat)
#'     * epsilon (旧版本)
#'   - pvalue: P值
#' @param gene_category 可选的基因分类数据框，包含两列：
#'   - gene: 基因/特征名称
#'   - category: 分类名称
#' @param threshold 双曲线阈值参数（默认：6，推荐范围4-8）
#' @param control_pattern 对照组的名称模式（默认：NULL）
#'   - 例如："NTC"（CRISPR对照）、"Control"（实验对照）
#'   - 匹配的基因会被标记为"Control"组
#' @param highlight_genes 需要特别高亮的基因向量（默认：NULL）
#' @param highlight_color 高亮基因的颜色（默认："#FFD100"）
#' @param base_colors 基础分组配色（命名向量）
#' @param category_colors 分类配色（命名向量）
#' @param show_labels 是否显示基因标签（默认：TRUE）
#' @param label_size 标签字号（默认：2.8）
#' @param point_size 点大小（默认：2.5）
#' @param point_alpha 点透明度（默认：0.3）
#' @param curve_linetype 双曲线线型（默认："dashed"）
#' @param curve_linewidth 双曲线宽度（默认：0.8）
#' @param x_limits X轴范围（默认：NULL，自动计算）
#' @param y_limits Y轴范围（默认：NULL，自动计算）
#' @param x_label X轴标签（默认："Effect Size"）
#' @param y_label Y轴标签（默认："-log10(P)"）
#' @param title 图表标题（默认：NULL）
#' @param show_legend 是否显示图例（默认：FALSE）
#' @param legend_position 图例位置（默认："right"）
#' @param output_name 输出文件名（不含扩展名）
#' @param plot_width 图宽（英寸，默认：6.5）
#' @param plot_height 图高（英寸，默认：4）
#' @param dpi PNG分辨率（默认：300）
#'
#' @return ggplot对象
#'
#' @examples
#' # 示例1：RNA-seq差异分析
#' data <- data.frame(
#'   gene = c("TP53", "MYC", "GAPDH", "ACTB"),
#'   effect_size = c(3.5, -2.8, 0.2, -0.1),
#'   pvalue = c(0.001, 0.005, 0.5, 0.8)
#' )
#' plot_volcano_hyperbolic(data, x_label = "log2(Fold Change)")
#'
#' # 示例2：CRISPR筛选
#' plot_volcano_hyperbolic(data, 
#'                        control_pattern = "NTC",
#'                        x_label = "Knockdown Phenotype")
#'
#' # 示例3：添加基因分类
#' gene_cat <- data.frame(
#'   gene = c("TP53", "MYC"),
#'   category = c("Tumor suppressor", "Oncogene")
#' )
#' plot_volcano_hyperbolic(data, gene_category = gene_cat, show_legend = TRUE)
#'
#' @export
plot_volcano_hyperbolic <- function(data,
                                   gene_category = NULL,
                                   threshold = 6,
                                   control_pattern = NULL,
                                   highlight_genes = NULL,
                                   highlight_color = "#FFD100",
                                   base_colors = NULL,
                                   category_colors = NULL,
                                   show_labels = TRUE,
                                   label_size = 2.8,
                                   point_size = 2.5,
                                   point_alpha = 0.3,
                                   curve_linetype = "dashed",
                                   curve_linewidth = 0.8,
                                   x_limits = NULL,
                                   y_limits = NULL,
                                   x_label = "Effect Size",
                                   y_label = expression(-log[10]*P),
                                   title = NULL,
                                   show_legend = FALSE,
                                   legend_position = "right",
                                   output_name = NULL,
                                   plot_width = 6.5,
                                   plot_height = 4,
                                   dpi = 300) {
  
  # ============================================================================
  # 参数验证和列名兼容性处理
  # ============================================================================
  
  # 支持多种效应值列名（按优先级检查）
  effect_col_names <- c("effect_size", "epsilon", "log2FoldChange", "logFC", "log2fc", "avg_log2FC")
  effect_col <- NULL
  
  for (col_name in effect_col_names) {
    if (col_name %in% colnames(data)) {
      effect_col <- col_name
      break
    }
  }
  
  if (is.null(effect_col)) {
    stop("Data must contain one of these columns: ", paste(effect_col_names, collapse = ", "))
  }
  
  # 标准化列名为 effect_size
  if (effect_col != "effect_size") {
    data$effect_size <- data[[effect_col]]
    message(sprintf("Using '%s' column as effect size", effect_col))
  }
  
  # 检查必需列
  required_cols <- c("gene", "pvalue")
  missing_cols <- setdiff(required_cols, colnames(data))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }
  
  # 检查数据有效性
  if (any(is.na(data$effect_size)) || any(is.na(data$pvalue))) {
    warning("Data contains NA values in effect_size or pvalue columns. Removing NA rows.")
    data <- data[!is.na(data$effect_size) & !is.na(data$pvalue), ]
  }
  
  if (any(data$pvalue <= 0)) {
    warning("P-values must be > 0. Removing invalid rows.")
    data <- data[data$pvalue > 0, ]
  }
  
  # ============================================================================
  # 数据处理
  # ============================================================================
  
  # 计算乘积（用于判断显著性）
  data$product <- abs(data$effect_size * -log10(data$pvalue))
  
  # 自动计算坐标轴范围
  if (is.null(x_limits)) {
    x_range <- range(data$effect_size, na.rm = TRUE)
    x_expand <- diff(x_range) * 0.1
    x_limits <- c(x_range[1] - x_expand, x_range[2] + x_expand)
  }
  
  if (is.null(y_limits)) {
    y_max <- max(-log10(data$pvalue), na.rm = TRUE)
    y_limits <- c(0, y_max * 1.1)
  }
  
  # 生成双曲线数据
  x_vals <- seq(x_limits[1], x_limits[2], length.out = 1000)
  x_vals <- x_vals[x_vals != 0]
  curve_df <- data.frame(x = x_vals, y = threshold / abs(x_vals))
  # 过滤掉超出y轴范围的点
  curve_df <- curve_df[curve_df$y <= y_limits[2], ]
  
  # 基因分组
  if (!is.null(control_pattern)) {
    # 如果指定了对照模式
    data <- data %>%
      mutate(base_group = case_when(
        grepl(control_pattern, gene, ignore.case = TRUE) ~ "Control",
        -log10(pvalue) > (threshold / abs(effect_size)) & effect_size > 0 ~ "Upregulated",
        -log10(pvalue) > (threshold / abs(effect_size)) & effect_size < 0 ~ "Downregulated",
        TRUE ~ "Not significant"
      ))
  } else {
    # 没有指定对照模式
    data <- data %>%
      mutate(base_group = case_when(
        -log10(pvalue) > (threshold / abs(effect_size)) & effect_size > 0 ~ "Upregulated",
        -log10(pvalue) > (threshold / abs(effect_size)) & effect_size < 0 ~ "Downregulated",
        TRUE ~ "Not significant"
      ))
  }
  
  # 设置基础配色
  if (is.null(base_colors)) {
    if (!is.null(control_pattern)) {
      base_colors <- c(
        "Control" = "#000000",
        "Not significant" = "#6D6E71",
        "Upregulated" = "#E74C3C",
        "Downregulated" = "#3498DB"
      )
    } else {
      base_colors <- c(
        "Not significant" = "#6D6E71",
        "Upregulated" = "#E74C3C",
        "Downregulated" = "#3498DB"
      )
    }
  }
  
  # 如果提供了基因分类
  has_category <- !is.null(gene_category)
  
  if (has_category) {
    # 合并分类信息
    data <- data %>%
      left_join(gene_category, by = "gene") %>%
      mutate(final_group = ifelse(!is.na(category), category, base_group))
    
    # 设置分类配色
    if (is.null(category_colors)) {
      category_colors <- c(
        "Tumor suppressor" = "#9B59B6",
        "Oncogene" = "#E67E22",
        "Mitochondria" = "#E3370C",
        "Autophagy" = "#238622",
        "Proteasome" = "#7915CC",
        "GPI anchor" = "#0212C8",
        "Metabolism" = "#16A085",
        "Signaling" = "#F39C12"
      )
    }
    
    # 合并所有颜色
    all_colors <- c(base_colors, category_colors)
    
    # 确保所有分组都有颜色
    unique_groups <- unique(data$final_group)
    missing_colors <- setdiff(unique_groups, names(all_colors))
    if (length(missing_colors) > 0) {
      extra_colors <- rainbow(length(missing_colors))
      names(extra_colors) <- missing_colors
      all_colors <- c(all_colors, extra_colors)
    }
    
    data$final_group <- factor(data$final_group, levels = names(all_colors))
    
  } else {
    data$final_group <- data$base_group
    all_colors <- base_colors
    data$final_group <- factor(data$final_group, levels = names(all_colors))
  }
  
  # 标记高亮基因
  if (!is.null(highlight_genes)) {
    data$is_highlight <- data$gene %in% highlight_genes
  } else {
    data$is_highlight <- FALSE
  }
  
  # ============================================================================
  # 绘图
  # ============================================================================
  
  p <- ggplot(data, aes(x = effect_size, y = -log10(pvalue)))
  
  # 根据是否有分类采用不同的绘图策略
  if (has_category) {
    # 有分类：分层绘制
    p <- p +
      # 1. 非显著基因（灰色背景）
      geom_point(data = filter(data, base_group == "Not significant" & !is_highlight),
                 aes(color = final_group), size = point_size, alpha = point_alpha) +
      # 2. 对照组（如果有）
      {if (!is.null(control_pattern)) {
        geom_point(data = filter(data, base_group == "Control" & !is_highlight),
                   aes(color = final_group), size = point_size, alpha = point_alpha)
      }} +
      # 3. 显著基因（无分类）
      geom_point(data = filter(data, base_group %in% c("Upregulated", "Downregulated") & 
                                  is.na(category) & !is_highlight),
                 aes(color = final_group), size = point_size, alpha = point_alpha + 0.2) +
      # 4. 有分类的基因（带黑色边框）
      geom_point(data = filter(data, !is.na(category) & !is_highlight),
                 aes(fill = final_group), shape = 21, size = point_size, 
                 stroke = 0.8, color = "black")
  } else {
    # 无分类：简单绘制
    p <- p +
      # 1. 非显著基因和对照
      geom_point(data = filter(data, !base_group %in% c("Upregulated", "Downregulated") & !is_highlight),
                 aes(color = final_group), size = point_size, alpha = point_alpha) +
      # 2. 显著基因
      geom_point(data = filter(data, base_group %in% c("Upregulated", "Downregulated") & !is_highlight),
                 aes(color = final_group), size = point_size, alpha = point_alpha + 0.2)
  }
  
  # 添加高亮基因
  if (any(data$is_highlight)) {
    p <- p +
      geom_point(data = filter(data, is_highlight),
                 fill = highlight_color, shape = 21, color = "black", 
                 size = point_size, stroke = 0.8)
  }
  
  # 添加双曲线
  p <- p +
    geom_line(data = curve_df, aes(x = x, y = y), 
              linetype = curve_linetype, color = "black", 
              linewidth = curve_linewidth, inherit.aes = FALSE)
  
  # 添加标签
  if (show_labels) {
    if (has_category) {
      label_data <- filter(data, !is.na(category) | is_highlight)
    } else {
      label_data <- filter(data, is_highlight)
    }
    
    if (nrow(label_data) > 0) {
      p <- p +
        geom_text_repel(data = label_data, aes(label = gene), 
                       size = label_size, fontface = "italic",
                       max.overlaps = 20)
    }
  }
  
  # 设置颜色和主题
  p <- p +
    scale_y_continuous(limits = y_limits, expand = c(0, 0)) +
    scale_x_continuous(limits = x_limits, expand = c(0, 0)) +
    scale_color_manual(values = all_colors, name = NULL) +
    labs(x = x_label, y = y_label, title = title) +
    theme_classic() +
    theme(
      legend.position = if(show_legend) legend_position else "none",
      axis.text = element_text(size = 10),
      axis.title = element_text(size = 12),
      plot.title = element_text(hjust = 0.5, face = "bold", size = 14)
    )
  
  # 如果有分类，添加fill scale
  if (has_category) {
    p <- p + scale_fill_manual(values = all_colors, name = NULL)
    if (show_legend) {
      p <- p + guides(color = guide_legend(override.aes = list(alpha = 1)))
    }
  }
  
  # ============================================================================
  # 保存图片
  # ============================================================================
  
  if (!is.null(output_name)) {
    # 创建输出目录
    if (grepl("/", output_name)) {
      dir.create(dirname(output_name), showWarnings = FALSE, recursive = TRUE)
    }
    
    # 保存PDF和PNG
    ggsave(paste0(output_name, ".pdf"), p, 
           width = plot_width, height = plot_height, device = "pdf")
    ggsave(paste0(output_name, ".png"), p, 
           width = plot_width, height = plot_height, dpi = dpi)
    
    message("Saved: ", output_name, ".pdf/png")
  }
  
  return(p)
}
