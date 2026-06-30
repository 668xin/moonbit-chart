/// 柱状图组件
/// 支持单组柱状图、多组分组柱状图、堆叠柱状图
/// 配套坐标轴、网格线、数据标签、图例

/// 柱状图系列数据
pub struct BarSeries {
  label : String
  values : Array[Double]
  color : String
}

/// 创建柱状图系列
pub fn BarSeries::new(label : String, values : Array[Double], color : String) -> BarSeries {
  { label, values, color }
}

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

/// 创建柱状图实例
pub fn BarChart::new(
  width : Double, height : Double,
  categories : Array[String],
  datasets : Array[BarSeries],
  theme : @lib.Theme,
  stacked : Bool
) -> BarChart {
  BarChart::{
    width, height,
    margin_top: 40.0, margin_bottom: 50.0,
    margin_left: 50.0, margin_right: 20.0,
    title: "", theme, categories, datasets,
    stacked, show_grid: true, show_legend: true,
    show_value_labels: false
  }
}

/// 设置标题
pub fn BarChart::with_title(self : BarChart, title : String) -> BarChart {
  { ..self, title, margin_top: 60.0 }
}

/// 设置边距
pub fn BarChart::with_margin(
  self : BarChart,
  top : Double, bottom : Double, left : Double, right : Double
) -> BarChart {
  { ..self, margin_top: top, margin_bottom: bottom, margin_left: left, margin_right: right }
}

/// 设置是否显示值标签
pub fn BarChart::with_value_labels(self : BarChart, show : Bool) -> BarChart {
  { ..self, show_value_labels: show }
}

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

  // 计算Y轴范围
  let max_val = calc_max_value(self.datasets, self.stacked)
  let scale = @lib.calc_scale(0.0, max_val, 5)
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
  let bg = @lib.SvgRect::new(0.0, 0.0, self.width, self.height, self.theme.background, "none", 0, 0.0, 0.0)
  elements = elements + [@lib.SvgElement::RectElement(bg)]

  // 标题
  if self.title != "" {
    let t = @lib.render_chart_title(self.title, self.width, 24.0, self.theme.title_color, 16, self.theme.font_family)
    elements = elements + [t]
  }

  // 网格线
  if self.show_grid {
    let grid = @lib.render_hgrid(scale, plot_left, plot_right, plot_top, plot_bottom, self.theme.grid_color)
    elements = elements + grid
  }

  // Y轴标签
  let y_labels = @lib.render_y_labels(scale, plot_left, plot_top, plot_bottom, self.theme.axis_color, 12, self.theme.font_family)
  elements = elements + y_labels

  // X轴标签
  let x_labels = @lib.render_x_labels(self.categories, plot_left, plot_right, plot_bottom, self.theme.axis_color, 12, self.theme.font_family)
  elements = elements + x_labels

  // 坐标轴线
  let x_axis = @lib.SvgLine::new(plot_left, plot_bottom, plot_right, plot_bottom, self.theme.axis_color, 1)
  elements = elements + [@lib.SvgElement::LineElement(x_axis)]
  let y_axis = @lib.SvgLine::new(plot_left, plot_top, plot_left, plot_bottom, self.theme.axis_color, 1)
  elements = elements + [@lib.SvgElement::LineElement(y_axis)]

  // 绘制柱子
  elements = elements + render_bars(self, scale, cat_width, group_offset, bar_width, plot_left, plot_bottom, plot_top, plot_height)

  // 图例
  if self.show_legend && n_datasets > 1 {
    let legend = render_bar_legend(self)
    elements = elements + legend
  }

  // 渲染文档
  let doc = @lib.SvgDocument::new(self.width.to_int(), self.height.to_int())
  let doc2 = doc.add_elements(elements)
  doc2.render()
}

/// 渲染空图表
fn render_empty_chart(w : Double, h : Double, theme : @lib.Theme) -> String {
  let doc = @lib.SvgDocument::new(w.to_int(), h.to_int())
  let bg = @lib.SvgRect::new(0.0, 0.0, w, h, theme.background, "none", 0, 0.0, 0.0)
  let msg = @lib.SvgText::new(w / 2.0, h / 2.0, "No data", 14, theme.text_color, "middle", theme.font_family)
  let d0 = doc.add_element(@lib.SvgElement::RectElement(bg))
  let d1 = d0.add_element(@lib.SvgElement::TextElement(msg))
  d1.render()
}

