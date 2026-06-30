/// 主题系统模块
/// 支持浅色/深色双主题，提供完整的图表配色方案

///|
/// 主题模式
pub enum ThemeMode {
  Light
  Dark
}

///|
/// 主题配置
pub struct Theme {
  mode : ThemeMode
  background : String
  text_color : String
  grid_color : String
  axis_color : String
  title_color : String
  legend_color : String
  tooltip_bg : String
  tooltip_text : String
  font_family : String
  font_size : Int
  palette : Array[String]
}

///|
/// 使用浅色主题默认配置
pub fn Theme::new_light() -> Theme {
  Theme::{
    mode: Light,
    background: "#ffffff",
    text_color: "#333333",
    grid_color: "#e0e0e0",
    axis_color: "#666666",
    title_color: "#1a1a1a",
    legend_color: "#555555",
    tooltip_bg: "rgba(255,255,255,0.95)",
    tooltip_text: "#333333",
    font_family: "sans-serif",
    font_size: 14,
    palette: [
      "#4e79a7", "#f28e2b", "#e15759", "#76b7b2", "#59a14f", "#edc948", "#b07aa1",
      "#ff9da7", "#9c755f", "#bab0ac",
    ],
  }
}

///|
/// 使用深色主题默认配置
pub fn Theme::new_dark() -> Theme {
  Theme::{
    mode: Dark,
    background: "#1e1e1e",
    text_color: "#e0e0e0",
    grid_color: "#444444",
    axis_color: "#999999",
    title_color: "#ffffff",
    legend_color: "#cccccc",
    tooltip_bg: "rgba(30,30,30,0.95)",
    tooltip_text: "#e0e0e0",
    font_family: "sans-serif",
    font_size: 14,
    palette: [
      "#4e79a7", "#f28e2b", "#e15759", "#76b7b2", "#59a14f", "#edc948", "#b07aa1",
      "#ff9da7", "#9c755f", "#bab0ac",
    ],
  }
}

///|
/// 获取指定索引的色板颜色（自动循环）
pub fn get_palette_color(theme : Theme, index : Int) -> String {
  let len = theme.palette.length()
  if len == 0 {
    return "#000000"
  }
  theme.palette[index % len]
}

///|
/// 获取浅色主题（向后兼容）
pub fn get_light_theme() -> Theme {
  Theme::new_light()
}

///|
/// 获取深色主题（向后兼容）
pub fn get_dark_theme() -> Theme {
  Theme::new_dark()
}

// ==================== 测试 ====================

///|
test "theme_light" {
  let t = Theme::new_light()
  assert_eq(t.background, "#ffffff")
  assert_eq(t.text_color, "#333333")
  assert_eq(t.palette.length(), 10)
}

///|
test "theme_dark" {
  let t = Theme::new_dark()
  assert_eq(t.background, "#1e1e1e")
  assert_eq(t.text_color, "#e0e0e0")
  assert_eq(t.palette.length(), 10)
}

///|
test "theme_palette_color_first" {
  let t = Theme::new_light()
  let c = get_palette_color(t, 0)
  assert_eq(c, "#4e79a7")
}

///|
test "theme_palette_color_wrap" {
  let t = Theme::new_light()
  let c = get_palette_color(t, 10)
  assert_eq(c, "#4e79a7")
}

///|
test "theme_palette_color_mid" {
  let t = Theme::new_light()
  let c = get_palette_color(t, 5)
  assert_eq(c, "#edc948")
}
