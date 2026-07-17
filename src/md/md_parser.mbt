/// Markdown 文档解析器
/// 将 Markdown 文本解析为 MdBlock 序列（标题、段落、图表块等）

///|
/// 解析 Markdown 文本，返回所有文档块
pub fn parse_markdown_blocks(text : String) -> Array[MdBlock] {
  let lines = text.split("\n")
  let line_arr : Array[StringView] = [ for l in lines => l ]
  let mut blocks : Array[MdBlock] = []
  let mut i = 0
  while i < line_arr.length() {
    let line = line_arr[i].trim()
    let line_owned = line.to_owned()
    // 空行
    if line_owned == "" {
      blocks = blocks + [MdBlock::EmptyLine]
      i = i + 1
      continue
    }
    // @chart 块
    if line_owned.has_prefix("@chart:") || line_owned.has_prefix("@chart ") {
      let (config, next_i) = parse_chart_block(line_owned, line_arr, i + 1)
      blocks = blocks + [MdBlock::Chart(config)]
      i = next_i
      continue
    }
    // 水平线 --- or ***
    if line_owned == "---" || line_owned == "***" || line_owned == "___" {
      blocks = blocks + [MdBlock::HorizontalRule]
      i = i + 1
      continue
    }
    // 标题 # ## ### 等
    if line_owned.has_prefix("#") {
      let level = count_heading_level(line)
      if 1 <= level && level <= 6 {
        let text = line_owned[level:].trim().to_owned()
        blocks = blocks + [MdBlock::Heading(level, text)]
        i = i + 1
        continue
      }
    }
    // 普通段落：收集连续文本行
    let mut paragraph_lines : Array[String] = [line_owned]
    i = i + 1
    while i < line_arr.length() {
      let next = line_arr[i].trim().to_owned()
      if next == "" {
        break
      }
      if next.has_prefix("#") ||
        next.has_prefix("@chart") ||
        next == "---" ||
        next == "***" ||
        next == "___" {
        break
      }
      paragraph_lines = paragraph_lines + [next]
      i = i + 1
    }
    let text = join_lines(paragraph_lines)
    blocks = blocks + [MdBlock::Paragraph(text)]
  }
  blocks
}

///|
/// 计算标题级别（# 的数量）
fn count_heading_level(line : StringView) -> Int {
  let mut level = 0
  let mut j = 0
  while j < line.length() && j < 7 {
    if line.code_unit_at(j) == 35 { // '#' = 35
      level = level + 1
      j = j + 1
    } else {
      break
    }
  }
  // 确保后面是空格
  if j < line.length() && line.code_unit_at(j).to_int() == 32 {
    level
  } else {
    0
  }
}

///|
/// 解析 @chart 块，返回 (配置, 下一行索引)
fn parse_chart_block(
  first_line : String,
  lines : Array[StringView],
  start : Int,
) -> (ChartConfig, Int) {
  let chart_type_str = parse_chart_type_line(first_line)
  let chart_type = str_to_chart_type(chart_type_str)
  let mut config = ChartConfig::new(chart_type, "", 600.0, 400.0)
  let mut i = start
  while i < lines.length() {
    let inner = lines[i].trim().to_owned()
    if inner == "@end" {
      break
    }
    if inner == "" {
      i = i + 1
      continue
    }
    config = apply_config_line(inner, config)
    i = i + 1
  }
  (config, i + 1)
}

///|
/// 提取 @chart: 后面的类型字符串
fn parse_chart_type_line(line : String) -> StringView {
  let trimmed = line.trim()
  if trimmed.has_prefix("@chart:") {
    let s = trimmed[7:].trim()
    s
  } else if trimmed.has_prefix("@chart ") {
    let s = trimmed[7:].trim()
    s
  } else {
    ""
  }
}

///|
/// 字符串转 ChartType
fn str_to_chart_type(s : StringView) -> ChartType {
  let lower = s.to_lower()
  if lower == "line" {
    ChartType::LineChart
  } else if lower == "pie" {
    ChartType::PieChart
  } else if lower == "radar" {
    ChartType::RadarChart
  } else {
    ChartType::BarChart
  }
}

///|
/// 将段落的多行文本用空格拼接
fn join_lines(lines : Array[String]) -> String {
  let mut result = ""
  let mut i = 0
  while i < lines.length() {
    if i > 0 {
      result = result + " "
    }
    result = result + lines[i]
    i = i + 1
  }
  result
}

///|
/// 应用单行配置到 ChartConfig，返回修改后的配置
fn apply_config_line(line : String, config : ChartConfig) -> ChartConfig {
  let idx = line.find(":")
  if idx is None {
    return config
  }
  let i = idx.unwrap()
  let key = line[:i].trim().to_lower().to_owned()
  let value = line[i + 1:].trim()

  if key == "title" {
    config.title = value.to_owned()
  } else if key == "width" {
    config.width = parse_double(value, 600.0)
  } else if key == "height" {
    config.height = parse_double(value, 400.0)
  } else if key == "theme" {
    let v = value.to_lower().to_owned()
    config.theme_mode = if v == "dark" { "dark" } else { "light" }
  } else if key == "stacked" {
    let v = value.to_lower().to_owned()
    config.stacked = v == "true" || v == "yes"
  } else if key == "categories" {
    config.categories = parse_categories(value)
  } else if key == "dataset" || key == "data" {
    config.datasets = config.datasets + [parse_dataset_row(value)]
  }
  config
}

