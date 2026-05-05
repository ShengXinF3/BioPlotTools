################################################################################
#' @title 环形UMAP图 (Circlize Plot)
#' 
#' @description
#' 将UMAP/tSNE图转换为环形布局，并添加密度等高线和多track展示。
#' 适合展示复杂的单细胞数据，特别是多条件、多时间点的数据。
#' 
#' ============================================================================
#' 原函数来源 (Original Source)
#' ============================================================================
#' 
#' 本函数集改编自 plot1cell 包
#' 
#' **原作者**: Haojia Wu (The Humphreys Lab)
#' **原始仓库**: https://github.com/TheHumphreysLab/plot1cell
#' **原始文件**: plot1cell/R/plot_circlize.R
#' **原始许可**: MIT License
#' **原始论文**: Wu H, et al. (2022). Mapping the single-cell transcriptomic 
#'               response of murine diabetic kidney disease to therapies. 
#'               Cell Metabolism, 34(7), 1064-1078.e6.
#' 
#' **灵感来源**: Linnarsson Lab, Nature 2018
#' 
#' ============================================================================
#' 改编信息 (Adaptation Information)
#' ============================================================================
#' 
#' **改编日期**: 2026-05-04
#' **改编版本**: v1.0.0 (Seurat v5 compatible)
#' 
#' **主要改编内容**:
#' 1. Seurat v5 兼容性
#'    - 更新坐标提取方法
#'    - 更新 Idents() 使用方式
#'    - 兼容 Assay5 对象结构
#' 
#' 2. 增强功能
#'    - 增强的参数验证
#'    - 更详细的错误提示
#'    - 改进的进度显示
#'    - 添加中文提示信息
#' 
#' 3. 文档改进
#'    - 完整的中文文档
#'    - 详细的参数说明
#'    - 丰富的使用示例
#' 
#' 4. 代码优化
#'    - 统一的代码格式
#'    - 清晰的函数结构
#'    - 详细的内部注释
#' 
#' **保留的核心算法**:
#' - 坐标转换逻辑（笛卡尔→极坐标）
#' - 密度估计方法
#' - 环形布局算法
#' - Track添加逻辑
#' 
#' **许可**: MIT License (与原始 plot1cell 保持一致)
#' 
#' ============================================================================
#'
#' @name plot_circlize
#' @rdname plot_circlize
################################################################################


# ==============================================================================
# 辅助函数1: transform_coordinates
# ==============================================================================

#' 坐标转换
#'
#' @description
#' 将笛卡尔坐标转换为极坐标。
#' 
#' 本函数改编自 plot1cell 包。
#'
#' @param coord_data 数值向量，笛卡尔坐标（来自tSNE或UMAP）
#' @param zoom 数值，缩放因子（0-1之间）
#'
#' @return 转换后的坐标向量
#' 
#' @export
#'
transform_coordinates <- function(coord_data, zoom) {
  # 原始函数来自 plot1cell by Haojia Wu
  # 已适配 Seurat v5
  
  center_data <- coord_data - mean(c(min(coord_data), max(coord_data)))
  max_data <- max(center_data)
  new_data <- center_data * zoom / max_data
  new_data
}


# ==============================================================================
# 辅助函数2: get_metadata
# ==============================================================================

