/// 饼图组件
/// 支持扇形区域、百分比标签、图例

///|
/// 饼图数据项
pub struct PieSlice {
  label : String
  value : Double
  color : String
}

///|
/// 创建饼图数据项
pub fn PieSlice::new(
  label : String,
  value : Double,
  color : String,
) -> PieSlice {
  { label, value, color }
}

///|
/// 饼图配置
pub struct PieChart {
  width : Double
  height : Double
  cx : Double
  cy : Double
  radius : Double
  title : String
  theme : @lib.Theme
  data : Array[PieSlice]
  show_labels : Bool
  show_percent : Bool
  show_legend : Bool
}

///|
/// 创建饼图实例
pub fn PieChart::new(
  width : Double,
  height : Double,
  data : Array[PieSlice],
  theme : @lib.Theme,
) -> PieChart {
  PieChart::{
    width,
    height,
    cx: width / 2.0,
    cy: height / 2.0,
    radius: if width < height {
      width / 2.0 - 60.0
    } else {
      height / 2.0 - 60.0
    },
    title: "",
    theme,
    data,
    show_labels: true,
    show_percent: true,
    show_legend: true,
  }
}

///|
/// 设置标题
pub fn PieChart::with_title(self : PieChart, title : String) -> PieChart {
  { ..self, title, cy: self.height / 2.0 - 10.0 }
}

///|
/// 设置饼图半径
pub fn PieChart::with_radius(self : PieChart, radius : Double) -> PieChart {
  { ..self, radius, }
}

///|
/// 设置是否显示标签
pub fn PieChart::with_labels(self : PieChart, show : Bool) -> PieChart {
  { ..self, show_labels: show }
}

///|
/// 渲染为 SVG 字符串
pub fn PieChart::render(self : PieChart) -> String {
  let n = self.data.length()

  if n == 0 {
    return render_empty_pie_chart(self.width, self.height, self.theme)
  }

  // 计算总和
  let total = sum_values(self.data)
  if total <= 0.0 {
    return render_empty_pie_chart(self.width, self.height, self.theme)
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
      22.0,
      self.theme.title_color,
      16,
      self.theme.font_family,
    )
    elements = elements + [t]
  }

  // 绘制扇形
  let slices = render_pie_slices(self, self.cx, self.cy, self.radius, total)
  elements = elements + slices

  // 标签和百分比
  if self.show_labels || self.show_percent {
    let labels = render_pie_labels(self, self.cx, self.cy, self.radius, total)
    elements = elements + labels
  }

  // 图例
  if self.show_legend && n > 1 {
    let legend = render_pie_legend(self)
    elements = elements + legend
  }

  // 渲染文档
  let doc = @lib.SvgDocument::new(self.width.to_int(), self.height.to_int())
  let doc2 = doc.add_elements(elements)
  doc2.render()
}

///|
/// 计算数据项总和（带数据净化）
fn sum_values(data : Array[PieSlice]) -> Double {
  let mut s = 0.0
  let mut i = 0
  while i < data.length() {
    s = s + @lib.sanitize_number(data[i].value)
    i = i + 1
  }
  s
}

///|
/// 构建 SVG 弧路径
fn arc_path(
  cx : Double,
  cy : Double,
  r : Double,
  start_angle : Double,
  end_angle : Double,
) -> String {
  let x1 = cx + r * @math.cos(start_angle)
  let y1 = cy + r * @math.sin(start_angle)
  let x2 = cx + r * @math.cos(end_angle)
  let y2 = cy + r * @math.sin(end_angle)
  let sweep = end_angle - start_angle
  let large_flag = if sweep > @math.PI { 1 } else { 0 }
  "M " +
  cx.to_string() +
  " " +
  cy.to_string() +
  " L " +
  x1.to_string() +
  " " +
  y1.to_string() +
  " A " +
  r.to_string() +
  " " +
  r.to_string() +
  " 0 " +
  large_flag.to_string() +
  " 1 " +
  x2.to_string() +
  " " +
  y2.to_string() +
  " Z"
}

///|
/// 渲染饼图扇形（带悬浮 Tooltip）
fn render_pie_slices(
  chart : PieChart,
  cx : Double,
  cy : Double,
  r : Double,
  total : Double,
) -> Array[@lib.SvgElement] {
  let mut elements : Array[@lib.SvgElement] = []
  let mut start_angle = -@math.PI / 2.0 // 从12点钟方向开始
  let mut i = 0
  while i < chart.data.length() {
    let slice = chart.data[i]
    let sweep = slice.value / total * 2.0 * @math.PI
    let end_angle = start_angle + sweep
    let path_data = arc_path(cx, cy, r, start_angle, end_angle)
    let path = @lib.SvgPath::new(path_data, slice.color, "white", 1)
    let path_elem = @lib.SvgElement::PathElement(path)
    // 添加悬浮 Tooltip
    let pct = (slice.value / total * 100.0).to_int()
    let tt_text = slice.label +
      ": " +
      slice.value.to_int().to_string() +
      " (" +
      pct.to_string() +
      "%)"
    elements = elements + [@lib.with_tooltip(path_elem, tt_text)]
    start_angle = end_angle
    i = i + 1
  }
  elements
}

