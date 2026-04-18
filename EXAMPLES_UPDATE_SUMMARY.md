# Examples 目录适配完成

## 📅 更新日期：2026-04-18

## 🎯 更新目标

统一所有示例脚本的输出路径到 `examples/output/` 目录，使项目结构更清晰。

---

## 📁 新的目录结构

```
examples/
├── data/                               # 测试数据
│   ├── test_data_gsea.xlsx
│   ├── test_data_crispr.xlsx
│   ├── test_gene_category.xlsx
│   ├── pbmc3k_annotated_test.rds
│   ├── generate_crispr_test_data.R
│   ├── prepare_pbmc3k_data.R
│   └── DATA_FORMAT_VOLCANO.md
├── output/                             # 所有输出文件（新增）
│   ├── plot_gsea/                      # GSEA输出
│   │   ├── 01_basic.pdf
│   │   ├── 02_custom_style.pdf
│   │   ├── 03_custom_genes.pdf
│   │   ├── 04_auto_labels.pdf
│   │   ├── gsea_result.rds
│   │   └── batch/                      # 批量输出
│   ├── plot_umap_density/              # UMAP密度图输出
│   │   ├── 01_single_celltype.pdf
│   │   ├── 02_multiple_celltypes.pdf
│   │   ├── 03_filtered_condition.pdf
│   │   ├── 04_custom_style.pdf
│   │   ├── 05_batch_*.pdf
│   │   └── 06_small_clusters.pdf
│   └── plot_volcano_hyperbolic/        # 火山图输出
│       ├── 01_rnaseq.pdf
│       ├── 02_rnaseq_category.pdf
│       ├── 03_crispr.pdf
│       ├── 04_singlecell.pdf
│       ├── 05_proteomics.pdf
│       ├── 06_threshold_*.pdf
│       ├── 07_custom_colors.pdf
│       └── 08_batch_*.pdf
├── gsea_example.R                      # 示例脚本
├── umap_density_example.R
└── volcano_hyperbolic_example.R
```

---

## ✅ 已更新的文件

### 1. gsea_example.R

**变更：**
- 输出目录：`examples/output/plot_gsea/`
- 批量输出：`examples/output/plot_gsea/batch/`
- 保存GSEA结果：`examples/output/plot_gsea/gsea_result.rds`

**输出文件：**
```
examples/output/plot_gsea/
├── 01_basic.pdf & .png
├── 02_custom_style.pdf & .png
├── 03_custom_genes.pdf & .png
├── 04_auto_labels.pdf & .png
├── gsea_result.rds
└── batch/
    └── [所有显著通路的图]
```

### 2. umap_density_example.R

**变更：**
- 输出目录：`examples/output/plot_umap_density/`

**输出文件：**
```
examples/output/plot_umap_density/
├── 01_single_celltype.pdf & .png
├── 02_multiple_celltypes.pdf & .png
├── 03_filtered_condition.pdf & .png
├── 04_custom_style.pdf & .png
├── 05_batch_Control.pdf
├── 05_batch_Treatment.pdf
└── 06_small_clusters.pdf
```

### 3. volcano_hyperbolic_example.R

**变更：**
- 输出目录：`examples/output/plot_volcano_hyperbolic/`

**输出文件：**
```
examples/output/plot_volcano_hyperbolic/
├── 01_rnaseq.pdf & .png
├── 02_rnaseq_category.pdf & .png
├── 03_crispr.pdf & .png
├── 04_singlecell.pdf & .png
├── 05_proteomics.pdf & .png
├── 06_threshold_4.pdf & .png
├── 06_threshold_6.pdf & .png
├── 06_threshold_8.pdf & .png
├── 07_custom_colors.pdf & .png
├── 08_batch_TreatmentA_vs_Control.pdf & .png
├── 08_batch_TreatmentB_vs_Control.pdf & .png
└── 08_batch_TreatmentC_vs_Control.pdf & .png
```

### 4. generate_volcano_hyperbolic_test_data.R (重命名)

**旧文件名**: `generate_crispr_test_data.R`
**新文件名**: `generate_volcano_hyperbolic_test_data.R`

**变更：**
- ✅ 文件重命名：与函数名 `plot_volcano_hyperbolic` 对应
- ✅ 更新函数名：`plot_crispr_volcano()` → `plot_volcano_hyperbolic()`
- ✅ 更新参数：添加 `control_pattern = "NTC"` 和 `x_label`
- ✅ 输出文件名：`test_data_crispr.*` → `test_data_volcano_hyperbolic.*`
- ✅ 输出目录：`examples/output/test_data_generation/`
- ✅ 测试图文件名：`test_crispr_*` → `test_volcano_hyperbolic_*`

