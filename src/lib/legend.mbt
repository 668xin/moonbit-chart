/// 图例组件
/// 支持位置（顶部/底部/左侧/右侧）、方向（水平/垂直）、颜色匹配

///|
/// 图例位置
pub enum LegendPosition {
  Top
  Bottom
  Left
  Right
}

///|
/// 图例配置
pub struct LegendConfig {
  position : LegendPosition
  font_size : Int
  font_family : String
  text_color : String
  item_width : Double
  item_height : Double
  marker_size : Double
  padding : Double
}

///|
/// 图例数据项
pub struct LegendItem {
  label : String
  color : String
}

///|
/// 创建图例数据项
pub fn LegendItem::new(label : String, color : String) -> LegendItem {
  { label, color }
}

///|
/// 创建默认图例配置
pub fn default_legend_config() -> LegendConfig {
  LegendConfig::{
    position: Bottom,
    font_size: 11,
    font_family: "sans-serif",
    text_color: "#555555",
    item_width: 120.0,
    item_height: 18.0,
    marker_size: 10.0,
    padding: 8.0,
  }
}

///|
/// 计算结果占用的高度（底部/顶部）或宽度（左侧/右侧）
pub fn legend_occupied_height(config : LegendConfig) -> Double {
  match config.position {
    Top | Bottom => config.item_height + config.padding * 2.0
    Left | Right => 0.0
  }
}

///|
pub fn legend_occupied_width(config : LegendConfig) -> Double {
  match config.position {
    Left | Right => 150.0
    Top | Bottom => 0.0
  }
}

///|
/// 渲染图例
/// 返回 (SVG元素数组, 更新后的绘图区)
pub fn render_legend(
  config : LegendConfig,
  items : Array[LegendItem],
  chart_width : Double,
  chart_height : Double,
  _plot_left : Double,
  plot_right : Double,
  plot_top : Double,
  plot_bottom : Double,
) -> Array[SvgElement] {
  let n = items.length()
  if n == 0 {
    return []
  }

  // 图例标记+文字宽度
  let item_total_width = config.marker_size + 4.0 + config.item_width

  match config.position {
    Bottom => {
      let legend_y = chart_height - config.padding - config.marker_size
      let total_items_width = n.to_double() * item_total_width
      let start_x = (chart_width - total_items_width) / 2.0
      let mut elems : Array[SvgElement] = []
      let mut i = 0
      while i < n {
        let item = items[i]
        let lx = start_x + i.to_double() * item_total_width
        let rect = SvgRect::new(
          lx,
          legend_y,
          config.marker_size,
          config.marker_size,
          item.color,
          "none",
          0,
          0.0,
          0.0,
        )
        let text = SvgText::new(
          lx + config.marker_size + 4.0,
          legend_y + config.marker_size - 2.0,
          item.label,
          config.font_size,
          config.text_color,
          "start",
          config.font_family,
        )
        elems = elems + [RectElement(rect), TextElement(text)]
        i = i + 1
      }
      elems
    }
    Top => {
      let legend_y = config.padding
      let total_items_width = n.to_double() * item_total_width
      let start_x = (chart_width - total_items_width) / 2.0
      let mut elems : Array[SvgElement] = []
      let mut i = 0
      while i < n {
        let item = items[i]
        let lx = start_x + i.to_double() * item_total_width
        let rect = SvgRect::new(
          lx,
          legend_y,
          config.marker_size,
          config.marker_size,
          item.color,
          "none",
          0,
          0.0,
          0.0,
        )
        let text = SvgText::new(
          lx + config.marker_size + 4.0,
          legend_y + config.marker_size - 2.0,
          item.label,
          config.font_size,
          config.text_color,
          "start",
          config.font_family,
        )
        elems = elems + [RectElement(rect), TextElement(text)]
        i = i + 1
      }
      elems
    }
    Right => {
      let legend_x = plot_right + config.padding
      let center_y = (plot_top + plot_bottom) / 2.0
      let total_height = n.to_double() * config.item_height
      let start_y = center_y - total_height / 2.0
      let mut elems : Array[SvgElement] = []
      let mut i = 0
      while i < n {
        let item = items[i]
        let ly = start_y + i.to_double() * config.item_height
        let rect = SvgRect::new(
          legend_x,
          ly,
          config.marker_size,
          config.marker_size,
          item.color,
          "none",
          0,
          0.0,
          0.0,
        )
        let text = SvgText::new(
          legend_x + config.marker_size + 4.0,
          ly + config.marker_size - 2.0,
          item.label,
          config.font_size,
          config.text_color,
          "start",
          config.font_family,
        )
        elems = elems + [RectElement(rect), TextElement(text)]
        i = i + 1
      }
      elems
    }
    Left => {
      let legend_x = config.padding
      let center_y = (plot_top + plot_bottom) / 2.0
      let total_height = n.to_double() * config.item_height
      let start_y = center_y - total_height / 2.0
      let mut elems : Array[SvgElement] = []
      let mut i = 0
      while i < n {
        let item = items[i]
        let ly = start_y + i.to_double() * config.item_height
        let rect = SvgRect::new(
          legend_x,
          ly,
          config.marker_size,
          config.marker_size,
          item.color,
          "none",
          0,
          0.0,
          0.0,
        )
        let text = SvgText::new(
          legend_x + config.marker_size + 4.0,
          ly + config.marker_size - 2.0,
          item.label,
          config.font_size,
          config.text_color,
          "start",
          config.font_family,
        )
        elems = elems + [RectElement(rect), TextElement(text)]
        i = i + 1
      }
      elems
    }
  }
}

