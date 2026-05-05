# ========== 富集分析组合图可视化函数 ==========

library(ggplot2)
library(dplyr)

#' 绘制富集分析组合图
#'
#' @description 将多个富集分析结果（GO BP/CC/MF, KEGG等）整合到一张图中展示
#' 
#' **适用场景：**
#' - GO富集分析结果展示（BP/CC/MF）
#' - KEGG通路富集分析
#' - 其他富集分析结果（Reactome, WikiPathways等）
#' - 多数据库富集结果对比
#' 
#' **设计特点：**
#' - 左侧类别标签（彩色背景）
#' - 基因数量气泡图
#' - 横向条形图展示显著性（-log10 p.adjust）
#' - 条形图内嵌通路描述和基因名称
#' - 自动截断过长文本
#' - 出版级质量输出
#'
#' @param enrichment_list 命名列表，每个元素是一个富集分析结果对象（enrichResult或data.frame）
#'   - 如果是enrichResult对象，会自动提取@result
#'   - 如果是data.frame，必须包含以下列：Description, GeneRatio, pvalue, p.adjust, geneID, Count
#'   - 列表名称将作为类别标签（如 list(BP = ego_bp, CC = ego_cc, KEGG = ekegg)）
#' @param top_n 每个类别展示的top通路数量（默认：5）
#' @param p_cutoff P值阈值（默认：0.05）
#' @param category_colors 类别配色（命名向量，默认：NULL自动配色）
#' @param bar_colors 条形图配色（命名向量，默认：NULL自动配色）
#' @param max_genes 最多显示的基因数量（默认：16）
#' @param show_genes 是否显示基因名称（默认：TRUE）
#'   - TRUE: 显示基因名称（最多max_genes个）
#'   - FALSE: 不显示基因名称，只显示通路描述和基因数量
#' @param max_desc_length 通路描述最大字符数（默认：60）
#' @param desc_size 通路描述字号（默认：4.0）
#' @param gene_size 基因名称字号（默认：3.2）
#' @param title 图表标题（默认：NULL）
#' @param convert_entrez 是否将Entrez ID转换为Gene Symbol（默认：FALSE）
#'   - 如果为TRUE，需要提供organism参数
#' @param organism 物种（默认："human"），用于Entrez ID转换
#'   - "human": Homo sapiens
#'   - "mouse": Mus musculus
#'   - "rat": Rattus norvegicus
#' @param output_name 输出文件名（不含扩展名，默认：NULL不保存）
#' @param dpi PNG分辨率（默认：300）
#'
#' @return 列表，包含：
#'   - plot: ggplot对象
#'   - data: 整合后的数据框
#'   - height: 推荐图高（英寸）
#'   - width: 推荐图宽（英寸）
#'
#' @examples
#' # 示例1：GO + KEGG富集分析
#' library(clusterProfiler)
#' ego_bp <- enrichGO(gene_list, OrgDb = org.Hs.eg.db, ont = "BP")
#' ego_cc <- enrichGO(gene_list, OrgDb = org.Hs.eg.db, ont = "CC")
#' ekegg <- enrichKEGG(gene_list, organism = "hsa")
#' 
#' result <- plot_combined_enrichment(
#'   enrichment_list = list(BP = ego_bp, CC = ego_cc, KEGG = ekegg),
#'   top_n = 5
#' )
#' print(result$plot)
#'
#' # 示例2：自定义配色
#' result <- plot_combined_enrichment(
#'   enrichment_list = list(BP = ego_bp, KEGG = ekegg),
#'   category_colors = c(BP = "#E74C3C", KEGG = "#3498DB"),
#'   bar_colors = c(BP = "#FADBD8", KEGG = "#D6EAF8")
#' )
#'
#' # 示例3：使用data.frame输入
#' custom_df <- data.frame(
#'   Description = c("Pathway 1", "Pathway 2"),
#'   GeneRatio = c("10/100", "15/100"),
#'   pvalue = c(0.001, 0.005),
#'   p.adjust = c(0.01, 0.02),
#'   geneID = c("TP53/MYC/BRCA1", "EGFR/KRAS"),
#'   Count = c(10, 15)
#' )
#' result <- plot_combined_enrichment(
#'   enrichment_list = list(Custom = custom_df),
#'   top_n = 10
#' )
#'
#' @export
plot_combined_enrichment <- function(enrichment_list,
                                    top_n = 5,
                                    p_cutoff = 0.05,
                                    category_colors = NULL,
                                    bar_colors = NULL,
                                    max_genes = 16,
                                    show_genes = TRUE,
                                    max_desc_length = 60,
                                    desc_size = 4.0,
                                    gene_size = 3.2,
                                    title = NULL,
                                    convert_entrez = FALSE,
                                    organism = "human",
                                    output_name = NULL,
                                    dpi = 300) {
  
  # ============================================================================
  # 参数验证
  # ============================================================================
  
  if (missing(enrichment_list) || length(enrichment_list) == 0) {
    stop("enrichment_list is required and cannot be empty")
  }
  
  if (is.null(names(enrichment_list))) {
    stop("enrichment_list must be a named list (e.g., list(BP = ego_bp, KEGG = ekegg))")
  }
  
  # ============================================================================
  # 数据处理
  # ============================================================================
  
  # 必需列
  required_cols <- c("Description", "pvalue", "p.adjust", "geneID", "Count")
  
  df_list <- list()
  
  for (category_name in names(enrichment_list)) {
    enrich_obj <- enrichment_list[[category_name]]
    
    # 跳过NULL对象
    if (is.null(enrich_obj)) next
    
    # 提取数据框
    if (inherits(enrich_obj, "enrichResult")) {
      df <- enrich_obj@result
    } else if (is.data.frame(enrich_obj)) {
      df <- enrich_obj
    } else {
      warning(sprintf("Skipping '%s': not an enrichResult object or data.frame", category_name))
      next
    }
    
    # 检查必需列
    missing_cols <- setdiff(required_cols, colnames(df))
    if (length(missing_cols) > 0) {
      warning(sprintf("Skipping '%s': missing columns: %s", 
                     category_name, paste(missing_cols, collapse = ", ")))
      next
    }
    
    # 过滤和排序
    df_filtered <- df %>%
      dplyr::filter(p.adjust < p_cutoff) %>%
      dplyr::slice_min(n = top_n, order_by = p.adjust)
    
    if (nrow(df_filtered) == 0) {
      message(sprintf("No significant results for '%s' (p.adjust < %s)", category_name, p_cutoff))
      next
    }
    
    # 保留必需列
    df_filtered <- df_filtered[, required_cols, drop = FALSE]
    df_filtered$Category <- category_name
    
    df_list[[category_name]] <- df_filtered
  }
  
  # 检查是否有有效数据
  if (length(df_list) == 0) {
    stop("No significant enrichment results found in any category")
  }
  
  # 合并数据
  combined_df <- dplyr::bind_rows(df_list)
  
  # Entrez ID转换（如果需要）
  if (convert_entrez) {
    combined_df$geneID <- sapply(combined_df$geneID, function(x) {
      convert_entrez_to_symbol(x, organism = organism)
    })
  }
  
  # 计算-log10(p.adjust)
  combined_df <- combined_df %>%
    dplyr::mutate(
      log10_padj = -log10(p.adjust),
      Count = as.numeric(Count),
      Category = factor(Category, levels = names(df_list))
    ) %>%
    dplyr::arrange(Category, p.adjust)
  
  # 分配行ID（从下到上）
  combined_df$row_id <- nrow(combined_df):1
  
  # ============================================================================
  # 配色方案
  # ============================================================================
  
  categories <- levels(combined_df$Category)
  n_categories <- length(categories)
  
  # 默认类别配色（深色，用于左侧标签）- 使用ggsci NPG配色
  if (is.null(category_colors)) {
    # NPG (Nature Publishing Group) 配色方案
    default_category_colors <- c(
      "#E64B35", "#4DBBD5", "#00A087", "#F39B7F",  # NPG红、蓝、绿、橙
      "#8491B4", "#91D1C2", "#DC0000", "#7E6148"   # NPG紫、青、深红、棕
    )
    category_colors <- setNames(
      default_category_colors[1:n_categories],
      categories
    )
  }
  
  # 默认条形图配色（中等深度，用于条形图背景）- 使用ggsci NPG浅色系
  if (is.null(bar_colors)) {
    # NPG浅色系（手动调整亮度）
    default_bar_colors <- c(
      "#F39B9A", "#A8DDE8", "#7FD4C1", "#FACFB8",  # 浅红、浅蓝、浅绿、浅橙
      "#C4CAD9", "#C9E8DF", "#EF9A9A", "#C9B5A8"   # 浅紫、浅青、浅深红、浅棕
    )
    bar_colors <- setNames(
      default_bar_colors[1:n_categories],
      categories
    )
  }
  
  # ============================================================================
  # 计算类别范围（用于左侧标签）
  # ============================================================================
  
  category_ranges <- combined_df %>%
    dplyr::group_by(Category) %>%
    dplyr::summarise(
      ymin = min(row_id) - 0.45,
      ymax = max(row_id) + 0.45,
      ymid = mean(row_id),
      .groups = "drop"
    )
  
  # ============================================================================
  # 文本截断
  # ============================================================================
  
  # 截断基因名（最多max_genes个）
  if (show_genes) {
    combined_df$gene_label <- sapply(strsplit(combined_df$geneID, "/"), function(x) {
      genes <- head(x, max_genes)
      label <- paste(genes, collapse = "/")
      if (length(x) > max_genes) {
        label <- paste0(label, "/...")
      }
      return(label)
    })
  } else {
    # 不显示基因名，显示基因数量
    combined_df$gene_label <- paste0(combined_df$Count, " genes")
  }
  
  # 截断Description
  combined_df$desc_label <- sapply(combined_df$Description, function(x) {
    if (nchar(x) > max_desc_length) {
      paste0(substr(x, 1, max_desc_length - 3), "...")
    } else {
      x
    }
  })
  
  # ============================================================================
  # 计算图表尺寸和动态间距
  # ============================================================================
  
  x_max <- max(combined_df$log10_padj) * 1.15
  n_terms <- nrow(combined_df)
  
  plot_height <- max(6, n_terms * 0.55 + 2)
  plot_width <- 14
  
  bar_height <- 0.85
  
  # 动态计算间距（基于x_max）
  # 左侧类别标签宽度：约为x轴范围的6%
  category_width <- x_max * 0.06
  category_left <- -x_max * 0.12  # 左侧边界（从15%减少到12%）
  category_right <- category_left + category_width
  category_center <- (category_left + category_right) / 2
  
  # 中间圆点位置：约为x轴范围的2.5%（从3%减少）
  count_x <- -x_max * 0.025
  
  # 条形图文字起始位置：略微偏移
  text_start <- x_max * 0.008
  
  # ============================================================================
  # 绘图
  # ============================================================================
  
  p <- ggplot(combined_df) +
    # 左侧类别背景色块（动态宽度）
    geom_rect(data = category_ranges,
              aes(xmin = category_left, xmax = category_right, ymin = ymin, ymax = ymax, fill = Category)) +
    # 左侧类别文字
    geom_text(data = category_ranges,
              aes(x = category_center, y = ymid, label = Category),
              color = "white", fontface = "bold", size = 5) +
    # 基因数量圆点（动态位置）
    geom_point(aes(x = count_x, y = row_id, size = Count), 
               color = "#37474F", alpha = 0.9) +
    geom_text(aes(x = count_x, y = row_id, label = Count), 
              color = "white", size = 3, fontface = "bold") +
    # 条形图背景（用geom_tile）
    geom_tile(aes(x = log10_padj / 2, y = row_id, 
                  width = log10_padj, height = bar_height, fill = Category),
              alpha = 0.95)
  
  # 根据show_genes参数决定文字显示方式
  if (show_genes) {
    # 显示基因名：通路描述在上方，基因名在下方
    p <- p +
      geom_text(aes(x = text_start, y = row_id + 0.18, label = desc_label),
                hjust = 0, size = desc_size, color = "black", fontface = "bold") +
      geom_text(aes(x = text_start, y = row_id - 0.18, label = gene_label),
                hjust = 0, size = gene_size, color = "#1A237E", fontface = "italic")
  } else {
    # 不显示基因名：通路描述居中显示
    p <- p +
      geom_text(aes(x = text_start, y = row_id, label = desc_label),
                hjust = 0, size = desc_size, color = "black", fontface = "bold")
  }
  
  # 添加配色和其他设置
  p <- p +
    # 配色
    scale_fill_manual(values = bar_colors, name = NULL,
                      guide = guide_legend(override.aes = list(alpha = 1))) +
    scale_size_continuous(range = c(6, 14), 
                          breaks = c(5, 10, 20, 30, 50),
                          name = "Count") +
    scale_x_continuous(
      limits = c(category_left * 1.05, x_max),  # 动态左边界
      breaks = seq(0, ceiling(x_max), by = 2),
      expand = expansion(mult = c(0, 0.02))
    ) +
    scale_y_continuous(expand = expansion(mult = c(0.02, 0.02))) +
    labs(x = "-log10(p.adjust)", y = NULL, title = title) +
    theme_classic() +
    theme(
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      axis.line.y = element_blank(),
      axis.text.x = element_text(size = 11),
      axis.title.x = element_text(size = 12),
      legend.position = "right",
      legend.box = "vertical",
      plot.title = element_text(hjust = 0.5, size = 13, face = "bold"),
      panel.grid.major.x = element_line(color = "grey90", linetype = "dashed"),
      plot.margin = margin(15, 15, 15, 15)
    )
  
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
  
  return(list(
    plot = p, 
    data = combined_df, 
    height = plot_height, 
    width = plot_width
  ))
}

