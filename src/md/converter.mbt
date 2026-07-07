///|
/// Markdown 转 HTML 工具模块
/// 解析 Markdown 全文（含 Markdown 标题/段落 + @chart 图表块），输出完整的 HTML 可视化页面
pub struct MdConverter {
  page_title : String
}

///|
/// 创建 MdConverter 实例
pub fn MdConverter::new() -> MdConverter {
  MdConverter::{ page_title: "Charts" }
}

///|
/// 设置页面标题
pub fn MdConverter::with_title(
  _self : MdConverter,
  title : String,
) -> MdConverter {
  { page_title: title }
}

///|
/// 转换 Markdown 文本为 HTML 可视化页面
/// 1. 解析全文为文档块（标题、段落、图表等）
/// 2. 图表块渲染为内嵌 SVG
/// 3. 所有块按原始顺序生成 HTML 页面
pub fn MdConverter::convert(self : MdConverter, markdown : String) -> String {
  let blocks = parse_markdown_blocks(markdown)
  render_html_page(self.page_title, blocks)
}

// ==================== 测试 ====================

///|
test "md_converter_new" {
  let converter = MdConverter::new()
  assert_eq(converter.page_title, "Charts")
}

///|
test "md_converter_with_title" {
  let converter = MdConverter::new()
  let c2 = converter.with_title("My Report")
  assert_eq(c2.page_title, "My Report")
}

///|
test "md_converter_convert_empty" {
  let converter = MdConverter::new()
  let html = converter.convert("")
  assert_eq(html.has_prefix("<!DOCTYPE html>"), true)
  assert_eq(html.contains("<h1>Charts</h1>"), true)
}

///|
test "md_converter_convert_heading" {
  let converter = MdConverter::new()
  let html = converter.convert("# Hello")
  assert_eq(html.contains("<h1>Hello</h1>"), true)
}

///|
test "md_converter_convert_paragraph" {
  let converter = MdConverter::new()
  let html = converter.convert("Some text here")
  assert_eq(html.contains("<p>Some text here</p>"), true)
}

///|
test "md_converter_convert_chart_to_svg" {
  let converter = MdConverter::new()
  let md = "@chart: bar\n  title: Bar\n  categories: A, B\n  dataset: S1, blue, 10, 20\n@end"
  let html = converter.convert(md)
  assert_eq(html.contains("<svg"), true)
}

// ==================== 回归测试 ====================

///|
/// CLI 输出回归测试：验证 HTML 页面结构完整性
test "html_output_structure_regression" {
  let converter = MdConverter::new()
  let md = "# Sales Report\n\nThis report shows Q1 sales.\n\n@chart: bar\n  title: Q1 Sales\n  categories: Jan, Feb, Mar\n  dataset: Revenue, #4e79a7, 100, 200, 150\n@end\n\n---\n\n@chart: line\n  title: Q1 Trend\n  categories: Jan, Feb, Mar\n  dataset: Growth, #f28e2b, 10, 25, 18\n@end"
  let html = converter.convert(md)
  // HTML 基本结构
  assert_eq(html.has_prefix("<!DOCTYPE html>"), true)
  assert_eq(html.contains("<html"), true)
  assert_eq(html.contains("<head>"), true)
  assert_eq(html.contains("<body>"), true)
  // 标题渲染
  assert_eq(html.contains("<h1>Sales Report</h1>"), true)
  // 段落渲染
  assert_eq(html.contains("<p>This report shows Q1 sales.</p>"), true)
  // 两个图表都应渲染为 SVG
  assert_eq(html.contains("<svg"), true)
  // 水平线渲染
  assert_eq(html.contains("<hr"), true)
}

///|
/// 空数据和边界情况回归测试
test "html_output_edge_cases_regression" {
  let converter = MdConverter::new()
  // 空内容
  let html1 = converter.convert("")
  assert_eq(html1.has_prefix("<!DOCTYPE html>"), true)
  // 纯 Markdown 文本（无图表）
  let html2 = converter.convert("# Title\n\nSome text")
  assert_eq(html2.contains("<h1>Title</h1>"), true)
  assert_eq(html2.contains("<p>Some text</p>"), true)
  // 无效图表配置应优雅降级，显示无数据 SVG
  let html3 = converter.convert("@chart: unknown\n@end")
  assert_eq(html3.contains("No data"), true)
}
