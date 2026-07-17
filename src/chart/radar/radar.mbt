/// 雷达图组件
/// 支持多边形网格、多组数据填充、图例

///|
/// 雷达图系列数据
pub struct RadarSeries {
  label : String
  values : Array[Double]
  color : String
}

///|
/// 创建雷达图系列
pub fn RadarSeries::new(
  label : String,
  values : Array[Double],
  color : String,
) -> RadarSeries {
  { label, values, color }
}

///|
/// 雷达图配置
pub struct RadarChart {
  width : Double
  height : Double
  cx : Double
  cy : Double
  radius : Double
  title : String
  theme : @lib.Theme
  categories : Array[String]
  datasets : Array[RadarSeries]
  levels : Int
  show_grid : Bool
  show_legend : Bool
  fill_opacity : Double
}

///|
/// 创建雷达图实例
pub fn RadarChart::new(
  width : Double,
  height : Double,
  categories : Array[String],
  datasets : Array[RadarSeries],
  theme : @lib.Theme,
) -> RadarChart {
  RadarChart::{
    width,
    height,
    cx: width / 2.0,
    cy: height / 2.0 - 20.0,
    radius: if width < height {
      width / 2.0 - 80.0
    } else {
      height / 2.0 - 80.0
    },
    title: "",
    theme,
    categories,
    datasets,
    levels: 5,
    show_grid: true,
    show_legend: true,
    fill_opacity: 0.2,
  }
}

///|
/// 设置标题
pub fn RadarChart::with_title(self : RadarChart, title : String) -> RadarChart {
  { ..self, title, cy: self.height / 2.0 - 30.0 }
}

///|
/// 设置网格层级数
pub fn RadarChart::with_levels(self : RadarChart, levels : Int) -> RadarChart {
  { ..self, levels, }
}

///|
/// 设置填充透明度
pub fn RadarChart::with_opacity(
  self : RadarChart,
  opacity : Double,
) -> RadarChart {
  { ..self, fill_opacity: opacity }
}

///|
/// 渲染为 SVG 字符串
pub fn RadarChart::render(self : RadarChart) -> String {
  let n_axes = self.categories.length()
  let n_datasets = self.datasets.length()

  if n_axes == 0 || n_datasets == 0 {
    return render_empty_radar_chart(self.width, self.height, self.theme)
  }

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
      20.0,
      self.theme.title_color,
      16,
      self.theme.font_family,
    )
    elements = elements + [t]
  }

  let angle_step = 2.0 * @math.PI / n_axes.to_double()

  // 网格线
  if self.show_grid {
    let grid = render_radar_grid(
      self,
      angle_step,
      self.cx,
      self.cy,
      self.radius,
    )
    elements = elements + grid
  }

  // 轴线和标签
  let axis_elems = render_radar_axes(
    self,
    angle_step,
    self.cx,
    self.cy,
    self.radius,
  )
  elements = elements + axis_elems

  // 数据集
  let data_elems = render_radar_data(
    self,
    angle_step,
    self.cx,
    self.cy,
    self.radius,
  )
  elements = elements + data_elems

  // 图例
  if self.show_legend && n_datasets > 1 {
    let legend = render_radar_legend(self)
    elements = elements + legend
  }

  // 渲染文档
  let doc = @lib.SvgDocument::new(self.width.to_int(), self.height.to_int())
  let doc2 = doc.add_elements(elements)
  doc2.render()
}

///|
/// 获取轴顶点坐标
fn get_axis_point(
  cx : Double,
  cy : Double,
  r : Double,
  angle : Double,
) -> (Double, Double) {
  (cx + r * @math.cos(angle), cy + r * @math.sin(angle))
}

///|
/// 渲染雷达图网格
fn render_radar_grid(
  chart : RadarChart,
  angle_step : Double,
  cx : Double,
  cy : Double,
  r : Double,
) -> Array[@lib.SvgElement] {
  let mut elements : Array[@lib.SvgElement] = []
  let n_axes = chart.categories.length()

  // 同心多边形网格
  let mut level = 1
  while level <= chart.levels {
    let lr = r * level.to_double() / chart.levels.to_double()
    let mut pts : Array[(Double, Double)] = []
    let mut ai = 0
    while ai < n_axes {
      let angle = ai.to_double() * angle_step - @math.PI / 2.0
      let (px, py) = get_axis_point(cx, cy, lr, angle)
      pts = pts + [(px, py)]
      ai = ai + 1
    }
    let poly = @lib.SvgPolygon::new(pts, "none", chart.theme.grid_color, 1)
    elements = elements + [@lib.SvgElement::PolygonElement(poly)]
    level = level + 1
  }

  // 中心到顶点的辐射线
  let mut ai = 0
  while ai < n_axes {
    let angle = ai.to_double() * angle_step - @math.PI / 2.0
    let (px, py) = get_axis_point(cx, cy, r, angle)
    let line = @lib.SvgLine::new(cx, cy, px, py, chart.theme.grid_color, 1)
    elements = elements + [@lib.SvgElement::LineElement(line)]
    ai = ai + 1
  }

  elements
}

///|
/// 渲染雷达图轴标签
fn render_radar_axes(
  chart : RadarChart,
  angle_step : Double,
  cx : Double,
  cy : Double,
  r : Double,
) -> Array[@lib.SvgElement] {
  let mut elements : Array[@lib.SvgElement] = []
  let n_axes = chart.categories.length()
  let label_r = r + 20.0

  let mut i = 0
  while i < n_axes {
    let angle = i.to_double() * angle_step - @math.PI / 2.0
    let (lx, ly) = get_axis_point(cx, cy, label_r, angle)
    let anchor = if angle < -@math.PI / 4.0 && angle > -3.0 * @math.PI / 4.0 {
      "middle"
    } else if angle < @math.PI / 4.0 && angle > -@math.PI / 4.0 {
      "start"
    } else {
      "end"
    }
    let text = @lib.SvgText::new(
      lx,
      ly + 4.0,
      chart.categories[i],
      11,
      chart.theme.axis_color,
      anchor,
      chart.theme.font_family,
    )
    elements = elements + [@lib.SvgElement::TextElement(text)]
    i = i + 1
  }
  elements
}

