/// 图表工厂模块
/// 根据 ChartConfig 创建对应图表组件并生成 SVG

/// 将 ChartConfig 渲染为 SVG 字符串
pub fn render_config_to_svg(config : ChartConfig) -> String {
  let theme = if config.theme_mode == "dark" {
    @lib.Theme::new_dark()
  } else {
    @lib.Theme::new_light()
  }

  match config.chart_type {
    ChartType::BarChart => render_bar_config(config, theme)
    ChartType::LineChart => render_line_config(config, theme)
    ChartType::PieChart => render_pie_config(config, theme)
    ChartType::RadarChart => render_radar_config(config, theme)
  }
}

/// 渲染柱状图
fn render_bar_config(config : ChartConfig, theme : @lib.Theme) -> String {
  let datasets = config.datasets
  if datasets.length() == 0 {
    return render_empty_svg(config.width, config.height, "No data", theme)
  }

  // 构建 BarSeries
  let mut series : Array[@bar.BarSeries] = []
  let mut i = 0
  while i < datasets.length() {
    let ds = datasets[i]
    // 如果没有颜色，使用调色板
    let color = if ds.color == "" || ds.color == "#" {
      @lib.get_palette_color(theme, i)
    } else {
      ds.color
    }
    series = series + [@bar.BarSeries::new(ds.label, ds.values, color)]
    i = i + 1
  }

  // 如果没有 categories，生成默认分类标签
  let cats = if config.categories.length() > 0 {
    config.categories
  } else if series.length() > 0 && series[0].values.length() > 0 {
    let mut default_cats : Array[String] = []
    let mut j = 0
    while j < series[0].values.length() {
      default_cats = default_cats + [(j + 1).to_string()]
      j = j + 1
    }
    default_cats
  } else {
    ["A", "B"]
  }

  let chart = @bar.BarChart::new(config.width, config.height, cats, series, theme, config.stacked)
  let c2 = if config.title != "" { chart.with_title(config.title) } else { chart }
  c2.render()
}

/// 渲染折线图
fn render_line_config(config : ChartConfig, theme : @lib.Theme) -> String {
  let datasets = config.datasets
  if datasets.length() == 0 {
    return render_empty_svg(config.width, config.height, "No data", theme)
  }

  // 构建 LineSeries（使用索引作为 X 值）
  let mut series : Array[@line.LineSeries] = []
  let mut i = 0
  while i < datasets.length() {
    let ds = datasets[i]
    let color = if ds.color == "" || ds.color == "#" {
      @lib.get_palette_color(theme, i)
    } else {
      ds.color
    }
    let mut points : Array[@line.DataPoint] = []
    let mut j = 0
    while j < ds.values.length() {
      points = points + [@line.DataPoint::new(j.to_double(), ds.values[j])]
      j = j + 1
    }
    series = series + [@line.LineSeries::new(ds.label, points, color)]
    i = i + 1
  }

  let chart = @line.LineChart::new(config.width, config.height, series, theme)
  let c2 = if config.title != "" { chart.with_title(config.title) } else { chart }
  c2.render()
}

/// 渲染饼图
fn render_pie_config(config : ChartConfig, theme : @lib.Theme) -> String {
  let datasets = config.datasets
  if datasets.length() == 0 {
    return render_empty_svg(config.width, config.height, "No data", theme)
  }

  // 如果有 categories，使用 categories 作为标签
  let has_cats = config.categories.length() > 0
  let mut slices : Array[@pie.PieSlice] = []
  let mut i = 0
  while i < datasets.length() {
    let ds = datasets[i]
    let label = if has_cats && i < config.categories.length() { config.categories[i] } else { ds.label }
    let color = if ds.color == "" || ds.color == "#" {
      @lib.get_palette_color(theme, i)
    } else {
      ds.color
    }
    // 取第一个值
    let val = if ds.values.length() > 0 { ds.values[0] } else { 1.0 }
    slices = slices + [@pie.PieSlice::new(label, val, color)]
    i = i + 1
  }

  let chart = @pie.PieChart::new(config.width, config.height, slices, theme)
  let c2 = if config.title != "" { chart.with_title(config.title) } else { chart }
  c2.render()
}

/// 渲染雷达图
fn render_radar_config(config : ChartConfig, theme : @lib.Theme) -> String {
  let datasets = config.datasets
  if datasets.length() == 0 || config.categories.length() == 0 {
    return render_empty_svg(config.width, config.height, "No data", theme)
  }

  let mut series : Array[@radar.RadarSeries] = []
  let mut i = 0
  while i < datasets.length() {
    let ds = datasets[i]
    let color = if ds.color == "" || ds.color == "#" {
      @lib.get_palette_color(theme, i)
    } else {
      ds.color
    }
    series = series + [@radar.RadarSeries::new(ds.label, ds.values, color)]
    i = i + 1
  }

  let chart = @radar.RadarChart::new(config.width, config.height, config.categories, series, theme)
  let c2 = if config.title != "" { chart.with_title(config.title) } else { chart }
  c2.render()
}

/// 渲染空数据 SVG
fn render_empty_svg(w : Double, h : Double, msg : String, theme : @lib.Theme) -> String {
  let doc = @lib.SvgDocument::new(w.to_int(), h.to_int())
  let bg = @lib.SvgRect::new(0.0, 0.0, w, h, theme.background, "none", 0, 0.0, 0.0)
  let text = @lib.SvgText::new(w / 2.0, h / 2.0, msg, 14, theme.text_color, "middle", theme.font_family)
  let d1 = doc.add_element(@lib.SvgElement::RectElement(bg))
  let d2 = d1.add_element(@lib.SvgElement::TextElement(text))
  d2.render()
}