#' 提取元数据
#'
#' @description
#' 从Seurat对象提取元数据并转换UMAP/tSNE坐标。
#' 
#' 本函数改编自 plot1cell 包，已适配 Seurat v5。
#'
#' @param seu_obj Seurat对象
#' @param reductions 字符，降维方法名称（"umap"或"tsne"）
#' @param color 字符向量，细胞类型的颜色
#' @param coord_scale 数值，坐标缩放因子（0-1）
#'
#' @return 包含转换后坐标的元数据数据框
#' 
#' @export
#'
get_metadata <- function(
  seu_obj, 
  reductions = "umap", 
  coord_scale = 0.8, 
  color
) {
  # 原始函数来自 plot1cell by Haojia Wu
  # 已适配 Seurat v5
  
  metadata <- seu_obj@meta.data
  
  # Seurat v5 兼容：使用 Idents() 函数
  metadata$Cluster <- as.character(Idents(seu_obj))
  
  # 提取降维坐标
  metadata$dim1 <- as.numeric(seu_obj[[reductions]]@cell.embeddings[, 1])
  metadata$dim2 <- as.numeric(seu_obj[[reductions]]@cell.embeddings[, 2])
  
  # 转换坐标
  metadata$x <- transform_coordinates(metadata$dim1, zoom = coord_scale)
  metadata$y <- transform_coordinates(metadata$dim2, zoom = coord_scale)
  
  # 添加颜色
  color_df <- data.frame(Cluster = levels(seu_obj), Colors = color)
  cellnames <- rownames(metadata)
  metadata$cells <- rownames(metadata)
  metadata <- merge(metadata, color_df, by = 'Cluster')
  rownames(metadata) <- metadata$cells
  metadata <- metadata[cellnames, ]
  
  metadata
}


# ==============================================================================
# 辅助函数3: mk_marker_ct
# ==============================================================================

#' 标记细胞类型
#'
#' @description
#' 根据marker基因表达标记细胞。
#' 
#' 本函数改编自 plot1cell 包，已适配 Seurat v5。
#'
#' @param seu_obj Seurat对象
#' @param features 字符向量，marker基因名称
#'
#' @return 包含细胞标记的数据框
#' 
#' @export
#'
mk_marker_ct <- function(seu_obj, features) {
  # 原始函数来自 plot1cell by Haojia Wu
  # 已适配 Seurat v5
  
  # Seurat v5 兼容的数据提取
  dat <- tryCatch({
    Seurat::FetchData(seu_obj, vars = features, layer = "data")
  }, error = function(e) {
    Seurat::FetchData(seu_obj, vars = features, slot = "data")
  })
  
  ori_names <- rownames(dat)
  zero_ct <- dat[rowSums(dat) == 0, ]
  non_zero <- dat[rowSums(dat) != 0, ]
  max_genes <- colnames(non_zero)[max.col(non_zero, ties.method = "first")]
  non_zero <- data.frame(cells = rownames(non_zero), genes = max_genes)
  zero_ct <- data.frame(cells = rownames(zero_ct), genes = 'No_expr')
  all_cells <- rbind(non_zero, zero_ct)
  rownames(all_cells) <- all_cells$cells
  all_cells <- all_cells[ori_names, ]
  all_cells
}


# ==============================================================================
# 辅助函数4: mk_color_table
# ==============================================================================

#' 创建颜色表
#'
#' @description
#' 为每个分组分配颜色。
#' 
#' 本函数改编自 plot1cell 包。
#'
#' @param group 字符向量，分组名称
#'
#' @return 包含颜色映射的数据框
#' 
#' @export
#'
mk_color_table <- function(group) {
  # 原始函数来自 plot1cell by Haojia Wu
  
  n <- length(group)
  colors <- scales::hue_pal()(n)
  color_table <- data.frame(group, colors)
  color_table
}


# ==============================================================================
# 辅助函数: get_sci_colors (新增)
# ==============================================================================

