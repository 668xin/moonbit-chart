# xinxin/moonbit-chart

MoonBit 原生可视化图表库，基于 SVG 渲染，支持浅色/深色双主题。可发布到 [mooncakes.io](https://mooncakes.io) 的标准 MoonBit 包。

## 项目架构

项目按四层模块化设计，职责单一，禁止跨层调用：

```
src/
├── lib/          # 第1层：底层绘图基座
│   ├── render/   #   SVG 渲染基座
│   ├── color/    #   颜色工具
│   ├── geometry/ #   几何计算工具
│   └── theme/    #   浅色/深色双主题
├── chart/        # 第2层：图表组件层
│   ├── bar/      #   柱状图
│   ├── line/     #   折线图
│   ├── pie/      #   饼图
│   ├── radar/    #   雷达图
│   ├── tooltip/  #   数据提示
│   └── legend/   #   图例
├── cli/          # 第3层：命令行工具
└── md/           # 第4层：Markdown 转 HTML 转换器
```

## 快速上手

### 前置条件

安装 MoonBit 工具链：

```bash
# Windows (PowerShell)
curl -fsSL https://cli.moonbitlang.com/install.ps1 | iex

# macOS / Linux
curl -fsSL https://cli.moonbitlang.com/install.sh | bash
```

### 构建项目

```bash
# 克隆仓库
git clone <repo-url>
cd moonbit

# 构建所有模块
moon build

# 运行测试
moon test

# 运行 Demo
moon run demo
```

### 运行命令行工具

```bash
moon run src/cli -- input.md output.html
```

## API 文档

### 第1层：底层绘图基座（src/lib/）

#### SvgDocument（SVG 渲染基座）

SVG 文档的构建和渲染。

```moonbit
let doc = SvgDocument::new(800, 600)
let doc = doc.add_element("<rect x=\"10\" y=\"10\" width=\"100\" height=\"50\" fill=\"blue\"/>")
let svg_string = doc.render()
```

| 方法                              | 说明                      |
| --------------------------------- | ------------------------- |
| `SvgDocument::new(width, height)` | 创建指定宽高的 SVG 文档   |
| `add_element(element)`            | 添加 SVG 元素字符串       |
| `render()`                        | 渲染为完整 SVG XML 字符串 |

#### Color（颜色工具）

颜色定义和转换。

```moonbit
let c = Color::red()
let css = c.to_css()  // "rgba(255,0,0,1.0)"
```

| 方法                                                          | 说明                 |
| ------------------------------------------------------------- | -------------------- |
| `Color::{r, g, b, a}`                                         | 创建 RGBA 颜色       |
| `Color::red()` / `green()` / `blue()` / `black()` / `white()` | 预定义颜色           |
| `to_css()`                                                    | 转为 CSS rgba 字符串 |

#### Theme（主题系统）

支持浅色/深色双主题。

```moonbit
let light = get_light_theme()
let dark  = get_dark_theme()
```

| 属性         | 说明                     |
| ------------ | ------------------------ |
| `mode`       | 主题模式（Light / Dark） |
| `background` | 背景色                   |
| `text_color` | 文字颜色                 |
| `grid_color` | 网格线颜色               |
| `axis_color` | 坐标轴颜色               |

#### Geometry（几何工具）

坐标和区域计算。

```moonbit
let p = Point::new(100, 200)
let r = Rect::new(0, 0, 800, 600)
```

### 第2层：图表组件（src/chart/）

当前为骨架阶段，各图表组件提供以下统一接口（待实现）：

| 组件         | 文件             | 说明                      |
| ------------ | ---------------- | ------------------------- |
| `BarChart`   | `chart/bar/`     | 柱状图，支持单组/多组堆叠 |
| `LineChart`  | `chart/line/`    | 折线图，支持单组/多组     |
| `PieChart`   | `chart/pie/`     | 饼图                      |
| `RadarChart` | `chart/radar/`   | 雷达图                    |
| `Tooltip`    | `chart/tooltip/` | 数据提示                  |
| `Legend`     | `chart/legend/`  | 图例                      |

### 第3层：命令行工具（src/cli/）

读取 Markdown 文件，输出包含可视化图表的完整 HTML 页面。

```bash
moon run src/cli -- <input.md> [output.html]
```

### 第4层：MD 转换工具（src/md/）

解析 Markdown 中的图表标记，生成 HTML 可视化页面。

## 示例

项目包含 4 个 Demo 示例，覆盖柱状图、折线图、饼图、雷达图：

```bash
moon run demo
```

运行后将依次展示各图表类型的示例输出。

## 输出产物

### SVG 字符串

通过 `SvgDocument::render()` 获取符合 SVG 标准的 XML 字符串，可直接嵌入 HTML 或保存为 `.svg` 文件。

### MD 转 HTML 可视化页面

通过命令行工具将 Markdown 文件转换为完整的 HTML 页面，包含内嵌图表。

## 发布到 mooncakes.io

```bash
# 构建检查
moon build

# 运行测试
moon test

# 登录 mooncakes
moon login

# 发布
moon publish
```

## CI 自动化

项目内置 GitHub Actions 流水线（`.github/workflows/ci.yml`），每次推送自动执行：

- `moon build` — 编译所有模块
- `moon test` — 运行单元测试

## 开发辅助脚本

辅助脚本位于 `scripts/` 目录，使用 JS/TS/Python 编写，仅用于：

- 本地预览 SVG 效果
- 批量生成测试数据
- 自动生成 Demo 文档

核心图表渲染、MD 转 HTML 逻辑全部由 MoonBit 实现，不依赖辅助脚本运行。

## 兼容性说明

图表组件在设计上考虑了以下边界情况：

- **空数据**：无数据时显示空白图表或友好提示
- **超大数值**：自动缩放坐标轴
- **负数**：坐标轴自适应包含负值区间
- **多组堆叠**：支持多组数据堆叠显示
