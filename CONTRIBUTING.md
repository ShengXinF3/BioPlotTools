# BioPlotTools 贡献指南

## 仓库结构规范

```
BioPlotTools/
├── functions/           # 所有绘图函数
│   ├── transcriptomics/ # 转录组学相关
│   ├── genomics/        # 基因组学相关
│   ├── proteomics/      # 蛋白质组学相关
│   ├── metabolomics/    # 代谢组学相关
│   └── general/         # 通用绘图函数
├── examples/            # 使用示例
├── data/               # 测试数据
└── docs/               # 文档
```

## 函数命名规范

### 命名格式
`plot_<分析类型>_<图表类型>.R`

### 示例
- `plot_gsea.R` - GSEA富集分析图
- `plot_volcano.R` - 火山图
- `plot_heatmap_expr.R` - 表达量热图
- `plot_pca.R` - PCA降维图
- `plot_venn.R` - 韦恩图

## 函数编写规范

### 1. 文件头部注释

```r
#' Plot Title
#'
#' Detailed description of what this function does.
#'
#' @param data Input data description
#' @param ... Other parameters
#'
#' @return Description of return value
#'
#' @examples
#' # Basic usage
#' plot_function(data)
#'
#' @export
```

### 2. 必需的参数

每个绘图函数应包含：
- 数据输入参数
- 输出文件名参数 `output_name`
- 图片尺寸参数 `plot_width`, `plot_height`
- 分辨率参数 `dpi`（默认300）

### 3. 颜色参数

使用描述性的参数名：
- `main_color` - 主要颜色
- `pos_color` / `neg_color` - 正负值颜色
- `group_colors` - 分组颜色向量

### 4. 字体参数

统一使用：
- `base_size` - 基础字号（默认15）
- `title_size` - 标题字号
- `label_size` - 标签字号

### 5. 输出格式

默认同时输出PDF和PNG：
```r
ggsave(paste0(output_name, ".pdf"), plot, width = plot_width, height = plot_height)
ggsave(paste0(output_name, ".png"), plot, width = plot_width, height = plot_height, dpi = dpi)
```

## 示例文件规范

### 命名格式
`<function_name>_example.R`

### 内容结构
```r
# Function Name Example
# Description

# Load required libraries
library(...)

# Load function from GitHub
source("https://raw.githubusercontent.com/ShengXinF3/BioPlotTools/main/functions/xxx.R")

# Step 1: Load data
# ...

# Step 2: Basic usage
# ...

# Step 3: Advanced usage
# ...
```

## 测试数据规范

### 数据格式
- 使用通用格式：CSV, TSV, Excel, RDS
- 文件大小控制在5MB以内
- 提供数据说明文档

### 命名格式
`test_<data_type>_<description>.<ext>`

示例：
- `test_expr_matrix.csv` - 表达矩阵
- `test_deg_results.xlsx` - 差异分析结果
- `test_metadata.csv` - 样本信息

## 文档规范

### README更新

每添加一个新函数，需要在README.md中更新：

```markdown
### plot_function_name()

Brief description.

**Features:**
- Feature 1
- Feature 2

**Quick Start:**
\`\`\`r
source("https://raw.githubusercontent.com/ShengXinF3/BioPlotTools/main/functions/plot_function.R")
plot_function(data)
\`\`\`
```

## 公众号推文规范

### 标题格式
`生信绘图工具 | <具体功能描述>`

### 开头模板
```markdown
# 生信绘图工具 | <具体功能>

这是生信绘图工具系列的第X篇，主要整理一些日常分析中常用的绘图函数，方便自己用，也分享给有需要的人。

今天分享的是<具体分析>的可视化函数。<现有工具的问题>。这个函数<解决方案和特点>。

代码已上传GitHub：https://github.com/ShengXinF3/BioPlotTools
```

### 内容结构
1. 先看效果（配图）
2. 主要功能（3-4个子功能）
3. 使用流程（完整代码示例）
4. 设计细节
5. 参数说明（表格）
6. 实现原理（可选）
7. 使用建议
8. 常见问题
9. 代码获取
10. 总结

## 组学分类建议

### 转录组学 (Transcriptomics)
- GSEA富集分析
- 火山图
- MA图
- 表达热图
- GO/KEGG富集气泡图
- PCA/t-SNE降维图

### 基因组学 (Genomics)
- 曼哈顿图
- QQ图
- LD热图
- 基因组结构图
- CNV图

### 蛋白质组学 (Proteomics)
- 蛋白表达热图
- 蛋白互作网络图
- 修饰位点图

### 代谢组学 (Metabolomics)
- 代谢通路图
- 代谢物相关性网络
- OPLS-DA图

### 通用工具 (General)
- 韦恩图
- UpSet图
- 箱线图/小提琴图
- 相关性热图
- 桑基图

## Git提交规范

### Commit格式
```
<type>: <description>

[optional body]
```

### Type类型
- `feat`: 新增函数
- `fix`: 修复bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 其他修改

### 示例
```
feat: add volcano plot function

- Add plot_volcano.R with customizable colors
- Include example script and test data
- Update README with usage instructions
```

## 版本管理

### 版本号格式
`v<major>.<minor>.<patch>`

- major: 重大更新（不兼容的API修改）
- minor: 新增功能（向后兼容）
- patch: Bug修复

### 更新日志
在CHANGELOG.md中记录每个版本的更新内容。

## 代码质量要求

1. **可读性** - 清晰的变量命名，适当的注释
2. **可维护性** - 模块化设计，避免重复代码
3. **健壮性** - 参数检查，错误处理
4. **性能** - 大数据集的处理效率
5. **兼容性** - 支持常见的R版本和依赖包

## 依赖管理

### 核心依赖
尽量使用常见的包：
- ggplot2 - 绘图
- dplyr - 数据处理
- tidyr - 数据整理

### 可选依赖
特定功能的包在函数文档中说明。

## 问题反馈

使用GitHub Issues进行问题追踪：
- Bug报告
- 功能请求
- 使用问题

## 联系方式

- GitHub: https://github.com/ShengXinF3/BioPlotTools
- Issues: https://github.com/ShengXinF3/BioPlotTools/issues
