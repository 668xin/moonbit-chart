# 668xin/moonbit-chart

MoonBit 原生可视化图表库，基于 SVG 渲染，支持浅色/深色双主题。可发布到 [mooncakes.io](https://mooncakes.io) 的标准 MoonBit 包。

## 项目架构

```
src/
├── lib/          # 底层绘图基座
│   ├── element   #  SVG 元素构建器（8 种：rect/circle/path/text/line/polyline/polygon/group）
│   ├── svg       #  SVG 文档管理（宽高、元素集合、完整渲染）
│   ├── theme     #  浅色/深色双主题（12 字段、Tableau 10 调色板）
│   ├── color     #  颜色工具（r/g/b/a + to_css）
│   ├── geometry  #  几何结构体（Point/Rect）
│   ├── axis      #  坐标轴配置（刻度计算、Y轴映射）
│   ├── legend    #  图例组件（4 种位置：bottom/top/left/right）
│   └── tooltip   #  提示框组件
├── chart/        # 图表组件层
│   ├── bar       #  柱状图（单组/分组/堆叠、负值支持）
│   ├── line      #  折线图（单组/多组、数据点标记）
│   ├── pie       #  饼图（扇形计算、百分比标签）
│   └── radar     #  雷达图（多边形网格、多组叠加）
├── cli/          # 命令行工具（MD → HTML）
└── md/           # Markdown 转换器
    ├── md_parser     #  图表块解析
    ├── md_renderer   #  内联渲染（粗体/斜体/代码/链接）
    ├── chart_factory #  图表工厂
    ├── html_renderer #  HTML 页面生成
    ├── md_types      #  类型定义
    └── converter     #  转换管道

demo/           # 可运行 Demo（18 个示例）
  ├── demo_bar.mbt          # 单组/分组/堆叠柱状图
  ├── demo_line.mbt         # 单组/多组折线图
  ├── demo_pie.mbt          # 饼图 / 简化饼图
  ├── demo_radar.mbt        # 双组/三组雷达图
  └── demo_edge_cases.mbt   # 暗色主题 / 负值 / 大数据 / 空数据

scripts/        # 辅助脚本（PowerShell 包装）
  └── moonbit-chart.ps1     # MD 文件 → HTML 页面
```

## 快速上手

### 前置条件

安装 MoonBit 工具链：

```bash
# Windows (PowerShell)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm https://cli.moonbitlang.com/install/powershell.ps1 | iex

# macOS / Linux
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash
```

### 构建与测试

```bash
# 克隆仓库
git clone https://github.com/668xin/moonbit-chart.git
cd moonbit-chart

# 构建所有模块
moon build

# 运行全部测试（80 个用例）
moon test

# 运行 Demo
moon run demo
```

### 命令行工具

将 Markdown 文件（含图表配置块）转换为完整 HTML 可视化页面：

```powershell
# PowerShell 包装脚本
.\scripts\moonbit-chart.ps1 charts.md report.html

# 或直接用 moonrun
$content = Get-Content -Raw charts.md
moonrun _build/wasm-gc/debug/build/src/cli/cli.wasm $content > output.html
```

## 图表配置语法

在 Markdown 中嵌入图表，使用 `@chart:` 标记块：

```markdown
@chart: bar
title: Monthly Sales
width: 600
height: 400
theme: light
stacked: false
categories: Jan, Feb, Mar, Apr, May, Jun
dataset: Product A, #4E79A7, 120, 200, 150, 80, 230, 180
dataset: Product B, #F28E2B, 90, 140, 200, 160, 120, 210
@end
```

支持的图表类型：`bar`（柱状图）、`line`（折线图）、`pie`（饼图）、`radar`（雷达图）。

配置项说明：
| 配置项 | 必选 | 说明 |
|--------|------|------|
| `title` | 否 | 图表标题 |
| `width` / `height` | 否 | 画布尺寸，默认 600×400 |
| `theme` | 否 | `light`（默认）/ `dark` |
| `stacked` | 否 | 柱状图是否堆叠，默认 false |
| `categories` | 是 | X轴标签，逗号分隔 |
| `dataset` | 是 | 数据系列：`标签, 颜色, 数值...` |

## API 参考

### 底层绘图基座

```moonbit
// SVG 文档
let doc = @lib.SvgDocument::new(800, 600)
let doc2 = doc.add_element("<rect x=\"10\" y=\"10\" width=\"100\" height=\"50\" fill=\"#4E79A7\"/>")
let svg_string = doc2.render()

// 主题
let light = @lib.Theme::new_light()
let dark  = @lib.Theme::new_dark()
let color = @lib.get_palette_color(light, 3)  // 调色板循环

// 颜色
let c = @lib.Color::red()
let css = c.to_css()  // "rgba(255,0,0,1.0)"

// 坐标轴
let config = @lib.AxisConfig::new()
  .with_max(300.0)
  .with_tick_count(5)
```

### 图表组件

```moonbit
// 柱状图
let series = @bar.BarSeries::new("Sales", [120.0, 200.0, 150.0], colors[0])
let chart = @bar.BarChart::new(600.0, 400.0, ["Jan", "Feb", "Mar"], [series], theme, false)
let svg = chart.with_title("Monthly Sales").render()

// 折线图
let pts = [@line.DataPoint::new(0.0, 200.0), @line.DataPoint::new(1.0, 150.0)]
let ds = @line.LineSeries::new("Series A", pts, colors[0])
let chart = @line.LineChart::new(500.0, 350.0, [ds], theme)
let svg = chart.with_title("Line Chart").render()

// 饼图
let slices = [@pie.PieSlice::new("A", 35.0, colors[0]), @pie.PieSlice::new("B", 25.0, colors[1])]
let chart = @pie.PieChart::new(450.0, 400.0, slices, theme)
let svg = chart.with_title("Pie Chart").render()

// 雷达图
let s1 = @radar.RadarSeries::new("Team A", [90.0, 80.0, 70.0], colors[0])
let chart = @radar.RadarChart::new(450.0, 420.0, ["Speed", "Quality", "Cost"], [s1], theme)
let svg = chart.with_title("Radar Chart").render()
```

## 演示示例

运行全部 18 个 Demo：

```bash
moon run demo
```

包括：单组/分组/堆叠柱状图、单组/多组折线图、饼图、雷达图，以及暗色主题、负值、大数据量、空数据等边界示例。

## 两种输出产物

### SVG 字符串

通过各图表组件的 `.render()` 方法获取符合 SVG 标准的 XML 字符串，可直接嵌入 HTML 或保存为 `.svg` 文件。

### MD 转 HTML 可视化页面

通过命令行工具将 Markdown 文件转换为完整的 HTML 页面，所有图表以 SVG 内嵌：

```powershell
.\scripts\moonbit-chart.ps1 charts.md report.html
```

## 发布到 mooncakes.io

```bash
moon build       # 构建检查
moon test        # 运行 80 个测试
moon login       # 登录 mooncakes.io
moon publish     # 发布
```

## CI 自动化

GitHub Actions 流水线（`.github/workflows/ci.yml`），每次推送自动执行：

- `moon check` + `moon fmt --check` + `moon info`
- `moon build`
- `moon test`

## 边界兼容

- **空数据**：无数据时显示空白图表标题
- **负值**：柱状图自动处理负值（反向绘制）
- **超大数据**：坐标轴自动缩放
- **多组堆叠**：支持多组数据堆叠柱状图
- **暗色主题**：全部图表支持 `Theme::new_dark()`

## 许可证

MIT License — 详见 [LICENSE](LICENSE)
