/// 坐标轴与刻度工具模块
/// 提供坐标轴刻度计算、网格线渲染、标签渲染等基础能力

/// 坐标轴刻度计算结果
pub struct AxisScale {
  min_val : Double
  max_val : Double
  step : Double
  tick_count : Int
}

/// 计算合适的坐标轴刻度范围（自动取整）
/// 例如 max=187 → nice_max=200, step=50
pub fn calc_scale(min_val : Double, max_val : Double, _target_steps : Int) -> AxisScale {
  let raw_range = if max_val > min_val { max_val - min_val } else { 1.0 }
  let raw_log10 = @math.log10(raw_range)
  let magnitude = @math.pow(10.0, @math.floor(raw_log10))
  let residue = raw_range / magnitude
  let nice_step = if residue <= 1.0 { magnitude / 5.0 }
    else if residue <= 2.0 { magnitude / 2.0 }
    else if residue <= 5.0 { magnitude * 1.0 }
    else { magnitude * 2.0 }
  let nice_max = if max_val == 0.0 { 1.0 }
    else { ((max_val / nice_step).ceil()) * nice_step }
  let nice_min = (min_val / nice_step).floor() * nice_step
  let actual_step = if nice_max - nice_min > 0.0 { nice_step } else { 1.0 }
  let count = ((nice_max - nice_min) / actual_step).ceil().to_int() + 1
  AxisScale::{ min_val: nice_min, max_val: nice_max, step: actual_step, tick_count: count }
}

/// 将数据值映射到 Y 轴像素位置
pub fn scale_to_y(value : Double, scale : AxisScale, plot_top : Double, plot_bottom : Double) -> Double {
  let range = scale.max_val - scale.min_val
  if range <= 0.0 { return plot_top }
  let ratio = (value - scale.min_val) / range
  plot_bottom - ratio * (plot_bottom - plot_top)
}

/// 渲染水平网格线
pub fn render_hgrid(
  scale : AxisScale, plot_left : Double, plot_right : Double,
  plot_top : Double, plot_bottom : Double,
  grid_color : String
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

/// 渲染 Y 轴标签
pub fn render_y_labels(
  scale : AxisScale,
  plot_left : Double, plot_top : Double, plot_bottom : Double,
  label_color : String, font_size : Int, font_family : String
) -> Array[SvgElement] {
  let mut labels : Array[SvgElement] = []
  let mut i = 0
  while i < scale.tick_count {
    let val = scale.min_val + scale.step * i.to_double()
    let y = scale_to_y(val, scale, plot_top, plot_bottom)
    let label_str = val.to_int().to_string()
    let text = SvgText::new(
      plot_left - 8.0, y + font_size.to_double() / 3.0,
      label_str, font_size, label_color, "end", font_family
    )
    labels = labels + [TextElement(text)]
    i = i + 1
  }
  labels
}

/// 渲染 X 轴分类标签
pub fn render_x_labels(
  categories : Array[String],
  plot_left : Double, plot_right : Double, plot_bottom : Double,
  label_color : String, font_size : Int, font_family : String
) -> Array[SvgElement] {
  let n = categories.length()
  if n == 0 { return [] }
  let cat_width = (plot_right - plot_left) / n.to_double()
  let mut labels : Array[SvgElement] = []
  let mut i = 0
  while i < n {
    let cx = plot_left + cat_width * (i.to_double() + 0.5)
    let text = SvgText::new(
      cx, plot_bottom + font_size.to_double() + 6.0,
      categories[i], font_size, label_color, "middle", font_family
    )
    labels = labels + [TextElement(text)]
    i = i + 1
  }
  labels
}

/// 渲染 X 轴标题
pub fn render_x_title(
  title : String,
  plot_left : Double, plot_right : Double, plot_bottom : Double,
  label_color : String, font_size : Int, font_family : String
) -> SvgElement {
  let cx = plot_left + (plot_right - plot_left) / 2.0
  TextElement(
    SvgText::new(cx, plot_bottom + font_size.to_double() * 3.0, title, font_size + 2, label_color, "middle", font_family)
  )
}

/// 渲染图表标题
pub fn render_chart_title(
  title : String,
  width : Double, y : Double,
  color : String, font_size : Int, font_family : String
) -> SvgElement {
  TextElement(
    SvgText::new(width / 2.0, y, title, font_size, color, "middle", font_family)
  )
}
