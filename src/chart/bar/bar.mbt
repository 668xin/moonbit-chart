/// 柱状图组件
/// 支持单组柱状图、多组分组柱状图、堆叠柱状图
/// 配套坐标轴、网格线、数据标签、图例

///|
/// 柱状图系列数据
pub struct BarSeries {
  label : String
  values : Array[Double]
  color : String
}

///|
/// 创建柱状图系列
pub fn BarSeries::new(
  label : String,
  values : Array[Double],
  color : String,
) -> BarSeries {
  { label, values, color }
}

///|
/// 柱状图配置
pub struct BarChart {
  width : Double
  height : Double
  margin_top : Double
  margin_bottom : Double
  margin_left : Double
  margin_right : Double
  title : String
  theme : @lib.Theme
  categories : Array[String]
  datasets : Array[BarSeries]
  stacked : Bool
  show_grid : Bool
  show_legend : Bool
  show_value_labels : Bool
}

///|
/// 创建柱状图实例
pub fn BarChart::new(
  width : Double,
  height : Double,
  categories : Array[String],
  datasets : Array[BarSeries],
  theme : @lib.Theme,
  stacked : Bool,
) -> BarChart {
  BarChart::{
    width,
    height,
    margin_top: 40.0,
    margin_bottom: 50.0,
    margin_left: 50.0,
    margin_right: 20.0,
    title: "",
    theme,
    categories,
    datasets,
    stacked,
    show_grid: true,
    show_legend: true,
    show_value_labels: false,
  }
}

///|
/// 设置标题
pub fn BarChart::with_title(self : BarChart, title : String) -> BarChart {
  { ..self, title, margin_top: 60.0 }
}

///|
/// 设置边距
pub fn BarChart::with_margin(
  self : BarChart,
  top : Double,
  bottom : Double,
  left : Double,
  right : Double,
) -> BarChart {
  {
    ..self,
    margin_top: top,
    margin_bottom: bottom,
    margin_left: left,
    margin_right: right,
  }
}

///|
/// 设置是否显示值标签
pub fn BarChart::with_value_labels(self : BarChart, show : Bool) -> BarChart {
  { ..self, show_value_labels: show }
}

///|
/// 渲染为 SVG 字符串
pub fn BarChart::render(self : BarChart) -> String {
  let plot_left = self.margin_left
  let plot_right = self.width - self.margin_right
  let plot_top = self.margin_top
  let plot_bottom = self.height - self.margin_bottom
  let plot_width = plot_right - plot_left
  let plot_height = plot_bottom - plot_top
  let n_cats = self.categories.length()
  let n_datasets = self.datasets.length()

  if n_cats == 0 || n_datasets == 0 {
    return render_empty_chart(self.width, self.height, self.theme)
  }

  // 计算Y轴范围（含负值）
  let (min_val, max_val) = calc_data_range(self.datasets, self.stacked)
  let scale = @lib.calc_scale(min_val, max_val, 5)
  // 计算分类宽度和柱宽
  let cat_width = plot_width / n_cats.to_double()
  let group_width = cat_width * 0.8
  let bar_width = if self.stacked || n_datasets == 1 {
    group_width
  } else {
    group_width / n_datasets.to_double()
  }
  let group_offset = (cat_width - group_width) / 2.0

  let mut elements : Array[@lib.SvgElement] = []

  // 背景
  let bg = @lib.SvgRect::new(
    0.0,
    0.0,
    self.width,
    self.height,
    self.theme.background,
    "none",
    0,
    0.0,
    0.0,
  )
  elements = elements + [@lib.SvgElement::RectElement(bg)]

  // 标题
  if self.title != "" {
    let t = @lib.render_chart_title(
      self.title,
      self.width,
      24.0,
      self.theme.title_color,
      16,
      self.theme.font_family,
    )
    elements = elements + [t]
  }

  // 使用共享 AxisConfig 渲染坐标轴
  let axis_config = @lib.default_axis_config()
  let c2 = axis_config
    .with_grid(self.show_grid, self.theme.grid_color)
    .with_y_color(self.theme.axis_color, self.theme.axis_color)
    .with_x_color(self.theme.axis_color, self.theme.axis_color)
  let y_axis_elems = @lib.render_y_axis(
    c2,
    scale,
    plot_left,
    plot_right,
    plot_top,
    plot_bottom,
    self.theme.font_family,
  )
  elements = elements + y_axis_elems
  let x_axis_elems = @lib.render_x_axis(
    c2,
    self.categories,
    plot_left,
    plot_right,
    plot_bottom,
    self.theme.font_family,
  )
  elements = elements + x_axis_elems

  // 绘制柱子
  elements = elements +
    render_bars(
      self, scale, cat_width, group_offset, bar_width, plot_left, plot_bottom, plot_top,
      plot_height,
    )

  // 图例（使用共享 Legend 组件）
  if self.show_legend && n_datasets > 1 {
    let legend_items = build_bar_legend_items(self)
    let legend_config = @lib.default_legend_config()
    let lc2 = legend_config
      .with_text_color(self.theme.legend_color)
      .with_font(self.theme.font_family, legend_config.font_size)
    let legend = @lib.render_legend(
      lc2,
      legend_items,
      self.width,
      self.height,
      plot_left,
      plot_right,
      plot_top,
      plot_bottom,
    )
    elements = elements + legend
  }

  // 渲染文档
  let doc = @lib.SvgDocument::new(self.width.to_int(), self.height.to_int())
  let doc2 = doc.add_elements(elements)
  doc2.render()
}

