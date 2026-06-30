/// 雷达图 Demo — 使用 SVG 元素构建雷达图
pub fn demo_radar_chart() -> String {
  let bg = @lib.SvgRect::new(0.0, 0.0, 400.0, 300.0, "#ffffff", "none", 0, 0.0, 0.0)
  let points : Array[(Double, Double)] = [
    (200.0, 50.0), (300.0, 150.0), (200.0, 250.0), (100.0, 150.0)
  ]
  let poly = @lib.SvgPolygon::new(points, "rgba(78,121,167,0.2)", "#4e79a7", 2)
  let ring = @lib.SvgCircle::new(200.0, 150.0, 100.0, "none", "#e0e0e0", 1)
  let d0 = @lib.SvgDocument::new(400, 300)
  let d1 = d0.add_element(@lib.SvgElement::RectElement(bg))
  let d2 = d1.add_element(@lib.SvgElement::PolygonElement(poly))
  let d3 = d2.add_element(@lib.SvgElement::CircleElement(ring))
  d3.render()
}
