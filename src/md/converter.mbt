/// Markdown 转 HTML 工具模块
/// 解析 Markdown 中的图表标记，输出完整的 HTML 可视化页面

pub struct MdConverter {
  page_title : String
}

/// 创建 MdConverter 实例
pub fn MdConverter::new() -> MdConverter { MdConverter::{ page_title: "Charts" } }

/// 设置页面标题
pub fn MdConverter::with_title(_self : MdConverter, title : String) -> MdConverter {
  { page_title: title }
}

/// 转换 Markdown 文本为 HTML 可视化页面
/// 解析 @chart 块生成图表并嵌入 HTML
pub fn MdConverter::convert(self : MdConverter, markdown : String) -> String {
  // 1. 解析图表配置
  let configs = parse_chart_configs(markdown)

  // 2. 渲染每个配置为 SVG
  let mut svgs : Array[String] = []
  let mut i = 0
  while i < configs.length() {
    let svg = render_config_to_svg(configs[i])
    svgs = svgs + [svg]
    i = i + 1
  }

  // 3. 生成完整 HTML 页面
  render_html_page(self.page_title, svgs)
}