///|
/// 解析分类标签
fn parse_categories(value : StringView) -> Array[String] {
  let parts = [ for p in value.split(",") => p.trim().to_owned() ]
  let mut result : Array[String] = []
  let mut i = 0
  while i < parts.length() {
    if parts[i] != "" {
      result = result + [parts[i]]
    }
    i = i + 1
  }
  result
}

///|
/// 解析数据集行，返回单个 DataSet
/// 格式: label, color, val1, val2, ...
fn parse_dataset_row(value : StringView) -> DataSet {
  let parts = [ for p in value.split(",") => p.trim().to_owned() ]
  if parts.length() < 3 {
    return DataSet::new("", "", [])
  }
  let label = parts[0]
  let color = parts[1]
  let mut values : Array[Double] = []
  let mut i = 2
  while i < parts.length() {
    let v = parse_double_parts(parts[i], 0.0)
    values = values + [v]
    i = i + 1
  }
  DataSet::new(label, color, values)
}

///|
/// 解析数值字符串为 Double
fn parse_double(s : StringView, default : Double) -> Double {
  let str = s.trim()
  parse_double_parts(str.to_owned(), default)
}

///|
/// 手动解析 String 中的数值
fn parse_double_parts(s : String, default : Double) -> Double {
  let len = s.length()
  if len == 0 {
    return default
  }
  let mut i = 0
  let mut sign = 1.0
  if i < len {
    let c = s.code_unit_at(i).to_int()
    if c == 45 {
      sign = -1.0
      i = i + 1
    } else if c == 43 {
      i = i + 1
    }
  }
  let mut int_part = 0.0
  let mut has_digit = false
  while i < len {
    let c = s.code_unit_at(i).to_int()
    if 48 <= c && c <= 57 {
      int_part = int_part * 10.0 + (c - 48).to_double()
      has_digit = true
      i = i + 1
    } else if c == 46 {
      i = i + 1
      break
    } else {
      break
    }
  }
  let mut frac_part = 0.0
  let mut frac_div = 1.0
  while i < len {
    let c = s.code_unit_at(i).to_int()
    if 48 <= c && c <= 57 {
      frac_part = frac_part * 10.0 + (c - 48).to_double()
      frac_div = frac_div * 10.0
      has_digit = true
      i = i + 1
    } else {
      break
    }
  }
  if !has_digit {
    return default
  }
  let result = sign * (int_part + frac_part / frac_div)
  // 应用 NaN/Infinity 安全检查
  @lib.sanitize_number(result)
}

// ==================== 测试 ====================

///|
test "parse_double_int" {
  let v = parse_double_parts("42", 0.0)
  assert_eq(v, 42.0)
}

///|
test "parse_double_negative" {
  let v = parse_double_parts("-3.14", 0.0)
  assert_eq(v < -3.0 && v > -3.2, true)
}

///|
test "parse_double_positive_sign" {
  let v = parse_double_parts("+5", 0.0)
  assert_eq(v, 5.0)
}

///|
test "parse_double_empty" {
  let v = parse_double_parts("", 99.0)
  assert_eq(v, 99.0)
}

///|
test "parse_double_label_color_vals" {
  let ds = parse_dataset_row("Sales, #ff0000, 100, 200, 150")
  assert_eq(ds.label, "Sales")
  assert_eq(ds.color, "#ff0000")
  assert_eq(ds.values.length(), 3)
  assert_eq(ds.values[0], 100.0)
}

///|
test "parse_heading_single" {
  let blocks = parse_markdown_blocks("# Hello World")
  assert_eq(blocks.length(), 1)
  // 第一个是 Heading(1, "Hello World")
}

///|
test "parse_heading_h2" {
  let blocks = parse_markdown_blocks("## Section Two")
  assert_eq(blocks.length(), 1)
}

///|
test "parse_chart_block" {
  let md = "@chart: bar\n  title: Test\n  width: 500\n  height: 300\n  categories: A, B\n  dataset: S1, red, 10, 20\n@end"
  let blocks = parse_markdown_blocks(md)
  assert_eq(blocks.length() >= 1, true)
}

///|
test "parse_paragraph" {
  let blocks = parse_markdown_blocks("This is a paragraph.")
  assert_eq(blocks.length(), 1)
}

///|
test "parse_mixed_document" {
  let md = "# Title\n\nThis is a paragraph.\n\n@chart: pie\n  title: Pie\n  dataset: A, red, 30\n  dataset: B, blue, 70\n@end"
  let blocks = parse_markdown_blocks(md)
  // 应包含 Heading + Paragraph + Chart 等
  assert_eq(blocks.length() >= 3, true)
}