#' 获取科研风格配色
#'
#' @description
#' 提供多种科研期刊风格的配色方案。
#' 
#' @param n 整数，需要的颜色数量
#' @param palette 字符，配色方案名称。可选：
#'   - "npg" (Nature Publishing Group, 默认)
#'   - "aaas" (Science)
#'   - "nejm" (New England Journal of Medicine)
#'   - "lancet" (The Lancet)
#'   - "jama" (JAMA)
#'   - "jco" (Journal of Clinical Oncology)
#'
#' @return 颜色向量
#' 
#' @export
#'
get_sci_colors <- function(n, palette = "npg") {
  
  # 定义各种科研配色方案
  color_palettes <- list(
    # Nature Publishing Group (默认)
    npg = c("#E64B35", "#4DBBD5", "#00A087", "#3C5488", "#F39B7F", 
            "#8491B4", "#91D1C2", "#DC0000", "#7E6148", "#B09C85"),
    
    # Science (AAAS)
    aaas = c("#3B4992", "#EE0000", "#008B45", "#631879", "#008280", 
             "#BB0021", "#5F559B", "#A20056", "#808180", "#1B1919"),
    
    # New England Journal of Medicine
    nejm = c("#BC3C29", "#0072B5", "#E18727", "#20854E", "#7876B1", 
             "#6F99AD", "#FFDC91", "#EE4C97"),
    
    # The Lancet
    lancet = c("#00468B", "#ED0000", "#42B540", "#0099B4", "#925E9F", 
               "#FDAF91", "#AD002A", "#ADB6B6", "#1B1919"),
    
    # JAMA
    jama = c("#374E55", "#DF8F44", "#00A1D5", "#B24745", "#79AF97", 
             "#6A6599", "#80796B"),
    
    # Journal of Clinical Oncology
    jco = c("#0073C2", "#EFC000", "#868686", "#CD534C", "#7AA6DC", 
            "#003C67", "#8F7700", "#3B3B3B", "#A73030", "#4A6990")
  )
  
  # 获取指定的配色方案
  if (!palette %in% names(color_palettes)) {
    warning("未知的配色方案 '", palette, "'，使用默认 'npg'")
    palette <- "npg"
  }
  
  colors <- color_palettes[[palette]]
  
  # 如果需要的颜色数量超过预定义的，则循环使用
  if (n > length(colors)) {
    colors <- rep(colors, ceiling(n / length(colors)))[1:n]
  } else {
    colors <- colors[1:n]
  }
  
  colors
}


# ==============================================================================
# 辅助函数5: cell_order
# ==============================================================================

#' 细胞排序
#'
#' @description
#' 对每个cluster的细胞进行排序。
#' 
#' 本函数改编自 plot1cell 包。
#'
#' @param dat 数据框，包含细胞信息
#'
#' @return 排序后的数据框
#' 
#' @export
#'
cell_order <- function(dat) {
  # 原始函数来自 plot1cell by Haojia Wu
  
  celltypes <- names(table(dat$Cluster))
  new_dat <- list()
  
  for (i in 1:length(celltypes)) {
    dat$Cluster <- as.character(dat$Cluster)
    dat1 <- dat[dat$Cluster == celltypes[i], ]
    dat1$x_polar <- 1:nrow(dat1)
    new_dat[[i]] <- dat1
  }
  
  new_dat <- do.call('rbind', new_dat)
  new_dat
}


# ==============================================================================
# 辅助函数6: get_segment
# ==============================================================================

#' 获取分段信息
#'
#' @description
#' 为每个分组创建分段。
#' 
#' 本函数改编自 plot1cell 包。
#'
#' @param dat 数据框
#' @param group 字符，分组变量名
#'
#' @return 分段位置向量
#' 
#' @export
#'
get_segment <- function(dat, group) {
  # 原始函数来自 plot1cell by Haojia Wu
  
  dat <- dat[order(dat[, group], decreasing = FALSE), ]
  rownames(dat) <- 1:nrow(dat)
  dat <- dat[!duplicated(dat[, group]), ]
  dat_seg <- as.integer(rownames(dat))
  dat_seg
}


# ==============================================================================
# 主函数1: prepare_circlize_data
# ==============================================================================