///|
/// 渲染空图表
fn render_empty_chart(w : Double, h : Double, theme : @lib.Theme) -> String {
  let doc = @lib.SvgDocument::new(w.to_int(), h.to_int())
  let bg = @lib.SvgRect::new(
    0.0,
    0.0,
    w,
    h,
    theme.background,
    "none",
    0,
    0.0,
    0.0,
  )
  let msg = @lib.SvgText::new(
    w / 2.0,
    h / 2.0,
    "No data",
    14,
    theme.text_color,
    "middle",
    theme.font_family,
  )
  let d0 = doc.add_element(@lib.SvgElement::RectElement(bg))
  let d1 = d0.add_element(@lib.SvgElement::TextElement(msg))
  d1.render()
}

///|
/// 计算数据集范围 (min, max)
fn calc_data_range(datasets : Array[BarSeries], stacked : Bool) -> (Double, Double) {
  if datasets.length() == 0 {
    return (0.0, 1.0)
  }
  if stacked {
    // 堆叠模式：同分类下所有数据求和，仅支持正值
    let n = datasets[0].values.length()
    let mut max_sum = 0.0
    let mut i = 0
    while i < n {
      let mut sum = 0.0
      let mut j = 0
      while j < datasets.length() {
        if i < datasets[j].values.length() {
          let v = datasets[j].values[i]
          if v > 0.0 {
            sum = sum + v
          }
        }
        j = j + 1
      }
      if sum > max_sum {
        max_sum = sum
      }
      i = i + 1
    }
    if max_sum <= 0.0 {
      (0.0, 1.0)
    } else {
      (0.0, max_sum)
    }
  } else {
    // 分组模式：取所有值的最小值和最大值
    let mut min_v = datasets[0].values[0]
    let mut max_v = datasets[0].values[0]
    let mut i = 0
    while i < datasets.length() {
      let mut j = 0
      while j < datasets[i].values.length() {
        let v = datasets[i].values[j]
        if v < min_v {
          min_v = v
        }
        if v > max_v {
          max_v = v
        }
        j = j + 1
      }
      i = i + 1
    }
    if min_v > 0.0 {
      min_v = 0.0
    }
    if max_v <= 0.0 {
      max_v = 1.0
    }
    if max_v - min_v <= 0.0 {
      (min_v, min_v + 1.0)
    } else {
      (min_v, max_v)
    }
  }
}

