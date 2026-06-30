/// 坐标轴与刻度工具模块
/// 提供坐标轴刻度计算、网格线渲染、标签渲染等基础能力
/// 支持 AxisConfig 自定义配置

///|
/// 坐标轴刻度计算结果
pub struct AxisScale {
  min_val : Double
  max_val : Double
  step : Double
  tick_count : Int
}

///|
/// 计算合适的坐标轴刻度范围（自动取整）
/// 例如 max=187 → nice_max=200, step=50
pub fn calc_scale(
  min_val : Double,
  max_val : Double,
  _target_steps : Int,
) -> AxisScale {
  let raw_range = if max_val > min_val { max_val - min_val } else { 1.0 }
  let raw_log10 = @math.log10(raw_range)
  let magnitude = @math.pow(10.0, @math.floor(raw_log10))
  let residue = raw_range / magnitude
  let nice_step = if residue <= 1.0 {
    magnitude / 5.0
  } else if residue <= 2.0 {
    magnitude / 2.0
  } else if residue <= 5.0 {
    magnitude * 1.0
  } else {
    magnitude * 2.0
  }
  let nice_max = if max_val == 0.0 {
    1.0
  } else {
    (max_val / nice_step).ceil() * nice_step
  }
  let nice_min = (min_val / nice_step).floor() * nice_step
  let actual_step = if nice_max - nice_min > 0.0 { nice_step } else { 1.0 }
  let count = ((nice_max - nice_min) / actual_step).ceil().to_int() + 1
  AxisScale::{
    min_val: nice_min,
    max_val: nice_max,
    step: actual_step,
    tick_count: count,
  }
}

///|
/// 将数据值映射到 Y 轴像素位置
pub fn scale_to_y(
  value : Double,
  scale : AxisScale,
  plot_top : Double,
  plot_bottom : Double,
) -> Double {
  let range = scale.max_val - scale.min_val
  if range <= 0.0 {
    return plot_top
  }
  let ratio = (value - scale.min_val) / range
  plot_bottom - ratio * (plot_bottom - plot_top)
}

///|
/// 渲染水平网格线
pub fn render_hgrid(
  scale : AxisScale,
  plot_left : Double,
  plot_right : Double,
  plot_top : Double,
  plot_bottom : Double,
  grid_color : String,
) -> Array[SvgElement] {
  let mut lines : Array[SvgElement] = []
  let mut i = 0
  while i < scale.tick_count {
    let val = scale.min_val + scale.step * i.to_double()
    let y = scale_to_y(val, scale, plot_top, plot_bottom)
    if y > plot_top + 1.0 && y < plot_bottom - 1.0 {
      let line = SvgLine::new(plot_left, y, plot_right, y, grid_color, 1)
      lines = lines + [LineElement(line)]
    }
    i = i + 1
  }
  lines
}

///|
/// 渲染 Y 轴标签
pub fn render_y_labels(
  scale : AxisScale,
  plot_left : Double,
  plot_top : Double,
  plot_bottom : Double,
  label_color : String,
  font_size : Int,
  font_family : String,
) -> Array[SvgElement] {
  let mut labels : Array[SvgElement] = []
  let mut i = 0
  while i < scale.tick_count {
    let val = scale.min_val + scale.step * i.to_double()
    let y = scale_to_y(val, scale, plot_top, plot_bottom)
    let label_str = val.to_int().to_string()
    let text = SvgText::new(
      plot_left - 8.0,
      y + font_size.to_double() / 3.0,
      label_str,
      font_size,
      label_color,
      "end",
      font_family,
    )
    labels = labels + [TextElement(text)]
    i = i + 1
  }
  labels
}

///|
/// 渲染 X 轴分类标签
pub fn render_x_labels(
  categories : Array[String],
  plot_left : Double,
  plot_right : Double,
  plot_bottom : Double,
  label_color : String,
  font_size : Int,
  font_family : String,
) -> Array[SvgElement] {
  let n = categories.length()
  if n == 0 {
    return []
  }
  let cat_width = (plot_right - plot_left) / n.to_double()
  let mut labels : Array[SvgElement] = []
  let mut i = 0
  while i < n {
    let cx = plot_left + cat_width * (i.to_double() + 0.5)
    let text = SvgText::new(
      cx,
      plot_bottom + font_size.to_double() + 6.0,
      categories[i],
      font_size,
      label_color,
      "middle",
      font_family,
    )
    labels = labels + [TextElement(text)]
    i = i + 1
  }
  labels
}

///|
/// 渲染 X 轴标题
pub fn render_x_title(
  title : String,
  plot_left : Double,
  plot_right : Double,
  plot_bottom : Double,
  label_color : String,
  font_size : Int,
  font_family : String,
) -> SvgElement {
  let cx = plot_left + (plot_right - plot_left) / 2.0
  TextElement(
    SvgText::new(
      cx,
      plot_bottom + font_size.to_double() * 3.0,
      title,
      font_size + 2,
      label_color,
      "middle",
      font_family,
    ),
  )
}

///|
/// 渲染图表标题
pub fn render_chart_title(
  title : String,
  width : Double,
  y : Double,
  color : String,
  font_size : Int,
  font_family : String,
) -> SvgElement {
  TextElement(
    SvgText::new(width / 2.0, y, title, font_size, color, "middle", font_family),
  )
}

