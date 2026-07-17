/// SVG 元素构建器模块
/// 提供标准 SVG 元素的类型定义和渲染函数

/// ---- 元素结构体 ----

///|
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

///|
/// 圆形元素
pub struct SvgCircle {
  cx : Double
  cy : Double
  r : Double
  fill : String
  stroke : String
  stroke_width : Int
}

///|
/// 路径元素
pub struct SvgPath {
  data : String
  fill : String
  stroke : String
  stroke_width : Int
}

///|
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

///|
/// 线段元素
pub struct SvgLine {
  x1 : Double
  y1 : Double
  x2 : Double
  y2 : Double
  stroke : String
  stroke_width : Int
}

///|
/// 折线元素
pub struct SvgPolyline {
  points : Array[(Double, Double)]
  fill : String
  stroke : String
  stroke_width : Int
}

///|
/// 多边形元素
pub struct SvgPolygon {
  points : Array[(Double, Double)]
  fill : String
  stroke : String
  stroke_width : Int
}

///|
/// 分组元素
pub struct SvgGroup {
  elements : Array[SvgElement]
  transform : String
  tooltip_text : String
}

/// ---- 元素枚举 ----

///|
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

///|
/// 创建矩形元素
pub fn SvgRect::new(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  fill : String,
  stroke : String,
  stroke_width : Int,
  rx : Double,
  ry : Double,
) -> SvgRect {
  { x, y, width, height, rx, ry, fill, stroke, stroke_width }
}

///|
/// 创建圆形元素
pub fn SvgCircle::new(
  cx : Double,
  cy : Double,
  r : Double,
  fill : String,
  stroke : String,
  stroke_width : Int,
) -> SvgCircle {
  { cx, cy, r, fill, stroke, stroke_width }
}

///|
/// 创建路径元素
pub fn SvgPath::new(
  data : String,
  fill : String,
  stroke : String,
  stroke_width : Int,
) -> SvgPath {
  { data, fill, stroke, stroke_width }
}

///|
/// 创建文本元素
pub fn SvgText::new(
  x : Double,
  y : Double,
  content : String,
  font_size : Int,
  fill : String,
  text_anchor : String,
  font_family : String,
) -> SvgText {
  { x, y, content, font_size, fill, text_anchor, font_family }
}

///|
/// 创建线段元素
pub fn SvgLine::new(
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  stroke : String,
  stroke_width : Int,
) -> SvgLine {
  { x1, y1, x2, y2, stroke, stroke_width }
}

///|
/// 创建折线元素
pub fn SvgPolyline::new(
  points : Array[(Double, Double)],
  fill : String,
  stroke : String,
  stroke_width : Int,
) -> SvgPolyline {
  { points, fill, stroke, stroke_width }
}

///|
/// 创建多边形元素
pub fn SvgPolygon::new(
  points : Array[(Double, Double)],
  fill : String,
  stroke : String,
  stroke_width : Int,
) -> SvgPolygon {
  { points, fill, stroke, stroke_width }
}

///|
/// 创建分组元素
pub fn SvgGroup::new(
  elements : Array[SvgElement],
  transform : String,
) -> SvgGroup {
  { elements, transform, tooltip_text: "" }
}

///|
/// 创建带 tooltip 的分组元素
pub fn SvgGroup::with_tooltip(
  elements : Array[SvgElement],
  transform : String,
  tooltip_text : String,
) -> SvgGroup {
  { elements, transform, tooltip_text }
}

///|
/// ---- 属性拼接辅助函数 ----
fn attr_str(name : String, value : String) -> String {
  " " + name + "=\"" + value + "\""
}

///|
fn opt_attr(name : String, value : Double, default : Double) -> String {
  if value != default {
    attr_str(name, value.to_string())
  } else {
    ""
  }
}

/// ---- 渲染函数 ----

///|
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

///|
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

