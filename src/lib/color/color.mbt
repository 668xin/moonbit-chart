/// 颜色工具模块
/// 提供颜色定义、转换和管理能力

/// 颜色结构体
pub struct Color {
  r : Int
  g : Int
  b : Int
  a : Double
}

/// 预定义颜色
pub fn Color::red() -> Color { Color::{ r: 255, g: 0, b: 0, a: 1.0 } }
pub fn Color::green() -> Color { Color::{ r: 0, g: 255, b: 0, a: 1.0 } }
pub fn Color::blue() -> Color { Color::{ r: 0, g: 0, b: 255, a: 1.0 } }
pub fn Color::black() -> Color { Color::{ r: 0, g: 0, b: 0, a: 1.0 } }
pub fn Color::white() -> Color { Color::{ r: 255, g: 255, b: 255, a: 1.0 } }

/// 转换为 CSS 颜色字符串
pub fn Color::to_css(self : Color) -> String {
  let r = self.r.to_string()
  let g = self.g.to_string()
  let b = self.b.to_string()
  "rgba(" + r + "," + g + "," + b + "," + self.a.to_string() + ")"
}