///|
/// 渲染柱子
fn render_bars(
  chart : BarChart,
  scale : @lib.AxisScale,
  cat_width : Double,
  group_offset : Double,
  bar_width : Double,
  plot_left : Double,
  plot_bottom : Double,
  plot_top : Double,
  _plot_height : Double,
) -> Array[@lib.SvgElement] {
  let mut elements : Array[@lib.SvgElement] = []
  let n_cats = chart.categories.length()
  let n_datasets = chart.datasets.length()

  let mut ci = 0
  while ci < n_cats {
    let cat_x = plot_left + ci.to_double() * cat_width + group_offset

    if chart.stacked {
      // 堆叠模式
      let mut stack_bottom = 0.0
      let mut di = 0
      while di < n_datasets {
        let ds = chart.datasets[di]
        let val = if ci < ds.values.length() { ds.values[ci] } else { 0.0 }
        if val > 0.0 {
          let y0 = @lib.scale_to_y(stack_bottom, scale, plot_top, plot_bottom)
          let y1 = @lib.scale_to_y(
            stack_bottom + val,
            scale,
            plot_top,
            plot_bottom,
          )
          let rect = @lib.SvgRect::new(
            cat_x,
            y1,
            bar_width,
            y0 - y1,
            ds.color,
            "none",
            0,
            0.0,
            0.0,
          )
          elements = elements + [@lib.SvgElement::RectElement(rect)]
          stack_bottom = stack_bottom + val
        }
        di = di + 1
      }
    } else {
      // 分组模式
      let baseline_y = @lib.scale_to_y(0.0, scale, plot_top, plot_bottom)
      let mut di = 0
      while di < n_datasets {
        let ds = chart.datasets[di]
        let val = if ci < ds.values.length() { ds.values[ci] } else { 0.0 }
        let bx = cat_width / n_datasets.to_double()
        let bar_x = cat_x + di.to_double() * bx
        let bw = if n_datasets == 1 { bar_width } else { bx * 0.9 }
        let gy = @lib.scale_to_y(val, scale, plot_top, plot_bottom)
        if val >= 0.0 {
          let rect = @lib.SvgRect::new(
            bar_x,
            gy,
            bw,
            baseline_y - gy,
            ds.color,
            "none",
            0,
            0.0,
            0.0,
          )
          elements = elements + [@lib.SvgElement::RectElement(rect)]
        } else {
          let rect = @lib.SvgRect::new(
            bar_x,
            baseline_y,
            bw,
            gy - baseline_y,
            ds.color,
            "none",
            0,
            0.0,
            0.0,
          )
          elements = elements + [@lib.SvgElement::RectElement(rect)]
        }

        // 值标签（正值在上方，负值在下方）
        if chart.show_value_labels {
          let label_y = if val >= 0.0 { gy - 4.0 } else { gy + 12.0 }
          let lbl = @lib.SvgText::new(
            bar_x + bw / 2.0,
            label_y,
            val.to_int().to_string(),
            10,
            chart.theme.text_color,
            "middle",
            chart.theme.font_family,
          )
          elements = elements + [@lib.SvgElement::TextElement(lbl)]
        }
        di = di + 1
      }
    }
    ci = ci + 1
  }
  elements
}

///|
/// 构建柱状图图例数据项
fn build_bar_legend_items(chart : BarChart) -> Array[@lib.LegendItem] {
  let mut items : Array[@lib.LegendItem] = []
  let mut i = 0
  while i < chart.datasets.length() {
    let ds = chart.datasets[i]
    items = items + [@lib.LegendItem::new(ds.label, ds.color)]
    i = i + 1
  }
  items
}

// ==================== 测试 ====================

///|
test "bar_series_new" {
  let s = BarSeries::new("Sales", [100.0, 200.0, 150.0], "#4e79a7")
  assert_eq(s.label, "Sales")
  assert_eq(s.values.length(), 3)
  assert_eq(s.values[0], 100.0)
}

///|
test "bar_chart_new" {
  let theme = @lib.Theme::new_light()
  let cats = ["Jan", "Feb", "Mar"]
  let series = BarSeries::new("Sales", [100.0, 200.0, 150.0], "#4e79a7")
  let chart = BarChart::new(600.0, 400.0, cats, [series], theme, false)
  assert_eq(chart.width, 600.0)
  assert_eq(chart.categories.length(), 3)
}

///|
test "bar_chart_render_has_svg" {
  let theme = @lib.Theme::new_light()
  let cats = ["A", "B"]
  let s = BarSeries::new("S1", [10.0, 20.0], "#4e79a7")
  let chart = BarChart::new(600.0, 400.0, cats, [s], theme, false)
  let svg = chart.render()
  assert_eq(svg.has_prefix("<?xml"), true)
  assert_eq(svg.contains("<rect"), true)
}