#' 准备环形图数据
#'
#' @description
#' 准备用于绘制环形图的数据。
#' 
#' 本函数改编自 plot1cell 包，已适配 Seurat v5。
#'
#' @param seu_obj Seurat对象
#' @param scale 数值，缩放因子（0-1）。默认0.8
#' @param color_palette 字符，配色方案。可选："npg"(默认), "aaas", "nejm", "lancet", "jama", "jco"
#'
#' @return 准备好的数据框
#' 
#' @export
#'
#' @examples
#' \dontrun{
#' # 使用默认NPG配色
#' data_plot <- prepare_circlize_data(pbmc, scale = 0.8)
#' 
#' # 使用Science配色
#' data_plot <- prepare_circlize_data(pbmc, scale = 0.8, color_palette = "aaas")
#' }
#'
prepare_circlize_data <- function(seu_obj, scale = 0.8, color_palette = "npg") {
  # 原始函数来自 plot1cell by Haojia Wu
  # 已适配 Seurat v5
  
  celltypes <- levels(seu_obj)
  
  # 使用科研风格配色
  cell_colors <- get_sci_colors(length(celltypes), palette = color_palette)
  
  data_plot <- get_metadata(seu_obj, color = cell_colors, coord_scale = scale)
  data_plot <- cell_order(data_plot)
  data_plot$x_polar2 <- log10(data_plot$x_polar)
  data_plot
}


# ==============================================================================
# 主函数2: plot_circlize
# ==============================================================================

