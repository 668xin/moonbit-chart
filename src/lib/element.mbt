/// SVG 元素构建器模块
/// 提供标准 SVG 元素的类型定义和渲染函数

/// ---- 元素结构体 ----

/// 矩形元素
pub struct SvgRect {
  x : Double
  y : Double
  width : Double
  height : Double
  rx : Double
  ry : Double
  fill : String
  stroke : String
  stroke_width : Int
}

/// 圆形元素
pub struct SvgCircle {
  cx : Double
  cy : Double
  r : Double
  fill : String
  stroke : String
  stroke_width : Int
}

/// 路径元素
pub struct SvgPath {
  data : String
  fill : String
  stroke : String
  stroke_width : Int
}

/// 文本元素
pub struct SvgText {
  x : Double
  y : Double
  content : String
  font_size : Int
  fill : String
  text_anchor : String
  font_family : String
}

/// 线段元素
pub struct SvgLine {
  x1 : Double
  y1 : Double
  x2 : Double
  y2 : Double
  stroke : String
  stroke_width : Int
}

/// 折线元素
pub struct SvgPolyline {
  points : Array[(Double, Double)]
  fill : String
  stroke : String
  stroke_width : Int
}

/// 多边形元素
pub struct SvgPolygon {
  points : Array[(Double, Double)]
  fill : String
  stroke : String
  stroke_width : Int
}

/// 分组元素
pub struct SvgGroup {
  elements : Array[SvgElement]
  transform : String
}

/// ---- 元素枚举 ----

/// SVG 元素联合类型
pub(all) enum SvgElement {
  RectElement(SvgRect)
  CircleElement(SvgCircle)
  PathElement(SvgPath)
  TextElement(SvgText)
  LineElement(SvgLine)
  PolylineElement(SvgPolyline)
  PolygonElement(SvgPolygon)
  GroupElement(SvgGroup)
}

/// ---- 构造函数 ----

/// 创建矩形元素
pub fn SvgRect::new(
  x : Double, y : Double,
  width : Double, height : Double,
  fill : String, stroke : String,
  stroke_width : Int,
  rx : Double, ry : Double
) -> SvgRect {
  { x, y, width, height, rx, ry, fill, stroke, stroke_width }
}

/// 创建圆形元素
pub fn SvgCircle::new(
  cx : Double, cy : Double, r : Double,
  fill : String, stroke : String, stroke_width : Int
) -> SvgCircle {
  { cx, cy, r, fill, stroke, stroke_width }
}

/// 创建路径元素
pub fn SvgPath::new(
  data : String, fill : String, stroke : String, stroke_width : Int
) -> SvgPath {
  { data, fill, stroke, stroke_width }
}

/// 创建文本元素
pub fn SvgText::new(
  x : Double, y : Double, content : String,
  font_size : Int, fill : String,
  text_anchor : String, font_family : String
) -> SvgText {
  { x, y, content, font_size, fill, text_anchor, font_family }
}

/// 创建线段元素
pub fn SvgLine::new(
  x1 : Double, y1 : Double, x2 : Double, y2 : Double,
  stroke : String, stroke_width : Int
) -> SvgLine {
  { x1, y1, x2, y2, stroke, stroke_width }
}

/// 创建折线元素
pub fn SvgPolyline::new(
  points : Array[(Double, Double)],
  fill : String, stroke : String, stroke_width : Int
) -> SvgPolyline {
  { points, fill, stroke, stroke_width }
}

/// 创建多边形元素
pub fn SvgPolygon::new(
  points : Array[(Double, Double)],
  fill : String, stroke : String, stroke_width : Int
) -> SvgPolygon {
  { points, fill, stroke, stroke_width }
}

/// 创建分组元素
pub fn SvgGroup::new(
  elements : Array[SvgElement], transform : String
) -> SvgGroup {
  { elements, transform }
}

/// ---- 属性拼接辅助函数 ----

fn attr_str(name : String, value : String) -> String {
  " " + name + "=\"" + value + "\""
}

fn opt_attr(name : String, value : Double, default : Double) -> String {
  if value != default { attr_str(name, value.to_string()) } else { "" }
}

/// ---- 渲染函数 ----