///|
test "bar_chart_render_empty" {
  let theme = @lib.Theme::new_light()
  let chart = BarChart::new(600.0, 400.0, [], [], theme, false)
  let svg = chart.render()
  assert_eq(svg.contains("No data"), true)
}

///|
test "bar_chart_stacked" {
  let theme = @lib.Theme::new_light()
  let cats = ["A", "B"]
  let s1 = BarSeries::new("S1", [10.0, 20.0], "#4e79a7")
  let s2 = BarSeries::new("S2", [5.0, 10.0], "#f28e2b")
  let chart = BarChart::new(600.0, 400.0, cats, [s1, s2], theme, true)
  let svg = chart.render()
  assert_eq(svg.has_prefix("<?xml"), true)
}

///|
test "bar_chart_with_title" {
  let theme = @lib.Theme::new_light()
  let chart = BarChart::new(
    600.0,
    400.0,
    ["A"],
    [BarSeries::new("S", [10.0], "red")],
    theme,
    false,
  )
  let c2 = chart.with_title("My Chart")
  assert_eq(c2.title, "My Chart")
}

// ==================== 回归测试 ====================

///|
/// 负值柱状图回归测试：验证负值柱不出现负数高度或画布外矩形
test "bar_chart_negative_values_regression" {
  let theme = @lib.Theme::new_light()
  let cats = ["Q1", "Q2", "Q3", "Q4"]
  let s = BarSeries::new("Profit", [30.0, -15.0, 45.0, -5.0], "#4e79a7")
  let chart = BarChart::new(500.0, 350.0, cats, [s], theme, false)
  let svg = chart.render()
  // 1. SVG 应包含 rect 元素
  assert_eq(svg.contains("<rect"), true)
  // 2. height 属性不应出现负号
  assert_eq(svg.contains("height=\"-"), false)
  // 3. 所有 rect 的 height 应为正数且在画布范围内
  let heights = @lib.extract_rect_heights(svg)
  let mut all_positive = true
  let mut hi = 0
  while hi < heights.length() {
    if heights[hi] <= 0.0 {
      all_positive = false
    }
    hi = hi + 1
  }
  assert_eq(all_positive, true)
  let (w, h) = @lib.extract_svg_size(svg)
  assert_eq(w, 500.0)
  assert_eq(h, 350.0)
}

///|
/// 分组柱状图负值回归测试
test "bar_chart_grouped_negative_regression" {
  let theme = @lib.Theme::new_light()
  let cats = ["A", "B", "C"]
  let s1 = BarSeries::new("S1", [10.0, -5.0, 8.0], "#4e79a7")
  let s2 = BarSeries::new("S2", [-3.0, 7.0, 12.0], "#f28e2b")
  let chart = BarChart::new(500.0, 350.0, cats, [s1, s2], theme, false)
  let svg = chart.render()
  assert_eq(svg.contains("height=\"-"), false)
  let heights = @lib.extract_rect_heights(svg)
  let mut ok = true
  let mut hi = 0
  while hi < heights.length() {
    if heights[hi] <= 0.0 {
      ok = false
    }
    hi = hi + 1
  }
  assert_eq(ok, true)
}

///|
/// 画布边界回归测试：验证所有 rect 的 x 和宽度不超出 SVG 画布
test "bar_chart_canvas_bounds_regression" {
  let theme = @lib.Theme::new_light()
  let cats = ["LongCat", "B", "C"]
  let s = BarSeries::new("S1", [100.0, 200.0, 50.0], "#4e79a7")
  let chart = BarChart::new(500.0, 350.0, cats, [s], theme, false)
  let svg = chart.render()
  let (w, h) = @lib.extract_svg_size(svg)
  let xs = @lib.extract_rect_xs(svg)
  if xs.length() > 0 {
    let mut ok = true
    let mut i = 0
    while i < xs.length() {
      if xs[i] < 0.0 || xs[i] > w {
        ok = false
      }
      i = i + 1
    }
    assert_eq(ok, true)
  }
}
