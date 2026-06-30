/// 折线图组件
/// 支持单组、多组折线图，数据点标记

/// 折线图数据点
pub struct DataPoint {
  x : Double
  y : Double
}

/// 创建数据点
pub fn DataPoint::new(x : Double, y : Double) -> DataPoint {
  { x, y }
}

/// 折线图系列数据
pub struct LineSeries {
  label : String
  points : Array[DataPoint]
  color : String
}

/// 创建折线图系列
pub fn LineSeries::new(label : String, points : Array[DataPoint], color : String) -> LineSeries {
  { label, points, color }
}

/// 折线图配置
pub struct LineChart {
  width : Double
  height : Double
  margin_top : Double
  margin_bottom : Double
  margin_left : Double
  margin_right : Double
  title : String
  theme : @lib.Theme
  datasets : Array[LineSeries]
  show_points : Bool
  show_grid : Bool
  show_legend : Bool
  point_radius : Double
}

/// 创建折线图实例
pub fn LineChart::new(
  width : Double, height : Double,
  datasets : Array[LineSeries],
  theme : @lib.Theme
) -> LineChart {
  LineChart::{
    width, height,
    margin_top: 40.0, margin_bottom: 50.0,
    margin_left: 50.0, margin_right: 30.0,
    title: "", theme, datasets,
    show_points: true, show_grid: true,
    show_legend: true, point_radius: 4.0
  }
}

/// 设置标题
pub fn LineChart::with_title(self : LineChart, title : String) -> LineChart {
  { ..self, title, margin_top: 60.0 }
}

/// 设置边距
pub fn LineChart::with_margin(
  self : LineChart,
  top : Double, bottom : Double, left : Double, right : Double
) -> LineChart {
  { ..self, margin_top: top, margin_bottom: bottom, margin_left: left, margin_right: right }
}

/// 设置是否显示数据点
pub fn LineChart::with_points(self : LineChart, show : Bool) -> LineChart {
  { ..self, show_points: show }
}

/// 渲染为 SVG 字符串
pub fn LineChart::render(self : LineChart) -> String {
  let plot_left = self.margin_left
  let plot_right = self.width - self.margin_right
  let plot_top = self.margin_top
  let plot_bottom = self.height - self.margin_bottom
  let plot_width = plot_right - plot_left
  let plot_height = plot_bottom - plot_top
  let n_datasets = self.datasets.length()

  if n_datasets == 0 {
    return render_empty_line_chart(self.width, self.height, self.theme)
  }

  // 收集所有数据点用于计算坐标范围
  let all_pts = collect_all_points(self.datasets)

  // 计算 X 范围（取索引作为分类值）- 基于最多点的数据集
  let max_pts = find_max_points(self.datasets)
  // 计算 Y 范围
  let (_y_min, y_max) = find_y_range(all_pts)
  let y_scale = @lib.calc_scale(0.0, y_max, 5)

  let mut elements : Array[@lib.SvgElement] = []

  // 背景
  let bg = @lib.SvgRect::new(0.0, 0.0, self.width, self.height, self.theme.background, "none", 0, 0.0, 0.0)
  elements = elements + [@lib.SvgElement::RectElement(bg)]

  // 标题
  if self.title != "" {
    let t = @lib.render_chart_title(self.title, self.width, 24.0, self.theme.title_color, 16, self.theme.font_family)
    elements = elements + [t]
  }

  // 使用共享 AxisConfig 渲染坐标轴
  let axis_config = @lib.default_axis_config()
  let c2 = axis_config
    .with_grid(self.show_grid, self.theme.grid_color)
    .with_y_color(self.theme.axis_color, self.theme.axis_color)
    .with_x_color(self.theme.axis_color, self.theme.axis_color)
  let y_axis_elems = @lib.render_y_axis(c2, y_scale, plot_left, plot_right, plot_top, plot_bottom, self.theme.font_family)
  elements = elements + y_axis_elems

  // X轴标签（基于索引）
  let max_n = max_pts
  let x_labels = render_line_x_labels(max_n, plot_left, plot_right, plot_bottom, self.theme.axis_color, 12, self.theme.font_family)
  elements = elements + x_labels

  // X轴轴线
  let x_axis_line = @lib.SvgLine::new(plot_left, plot_bottom, plot_right, plot_bottom, self.theme.axis_color, 1)
  elements = elements + [@lib.SvgElement::LineElement(x_axis_line)]

  // 绘制折线
  elements = elements + render_lines(self, y_scale, plot_left, plot_right, plot_top, plot_bottom, plot_width, plot_height)

  // 图例（使用共享 Legend 组件）
  if self.show_legend && n_datasets > 1 {
    let legend_items = build_line_legend_items(self)
    let legend_config = @lib.default_legend_config()
    let lc2 = legend_config
      .with_text_color(self.theme.legend_color)
      .with_font(self.theme.font_family, legend_config.font_size)
    let legend = @lib.render_legend(lc2, legend_items, self.width, self.height, plot_left, plot_right, plot_top, plot_bottom)
    elements = elements + legend
  }

  // 渲染文档
  let doc = @lib.SvgDocument::new(self.width.to_int(), self.height.to_int())
  let doc2 = doc.add_elements(elements)
  doc2.render()
}