///|
/// 渲染路径元素为 SVG 字符串
pub fn SvgPath::render(self : SvgPath) -> String {
  "<path" +
  attr_str("d", self.data) +
  attr_str("fill", self.fill) +
  attr_str("stroke", self.stroke) +
  attr_str("stroke-width", self.stroke_width.to_string()) +
  " />"
}

///|
/// HTML/SVG 转义 - 防止注入攻击
fn escape_svg_text(s : String) -> String {
  let len = s.length()
  let mut result = ""
  let mut i = 0
  while i < len {
    let c = s.code_unit_at(i).to_int()
    if c == 38 { // &
      result = result + "&amp;"
    } else if c == 60 { // <
      result = result + "&lt;"
    } else if c == 62 { // >
      result = result + "&gt;"
    } else {
      result = result + "\{c.unsafe_to_char()}"
    }
    i = i + 1
  }
  result
}

///|
/// 渲染文本元素为 SVG 字符串
pub fn SvgText::render(self : SvgText) -> String {
  "<text" +
  attr_str("x", self.x.to_string()) +
  attr_str("y", self.y.to_string()) +
  attr_str("font-size", self.font_size.to_string()) +
  attr_str("fill", self.fill) +
  attr_str("text-anchor", self.text_anchor) +
  attr_str("font-family", self.font_family) +
  ">" +
  escape_svg_text(self.content) +
  "</text>"
}

///|
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

///|
/// 将坐标点数组渲染为 SVG points 字符串
fn render_points(points : Array[(Double, Double)]) -> String {
  let point_strs = points.map(fn(p) {
    let (x, y) = p
    x.to_string() + "," + y.to_string()
  })
  point_strs.fold(init="", fn(a, s) { if a == "" { s } else { a + " " + s } })
}

///|
/// 渲染折线元素为 SVG 字符串
pub fn SvgPolyline::render(self : SvgPolyline) -> String {
  "<polyline" +
  attr_str("points", render_points(self.points)) +
  attr_str("fill", self.fill) +
  attr_str("stroke", self.stroke) +
  attr_str("stroke-width", self.stroke_width.to_string()) +
  " />"
}

///|
/// 渲染多边形元素为 SVG 字符串
pub fn SvgPolygon::render(self : SvgPolygon) -> String {
  "<polygon" +
  attr_str("points", render_points(self.points)) +
  attr_str("fill", self.fill) +
  attr_str("stroke", self.stroke) +
  attr_str("stroke-width", self.stroke_width.to_string()) +
  " />"
}

///|
/// 渲染分组元素为 SVG 字符串
pub fn SvgGroup::render(self : SvgGroup) -> String {
  let inner = self.elements.fold(init="", fn(a, e) {
    a + render_svg_element(e) + "\n"
  })
  let title_tag = if self.tooltip_text != "" {
    "  <title>" + escape_svg_text(self.tooltip_text) + "</title>\n"
  } else {
    ""
  }
  let group_tag_open = if self.transform == "" {
    "<g>"
  } else {
    "<g" + attr_str("transform", self.transform) + ">"
  }
  group_tag_open + "\n" + title_tag + inner + "</g>"
}

///|
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

// ==================== SVG 解析辅助函数（回归测试用）====================

///|
/// 在字符串 text 中从 start 位置开始查找 pattern，返回匹配位置或 -1
fn svg_find(text : String, start : Int, pattern : String) -> Int {
  let tlen = text.length()
  let plen = pattern.length()
  if plen == 0 {
    return -1
  }
  let mut i = start
  while i + plen <= tlen {
    let mut matched = true
    let mut j = 0
    while j < plen {
      if text.code_unit_at(i + j) != pattern.code_unit_at(j) {
        matched = false
        break
      }
      j = j + 1
    }
    if matched {
      return i
    }
    i = i + 1
  }
  -1
}

