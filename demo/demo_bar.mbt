/// 柱状图 Demo — 使用 BarChart 组件
pub fn demo_bar_chart() -> String {
  let theme = @lib.Theme::new_light()
  let colors = theme.palette
  let categories = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
  let values = [40.0, 150.0, 180.0, 100.0, 220.0, 130.0]

  // 单组柱状图
  let data0 = @bar.BarSeries::new("Sales", values, colors[0])
  let chart = @bar.BarChart::new(500.0, 350.0, categories, [data0], theme, false)
  let c2 = chart.with_title("Monthly Sales")
  c2.render()
}

/// 多组柱状图 Demo
pub fn demo_grouped_bar_chart() -> String {
  let theme = @lib.Theme::new_light()
  let colors = theme.palette
  let categories = ["Q1", "Q2", "Q3", "Q4"]

  let s1 = @bar.BarSeries::new("Product A", [30.0, 80.0, 60.0, 100.0], colors[0])
  let s2 = @bar.BarSeries::new("Product B", [50.0, 60.0, 90.0, 70.0], colors[1])
  let s3 = @bar.BarSeries::new("Product C", [20.0, 40.0, 50.0, 60.0], colors[2])

  let chart = @bar.BarChart::new(600.0, 380.0, categories, [s1, s2, s3], theme, false)
  let c2 = chart.with_title("Grouped Bar Chart")
  c2.render()
}

/// 堆叠柱状图 Demo
pub fn demo_stacked_bar_chart() -> String {
  let theme = @lib.Theme::new_light()
  let colors = theme.palette
  let categories = ["Q1", "Q2", "Q3", "Q4"]

  let s1 = @bar.BarSeries::new("Product A", [30.0, 80.0, 60.0, 100.0], colors[0])
  let s2 = @bar.BarSeries::new("Product B", [50.0, 60.0, 90.0, 70.0], colors[1])
  let s3 = @bar.BarSeries::new("Product C", [20.0, 40.0, 50.0, 60.0], colors[2])

  let chart = @bar.BarChart::new(600.0, 380.0, categories, [s1, s2, s3], theme, true)
  let c2 = chart.with_title("Stacked Bar Chart")
  c2.render()
}
