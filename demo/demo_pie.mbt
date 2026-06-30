/// 饼图 Demo — 使用 SVG 元素构建饼图
pub fn demo_pie_chart() -> String {
  let bg = @lib.SvgRect::new(0.0, 0.0, 400.0, 300.0, "#ffffff", "none", 0, 0.0, 0.0)
  let circle = @lib.SvgCircle::new(200.0, 150.0, 100.0, "#4e79a7", "#333333", 2)
  let label = @lib.SvgText::new(200.0, 150.0, "Pie", 24, "#ffffff", "middle", "sans-serif")
  let d0 = @lib.SvgDocument::new(400, 300)
  let d1 = d0.add_element(@lib.SvgElement::RectElement(bg))
  let d2 = d1.add_element(@lib.SvgElement::CircleElement(circle))
  let d3 = d2.add_element(@lib.SvgElement::TextElement(label))
  d3.render()
}