# ============================================================================
# 辅助函数：Entrez ID转换为Gene Symbol
# ============================================================================

#' 将Entrez ID转换为Gene Symbol
#'
#' @param entrez_string 以"/"分隔的Entrez ID字符串
#' @param organism 物种（"human", "mouse", "rat"）
#'
#' @return 以"/"分隔的Gene Symbol字符串
#'
#' @keywords internal
convert_entrez_to_symbol <- function(entrez_string, organism = "human") {
  
  # 检查是否已安装必需的包
  if (!requireNamespace("AnnotationDbi", quietly = TRUE)) {
    warning("Package 'AnnotationDbi' is required for Entrez ID conversion. Returning original IDs.")
    return(entrez_string)
  }
  
  # 选择对应的OrgDb包
  orgdb_map <- list(
    human = "org.Hs.eg.db",
    mouse = "org.Mm.eg.db",
    rat = "org.Rn.eg.db"
  )
  
  orgdb_name <- orgdb_map[[tolower(organism)]]
  if (is.null(orgdb_name)) {
    warning(sprintf("Unsupported organism: %s. Returning original IDs.", organism))
    return(entrez_string)
  }
  
  if (!requireNamespace(orgdb_name, quietly = TRUE)) {
    warning(sprintf("Package '%s' is required for %s. Returning original IDs.", 
                   orgdb_name, organism))
    return(entrez_string)
  }
  
  # 加载OrgDb
  orgdb <- get(orgdb_name)
  
  # 分割Entrez ID
  entrez_ids <- strsplit(entrez_string, "/")[[1]]
  
  # 转换
  tryCatch({
    symbols <- AnnotationDbi::mapIds(
      orgdb,
      keys = entrez_ids,
      column = "SYMBOL",
      keytype = "ENTREZID",
      multiVals = "first"
    )
    
    # 替换NA为原始ID
    symbols[is.na(symbols)] <- entrez_ids[is.na(symbols)]
    
    return(paste(symbols, collapse = "/"))
  }, error = function(e) {
    warning("Error during Entrez ID conversion: ", e$message)
    return(entrez_string)
  })
}
