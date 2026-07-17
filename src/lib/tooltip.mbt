/// Tooltip 提示框组件
/// 支持 SVG 原生悬浮提示（<title>）和结构化 Tooltip 框

///|
/// Tooltip 配置
pub struct TooltipConfig {
  background : String
  text_color : String
  font_size : Int
  font_family : String
  border_radius : Double
  padding : Double
}

///|
/// 创建默认 Tooltip 配置
pub fn default_tooltip_config() -> TooltipConfig {
  TooltipConfig::{
    background: "#333333",
    text_color: "#ffffff",
    font_size: 11,
    font_family: "sans-serif",
    border_radius: 4.0,
    padding: 6.0,
  }
}

///|
/// 为 SVG 元素添加 title 悬浮提示
/// 将元素包裹在 <g> 内，添加 <title> 子元素以实现浏览器原生悬浮效果
pub fn with_tooltip(elem : SvgElement, tooltip_text : String) -> SvgElement {
  GroupElement(SvgGroup::with_tooltip([elem], "", tooltip_text))
}

///|
/// 渲染结构化 Tooltip 框（浮现在图表上方）
/// 返回一个带背景和文字的 Tooltip 框元素
pub fn render_tooltip_box(
  x : Double,
  y : Double,
  lines : Array[String],
  config : TooltipConfig,
) -> SvgElement {
  let line_height = config.font_size.to_double() + 4.0
  let box_height = lines.length().to_double() * line_height +
    config.padding * 2.0
  // 估算最大文字宽度（按平均字符宽度 7px）
  let mut max_w = 0
  let mut i = 0
  while i < lines.length() {
    let w = lines[i].length() * 7
    if w > max_w {
      max_w = w
    }
    i = i + 1
  }
  let box_width = max_w.to_double() + config.padding * 2.0

  let mut group_children = [
    RectElement(
      SvgRect::new(
        x,
        y,
        box_width,
        box_height,
        config.background,
        "none",
        0,
        config.border_radius,
        config.border_radius,
      ),
    ),
  ]
  let mut cy = y + config.padding + config.font_size.to_double()
  let mut i = 0
  while i < lines.length() {
    let text = TextElement(
      SvgText::new(
        x + config.padding,
        cy,
        lines[i],
        config.font_size,
        config.text_color,
        "start",
        config.font_family,
      ),
    )
    group_children = group_children + [text]
    cy = cy + line_height
    i = i + 1
  }
  GroupElement(SvgGroup::new(group_children, ""))
}

///|
/// 快捷创建单行 Tooltip 框
pub fn render_simple_tooltip(
  x : Double,
  y : Double,
  text : String,
  config : TooltipConfig,
) -> SvgElement {
  render_tooltip_box(x, y, [text], config)
}

// ==================== 测试 ====================

///|
test "tooltip_config_default" {
  let c = default_tooltip_config()
  assert_eq(c.font_size, 11)
  assert_eq(c.text_color, "#ffffff")
}

///|
test "tooltip_with_title_wraps" {
  let r = SvgRect::new(0.0, 0.0, 10.0, 10.0, "red", "none", 0, 0.0, 0.0)
  let elem = RectElement(r)
  let wrapped = with_tooltip(elem, "Hello")
  // 验证返回的是 GroupElement 且包含 title 标签
  let s = wrapped |> render_svg_element
  assert_eq(s.has_prefix("<g>"), true)
  assert_eq(s.contains("<title>Hello</title>"), true)
}

///|
test "tooltip_simple_box" {
  let c = default_tooltip_config()
  let box_elem = render_simple_tooltip(50.0, 50.0, "Item: 100", c)
  let s = box_elem |> render_svg_element
  assert_eq(s.contains("Item: 100"), true)
}