/// 计算数据集最大值
fn calc_max_value(datasets : Array[BarSeries], stacked : Bool) -> Double {
  if datasets.length() == 0 { return 1.0 }
  if stacked {
    // 堆叠模式：同分类下所有数据求和
    let n = datasets[0].values.length()
    let mut max_sum = 0.0
    let mut i = 0
    while i < n {
      let mut sum = 0.0
      let mut j = 0
      while j < datasets.length() {
        if i < datasets[j].values.length() {
          sum = sum + datasets[j].values[i]
        }
        j = j + 1
      }
      if sum > max_sum { max_sum = sum }
      i = i + 1
    }
    if max_sum <= 0.0 { 1.0 } else { max_sum }
  } else {
    // 分组模式：取所有值的最大值
    let mut max_v = 0.0
    let mut i = 0
    while i < datasets.length() {
      let mut j = 0
      while j < datasets[i].values.length() {
        let v = datasets[i].values[j]
        if v > max_v { max_v = v }
        j = j + 1
      }
      i = i + 1
    }
    if max_v <= 0.0 { 1.0 } else { max_v }
  }
}

/// 渲染柱子
fn render_bars(
  chart : BarChart, scale : @lib.AxisScale,
  cat_width : Double, group_offset : Double, bar_width : Double,
  plot_left : Double, plot_bottom : Double, plot_top : Double, plot_height : Double
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
          let y1 = @lib.scale_to_y(stack_bottom + val, scale, plot_top, plot_bottom)
          let rect = @lib.SvgRect::new(cat_x, y1, bar_width, y0 - y1, ds.color, "none", 0, 0.0, 0.0)
          elements = elements + [@lib.SvgElement::RectElement(rect)]
          stack_bottom = stack_bottom + val
        }
        di = di + 1
      }
    } else {
      // 分组模式
      let mut di = 0
      while di < n_datasets {
        let ds = chart.datasets[di]
        let val = if ci < ds.values.length() { ds.values[ci] } else { 0.0 }
        let bx = cat_width / n_datasets.to_double()
        let bar_x = cat_x + di.to_double() * bx
        let bw = if n_datasets == 1 { bar_width } else { bx * 0.9 }
        let gy = @lib.scale_to_y(val, scale, plot_top, plot_bottom)
        let rect = @lib.SvgRect::new(bar_x, gy, bw, plot_bottom - gy, ds.color, "none", 0, 0.0, 0.0)
        elements = elements + [@lib.SvgElement::RectElement(rect)]

        // 值标签
        if chart.show_value_labels && val > 0.0 {
          let lbl = @lib.SvgText::new(
            bar_x + bw / 2.0, gy - 4.0,
            val.to_int().to_string(), 10, chart.theme.text_color, "middle", chart.theme.font_family
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

/// 渲染柱状图图例
fn render_bar_legend(chart : BarChart) -> Array[@lib.SvgElement] {
  let mut elems : Array[@lib.SvgElement] = []
  let n = chart.datasets.length()
  let legend_y = chart.height - 8.0
  let total_width = n.to_double() * 120.0
  let start_x = (chart.width - total_width) / 2.0

  let mut i = 0
  while i < n {
    let ds = chart.datasets[i]
    let lx = start_x + i.to_double() * 120.0
    let rect = @lib.SvgRect::new(lx, legend_y - 10.0, 12.0, 12.0, ds.color, "none", 0, 0.0, 0.0)
    let text = @lib.SvgText::new(
      lx + 16.0, legend_y,
      ds.label, 11, chart.theme.legend_color, "start", chart.theme.font_family
    )
    elems = elems + [@lib.SvgElement::RectElement(rect)]
    elems = elems + [@lib.SvgElement::TextElement(text)]
    i = i + 1
  }
  elems
}
