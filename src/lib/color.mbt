/// 颜色工具模块
/// 提供颜色定义、转换和管理能力

///|
/// 颜色结构体
pub struct Color {
  r : Int
  g : Int
  b : Int
  a : Double
}

///|
/// 预定义颜色
pub fn Color::red() -> Color {
  Color::{ r: 255, g: 0, b: 0, a: 1.0 }
}

///|
pub fn Color::green() -> Color {
  Color::{ r: 0, g: 255, b: 0, a: 1.0 }
}

///|
pub fn Color::blue() -> Color {
  Color::{ r: 0, g: 0, b: 255, a: 1.0 }
}

///|
pub fn Color::black() -> Color {
  Color::{ r: 0, g: 0, b: 0, a: 1.0 }
}

///|
pub fn Color::white() -> Color {
  Color::{ r: 255, g: 255, b: 255, a: 1.0 }
}

///|
/// 转换为 CSS 颜色字符串
pub fn Color::to_css(self : Color) -> String {
  let r = self.r.to_string()
  let g = self.g.to_string()
  let b = self.b.to_string()
  "rgba(" + r + "," + g + "," + b + "," + self.a.to_string() + ")"
}

// ==================== 测试 ====================

///|
test "color_red" {
  let c = Color::red()
  assert_eq(c.r, 255)
  assert_eq(c.g, 0)
  assert_eq(c.b, 0)
  assert_eq(c.a, 1.0)
}

///|
test "color_green" {
  let c = Color::green()
  assert_eq(c.r, 0)
  assert_eq(c.g, 255)
  assert_eq(c.b, 0)
}

///|
test "color_blue" {
  let c = Color::blue()
  assert_eq(c.b, 255)
}

///|
test "color_black" {
  let c = Color::black()
  assert_eq(c.r, 0)
  assert_eq(c.g, 0)
  assert_eq(c.b, 0)
}

///|
test "color_white" {
  let c = Color::white()
  assert_eq(c.r, 255)
  assert_eq(c.g, 255)
  assert_eq(c.b, 255)
}

///|
test "color_to_css" {
  let c = Color::red()
  let css = c.to_css()
  assert_eq(css, "rgba(255,0,0,1)")
}
