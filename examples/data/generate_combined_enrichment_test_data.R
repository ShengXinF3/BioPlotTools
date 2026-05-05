# ========== 生成富集分析组合图测试数据 ==========
# 
# 如果没有安装clusterProfiler，可以使用这个脚本生成模拟数据进行测试

library(dplyr)
library(writexl)

cat("\n========== 生成富集分析组合图测试数据 ==========\n")

# 创建输出目录
output_dir <- "examples/data"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# ============================================================================
# 步骤1: 生成GO BP数据
# ============================================================================

cat("\n步骤1: 生成GO BP数据...\n")

go_bp_data <- data.frame(
  ID = paste0("GO:", sprintf("%07d", 1:10)),
  Description = c(
    "regulation of cell proliferation",
    "apoptotic process",
    "cell cycle checkpoint",
    "DNA repair",
    "response to DNA damage stimulus",
    "regulation of transcription from RNA polymerase II promoter",
    "signal transduction",
    "protein phosphorylation",
    "cell differentiation",
    "negative regulation of cell growth"
  ),
  GeneRatio = c("25/80", "22/80", "18/80", "20/80", "19/80", 
                "23/80", "21/80", "17/80", "16/80", "15/80"),
  BgRatio = c("500/18000", "450/18000", "380/18000", "420/18000", "400/18000",
              "480/18000", "460/18000", "360/18000", "340/18000", "320/18000"),
  pvalue = c(1e-8, 5e-8, 1e-7, 3e-7, 5e-7, 8e-7, 1e-6, 2e-6, 3e-6, 5e-6),
  p.adjust = c(1e-6, 5e-6, 1e-5, 3e-5, 5e-5, 8e-5, 1e-4, 2e-4, 3e-4, 5e-4),
  qvalue = c(8e-7, 4e-6, 8e-6, 2e-5, 4e-5, 6e-5, 8e-5, 1.5e-4, 2.5e-4, 4e-4),
  geneID = c(
    "TP53/MYC/BRCA1/EGFR/KRAS/PTEN/RB1/APC/CDKN2A/PIK3CA",
    "TP53/BAX/BCL2/CASP3/CASP8/CASP9/APAF1/CYCS/BID/BAK1",
    "TP53/RB1/CDKN2A/CDK4/CDK6/E2F1/CCND1/ATM/CHEK1/CHEK2",
    "TP53/BRCA1/BRCA2/ATM/MLH1/MSH2/XRCC1/PARP1/RAD51/ERCC1",
    "TP53/ATM/BRCA1/BRCA2/CHEK1/CHEK2/RAD51/XRCC1/PARP1/MLH1",
    "TP53/MYC/JUN/FOS/STAT3/CTNNB1/SMAD2/SMAD3/E2F1/SP1",
    "EGFR/KRAS/BRAF/PIK3CA/AKT1/MTOR/MAPK1/RAF1/MEK1/ERK1",
    "EGFR/KRAS/BRAF/PIK3CA/AKT1/MTOR/CDK4/CDK6/JAK2/ABL1",
    "TP53/MYC/NOTCH1/CTNNB1/SMAD2/SMAD3/TGFB1/WNT1/BMP2/RUNX2",
    "TP53/PTEN/RB1/CDKN2A/TSC1/TSC2/NF1/VHL/APC/SMAD4"
  ),
  Count = c(25, 22, 18, 20, 19, 23, 21, 17, 16, 15)
)

cat("  - 生成", nrow(go_bp_data), "条GO BP记录\n")

# ============================================================================
# 步骤2: 生成GO CC数据
# ============================================================================

cat("\n步骤2: 生成GO CC数据...\n")

go_cc_data <- data.frame(
  ID = paste0("GO:", sprintf("%07d", 101:108)),
  Description = c(
    "nucleus",
    "cytoplasm",
    "plasma membrane",
    "mitochondrion",
    "endoplasmic reticulum",
    "Golgi apparatus",
    "cytoskeleton",
    "extracellular region"
  ),
  GeneRatio = c("30/80", "28/80", "25/80", "20/80", "18/80", "16/80", "15/80", "14/80"),
  BgRatio = c("3000/18000", "2800/18000", "2500/18000", "2000/18000", 
              "1800/18000", "1600/18000", "1500/18000", "1400/18000"),
  pvalue = c(1e-7, 5e-7, 1e-6, 3e-6, 5e-6, 8e-6, 1e-5, 2e-5),
  p.adjust = c(1e-5, 5e-5, 1e-4, 3e-4, 5e-4, 8e-4, 1e-3, 2e-3),
  qvalue = c(8e-6, 4e-5, 8e-5, 2e-4, 4e-4, 6e-4, 8e-4, 1.5e-3),
  geneID = c(
    "TP53/MYC/BRCA1/RB1/E2F1/STAT3/JUN/FOS/SMAD2/SMAD3",
    "EGFR/KRAS/BRAF/PIK3CA/AKT1/MTOR/MAPK1/RAF1/MEK1/ERK1",
    "EGFR/ERBB2/MET/ALK/RET/FGFR2/PDGFRA/KIT/FLT3/VEGFR2",
    "BAX/BCL2/CYCS/APAF1/CASP9/ATP5A/COX1/ND1/CYTB/SOD2",
    "ATM/BRCA1/BRCA2/PARP1/XRCC1/ERCC1/XPA/XPC/DDB1/DDB2",
    "TGFB1/SMAD2/SMAD3/BMP2/BMPR1A/ACVR1/LTBP1/LTBP2/LTBP3/LTBP4",
    "CTNNB1/APC/CDH1/CTNNA1/CTNND1/ACTB/TUBB/VIM/KRT8/KRT18",
    "VEGFA/TGFA/EGF/IGF1/PDGFB/FGF2/HGF/ANGPT1/ANGPT2/CXCL12"
  ),
  Count = c(30, 28, 25, 20, 18, 16, 15, 14)
)

