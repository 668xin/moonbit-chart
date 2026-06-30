/// 几何计算工具模块
/// 提供坐标计算、图形变换等能力

/// 二维坐标点
pub struct Point {
  x : Int
  y : Int
}

/// 矩形区域
pub struct Rect {
  x : Int
  y : Int
  width : Int
  height : Int
}

/// 创建一个坐标点
pub fn Point::new(x : Int, y : Int) -> Point { { x, y } }

/// 创建一个矩形
pub fn Rect::new(x : Int, y : Int, width : Int, height : Int) -> Rect {
  { x, y, width, height }
}