/// 收集所有数据点
fn collect_all_points(datasets : Array[LineSeries]) -> Array[DataPoint] {
  let mut all : Array[DataPoint] = []
  let mut i = 0
  while i < datasets.length() {
    all = all + datasets[i].points
    i = i + 1
  }
  all
}

/// 找到最多点的数据集点数
fn find_max_points(datasets : Array[LineSeries]) -> Int {
  let mut max_n = 0
  let mut i = 0
  while i < datasets.length() {
    let n = datasets[i].points.length()
    if n > max_n { max_n = n }
    i = i + 1
  }
  if max_n <= 0 { 1 } else { max_n }
}

/// 查找 Y 值范围 (min, max)
fn find_y_range(points : Array[DataPoint]) -> (Double, Double) {
  if points.length() == 0 { return (0.0, 10.0) }
  let mut min_y = points[0].y
  let mut max_y = points[0].y
  let mut i = 0
  while i < points.length() {
    let y = points[i].y
    if y < min_y { min_y = y }
    if y > max_y { max_y = y }
    i = i + 1
  }
  if max_y <= 0.0 { max_y = 10.0 }
  if min_y > 0.0 { min_y = 0.0 }
  (min_y, max_y)
}

/// 渲染 X 轴索引标签
fn render_line_x_labels(
  n : Int,
  plot_left : Double, plot_right : Double, plot_bottom : Double,
  label_color : String, font_size : Int, font_family : String
) -> Array[@lib.SvgElement] {
  let mut labels : Array[@lib.SvgElement] = []
  let cat_width = (plot_right - plot_left) / n.to_double()
  let mut i = 0
  while i < n {
    let cx = plot_left + cat_width * (i.to_double() + 0.5)
    let text = @lib.SvgText::new(
      cx, plot_bottom + font_size.to_double() + 6.0,
      (i + 1).to_string(), font_size, label_color, "middle", font_family
    )
    labels = labels + [@lib.SvgElement::TextElement(text)]
    i = i + 1
  }
  labels
}

/// 渲染折线
fn render_lines(
  chart : LineChart, y_scale : @lib.AxisScale,
  plot_left : Double, plot_right : Double,
  plot_top : Double, plot_bottom : Double,
  plot_width : Double, plot_height : Double
) -> Array[@lib.SvgElement] {
  let mut elements : Array[@lib.SvgElement] = []
  let n_datasets = chart.datasets.length()

  let mut di = 0
  while di < n_datasets {
    let ds = chart.datasets[di]
    let pts = ds.points
    let n_pts = pts.length()
    if n_pts < 2 { di = di + 1; continue }

    // 计算点坐标并构建折线点串
    let max_n = find_max_points(chart.datasets)
    let x_step = if max_n > 1 { plot_width / (max_n - 1).to_double() } else { plot_width }

    let mut mapped_pts : Array[(Double, Double)] = []
    let mut pi = 0
    while pi < n_pts {
      let raw_x = pts[pi].x
      // 用实际 x 值在 0..max_n 范围内映射
      let px = plot_left + raw_x * x_step
      let py = @lib.scale_to_y(pts[pi].y, y_scale, plot_top, plot_bottom)
      mapped_pts = mapped_pts + [(px, py)]
      pi = pi + 1
    }

    // 渲染折线
    let polyline = @lib.SvgPolyline::new(mapped_pts, "none", ds.color, 2)
    elements = elements + [@lib.SvgElement::PolylineElement(polyline)]

    // 渲染数据点
    if chart.show_points {
      let mut pi = 0
      while pi < mapped_pts.length() {
        let (cx, cy) = mapped_pts[pi]
        let circle = @lib.SvgCircle::new(cx, cy, chart.point_radius, ds.color, "white", 2)
        elements = elements + [@lib.SvgElement::CircleElement(circle)]
        pi = pi + 1
      }
    }

    di = di + 1
  }
  elements
}

/// 构建折线图图例数据项
fn build_line_legend_items(chart : LineChart) -> Array[@lib.LegendItem] {
  let mut items : Array[@lib.LegendItem] = []
  let mut i = 0
  while i < chart.datasets.length() {
    let ds = chart.datasets[i]
    items = items + [@lib.LegendItem::new(ds.label, ds.color)]
    i = i + 1
  }
  items
}

/// 渲染空折线图
fn render_empty_line_chart(w : Double, h : Double, theme : @lib.Theme) -> String {
  let doc = @lib.SvgDocument::new(w.to_int(), h.to_int())
  let bg = @lib.SvgRect::new(0.0, 0.0, w, h, theme.background, "none", 0, 0.0, 0.0)
  let msg = @lib.SvgText::new(w / 2.0, h / 2.0, "No data", 14, theme.text_color, "middle", theme.font_family)
  let d0 = doc.add_element(@lib.SvgElement::RectElement(bg))
  let d1 = d0.add_element(@lib.SvgElement::TextElement(msg))
  d1.render()
}