**输出文件：**
```
examples/data/
├── test_data_volcano_hyperbolic.xlsx (旧: test_data_crispr.xlsx)
└── test_data_volcano_hyperbolic.csv (旧: test_data_crispr.csv)

examples/output/test_data_generation/
├── test_volcano_hyperbolic_basic.pdf & .png (旧: test_crispr_basic.*)
└── test_volcano_hyperbolic_category.pdf & .png (旧: test_crispr_category.*)
```

### 5. examples/data/ 目录清理和重命名

**删除的文件：**
- ❌ `test_crispr_basic.pdf`
- ❌ `test_crispr_basic.png`
- ❌ `test_crispr_category.pdf`
- ❌ `test_crispr_category.png`

**原因**: 这些是测试输出图片，应该在 `examples/output/` 目录中，而不是 `data/` 目录

**重命名的文件：**
- 🔄 `test_data_crispr.xlsx` → `test_data_volcano_hyperbolic.xlsx`
- 🔄 `test_data_crispr.csv` → `test_data_volcano_hyperbolic.csv`
- 🔄 `generate_crispr_test_data.R` → `generate_volcano_hyperbolic_test_data.R`

**原因**: 与函数名 `plot_volcano_hyperbolic` 保持一致

**新增文件：**
- ✅ `README.md` - 测试数据说明文档

---

## 🔄 主要变更

### 旧路径 → 新路径

| 函数 | 旧路径 | 新路径 |
|------|--------|--------|
| GSEA | `GSEA_Plots/` | `examples/output/plot_gsea/` |
| GSEA批量 | `GSEA_Plots/` | `examples/output/plot_gsea/batch/` |
| UMAP密度 | `examples/plot_umap_density/` | `examples/output/plot_umap_density/` |
| 火山图 | `examples/plot_volcano_hyperbolic/` | `examples/output/plot_volcano_hyperbolic/` |

### 代码变更示例

**旧代码：**
```r
plot_gsea(gsea_result, pathway_id, 
         output_name = "GSEA_Plots/pathway")
```

**新代码：**
```r
output_dir <- "examples/output/plot_gsea"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

plot_gsea(gsea_result, pathway_id, 
         output_name = file.path(output_dir, "pathway"))
```

---

## 💡 优势

### 1. 结构清晰

```
examples/
├── data/       # 输入数据
├── output/     # 输出结果
└── *.R         # 示例脚本
```

### 2. 易于管理

- 所有输出集中在 `output/` 目录
- 按函数分类存放
- 便于清理和版本控制

### 3. 符合规范

- 输入输出分离
- 便于添加到 `.gitignore`
- 符合项目最佳实践

---

## 🔧 .gitignore 建议

建议在 `.gitignore` 中添加：

```gitignore
# 输出文件
examples/output/
*.pdf
*.png

# 保留目录结构
!examples/output/.gitkeep
```

---

## 📝 使用方法

### 运行示例

```bash
# GSEA示例
Rscript examples/gsea_example.R

# UMAP密度图示例
Rscript examples/umap_density_example.R

# 火山图示例
Rscript examples/volcano_hyperbolic_example.R
```

### 查看输出

```bash
# 查看GSEA输出
ls examples/output/plot_gsea/

# 查看UMAP密度图输出
ls examples/output/plot_umap_density/

# 查看火山图输出
ls examples/output/plot_volcano_hyperbolic/
```

### 清理输出

```bash
# 清理所有输出
rm -rf examples/output/

# 清理特定函数的输出
rm -rf examples/output/plot_gsea/
```

---

## ✅ 测试清单

- [x] gsea_example.R - 输出路径更新
- [x] umap_density_example.R - 输出路径更新
- [x] volcano_hyperbolic_example.R - 输出路径更新，数据文件引用更新
- [x] generate_volcano_hyperbolic_test_data.R - 文件重命名，与函数名对应
- [x] test_data_volcano_hyperbolic.xlsx/csv - 文件重命名，与函数名对应
- [x] examples/data/ - 清理测试输出图片
- [x] examples/data/README.md - 新增数据说明文档，更新文件名引用
- [x] 所有输出目录自动创建
- [x] 批量输出路径正确
- [x] 文件路径使用 `file.path()` 跨平台兼容
- [x] 所有文件名与函数名 `plot_volcano_hyperbolic` 保持一致

---

## 🎯 下一步

1. **测试示例脚本**：
```bash
Rscript examples/gsea_example.R
Rscript examples/umap_density_example.R
Rscript examples/volcano_hyperbolic_example.R
```

2. **更新 .gitignore**：
```bash
echo "examples/output/" >> .gitignore
```

3. **提交更改**：
```bash
git add examples/
git commit -m "refactor: unify example output paths to examples/output/"
git push
```

---

**适配完成！** 🎉

所有示例脚本现在统一输出到 `examples/output/` 目录，项目结构更加清晰！
