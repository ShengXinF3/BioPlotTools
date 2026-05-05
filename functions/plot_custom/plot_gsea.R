library(ggplot2)
library(dplyr)
library(patchwork)

#' Plot GSEA Enrichment with Gene Labels
#'
#' Generate publication-quality GSEA plots with three panels: ES curve with gene labels,
#' barcode plot with expression heatmap, and ranked list visualization.
#'
#' @param gsea_object GSEA result object or path to .rds file
#' @param pathway_id Character. KEGG pathway ID (e.g., "KEGG_OXIDATIVE_PHOSPHORYLATION")
#' @param n_genes Integer. Number of genes to label (default: 8)
#' @param custom_genes Character vector. Custom gene list to label (default: NULL)
#' @param output_name Character. Output file name without extension (default: pathway_id)
#' @param curve_color Character. ES curve color (default: "#9370DB")
#' @param vline_color Character. Vertical line color (default: "#DC143C")
#' @param pos_color Character. Positive area color (default: "#FFB6C1")
#' @param neg_color Character. Negative area color (default: "#87CEEB")
#' @param barcode_color Character. Barcode line color (default: "black")
#' @param curve_lwd Numeric. ES curve line width (default: 2.2)
#' @param vline_lwd Numeric. Vertical line width (default: 1.2)
#' @param barcode_lwd Numeric. Barcode line width (default: 0.8)
#' @param base_size Numeric. Base font size (default: 15)
#' @param title_size Numeric. Title font size (default: 19)
#' @param subtitle_size Numeric. Subtitle font size (default: 14)
#' @param gene_label_size Numeric. Gene label font size (default: 6.5)
#' @param plot_width Numeric. Plot width in inches (default: 12)
#' @param plot_height Numeric. Plot height in inches (default: 9)
#' @param dpi Numeric. PNG resolution (default: 300)
#' @param panel_heights Numeric vector. Panel height ratios (default: c(3.5, 0.4, 1.5))
#' @param show_stats Logical. Show statistics in subtitle (default: TRUE)
#'
#' @return A patchwork combined plot object
#'
#' @examples
#' # Basic usage
#' plot_gsea(gsea_result, "KEGG_OXIDATIVE_PHOSPHORYLATION")
#'
#' # Custom styling
#' plot_gsea(gsea_result, "KEGG_WNT_SIGNALING_PATHWAY",
#'          curve_color = "#FF6347",
#'          base_size = 18,
#'          plot_width = 14)
#'
#' # Custom gene selection
#' plot_gsea(gsea_result, "KEGG_CALCIUM_SIGNALING_PATHWAY",
#'          custom_genes = c("Calm1", "Camk2a", "Prkca"))
#'
#' @export
plot_gsea <- function(gsea_object, pathway_id, 
                      n_genes = 8, 
                      custom_genes = NULL,
                      output_name = NULL,
                      # Colors
                      curve_color = "#9370DB",
                      vline_color = "#DC143C",
                      pos_color = "#FFB6C1",
                      neg_color = "#87CEEB",
                      barcode_color = "black",
                      # Line widths
                      curve_lwd = 2.2,
                      vline_lwd = 1.2,
                      barcode_lwd = 0.8,
                      # Font sizes
                      base_size = 15,
                      title_size = 19,
                      subtitle_size = 14,
                      gene_label_size = 6.5,
                      # Plot dimensions
                      plot_width = 12,
                      plot_height = 9,
                      dpi = 300,
                      # Panel heights
                      panel_heights = c(3.5, 0.4, 1.5),
                      # Other
                      show_stats = TRUE) {
  
  # Load object if path provided
  if (is.character(gsea_object)) {
    if (!file.exists(gsea_object)) stop("File not found: ", gsea_object)
    gsea_obj <- readRDS(gsea_object)
  } else {
    gsea_obj <- gsea_object
  }
  
  # Extract pathway info
  pathway_info <- gsea_obj@result %>% filter(ID == pathway_id)
  if (nrow(pathway_info) == 0) stop("Pathway not found: ", pathway_id)
  
  # Get gene list
  if (!is.null(attr(gsea_obj, "gene_list_sorted"))) {
    gene_rank_vec <- attr(gsea_obj, "gene_list_sorted")
  } else {
    gene_rank_vec <- gsea_obj@geneList
  }
  
  gene_rank <- data.frame(
    gene_name = names(gene_rank_vec),
    log2fc = as.numeric(gene_rank_vec),
    rank = 1:length(gene_rank_vec),
    stringsAsFactors = FALSE
  )
  
  # Mark pathway genes
  pathway_genes <- gsea_obj@geneSets[[pathway_id]]
  gene_rank$in_pathway <- gene_rank$gene_name %in% pathway_genes
  
  n_genes_total <- nrow(gene_rank)
  n_pathway <- sum(gene_rank$in_pathway)

  # Calculate ES curve
  es_curve <- numeric(n_genes_total)
  current_es <- 0
  Nr <- sum(abs(gene_rank$log2fc[gene_rank$in_pathway]))
  
  for (i in 1:n_genes_total) {
    if (gene_rank$in_pathway[i]) {
      current_es <- current_es + abs(gene_rank$log2fc[i]) / Nr
    } else {
      current_es <- current_es - 1 / (n_genes_total - n_pathway)
    }
    es_curve[i] <- current_es
  }
  
  # Select genes to label
  pathway_genes_ranked <- gene_rank %>% filter(in_pathway) %>% arrange(rank)
  
  if (!is.null(custom_genes)) {
    selected <- pathway_genes_ranked %>% filter(gene_name %in% custom_genes)
  } else {
    idx <- round(seq(1, nrow(pathway_genes_ranked), length.out = n_genes))
    selected <- pathway_genes_ranked[idx, ]
  }
  
  # Prepare labels
  labels <- data.frame(
    rank = selected$rank,
    gene = selected$gene_name,
    es = es_curve[selected$rank],
    log2fc = selected$log2fc
  )
  
  x_span <- n_genes_total * 0.05
  labels$x_offset <- rep(c(-x_span, x_span, -x_span*1.5, x_span*1.5), length.out = nrow(labels))
  labels$y_offset <- rep(c(1, -1, 1.2, -1.2), length.out = nrow(labels))
  
  max_es_abs <- max(abs(es_curve))
  labels$label_x <- pmax(pmin(labels$rank + labels$x_offset, n_genes_total * 0.95), n_genes_total * 0.05)
  labels$label_y <- labels$es + labels$y_offset * max_es_abs * 0.15
  
  # Plot data
  plot_data <- data.frame(
    rank = 1:n_genes_total,
    es = es_curve,
    log2fc = gene_rank$log2fc
  )
  
  # Panel 1: ES curve
  p1 <- ggplot(plot_data, aes(x = rank, y = es)) +
    geom_line(color = curve_color, linewidth = curve_lwd) +
    geom_hline(yintercept = 0, linetype = "dashed", linewidth = 0.8) +
    geom_segment(data = labels, aes(x = rank, xend = rank, y = 0, yend = es),
                 color = vline_color, linewidth = vline_lwd, alpha = 0.6) +
    geom_point(data = labels, aes(x = rank, y = es), size = 2.5) +
    geom_segment(data = labels, aes(x = rank, xend = label_x, y = es, yend = label_y),
                 linewidth = 0.8, arrow = arrow(length = unit(0.2, "cm"), type = "closed"), alpha = 0.7) +
    geom_text(data = labels, aes(x = label_x, y = label_y, label = gene),
              hjust = 0.5, vjust = ifelse(labels$y_offset > 0, -0.3, 1.3),
              size = gene_label_size, fontface = "italic", color = "#2F4F4F") +
    labs(y = "Running Enrichment Score", x = NULL) +
    scale_x_continuous(limits = c(0, n_genes_total), expand = c(0, 0)) +
    scale_y_continuous(expand = expansion(mult = c(0.15, 0.15))) +
    theme_classic(base_size = base_size) +
    theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(),
          axis.line.x = element_blank(), panel.grid.major.y = element_line(color = "grey90"))
  
  # Add stats subtitle
  if (show_stats) {
    stats_subtitle <- paste0(
      "NES: ", round(pathway_info$NES, 2),
      "  |  P-value: ", format(pathway_info$pvalue, scientific = TRUE, digits = 2),
      "  |  Adjusted P-value: ", format(pathway_info$p.adjust, scientific = TRUE, digits = 2)
    )
    
    p1 <- p1 + labs(subtitle = stats_subtitle) +
      theme(plot.subtitle = element_text(hjust = 0.5, size = subtitle_size, face = "italic", margin = margin(b = 10)))
  }
  
  # Panel 2: Barcode
  barcode_pos <- which(gene_rank$in_pathway)
  # 分开标注的基因和其他通路基因
  labeled_pos <- labels$rank
  unlabeled_pos <- setdiff(barcode_pos, labeled_pos)
  
  heatmap_data <- plot_data %>%
    mutate(group = cut(rank, breaks = 100, labels = FALSE)) %>%
    group_by(group) %>%
    summarise(x1 = min(rank), x2 = max(rank), fc = mean(log2fc, na.rm = TRUE), .groups = 'drop')
  
  p2 <- ggplot() +
    geom_rect(data = heatmap_data, aes(xmin = x1, xmax = x2, ymin = 0, ymax = 1, fill = fc)) +
    scale_fill_gradient2(low = neg_color, mid = "#FFE4E1", high = "#4169E1", midpoint = 0, guide = "none") +
    # 未标注的基因用黑色
    geom_segment(data = data.frame(x = unlabeled_pos), aes(x = x, xend = x, y = 0, yend = 1), 
                 linewidth = barcode_lwd, color = barcode_color) +
    # 标注的基因用红色（与上方面板一致）
    geom_segment(data = data.frame(x = labeled_pos), aes(x = x, xend = x, y = 0, yend = 1), 
                 linewidth = barcode_lwd * 1.5, color = vline_color) +
    scale_x_continuous(limits = c(0, n_genes_total), expand = c(0, 0)) +
    theme_void()
  
  # Panel 3: Ranked list
  p3 <- ggplot(plot_data, aes(x = rank, y = log2fc)) +
    geom_area(data = plot_data %>% filter(log2fc >= 0), fill = pos_color, alpha = 0.8) +
    geom_area(data = plot_data %>% filter(log2fc < 0), fill = neg_color, alpha = 0.8) +
    geom_hline(yintercept = 0, linetype = "dashed", linewidth = 0.8) +
    scale_x_continuous(limits = c(0, n_genes_total), expand = c(0, 0)) +
    labs(y = "Ranked List", x = "Rank in Ordered Dataset") +
    theme_classic(base_size = base_size) +
    theme(panel.grid.major.y = element_line(color = "grey90"))
  
  # Combine panels
  combined <- p1 / p2 / p3 + 
    plot_layout(heights = panel_heights) +
    plot_annotation(title = gsub("_", " ", pathway_id),
                    theme = theme(plot.title = element_text(size = title_size, face = "bold", hjust = 0.5)))
  
  # Save
  if (is.null(output_name)) {
    output_name <- gsub("[^A-Za-z0-9_]", "_", pathway_id)
  }
  
  if (grepl("/", output_name)) {
    dir.create(dirname(output_name), showWarnings = FALSE, recursive = TRUE)
  }
  
  ggsave(paste0(output_name, ".pdf"), combined, width = plot_width, height = plot_height)
  ggsave(paste0(output_name, ".png"), combined, width = plot_width, height = plot_height, dpi = dpi)
  
  message("Saved: ", output_name, ".pdf/png")
  return(combined)
}
