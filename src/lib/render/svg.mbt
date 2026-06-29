/// SVG 渲染基座模块
/// 提供基础的 SVG 元素构建和渲染能力

/// SVG 文档结构
pub struct SvgDocument {
  width : Int
  height : Int
  elements : Array[String]
}

/// 创建一个新的 SVG 文档
pub fn SvgDocument::new(width : Int, height : Int) -> SvgDocument {
  SvgDocument::{ width, height, elements: [] }
}

/// 添加 SVG 元素
pub fn SvgDocument::add_element(self : SvgDocument, element : String) -> SvgDocument {
  { ..self, elements: self.elements + [element] }
}

/// 渲染为 SVG 字符串
pub fn SvgDocument::render(self : SvgDocument) -> String {
  let inner = self.elements.fold(init="", fn(acc, el) { acc + el + "\n" })
  let width_str = self.width.to_string()
  let height_str = self.height.to_string()
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<svg width=\"" + width_str + "\" height=\"" + height_str +
    "\" xmlns=\"http://www.w3.org/2000/svg\">\n" + inner + "</svg>"
}