///|
/// 渲染饼图标签和百分比
fn render_pie_labels(
  chart : PieChart,
  cx : Double,
  cy : Double,
  r : Double,
  total : Double,
) -> Array[@lib.SvgElement] {
  let mut elements : Array[@lib.SvgElement] = []
  let label_r = r * 0.65
  let mut start_angle = -@math.PI / 2.0
  let mut i = 0
  while i < chart.data.length() {
    let slice = chart.data[i]
    let sweep = slice.value / total * 2.0 * @math.PI
    let mid_angle = start_angle + sweep / 2.0
    let lx = cx + label_r * @math.cos(mid_angle)
    let ly = cy + label_r * @math.sin(mid_angle)
    let pct = (slice.value / total * 100.0).to_int().to_string() + "%"

    if chart.show_labels && chart.show_percent {
      let text = @lib.SvgText::new(
        lx,
        ly + 4.0,
        pct,
        11,
        "white",
        "middle",
        chart.theme.font_family,
      )
      elements = elements + [@lib.SvgElement::TextElement(text)]
    } else if chart.show_labels {
      let text = @lib.SvgText::new(
        lx,
        ly + 4.0,
        slice.label,
        11,
        "white",
        "middle",
        chart.theme.font_family,
      )
      elements = elements + [@lib.SvgElement::TextElement(text)]
    }
    start_angle = start_angle + sweep
    i = i + 1
  }
  elements
}

///|
/// 渲染饼图图例
fn render_pie_legend(chart : PieChart) -> Array[@lib.SvgElement] {
  let mut elems : Array[@lib.SvgElement] = []
  let n = chart.data.length()
  let legend_y = chart.height - 10.0
  // 纵向排列图例
  let max_cols = 4
  let items_per_col = (n - 1) / max_cols + 1
  let col_width = chart.width / items_per_col.to_double()
  let mut i = 0
  while i < n {
    let slice = chart.data[i]
    let col = i / items_per_col
    let row = i % items_per_col
    let lx = col.to_double() * col_width + 20.0
    let ly = legend_y - row.to_double() * 18.0
    let rect = @lib.SvgRect::new(
      lx,
      ly - 10.0,
      10.0,
      10.0,
      slice.color,
      "none",
      0,
      0.0,
      0.0,
    )
    let text = @lib.SvgText::new(
      lx + 14.0,
      ly,
      slice.label,
      10,
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
/// 渲染空饼图
fn render_empty_pie_chart(w : Double, h : Double, theme : @lib.Theme) -> String {
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
test "pie_slice_new" {
  let s = PieSlice::new("A", 30.0, "#ff0000")
  assert_eq(s.label, "A")
  assert_eq(s.value, 30.0)
}

///|
test "pie_chart_new" {
  let theme = @lib.Theme::new_light()
  let data = [
    PieSlice::new("A", 50.0, "#4e79a7"),
    PieSlice::new("B", 50.0, "#f28e2b"),
  ]
  let chart = PieChart::new(400.0, 400.0, data, theme)
  assert_eq(chart.radius > 0.0, true)
}

///|
test "pie_chart_render" {
  let theme = @lib.Theme::new_light()
  let data = [
    PieSlice::new("A", 30.0, "#4e79a7"),
    PieSlice::new("B", 70.0, "#f28e2b"),
  ]
  let chart = PieChart::new(400.0, 400.0, data, theme)
  let svg = chart.render()
  assert_eq(svg.has_prefix("<?xml"), true)
  assert_eq(svg.contains("<path"), true)
}

///|
test "pie_chart_render_empty" {
  let theme = @lib.Theme::new_light()
  let chart = PieChart::new(400.0, 400.0, [], theme)
  let svg = chart.render()
  assert_eq(svg.contains("No data"), true)
}

///|
test "pie_chart_zero_total" {
  let theme = @lib.Theme::new_light()
  let data = [PieSlice::new("A", 0.0, "#4e79a7")]
  let chart = PieChart::new(400.0, 400.0, data, theme)
  let svg = chart.render()
  assert_eq(svg.contains("No data"), true)
}