// ==================== AxisConfig 坐标轴自定义配置 ====================

///|
/// 坐标轴自定义配置
pub struct AxisConfig {
  // Y 轴
  y_show_grid : Bool
  y_show_labels : Bool
  y_label_size : Int
  y_label_color : String
  y_grid_color : String
  y_grid_width : Double
  y_axis_color : String
  y_axis_width : Double
  y_tick_length : Double
  // X 轴
  x_show_labels : Bool
  x_label_size : Int
  x_label_color : String
  x_axis_color : String
  x_axis_width : Double
  x_tick_length : Double
}

///|
/// 创建默认 AxisConfig
pub fn default_axis_config() -> AxisConfig {
  AxisConfig::{
    y_show_grid: true,
    y_show_labels: true,
    y_label_size: 12,
    y_label_color: "#666666",
    y_grid_color: "#e0e0e0",
    y_grid_width: 1.0,
    y_axis_color: "#999999",
    y_axis_width: 1.0,
    y_tick_length: 4.0,
    x_show_labels: true,
    x_label_size: 12,
    x_label_color: "#666666",
    x_axis_color: "#999999",
    x_axis_width: 1.0,
    x_tick_length: 4.0,
  }
}

///|
/// 使用 AxisConfig 渲染 Y 轴（网格线 + 标签 + 轴线）
pub fn render_y_axis(
  config : AxisConfig,
  scale : AxisScale,
  plot_left : Double,
  plot_right : Double,
  plot_top : Double,
  plot_bottom : Double,
  font_family : String,
) -> Array[SvgElement] {
  let mut elements : Array[SvgElement] = []

  // 网格线
  if config.y_show_grid {
    let grid = render_hgrid(
      scale,
      plot_left,
      plot_right,
      plot_top,
      plot_bottom,
      config.y_grid_color,
    )
    elements = elements + grid
  }

  // Y轴标签
  if config.y_show_labels {
    let labels = render_y_labels(
      scale,
      plot_left,
      plot_top,
      plot_bottom,
      config.y_label_color,
      config.y_label_size,
      font_family,
    )
    elements = elements + labels
  }

  // Y轴轴线
  let y_axis = SvgLine::new(
    plot_left,
    plot_top,
    plot_left,
    plot_bottom,
    config.y_axis_color,
    config.y_axis_width.to_int(),
  )
  elements = elements + [LineElement(y_axis)]

  elements
}

///|
/// 使用 AxisConfig 渲染 X 轴（标签 + 轴线）
pub fn render_x_axis(
  config : AxisConfig,
  categories : Array[String],
  plot_left : Double,
  plot_right : Double,
  plot_bottom : Double,
  font_family : String,
) -> Array[SvgElement] {
  let mut elements : Array[SvgElement] = []

  // X轴标签
  if config.x_show_labels {
    let labels = render_x_labels(
      categories,
      plot_left,
      plot_right,
      plot_bottom,
      config.x_label_color,
      config.x_label_size,
      font_family,
    )
    elements = elements + labels
  }

  // X轴轴线
  let x_axis = SvgLine::new(
    plot_left,
    plot_bottom,
    plot_right,
    plot_bottom,
    config.x_axis_color,
    config.x_axis_width.to_int(),
  )
  elements = elements + [LineElement(x_axis)]

  elements
}

// ---- AxisConfig builder 辅助方法（供外部包链式调用）----

///|
/// 设置网格显示和颜色
pub fn AxisConfig::with_grid(
  self : AxisConfig,
  show : Bool,
  color : String,
) -> AxisConfig {
  { ..self, y_show_grid: show, y_grid_color: color }
}

///|
/// 设置 Y 轴标签和轴线颜色
pub fn AxisConfig::with_y_color(
  self : AxisConfig,
  label_color : String,
  axis_color : String,
) -> AxisConfig {
  { ..self, y_label_color: label_color, y_axis_color: axis_color }
}

///|
/// 设置 X 轴标签和轴线颜色
pub fn AxisConfig::with_x_color(
  self : AxisConfig,
  label_color : String,
  axis_color : String,
) -> AxisConfig {
  { ..self, x_label_color: label_color, x_axis_color: axis_color }
}

// ==================== 测试 ====================

///|
test "calc_scale_normal" {
  let s = calc_scale(0.0, 187.0, 5)
  assert_eq(s.max_val >= 187.0, true)
  assert_eq(s.step > 0.0, true)
  assert_eq(s.tick_count > 0, true)
}

///|
test "calc_scale_zero_max" {
  let s = calc_scale(0.0, 0.0, 5)
  assert_eq(s.max_val > 0.0, true)
}

///|
test "calc_scale_negative_min" {
  let s = calc_scale(-10.0, 50.0, 5)
  assert_eq(s.min_val <= -10.0, true)
}

///|
test "scale_to_y_mapping" {
  let s = calc_scale(0.0, 100.0, 5)
  let y = scale_to_y(50.0, s, 50.0, 350.0)
  // 50 应在 0-100 的中间，即 plot 区中间
  let mid = (50.0 + 350.0) / 2.0
  assert_eq(y > mid - 10.0 && y < mid + 10.0, true)
}

///|
test "default_axis_config" {
  let c = default_axis_config()
  assert_eq(c.y_show_grid, true)
  assert_eq(c.x_show_labels, true)
}