cat("  - 生成", nrow(go_cc_data), "条GO CC记录\n")

# ============================================================================
# 步骤3: 生成GO MF数据
# ============================================================================

cat("\n步骤3: 生成GO MF数据...\n")

go_mf_data <- data.frame(
  ID = paste0("GO:", sprintf("%07d", 201:208)),
  Description = c(
    "protein kinase activity",
    "transcription factor activity",
    "DNA binding",
    "protein binding",
    "ATP binding",
    "enzyme binding",
    "receptor activity",
    "signal transducer activity"
  ),
  GeneRatio = c("22/80", "20/80", "24/80", "35/80", "18/80", "16/80", "15/80", "17/80"),
  BgRatio = c("800/18000", "750/18000", "900/18000", "1200/18000", 
              "700/18000", "650/18000", "600/18000", "680/18000"),
  pvalue = c(1e-7, 3e-7, 5e-7, 8e-7, 1e-6, 2e-6, 3e-6, 5e-6),
  p.adjust = c(1e-5, 3e-5, 5e-5, 8e-5, 1e-4, 2e-4, 3e-4, 5e-4),
  qvalue = c(8e-6, 2e-5, 4e-5, 6e-5, 8e-5, 1.5e-4, 2.5e-4, 4e-4),
  geneID = c(
    "EGFR/BRAF/PIK3CA/AKT1/MTOR/CDK4/CDK6/JAK2/ABL1/SRC",
    "TP53/MYC/JUN/FOS/STAT3/E2F1/SP1/CREB1/NFKB1/RELA",
    "TP53/MYC/JUN/FOS/STAT3/E2F1/SP1/CREB1/NFKB1/RELA/CTNNB1/SMAD2",
    "TP53/BRCA1/EGFR/KRAS/BRAF/PIK3CA/AKT1/MTOR/RB1/MYC/PTEN/ATM/BCL2/BAX/CASP3",
    "EGFR/KRAS/BRAF/AKT1/MTOR/CDK4/CDK6/JAK2/ABL1/ATP5A",
    "EGFR/KRAS/BRAF/PIK3CA/AKT1/MTOR/RAF1/MEK1/ERK1/MAPK1",
    "EGFR/ERBB2/MET/ALK/RET/FGFR2/PDGFRA/KIT/FLT3/VEGFR2",
    "EGFR/KRAS/BRAF/PIK3CA/AKT1/MTOR/STAT3/JAK2/SMAD2/SMAD3"
  ),
  Count = c(22, 20, 24, 35, 18, 16, 15, 17)
)

cat("  - 生成", nrow(go_mf_data), "条GO MF记录\n")

# ============================================================================
# 步骤4: 生成KEGG数据
# ============================================================================

cat("\n步骤4: 生成KEGG数据...\n")

