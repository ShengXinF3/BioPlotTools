# ========== 准备测试数据：从公开数据集创建带注释的Seurat对象 ==========
# 
# 本脚本从Seurat官方数据集下载PBMC数据，并添加模拟的组间比较条件

# 设置CRAN镜像
options(repos = c(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))

# 安装和加载必要的包
required_packages <- c("Seurat", "SeuratData", "tidyverse", "ggplot2")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    if (pkg == "SeuratData") {
      # SeuratData需要从GitHub安装
      if (!require("remotes", quietly = TRUE)) {
        install.packages("remotes")
      }
      remotes::install_github("satijalab/seurat-data", quiet = TRUE)
    } else {
      install.packages(pkg, quiet = TRUE)
    }
    library(pkg, character.only = TRUE)
  }
}

cat("========== 步骤1: 下载PBMC数据集 ==========\n")

# 初始化seu对象
seu <- NULL

# 方法1：使用SeuratData包下载（推荐）
seu <- tryCatch({
  # 安装PBMC3k数据集
  if (!"pbmc3k" %in% InstalledData()$Dataset) {
    InstallData("pbmc3k")
  }
  
  # 加载数据
  data("pbmc3k")
  cat("✓ 成功从SeuratData加载PBMC3k数据集\n")
  pbmc3k
  
}, error = function(e) {
  cat("! SeuratData方法失败，尝试从URL直接下载...\n")
  
  # 方法2：从URL直接下载
  url <- "https://cf.10xgenomics.com/samples/cell/pbmc3k/pbmc3k_filtered_gene_bc_matrices.tar.gz"
  download.file(url, destfile = "pbmc3k.tar.gz")
  untar("pbmc3k.tar.gz")
  
  # 读取数据
  pbmc.data <- Read10X(data.dir = "filtered_gene_bc_matrices/hg19/")
  seu_obj <- CreateSeuratObject(counts = pbmc.data, project = "pbmc3k", min.cells = 3, min.features = 200)
  
  cat("✓ 成功从URL下载并加载数据\n")
  seu_obj
})

# 检查是否成功加载
if (is.null(seu)) {
  stop("无法加载PBMC数据集，请检查网络连接")
}

cat("\n========== 步骤2: 标准化和降维分析 ==========\n")

# 如果数据还没有经过标准化处理
if (!"RNA" %in% names(seu@assays) || is.null(seu@reductions$umap)) {
  
  # 质控
  seu[["percent.mt"]] <- PercentageFeatureSet(seu, pattern = "^MT-")
  seu <- subset(seu, subset = nFeature_RNA > 200 & nFeature_RNA < 2500 & percent.mt < 5)
  
  # 标准化
  seu <- NormalizeData(seu, normalization.method = "LogNormalize", scale.factor = 10000)
  
  # 寻找高变基因
  seu <- FindVariableFeatures(seu, selection.method = "vst", nfeatures = 2000)
  
  # 标准化
  all.genes <- rownames(seu)
  seu <- ScaleData(seu, features = all.genes)
  
  # PCA降维
  seu <- RunPCA(seu, features = VariableFeatures(object = seu), verbose = FALSE)
  
  # UMAP降维
  seu <- RunUMAP(seu, dims = 1:10, verbose = FALSE)
  
  # 聚类
  seu <- FindNeighbors(seu, dims = 1:10, verbose = FALSE)
  seu <- FindClusters(seu, resolution = 0.4, verbose = FALSE)
  
  cat("✓ 完成标准化和降维分析\n")
}

cat("\n========== 步骤3: 细胞类型注释 ==========\n")

# 使用已知的marker基因进行细胞类型注释
# 基于Seurat官方教程的注释
# PBMC3k标准有8个主要细胞类型，但聚类可能产生9个cluster
new.cluster.ids <- c(
  "CD4 T", "CD14 Mono", "B", "CD8 T", 
  "NK", "FCGR3A Mono", "DC", "Platelet", "Megakaryocyte"
)