///|
/// 解析字符串中的浮点数（支持负号、整数/小数）
fn svg_parse_double(s : String) -> Double {
  let len = s.length()
  if len == 0 {
    return 0.0
  }
  let mut i = 0
  let mut sign = 1.0
  if i < len {
    let c = s.code_unit_at(i).to_int()
    if c == 45 {
      sign = -1.0
      i = i + 1
    } else if c == 43 {
      i = i + 1
    }
  }
  let mut int_part = 0.0
  let mut has_digit = false
  while i < len {
    let c = s.code_unit_at(i).to_int()
    if 48 <= c && c <= 57 {
      int_part = int_part * 10.0 + (c - 48).to_double()
      has_digit = true
      i = i + 1
    } else if c == 46 {
      i = i + 1
      break
    } else {
      break
    }
  }
  let mut frac_part = 0.0
  let mut frac_div = 1.0
  while i < len {
    let c = s.code_unit_at(i).to_int()
    if 48 <= c && c <= 57 {
      frac_part = frac_part * 10.0 + (c - 48).to_double()
      frac_div = frac_div * 10.0
      has_digit = true
      i = i + 1
    } else {
      break
    }
  }
  if !has_digit {
    return 0.0
  }
  sign * (int_part + frac_part / frac_div)
}

///|
/// 提取两个引号之间的属性值
fn extract_attr_value(text : String, attr_name : String) -> Array[Double] {
  let mut result : Array[Double] = []
  let tag_len = attr_name.length()
  let mut pos = 0
  let tlen = text.length()
  // 先找属性名标签
  while pos < tlen {
    let tag_start = svg_find(text, pos, attr_name)
    if tag_start == -1 {
      break
    }
    let val_start = tag_start + tag_len
    // 找结束引号
    let val_end_pos = svg_find(text, val_start, "\"")
    if val_end_pos == -1 {
      break
    }
    if val_end_pos > val_start {
      let val_s = text[val_start:val_end_pos].to_owned()
      result = result + [svg_parse_double(val_s)]
    }
    pos = val_end_pos + 1
  }
  result
}

///|
/// 从 SVG 字符串中提取所有 `<rect` 元素的 height 属性值
pub fn extract_rect_heights(svg : String) -> Array[Double] {
  // 先拆出每个 <rect...> 片段
  let rect_parts : Array[StringView] = [ for p in svg.split("<rect") => p ]
  let mut heights : Array[Double] = []
  let mut i = 1
  while i < rect_parts.length() {
    let s = rect_parts[i].to_owned()
    let vals = extract_attr_value(s, "height=\"")
    let mut j = 0
    while j < vals.length() {
      heights = heights + [vals[j]]
      j = j + 1
    }
    i = i + 1
  }
  heights
}

///|
/// 从 SVG 字符串中提取 `<polyline` 元素的 points 中的 x 坐标
pub fn extract_polyline_xs(svg : String) -> Array[Double] {
  let pl_parts : Array[StringView] = [ for p in svg.split("<polyline") => p ]
  let mut xs : Array[Double] = []
  let mut i = 1
  while i < pl_parts.length() {
    let s = pl_parts[i].to_owned()
    let p_tag = "points=\""
    let pts_start = svg_find(s, 0, p_tag)
    if pts_start >= 0 {
      let val_start = pts_start + p_tag.length()
      let val_end = svg_find(s, val_start, "\"")
      if val_end > val_start {
        let pts_str = s[val_start:val_end].to_owned()
        // 解析 "x1,y1 x2,y2 ..."
        let coord_parts : Array[StringView] = [
          for p in pts_str.split(" ") => p
        ]
        let mut j = 0
        while j < coord_parts.length() {
          let coord = coord_parts[j].to_owned()
          let comma = svg_find(coord, 0, ",")
          if comma >= 0 {
            let x_str = coord[:comma].to_owned()
            xs = xs + [svg_parse_double(x_str)]
          }
          j = j + 1
        }
      }
    }
    i = i + 1
  }
  xs
}

///|
/// 从 SVG 字符串中提取 `<rect` 元素的 x 坐标
pub fn extract_rect_xs(svg : String) -> Array[Double] {
  let rect_parts : Array[StringView] = [ for p in svg.split("<rect") => p ]
  let mut xs : Array[Double] = []
  let mut i = 1
  while i < rect_parts.length() {
    let s = rect_parts[i].to_owned()
    let vals = extract_attr_value(s, "x=\"")
    let mut j = 0
    while j < vals.length() {
      xs = xs + [vals[j]]
      j = j + 1
    }
    i = i + 1
  }
  xs
}

