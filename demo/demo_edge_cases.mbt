///|
/// 暗色主题柱状图 Demo
pub fn demo_dark_bar_chart() -> String {
  let theme = @lib.Theme::new_dark()
  let colors = theme.palette
  let categories = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
  let s1 = @bar.BarSeries::new("Views", [1200.0, 900.0, 1500.0, 1800.0, 1300.0, 800.0, 600.0], colors[0])
  let chart = @bar.BarChart::new(600.0, 380.0, categories, [s1], theme, false)
  let c2 = chart.with_title("Weekly Views (Dark Theme)")
  c2.render()
}

///|
/// 含负值柱状图 Demo
pub fn demo_negative_bar_chart() -> String {
  let theme = @lib.Theme::new_light()
  let colors = theme.palette
  let categories = ["Q1", "Q2", "Q3", "Q4"]
  let s1 = @bar.BarSeries::new("Profit", [30.0, -15.0, 45.0, -5.0], colors[0])
  let chart = @bar.BarChart::new(500.0, 350.0, categories, [s1], theme, false)
  let c2 = chart.with_title("Profit by Quarter")
  c2.render()
}

///|
/// 暗色主题折线图 Demo
pub fn demo_dark_line_chart() -> String {
  let theme = @lib.Theme::new_dark()
  let colors = theme.palette
  let pts = [
    @line.DataPoint::new(0.0, 300.0),
    @line.DataPoint::new(2.0, 420.0),
    @line.DataPoint::new(4.0, 280.0),
    @line.DataPoint::new(6.0, 510.0),
    @line.DataPoint::new(8.0, 390.0),
    @line.DataPoint::new(10.0, 450.0),
  ]
  let ds = @line.LineSeries::new("Revenue", pts, colors[0])
  let chart = @line.LineChart::new(500.0, 350.0, [ds], theme)
  let c2 = chart.with_title("Revenue Trend (Dark Theme)")
  c2.render()
}

///|
/// 暗色主题饼图 Demo
pub fn demo_dark_pie_chart() -> String {
  let theme = @lib.Theme::new_dark()
  let colors = theme.palette
  let data = [
    @pie.PieSlice::new("Chrome", 64.0, colors[0]),
    @pie.PieSlice::new("Safari", 19.0, colors[1]),
    @pie.PieSlice::new("Firefox", 8.0, colors[2]),
    @pie.PieSlice::new("Edge", 5.0, colors[3]),
    @pie.PieSlice::new("Other", 4.0, colors[4]),
  ]
  let chart = @pie.PieChart::new(420.0, 380.0, data, theme)
  let c2 = chart.with_title("Browser Market Share (Dark Theme)")
  c2.render()
}

///|
/// 暗色主题雷达图 Demo
pub fn demo_dark_radar_chart() -> String {
  let theme = @lib.Theme::new_dark()
  let colors = theme.palette
  let categories = ["Price", "Quality", "Design", "Service", "Brand"]
  let s1 = @radar.RadarSeries::new("Brand X", [85.0, 70.0, 60.0, 75.0, 80.0], colors[0])
  let s2 = @radar.RadarSeries::new("Brand Y", [60.0, 85.0, 80.0, 65.0, 55.0], colors[1])
  let chart = @radar.RadarChart::new(420.0, 400.0, categories, [s1, s2], theme)
  let c2 = chart.with_title("Brand Comparison (Dark Theme)")
  c2.render()
}

///|
/// 大数据量柱状图 Demo（12 个月）
pub fn demo_large_data_bar_chart() -> String {
  let theme = @lib.Theme::new_light()
  let colors = theme.palette
  let categories = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
  ]
  let s1 = @bar.BarSeries::new(
    "Sales",
    [45.0, 60.0, 80.0, 55.0, 90.0, 110.0, 130.0, 95.0, 70.0, 85.0, 100.0, 120.0],
    colors[0],
  )
  let chart = @bar.BarChart::new(700.0, 380.0, categories, [s1], theme, false)
  let c2 = chart.with_title("Annual Sales")
  c2.render()
}

///|
/// 零值饼图 Demo（边界条件）
pub fn demo_zero_value_pie_chart() -> String {
  let theme = @lib.Theme::new_light()
  let chart = @pie.PieChart::new(300.0, 250.0, [], theme)
  let c2 = chart.with_title("Empty Pie Chart")
  c2.render()
}
