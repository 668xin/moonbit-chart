/// 折线图 Demo — 使用 LineChart 组件
pub fn demo_line_chart() -> String {
  let theme = @lib.Theme::new_light()
  let colors = theme.palette

  let pts = [
    @line.DataPoint::new(0.0, 200.0),
    @line.DataPoint::new(1.0, 150.0),
    @line.DataPoint::new(2.0, 180.0),
    @line.DataPoint::new(3.0, 100.0),
    @line.DataPoint::new(4.0, 140.0),
    @line.DataPoint::new(5.0, 80.0),
    @line.DataPoint::new(6.0, 120.0)
  ]
  let ds = @line.LineSeries::new("Series A", pts, colors[0])
  let chart = @line.LineChart::new(500.0, 350.0, [ds], theme)
  let c2 = chart.with_title("Line Chart")
  c2.render()
}

/// 多组折线图 Demo
pub fn demo_multi_line_chart() -> String {
  let theme = @lib.Theme::new_light()
  let colors = theme.palette

  let pts_a = [
    @line.DataPoint::new(0.0, 200.0),
    @line.DataPoint::new(1.0, 150.0),
    @line.DataPoint::new(2.0, 180.0),
    @line.DataPoint::new(3.0, 100.0),
    @line.DataPoint::new(4.0, 140.0),
    @line.DataPoint::new(5.0, 80.0),
    @line.DataPoint::new(6.0, 120.0)
  ]
  let pts_b = [
    @line.DataPoint::new(0.0, 100.0),
    @line.DataPoint::new(1.0, 200.0),
    @line.DataPoint::new(2.0, 120.0),
    @line.DataPoint::new(3.0, 160.0),
    @line.DataPoint::new(4.0, 90.0),
    @line.DataPoint::new(5.0, 180.0),
    @line.DataPoint::new(6.0, 140.0)
  ]
  let pts_c = [
    @line.DataPoint::new(0.0, 50.0),
    @line.DataPoint::new(1.0, 80.0),
    @line.DataPoint::new(2.0, 100.0),
    @line.DataPoint::new(3.0, 70.0),
    @line.DataPoint::new(4.0, 130.0),
    @line.DataPoint::new(5.0, 60.0),
    @line.DataPoint::new(6.0, 90.0)
  ]

  let ds_a = @line.LineSeries::new("Series A", pts_a, colors[0])
  let ds_b = @line.LineSeries::new("Series B", pts_b, colors[1])
  let ds_c = @line.LineSeries::new("Series C", pts_c, colors[2])

  let chart = @line.LineChart::new(550.0, 380.0, [ds_a, ds_b, ds_c], theme)
  let c2 = chart.with_title("Multi-Line Chart")
  c2.render()
}
