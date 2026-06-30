/// 折线图 Demo — 使用 SVG 元素构建折线图
pub fn demo_line_chart() -> String {
  let bg = @lib.SvgRect::new(0.0, 0.0, 400.0, 300.0, "#ffffff", "none", 0, 0.0, 0.0)
  let points : Array[(Double, Double)] = [
    (20.0, 200.0), (80.0, 150.0), (140.0, 180.0),
    (200.0, 100.0), (260.0, 140.0), (320.0, 80.0), (380.0, 120.0)
  ]
  let poly = @lib.SvgPolyline::new(points, "none", "#4e79a7", 3)
  let d0 = @lib.SvgDocument::new(400, 300)
  let d1 = d0.add_element(@lib.SvgElement::RectElement(bg))
  let d2 = d1.add_element(@lib.SvgElement::PolylineElement(poly))
  d2.render()
}
