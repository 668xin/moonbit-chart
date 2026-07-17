/// 图例组件
/// 支持位置（顶部/底部/左侧/右侧）、方向（水平/垂直）、颜色匹配
/// 支持自动自适应（文字宽度/字体大小/位置选择）

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
  // 自适应模式启用标志
  auto_adapt : Bool
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
    auto_adapt: true,
  }
}

///|
/// 启用自适应模式
pub fn LegendConfig::with_auto_adapt(self : LegendConfig) -> LegendConfig {
  { ..self, auto_adapt: true }
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
/// 自动计算最佳 item_width（基于最长标签文字）
fn calc_auto_item_width(
  items : Array[LegendItem],
  font_size : Int,
  min_width : Double,
  max_width : Double,
) -> Double {
  let mut max_len = 0
  let mut i = 0
  while i < items.length() {
    let l = items[i].label.length()
    if l > max_len {
      max_len = l
    }
    i = i + 1
  }
  // 估算宽度：平均字符宽度约 0.6 * font_size px，标记占 14px，边距 8px
  let estimated = max_len.to_double() * font_size.to_double() * 0.6 + 14.0 + 8.0
  if estimated < min_width {
    min_width
  } else if estimated > max_width {
    max_width
  } else {
    estimated
  }
}

///|
/// 根据项目数量自动计算合适的字体大小
fn calc_auto_font_size(
  n_items : Int,
  available_width : Double,
  base_size : Int,
) -> Int {
  if n_items <= 0 {
    return base_size
  }
  // 粗略估计：每个项目至少需要 60px 宽度（含标记）
  let needed_per_item = 60.0
  let total_needed = n_items.to_double() * needed_per_item
  if total_needed > available_width && available_width > 100.0 {
    // 空间不足时缩小字体
    let ratio = available_width / total_needed
    let new_size = (base_size.to_double() * ratio).floor()
    if new_size < 8.0 {
      8
    } else if new_size > base_size.to_double() {
      base_size
    } else {
      new_size.to_int()
    }
  } else {
    base_size
  }
}

///|
/// 渲染图例（支持自动自适应）
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

  // 自动自适应计算
  let final_config = if config.auto_adapt {
    let plot_width = plot_right - _plot_left
    let plot_available_w = if plot_width > 100.0 {
      plot_width
    } else {
      chart_width * 0.8
    }
    let auto_fs = calc_auto_font_size(n, plot_available_w, config.font_size)
    let auto_iw = calc_auto_item_width(
      items,
      auto_fs,
      config.item_width,
      if plot_available_w / n.to_double() > 60.0 {
        plot_available_w / n.to_double()
      } else {
        config.item_width
      },
    )
    { ..config, font_size: auto_fs, item_width: auto_iw }
  } else {
    config
  }

  let fs = final_config.font_size
  let iw = final_config.item_width
  let ms = final_config.marker_size
  let pd = final_config.padding

  // 图例标记+文字宽度
  let item_total_width = ms + 4.0 + iw

  match final_config.position {
    Bottom => {
      let legend_y = chart_height - pd - ms
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
          ms,
          ms,
          item.color,
          "none",
          0,
          0.0,
          0.0,
        )
        let text = SvgText::new(
          lx + ms + 4.0,
          legend_y + ms - 2.0,
          truncate_text(item.label, iw, fs),
          fs,
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
      let legend_y = pd
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
          ms,
          ms,
          item.color,
          "none",
          0,
          0.0,
          0.0,
        )
        let text = SvgText::new(
          lx + ms + 4.0,
          legend_y + ms - 2.0,
          truncate_text(item.label, iw, fs),
          fs,
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
      let legend_x = plot_right + pd
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
          ms,
          ms,
          item.color,
          "none",
          0,
          0.0,
          0.0,
        )
        let text = SvgText::new(
          legend_x + ms + 4.0,
          ly + ms - 2.0,
          truncate_text(item.label, iw, fs),
          fs,
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
      let legend_x = pd
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
          ms,
          ms,
          item.color,
          "none",
          0,
          0.0,
          0.0,
        )
        let text = SvgText::new(
          legend_x + ms + 4.0,
          ly + ms - 2.0,
          truncate_text(item.label, iw, fs),
          fs,
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

///|
/// 截断长文本以适应图例宽度
fn truncate_text(label : String, max_width : Double, font_size : Int) -> String {
  // 估算字符宽度为 0.6 * font_size
  let char_w = font_size.to_double() * 0.6
  let max_chars = (max_width / char_w).floor().to_int()
  if max_chars <= 3 {
    return label
  }
  if label.length() > max_chars {
    label[:max_chars - 2].to_owned() + ".."
  } else {
    label
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

///|
test "legend_truncate_long_text" {
  let t = truncate_text("This is a very long series name", 80.0, 11)
  assert_eq(t.length() < "This is a very long series name".length(), true)
}

///|
test "legend_truncate_short_text" {
  let t = truncate_text("Short", 80.0, 11)
  assert_eq(t, "Short")
}

///|
test "calc_auto_item_width_basic" {
  let items = [
    LegendItem::new("Short", "red"),
    LegendItem::new("Very Long Name", "blue"),
  ]
  let w = calc_auto_item_width(items, 11, 60.0, 200.0)
  assert_eq(w >= 60.0, true)
}

///|
test "calc_auto_font_size_small" {
  let fs = calc_auto_font_size(20, 300.0, 11)
  assert_eq(fs <= 11, true)
}