# 检查聚类数量并调整注释
n_clusters <- length(unique(Idents(seu)))
cat(paste0("检测到 ", n_clusters, " 个clusters\n"))

if (n_clusters > length(new.cluster.ids)) {
  # 如果cluster数量超过预定义类型，使用通用注释
  new.cluster.ids <- paste0("Cluster_", 0:(n_clusters-1))
  cat("! 使用通用聚类注释（Cluster_0 到 Cluster_", n_clusters-1, "）\n")
} else if (n_clusters < length(new.cluster.ids)) {
  # 如果cluster数量少于预定义类型，截取
  new.cluster.ids <- new.cluster.ids[1:n_clusters]
  cat("✓ 使用标准细胞类型注释（前", n_clusters, "个类型）\n")
} else {
  cat("✓ 使用标准细胞类型注释\n")
}

names(new.cluster.ids) <- levels(seu)
seu <- RenameIdents(seu, new.cluster.ids)
seu$cell_type <- Idents(seu)

cat("\n========== 步骤4: 添加模拟的组间比较条件 ==========\n")

# 为了测试组间比较功能，我们添加模拟的实验条件
set.seed(123)

# 方案1：随机分配Treatment和Control组
n_cells <- ncol(seu)
seu$condition <- sample(c("Treatment", "Control"), n_cells, replace = TRUE, prob = c(0.5, 0.5))

# 方案2：添加时间点信息
seu$timepoint <- sample(c("Day0", "Day7", "Day14"), n_cells, replace = TRUE)

# 方案3：添加样本ID（模拟多个生物学重复）
seu$sample_id <- paste0(
  seu$condition, "_",
  sample(c("Rep1", "Rep2", "Rep3"), n_cells, replace = TRUE)
)

# 方案4：添加基因型信息
seu$genotype <- sample(c("WT", "KO"), n_cells, replace = TRUE, prob = c(0.6, 0.4))

# 方案5：组合条件（用于测试复杂比较）
seu$group <- paste(seu$genotype, seu$condition, sep = "_")

cat("✓ 添加了以下元数据列：\n")
cat("  - condition: Treatment vs Control\n")
cat("  - timepoint: Day0, Day7, Day14\n")
cat("  - sample_id: 组合样本标识\n")
cat("  - genotype: WT vs KO\n")
cat("  - group: 组合分组\n")

cat("\n========== 步骤5: 添加细胞亚型注释（用于密度图测试）==========\n")

# 为主要细胞类型添加亚型
seu$cell_subtype <- as.character(seu$cell_type)

# 为T细胞添加亚型
t_cells <- which(seu$cell_type %in% c("CD4 T", "CD8 T"))
if (length(t_cells) > 0) {
  seu$cell_subtype[t_cells] <- paste0(
    seu$cell_type[t_cells], "_",
    sample(c("Naive", "Memory", "Effector"), length(t_cells), replace = TRUE)
  )
}

# 为单核细胞添加亚型
mono_cells <- which(grepl("Mono", seu$cell_type))
if (length(mono_cells) > 0) {
  seu$cell_subtype[mono_cells] <- paste0(
    seu$cell_type[mono_cells], "_",
    sample(c("Classical", "NonClassical"), length(mono_cells), replace = TRUE)
  )
}

cat("✓ 添加了细胞亚型注释\n")

cat("\n========== 步骤6: 保存数据 ==========\n")

# 保存完整的Seurat对象
output_file <- "examples/data/pbmc3k_annotated_test.rds"
saveRDS(seu, file = output_file)

cat(paste0("✓ 数据已保存到: ", output_file, "\n"))
cat(paste0("  文件大小: ", round(file.size(output_file) / 1024^2, 2), " MB\n"))

cat("\n========== 步骤7: 数据摘要 ==========\n")

cat(paste0("细胞数量: ", ncol(seu), "\n"))
cat(paste0("基因数量: ", nrow(seu), "\n"))
cat("\n细胞类型分布:\n")
print(table(seu$cell_type))
cat("\n实验条件分布:\n")
print(table(seu$condition))
cat("\n基因型分布:\n")
print(table(seu$genotype))
