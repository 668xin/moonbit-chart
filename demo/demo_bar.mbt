/// 柱状图 Demo — 使用 SVG 元素构建柱状图
pub fn demo_bar_chart() -> String {
  let bars = [
    (40.0, 200.0, "#4e79a7"), (100.0, 150.0, "#f28e2b"),
    (160.0, 180.0, "#e15759"), (220.0, 100.0, "#76b7b2"),
    (280.0, 220.0, "#59a14f"), (340.0, 130.0, "#edc948")
  ]
  let bg = @lib.SvgRect::new(0.0, 0.0, 400.0, 300.0, "#ffffff", "none", 0, 0.0, 0.0)
  let rects : Array[@lib.SvgElement] = bars.map(fn(tup) {
    let (x, h, c) = tup
    let y = 280.0 - h
    @lib.SvgElement::RectElement(@lib.SvgRect::new(x, y, 40.0, h, c, "none", 0, 0.0, 0.0))
  })
  let d0 = @lib.SvgDocument::new(400, 300)
  let d1 = d0.add_element(@lib.SvgElement::RectElement(bg))
  let d2 = d1.add_elements(rects)
  d2.render()
}