// ---- LegendConfig builder 辅助方法（供外部包链式调用）----

///|
/// 设置图例位置为顶部
pub fn LegendConfig::with_top_position(self : LegendConfig) -> LegendConfig {
  { ..self, position: Top }
}

///|
/// 设置图例位置为左侧
pub fn LegendConfig::with_left_position(self : LegendConfig) -> LegendConfig {
  { ..self, position: Left }
}

///|
/// 设置图例位置为右侧
pub fn LegendConfig::with_right_position(self : LegendConfig) -> LegendConfig {
  { ..self, position: Right }
}

///|
/// 设置图例文字颜色
pub fn LegendConfig::with_text_color(
  self : LegendConfig,
  color : String,
) -> LegendConfig {
  { ..self, text_color: color }
}

///|
/// 设置字体
pub fn LegendConfig::with_font(
  self : LegendConfig,
  family : String,
  size : Int,
) -> LegendConfig {
  { ..self, font_family: family, font_size: size }
}

// ==================== 测试 ====================

///|
test "legend_item_new" {
  let item = LegendItem::new("Series A", "#ff0000")
  assert_eq(item.label, "Series A")
  assert_eq(item.color, "#ff0000")
}

///|
test "legend_config_default" {
  let c = default_legend_config()
  assert_eq(c.font_size, 11)
  assert_eq(c.item_width, 120.0)
}

///|
test "legend_config_with_top" {
  let c = default_legend_config()
  let c2 = c.with_top_position()
  // 默认 position 是 Bottom，修改为 Top 后 height 计算结果应一致
  let h = legend_occupied_height(c2)
  assert_eq(h > 0.0, true)
}

///|
test "legend_config_with_left" {
  let c = default_legend_config()
  let c2 = c.with_left_position()
  let w = legend_occupied_width(c2)
  assert_eq(w > 0.0, true)
}

///|
test "legend_config_with_right" {
  let c = default_legend_config()
  let c2 = c.with_right_position()
  let w = legend_occupied_width(c2)
  assert_eq(w > 0.0, true)
}

///|
test "legend_occupied_height_bottom" {
  let c = default_legend_config()
  let h = legend_occupied_height(c)
  assert_eq(h > 0.0, true)
}