///|
/// 计算数据点的最大范围（用于归一化，带数据净化）
fn calc_radar_max(chart : RadarChart) -> Double {
  let mut max_v = 0.0
  let mut di = 0
  while di < chart.datasets.length() {
    let mut vi = 0
    while vi < chart.datasets[di].values.length() {
      let v = @lib.sanitize_number(chart.datasets[di].values[vi])
      if v > max_v {
        max_v = v
      }
      vi = vi + 1
    }
    di = di + 1
  }
  if max_v <= 0.0 {
    1.0
  } else {
    max_v
  }
}

///|
/// 渲染雷达图数据
fn render_radar_data(
  chart : RadarChart,
  angle_step : Double,
  cx : Double,
  cy : Double,
  r : Double,
) -> Array[@lib.SvgElement] {
  let mut elements : Array[@lib.SvgElement] = []
  let n_axes = chart.categories.length()
  let max_val = calc_radar_max(chart)

  let mut di = chart.datasets.length() - 1
  while di >= 0 {
    let ds = chart.datasets[di]
    let n_vals = ds.values.length()
    let mut pts : Array[(Double, Double)] = []
    let mut ai = 0
    while ai < n_axes {
      let val = if ai < n_vals { ds.values[ai] } else { 0.0 }
      let ratio = val / max_val
      let pt_r = r * ratio
      let angle = ai.to_double() * angle_step - @math.PI / 2.0
      let (px, py) = get_axis_point(cx, cy, pt_r, angle)
      pts = pts + [(px, py)]
      ai = ai + 1
    }
    // 填充区域
    let fill_color = ds.color
    let poly = @lib.SvgPolygon::new(pts, fill_color, ds.color, 2)
    elements = elements + [@lib.SvgElement::PolygonElement(poly)]

    // 数据点标记（带悬浮 Tooltip）
    let mut pi = 0
    while pi < pts.length() {
      let (px, py) = pts[pi]
      let dot_elem = @lib.SvgElement::CircleElement(
        @lib.SvgCircle::new(px, py, 3.0, ds.color, "white", 1),
      )
      // 添加悬浮 Tooltip
      let cat_label = if pi < chart.categories.length() {
        chart.categories[pi]
      } else {
        ""
      }
      let val = if pi < ds.values.length() { ds.values[pi] } else { 0.0 }
      let tt_text = ds.label +
        " - " +
        cat_label +
        ": " +
        val.to_int().to_string()
      elements = elements + [@lib.with_tooltip(dot_elem, tt_text)]
      pi = pi + 1
    }

    di = di - 1
  }
  elements
}

///|
/// 渲染雷达图图例
fn render_radar_legend(chart : RadarChart) -> Array[@lib.SvgElement] {
  let mut elems : Array[@lib.SvgElement] = []
  let n = chart.datasets.length()
  let legend_y = chart.height - 8.0
  let total_width = n.to_double() * 120.0
  let start_x = (chart.width - total_width) / 2.0

  let mut i = 0
  while i < n {
    let ds = chart.datasets[i]
    let lx = start_x + i.to_double() * 120.0
    let rect = @lib.SvgRect::new(
      lx,
      legend_y - 10.0,
      12.0,
      12.0,
      ds.color,
      "none",
      0,
      0.0,
      0.0,
    )
    let text = @lib.SvgText::new(
      lx + 16.0,
      legend_y,
      ds.label,
      11,
      chart.theme.legend_color,
      "start",
      chart.theme.font_family,
    )
    elems = elems + [@lib.SvgElement::RectElement(rect)]
    elems = elems + [@lib.SvgElement::TextElement(text)]
    i = i + 1
  }
  elems
}

///|
/// 渲染空雷达图
fn render_empty_radar_chart(
  w : Double,
  h : Double,
  theme : @lib.Theme,
) -> String {
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

// ==================== 测试 ====================

///|
test "radar_series_new" {
  let s = RadarSeries::new("Score", [80.0, 70.0, 90.0], "#4e79a7")
  assert_eq(s.label, "Score")
  assert_eq(s.values.length(), 3)
}

///|
test "radar_chart_new" {
  let theme = @lib.Theme::new_light()
  let cats = ["A", "B", "C", "D"]
  let s = RadarSeries::new("S1", [50.0, 60.0, 70.0, 80.0], "#4e79a7")
  let chart = RadarChart::new(400.0, 400.0, cats, [s], theme)
  assert_eq(chart.radius > 0.0, true)
  assert_eq(chart.levels, 5)
}

///|
test "radar_chart_render" {
  let theme = @lib.Theme::new_light()
  let cats = ["A", "B", "C", "D"]
  let s = RadarSeries::new("S1", [50.0, 60.0, 70.0, 80.0], "#4e79a7")
  let chart = RadarChart::new(400.0, 400.0, cats, [s], theme)
  let svg = chart.render()
  assert_eq(svg.has_prefix("<?xml"), true)
  assert_eq(svg.contains("<polygon"), true)
}

///|
test "radar_chart_render_empty" {
  let theme = @lib.Theme::new_light()
  let chart = RadarChart::new(400.0, 400.0, [], [], theme)
  let svg = chart.render()
  assert_eq(svg.contains("No data"), true)
}