kegg_data <- data.frame(
  ID = paste0("hsa", sprintf("%05d", 1:10)),
  Description = c(
    "Pathways in cancer",
    "PI3K-Akt signaling pathway",
    "MAPK signaling pathway",
    "p53 signaling pathway",
    "Cell cycle",
    "Apoptosis",
    "Focal adhesion",
    "Ras signaling pathway",
    "EGFR tyrosine kinase inhibitor resistance",
    "Breast cancer"
  ),
  GeneRatio = c("28/80", "25/80", "23/80", "18/80", "20/80", 
                "17/80", "22/80", "21/80", "16/80", "19/80"),
  BgRatio = c("530/8000", "480/8000", "450/8000", "380/8000", "420/8000",
              "360/8000", "460/8000", "440/8000", "340/8000", "400/8000"),
  pvalue = c(1e-9, 5e-9, 1e-8, 3e-8, 5e-8, 8e-8, 1e-7, 2e-7, 3e-7, 5e-7),
  p.adjust = c(1e-7, 5e-7, 1e-6, 3e-6, 5e-6, 8e-6, 1e-5, 2e-5, 3e-5, 5e-5),
  qvalue = c(8e-8, 4e-7, 8e-7, 2e-6, 4e-6, 6e-6, 8e-6, 1.5e-5, 2.5e-5, 4e-5),
  geneID = c(
    "TP53/MYC/BRCA1/EGFR/KRAS/BRAF/PIK3CA/AKT1/PTEN/RB1/CDKN2A/ERBB2/MET/ALK",
    "EGFR/PIK3CA/AKT1/MTOR/PTEN/ERBB2/MET/IGF1/PDGFRA/KIT/FLT3/VEGFR2/FGFR2",
    "EGFR/KRAS/BRAF/RAF1/MEK1/ERK1/MAPK1/JUN/FOS/MYC/TP53/CASP3",
    "TP53/MDM2/MDM4/CDKN2A/CCND1/CDK4/CDK6/BAX/BCL2/CASP3/CASP8/CASP9",
    "TP53/RB1/CDKN2A/CCND1/CDK4/CDK6/E2F1/MYC/ATM/CHEK1/CHEK2/WEE1",
    "TP53/BAX/BCL2/BCL2L1/CASP3/CASP8/CASP9/APAF1/CYCS/BID/BAK1/BAD",
    "EGFR/ERBB2/MET/PIK3CA/AKT1/PTEN/SRC/PTK2/PXN/VCL/TLN1/ITGB1",
    "KRAS/HRAS/NRAS/BRAF/RAF1/MEK1/ERK1/PIK3CA/AKT1/RALGDS/RAC1/CDC42",
    "EGFR/ERBB2/KRAS/BRAF/PIK3CA/AKT1/MTOR/MET/IGF1R/FGFR1/PDGFRA",
    "TP53/BRCA1/BRCA2/ERBB2/ESR1/PGR/PIK3CA/AKT1/PTEN/CDH1/CCND1/MYC"
  ),
  Count = c(28, 25, 23, 18, 20, 17, 22, 21, 16, 19)
)

cat("  - 生成", nrow(kegg_data), "条KEGG记录\n")

# ============================================================================
# 步骤5: 保存数据
# ============================================================================

cat("\n步骤5: 保存数据...\n")

# 保存为Excel（多个sheet）
write_xlsx(
  list(
    GO_BP = go_bp_data,
    GO_CC = go_cc_data,
    GO_MF = go_mf_data,
    KEGG = kegg_data
  ),
  path = file.path(output_dir, "test_data_combined_enrichment.xlsx")
)

cat("  ✓ 已保存: test_data_combined_enrichment.xlsx\n")

# 也保存为CSV（分别保存）
write.csv(go_bp_data, file.path(output_dir, "test_data_go_bp.csv"), row.names = FALSE)
write.csv(go_cc_data, file.path(output_dir, "test_data_go_cc.csv"), row.names = FALSE)
write.csv(go_mf_data, file.path(output_dir, "test_data_go_mf.csv"), row.names = FALSE)
write.csv(kegg_data, file.path(output_dir, "test_data_kegg.csv"), row.names = FALSE)

cat("  ✓ 已保存: test_data_go_bp.csv\n")
cat("  ✓ 已保存: test_data_go_cc.csv\n")
cat("  ✓ 已保存: test_data_go_mf.csv\n")
cat("  ✓ 已保存: test_data_kegg.csv\n")

# ============================================================================
# 总结
# ============================================================================

cat("\n========== 数据生成完成！ ==========\n")
cat("\n生成的数据文件:\n")
cat("  - test_data_combined_enrichment.xlsx (包含4个sheet)\n")
cat("  - test_data_go_bp.csv (GO Biological Process)\n")
cat("  - test_data_go_cc.csv (GO Cellular Component)\n")
cat("  - test_data_go_mf.csv (GO Molecular Function)\n")
cat("  - test_data_kegg.csv (KEGG Pathway)\n")

cat("\n数据摘要:\n")
cat("  - GO BP:", nrow(go_bp_data), "条记录\n")
cat("  - GO CC:", nrow(go_cc_data), "条记录\n")
cat("  - GO MF:", nrow(go_mf_data), "条记录\n")
cat("  - KEGG:", nrow(kegg_data), "条记录\n")

cat("\n使用方法:\n")
cat("  # 读取数据\n")
cat("  library(readxl)\n")
cat("  go_bp <- read_excel('test_data_combined_enrichment.xlsx', sheet = 'GO_BP')\n")
cat("  go_cc <- read_excel('test_data_combined_enrichment.xlsx', sheet = 'GO_CC')\n")
cat("  go_mf <- read_excel('test_data_combined_enrichment.xlsx', sheet = 'GO_MF')\n")
cat("  kegg <- read_excel('test_data_combined_enrichment.xlsx', sheet = 'KEGG')\n")
cat("\n")
cat("  # 绘图\n")
cat("  result <- plot_combined_enrichment(\n")
cat("    enrichment_list = list(BP = go_bp, CC = go_cc, MF = go_mf, KEGG = kegg),\n")
cat("    top_n = 5\n")
cat("  )\n")