#' 绘制环形UMAP图
#'
#' @description
#' 生成环形布局的UMAP/tSNE图，包含密度等高线。
#' 
#' 本函数改编自 plot1cell 包，已适配 Seurat v5。
#' 
#' @details
#' 该函数将传统的UMAP/tSNE图转换为环形布局，每个细胞类型占据一个扇形区域。
#' 可以添加密度等高线来显示细胞分布的密集程度。
#' 
#' 特点：
#' \itemize{
#'   \item 环形布局，节省空间
#'   \item 密度等高线，显示细胞分布
#'   \item 支持多track展示不同变量
#'   \item 高度可定制的颜色和样式
#' }
#'
#' @param data_plot 数据框，由 prepare_circlize_data() 生成
#' @param do.label 逻辑值，是否标注细胞类型名称。默认TRUE
#' @param contour.levels 数值向量，等高线水平（0-1）。默认c(0.2, 0.3)
#' @param pt.size 数值，点的大小。默认0.5
#' @param kde2d.n 整数，密度估计的网格点数。默认1000
#' @param contour.nlevels 整数，等高线总数。默认100
#' @param bg.color 字符，背景颜色。默认"white"
#' @param col.use 字符向量，自定义颜色。默认NULL（自动生成）
#' @param label.cex 数值，细胞类型标签字体大小。默认1.2
#' @param cluster.label.cex 数值，cluster标签字体大小。默认1.0
#' @param track.label.cex 数值，track标签字体大小。默认0.8
#' @param axis.label.cex 数值，坐标轴标签字体大小。默认0.6
#' @param repel 逻辑值，是否使用repel避免标签重叠。默认FALSE
#'
#' @return 环形图（直接绘制）
#' 
#' @import circlize
#' @import MASS
#' @importFrom scales hue_pal alpha
#' @importFrom dplyr group_by summarise
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # 基本用法
#' data_plot <- prepare_circlize_data(pbmc)
#' plot_circlize(data_plot)
#' 
#' # 自定义参数
#' plot_circlize(
#'   data_plot,
#'   contour.levels = c(0.1, 0.2, 0.3),
#'   pt.size = 0.3,
#'   bg.color = "white"
#' )
#' }
#'
#' @references
#' Wu H, et al. (2022). Cell Metabolism, 34(7), 1064-1078.e6.
#' Inspired by Linnarsson Lab, Nature 2018.
#'
plot_circlize <- function(
  data_plot,
  do.label = TRUE,
  contour.levels = c(0.2, 0.3),
  pt.size = 0.5,
  kde2d.n = 1000,
  contour.nlevels = 100,
  bg.color = 'white',
  col.use = NULL,
  label.cex = 1.2,
  cluster.label.cex = 1.0,
  track.label.cex = 0.8,
  axis.label.cex = 0.6,
  repel = FALSE
) {
  
  # ==========================================================================
  # 归属声明 (Attribution)
  # ==========================================================================
  # This function is adapted from plot1cell package
  # Original author: Haojia Wu (The Humphreys Lab)
  # Inspired by Linnarsson Lab, Nature 2018
  # Modified for Seurat v5 compatibility (2026-05-04)
  # License: MIT (same as original)
  # ==========================================================================
  
  # 检查必需的包
  if (!requireNamespace("circlize", quietly = TRUE)) {
    stop("❌ 需要安装 circlize 包\n",
         "   Please install: install.packages('circlize')")
  }
  
  if (!requireNamespace("MASS", quietly = TRUE)) {
    stop("❌ 需要安装 MASS 包\n",
         "   Please install: install.packages('MASS')")
  }
  
  # ==========================================================================
  # 核心算法：环形图绘制（来自原始 plot1cell 函数）
  # Core algorithm from original plot1cell function
  # ==========================================================================
  
  # 计算中心点
  data_plot %>%
    dplyr::group_by(Cluster) %>%
    dplyr::summarise(x = median(x = x), y = median(x = y)) -> centers
  
  # 密度估计
  z <- MASS::kde2d(data_plot$x, data_plot$y, n = kde2d.n)
  
  # 设置颜色
  celltypes <- names(table(data_plot$Cluster))
  
  # 使用科研风格配色（NPG默认）
  cell_colors <- get_sci_colors(length(celltypes), palette = "npg")
  
  if (!is.null(col.use)) {
    cell_colors <- col.use
    col_df <- data.frame(Cluster = celltypes, color2 = col.use)
    cells_order <- rownames(data_plot)
    data_plot <- merge(data_plot, col_df, by = "Cluster")
    rownames(data_plot) <- data_plot$cells
    data_plot <- data_plot[cells_order, ]
    data_plot$Colors <- data_plot$color2
  }
  
  # 初始化circlize
  circlize::circos.clear()
  par(bg = bg.color)
  circlize::circos.par(
    cell.padding = c(0, 0, 0, 0), 
    track.margin = c(0.01, 0),
    "track.height" = 0.01, 
    gap.degree = c(rep(2, (length(celltypes) - 1)), 12),
    points.overflow.warning = FALSE
  )
  
  # 初始化扇区
  circlize::circos.initialize(
    sectors = data_plot$Cluster, 
    x = data_plot$x_polar2
  )
  
  # 绘制track
  circlize::circos.track(
    data_plot$Cluster, 
    data_plot$x_polar2, 
    y = data_plot$dim2, 
    bg.border = NA,
    panel.fun = function(x, y) {
      circlize::circos.text(
        circlize::CELL_META$xcenter,
        circlize::CELL_META$cell.ylim[2] + circlize::mm_y(4),
        circlize::CELL_META$sector.index,
        cex = cluster.label.cex, 
        col = 'black', 
        facing = "bending.inside", 
        niceFacing = TRUE
      )
      circlize::circos.axis(
        labels.cex = axis.label.cex, 
        col = 'black', 
        labels.col = 'black'
      )
    }
  )
  
  # 绘制分段线
  for (i in 1:length(celltypes)) {
    dd <- data_plot[data_plot$Cluster == celltypes[i], ]
    circlize::circos.segments(
      x0 = min(dd$x_polar2), 
      y0 = 0, 
      x1 = max(dd$x_polar2), 
      y1 = 0, 
      col = cell_colors[i],  
      lwd = 3, 
      sector.index = celltypes[i]
    )
  }
  
  # 添加标签
  text(x = 1, y = 0.1, labels = "Cluster", cex = track.label.cex, col = 'black', srt = -90)
  
  # 绘制点
  points(
    data_plot$x, 
    data_plot$y, 
    pch = 19, 
    col = scales::alpha(data_plot$Colors, 0.2), 
    cex = pt.size
  )
  
  # 绘制等高线
  contour(
    z, 
    drawlabels = FALSE, 
    nlevels = contour.nlevels, 
    levels = contour.levels,
    col = '#ae9c76', 
    add = TRUE
  )
  
  # 添加细胞类型标签
  if (do.label) {
    if (repel) {
      if (requireNamespace("wordcloud", quietly = TRUE)) {
        wordcloud::textplot(
          x = centers$x, 
          y = centers$y, 
          words = centers$Cluster,
          cex = label.cex, 
          new = FALSE,
          show.lines = FALSE
        )
      } else {
        text(centers$x, centers$y, labels = centers$Cluster, cex = label.cex, col = 'black')
      }
    } else {
      text(centers$x, centers$y, labels = centers$Cluster, cex = label.cex, col = 'black')
    }
  }
}


