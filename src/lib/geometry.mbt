/// 几何计算工具模块
/// 提供坐标计算、图形变换等能力

///|
/// 二维坐标点
pub struct Point {
  x : Int
  y : Int
}

///|
/// 矩形区域
pub struct Rect {
  x : Int
  y : Int
  width : Int
  height : Int
}

///|
/// 创建一个坐标点
pub fn Point::new(x : Int, y : Int) -> Point {
  { x, y }
}

///|
/// 创建一个矩形
pub fn Rect::new(x : Int, y : Int, width : Int, height : Int) -> Rect {
  { x, y, width, height }
}

// ==================== 测试 ====================

///|
test "point_new" {
  let p = Point::new(10, 20)
  assert_eq(p.x, 10)
  assert_eq(p.y, 20)
}

///|
test "rect_new" {
  let r = Rect::new(0, 0, 100, 200)
  assert_eq(r.x, 0)
  assert_eq(r.y, 0)
  assert_eq(r.width, 100)
  assert_eq(r.height, 200)
}