/// 渲染矩形元素为 SVG 字符串
pub fn SvgRect::render(self : SvgRect) -> String {
  "<rect" +
    attr_str("x", self.x.to_string()) +
    attr_str("y", self.y.to_string()) +
    attr_str("width", self.width.to_string()) +
    attr_str("height", self.height.to_string()) +
    opt_attr("rx", self.rx, 0.0) +
    opt_attr("ry", self.ry, 0.0) +
    attr_str("fill", self.fill) +
    attr_str("stroke", self.stroke) +
    attr_str("stroke-width", self.stroke_width.to_string()) +
    " />"
}

/// 渲染圆形元素为 SVG 字符串
pub fn SvgCircle::render(self : SvgCircle) -> String {
  "<circle" +
    attr_str("cx", self.cx.to_string()) +
    attr_str("cy", self.cy.to_string()) +
    attr_str("r", self.r.to_string()) +
    attr_str("fill", self.fill) +
    attr_str("stroke", self.stroke) +
    attr_str("stroke-width", self.stroke_width.to_string()) +
    " />"
}

/// 渲染路径元素为 SVG 字符串
pub fn SvgPath::render(self : SvgPath) -> String {
  "<path" +
    attr_str("d", self.data) +
    attr_str("fill", self.fill) +
    attr_str("stroke", self.stroke) +
    attr_str("stroke-width", self.stroke_width.to_string()) +
    " />"
}

/// 渲染文本元素为 SVG 字符串
pub fn SvgText::render(self : SvgText) -> String {
  "<text" +
    attr_str("x", self.x.to_string()) +
    attr_str("y", self.y.to_string()) +
    attr_str("font-size", self.font_size.to_string()) +
    attr_str("fill", self.fill) +
    attr_str("text-anchor", self.text_anchor) +
    attr_str("font-family", self.font_family) +
    ">" + self.content + "</text>"
}

/// 渲染线段元素为 SVG 字符串
pub fn SvgLine::render(self : SvgLine) -> String {
  "<line" +
    attr_str("x1", self.x1.to_string()) +
    attr_str("y1", self.y1.to_string()) +
    attr_str("x2", self.x2.to_string()) +
    attr_str("y2", self.y2.to_string()) +
    attr_str("stroke", self.stroke) +
    attr_str("stroke-width", self.stroke_width.to_string()) +
    " />"
}

/// 将坐标点数组渲染为 SVG points 字符串
fn render_points(points : Array[(Double, Double)]) -> String {
  let point_strs = points.map(fn(p) {
    let (x, y) = p
    x.to_string() + "," + y.to_string()
  })
  point_strs.fold(init="", fn(a, s) {
    if a == "" { s } else { a + " " + s }
  })
}

/// 渲染折线元素为 SVG 字符串
pub fn SvgPolyline::render(self : SvgPolyline) -> String {
  "<polyline" +
    attr_str("points", render_points(self.points)) +
    attr_str("fill", self.fill) +
    attr_str("stroke", self.stroke) +
    attr_str("stroke-width", self.stroke_width.to_string()) +
    " />"
}

/// 渲染多边形元素为 SVG 字符串
pub fn SvgPolygon::render(self : SvgPolygon) -> String {
  "<polygon" +
    attr_str("points", render_points(self.points)) +
    attr_str("fill", self.fill) +
    attr_str("stroke", self.stroke) +
    attr_str("stroke-width", self.stroke_width.to_string()) +
    " />"
}

/// 渲染分组元素为 SVG 字符串
pub fn SvgGroup::render(self : SvgGroup) -> String {
  let inner = self.elements.fold(init="", fn(a, e) { a + render_svg_element(e) + "\n" })
  if self.transform == "" {
    "<g>\n" + inner + "</g>"
  } else {
    "<g" + attr_str("transform", self.transform) + ">\n" + inner + "</g>"
  }
}

/// 渲染任意 SVG 元素
pub fn render_svg_element(elem : SvgElement) -> String {
  match elem {
    RectElement(r) => r.render()
    CircleElement(c) => c.render()
    PathElement(p) => p.render()
    TextElement(t) => t.render()
    LineElement(l) => l.render()
    PolylineElement(pl) => pl.render()
    PolygonElement(pg) => pg.render()
    GroupElement(g) => g.render()
  }
}