///|
/// 从 SVG 字符串中提取 `<svg` 元素的 width 和 height 属性值
pub fn extract_svg_size(svg : String) -> (Double, Double) {
  let svg_tag = "<svg"
  let tag_start = svg_find(svg, 0, svg_tag)
  if tag_start < 0 {
    return (0.0, 0.0)
  }
  // 从 <svg ...> 部分提取
  let close_tag = svg_find(svg, tag_start, ">")
  let section = if close_tag > tag_start {
    svg[tag_start:close_tag].to_owned()
  } else {
    svg[tag_start:tag_start + 200].to_owned()
  }
  let ws = extract_attr_value(section, "width=\"")
  let hs = extract_attr_value(section, "height=\"")
  let w = if ws.length() > 0 { ws[0] } else { 0.0 }
  let h = if hs.length() > 0 { hs[0] } else { 0.0 }
  (w, h)
}

///|
/// 验证数值是否为合法的有限数（非 NaN/Infinity）
/// NaN 不满足 v == v，Infinity 满足 v * 2 == v
pub fn is_valid_number(v : Double) -> Bool {
  // NaN 检查: NaN != NaN
  // Infinity 检查: Infinity * 2 == Infinity, 且不等于 0
  v == v && (v * 2.0 != v || v == 0.0)
}

///|
/// 将非法数值（NaN/Infinity）替换为 0.0
pub fn sanitize_number(v : Double) -> Double {
  if is_valid_number(v) {
    v
  } else {
    0.0
  }
}

// ==================== 测试 ====================

///|
test "svg_rect_render" {
  let r = SvgRect::new(10.0, 20.0, 100.0, 50.0, "red", "black", 2, 0.0, 0.0)
  let s = r.render()
  assert_eq(s.has_prefix("<rect"), true)
  assert_eq(s.contains("width=\"100\""), true)
  assert_eq(s.contains("fill=\"red\""), true)
}

///|
test "svg_circle_render" {
  let c = SvgCircle::new(50.0, 50.0, 30.0, "blue", "none", 0)
  let s = c.render()
  assert_eq(s.has_prefix("<circle"), true)
  assert_eq(s.contains("r=\"30\""), true)
}

///|
test "svg_text_render" {
  let t = SvgText::new(10.0, 20.0, "Hello", 14, "black", "start", "sans-serif")
  let s = t.render()
  assert_eq(s.has_prefix("<text"), true)
  assert_eq(s.contains(">Hello</text>"), true)
}

///|
test "svg_line_render" {
  let l = SvgLine::new(0.0, 0.0, 100.0, 100.0, "#333", 1)
  let s = l.render()
  assert_eq(s.has_prefix("<line"), true)
  assert_eq(s.contains("x1=\"0\""), true)
}

///|
test "svg_group_render" {
  let r = SvgRect::new(0.0, 0.0, 10.0, 10.0, "red", "none", 0, 0.0, 0.0)
  let g = SvgGroup::new([RectElement(r)], "")
  let s = g.render()
  assert_eq(s.has_prefix("<g>"), true)
}

///|
test "svg_group_with_transform" {
  let r = SvgRect::new(0.0, 0.0, 10.0, 10.0, "red", "none", 0, 0.0, 0.0)
  let g = SvgGroup::new([RectElement(r)], "rotate(45)")
  let s = g.render()
  assert_eq(s.contains("transform=\"rotate(45)\""), true)
}

///|
test "render_svg_element_dispatch" {
  let r = SvgRect::new(0.0, 0.0, 10.0, 10.0, "red", "none", 0, 0.0, 0.0)
  let s = RectElement(r) |> render_svg_element
  assert_eq(s.has_prefix("<rect"), true)
}
