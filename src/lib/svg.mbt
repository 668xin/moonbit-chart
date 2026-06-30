/// SVG 渲染基座模块
/// 提供基础的 SVG 文档管理和渲染能力

///|
/// SVG 文档结构
pub struct SvgDocument {
  width : Int
  height : Int
  elements : Array[SvgElement]
}

///|
/// 创建一个新的 SVG 文档
pub fn SvgDocument::new(width : Int, height : Int) -> SvgDocument {
  SvgDocument::{ width, height, elements: [] }
}

///|
/// 添加 SVG 元素
pub fn SvgDocument::add_element(
  self : SvgDocument,
  element : SvgElement,
) -> SvgDocument {
  { ..self, elements: self.elements + [element] }
}

///|
/// 批量添加 SVG 元素
pub fn SvgDocument::add_elements(
  self : SvgDocument,
  elems : Array[SvgElement],
) -> SvgDocument {
  { ..self, elements: self.elements + elems }
}

///|
/// 渲染为 SVG 字符串
pub fn SvgDocument::render(self : SvgDocument) -> String {
  let inner = self.elements.fold(init="", fn(a, e) {
    a + render_svg_element(e) + "\n"
  })
  let width_str = self.width.to_string()
  let height_str = self.height.to_string()
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<svg width=\"" +
  width_str +
  "\" height=\"" +
  height_str +
  "\" xmlns=\"http://www.w3.org/2000/svg\">\n" +
  inner +
  "</svg>"
}

// ==================== 测试 ====================

///|
test "svg_doc_new" {
  let doc = SvgDocument::new(600, 400)
  assert_eq(doc.width, 600)
  assert_eq(doc.height, 400)
  assert_eq(doc.elements.length(), 0)
}

///|
test "svg_doc_add_element" {
  let doc = SvgDocument::new(100, 100)
  let r = SvgRect::new(0.0, 0.0, 50.0, 50.0, "red", "none", 0, 0.0, 0.0)
  let d2 = doc.add_element(RectElement(r))
  assert_eq(d2.elements.length(), 1)
}

///|
test "svg_doc_render_empty" {
  let doc = SvgDocument::new(100, 200)
  let s = doc.render()
  assert_eq(s.has_prefix("<?xml"), true)
  assert_eq(s.contains("width=\"100\""), true)
  assert_eq(s.contains("height=\"200\""), true)
}
