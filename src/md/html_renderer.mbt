/// HTML 页面生成器
/// 将 SVG 嵌入 HTML 页面

/// 生成完整 HTML 页面，包含所有 SVG
pub fn render_html_page(title : String, svg_list : Array[String]) -> String {
  let mut html = "<!DOCTYPE html>\n"
  html = html + "<html lang=\"zh-CN\">\n"
  html = html + "<head>\n"
  html = html + "  <meta charset=\"UTF-8\">\n"
  html = html + "  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n"
  html = html + "  <title>" + escape_html(title) + "</title>\n"
  html = html + "  <style>\n"
  html = html + "    body { font-family: -apple-system, BlinkMacSystemFont, "
  html = html + "Segoe UI, sans-serif; max-width: 960px; margin: 0 auto; "
  html = html + "padding: 20px; background: #f5f5f5; }\n"
  html = html + "    h1 { text-align: center; color: #333; }\n"
  html = html + "    .chart-container { background: white; border-radius: 8px; "
  html = html + "box-shadow: 0 2px 8px rgba(0,0,0,0.1); padding: 20px; "
  html = html + "margin: 20px 0; overflow-x: auto; }\n"
  html = html + "    .chart-title { text-align: center; color: #555; "
  html = html + "font-size: 1.2em; margin-bottom: 15px; }\n"
  html = html + "  </style>\n"
  html = html + "</head>\n"
  html = html + "<body>\n"
  html = html + "  <h1>" + escape_html(title) + "</h1>\n"

  let mut i = 0
  while i < svg_list.length() {
    html = html + "  " + svg_list[i] + "\n"
    i = i + 1
  }

  html = html + "</body>\n"
  html = html + "</html>\n"
  html
}

/// HTML 转义
fn escape_html(s : String) -> String {
  let len = s.length()
  let mut result = ""
  let mut i = 0
  while i < len {
    let c = s.code_unit_at(i).to_int()
    // '<' = 60, '>' = 62, '&' = 38, '"' = 34
    if c == 38 { result = result + "&amp;" }
    else if c == 60 { result = result + "&lt;" }
    else if c == 62 { result = result + "&gt;" }
    else if c == 34 { result = result + "&quot;" }
    else { result = result + "\{c.unsafe_to_char()}" }
    i = i + 1
  }
  result
}

/// SVG 包裹到图表容器
pub fn wrap_chart_svg(title : String, svg : String) -> String {
  let html = "  <div class=\"chart-container\">\n"
  let html2 = html + "    <div class=\"chart-title\">" + escape_html(title) + "</div>\n"
  html2 + "    " + svg + "\n  </div>"
}