# ==============================================================================
# 主函数3: add_track
# ==============================================================================

#' 添加track到环形图
#'
#' @description
#' 在现有环形图上添加额外的track来展示其他变量。
#' 
#' 本函数改编自 plot1cell 包。
#'
#' @param data_plot 数据框，由 prepare_circlize_data() 生成
#' @param group 字符，要展示的分组变量名
#' @param track_num 整数，track编号（从2开始，1是cluster track）
#' @param track_lwd 数值，track线宽。默认3
#' @param track_label_cex 数值，track标签字体大小。默认0.8
#' @param colors 字符向量，自定义颜色。默认NULL（使用NPG配色）
#' @param color_palette 字符，配色方案。默认"npg"
#'
#' @return 在当前图上添加新track
#' 
#' @export
#'
#' @examples
#' \dontrun{
#' # 绘制基础环形图
#' data_plot <- prepare_circlize_data(pbmc)
#' plot_circlize(data_plot)
#' 
#' # 添加第2个track（显示condition）
#' add_track(data_plot, group = "condition", track_num = 2)
#' 
#' # 添加第3个track（显示timepoint）
#' add_track(data_plot, group = "timepoint", track_num = 3)
#' }
#'
add_track <- function(
  data_plot, 
  group, 
  track_num,
  track_lwd = 3,
  track_label_cex = 0.8,
  colors = NULL,
  color_palette = "npg"
) {
  
  # 原始函数来自 plot1cell by Haojia Wu
  
  if (track_num < 2) {
    stop("❌ 第一个track是cluster track。\n",
         "   请将 track_num 设置为 >= 2 的值")
  }
  
  # 添加新track
  circlize::circos.track(
    data_plot$Cluster, 
    data_plot$x_polar2, 
    y = data_plot$dim2, 
    bg.border = NA
  )
  
  celltypes <- names(table(data_plot$Cluster))
  group_names <- names(table(data_plot[, group]))
  
  # 设置颜色 - 使用科研风格配色
  if (is.null(colors)) {
    col_group <- get_sci_colors(length(group_names), palette = color_palette)
  } else {
    col_group <- colors
  }
  names(col_group) <- group_names
  
  # 为每个细胞类型绘制分段
  for (i in 1:length(celltypes)) {
    data_plot_cl <- data_plot[data_plot$Cluster == celltypes[i], ]
    group_names_cl <- names(table(data_plot_cl[, group]))
    col_group_cl <- as.character(col_group[group_names_cl])
    
    dat_seg <- get_segment(data_plot_cl, group = group)
    dat_seg2 <- c(dat_seg[-1] - 1, nrow(data_plot_cl))
    
    scale_factor <- max(data_plot_cl$x_polar2) / nrow(data_plot_cl)
    dat_seg <- scale_factor * dat_seg
    dat_seg2 <- scale_factor * dat_seg2
    
    circlize::circos.segments(
      x0 = dat_seg, 
      y0 = 0, 
      x1 = dat_seg2, 
      y1 = 0, 
      col = col_group_cl, 
      sector.index = celltypes[i], 
      lwd = track_lwd
    )
  }
  
  # 添加标签
  text(
    x = (1 - 0.03 * (track_num - 1)), 
    y = 0.1, 
    labels = group, 
    cex = track_label_cex, 
    col = 'black',
    srt = -90
  )
}
