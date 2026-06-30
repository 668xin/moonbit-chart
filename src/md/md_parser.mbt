/// Markdown 图表配置解析器
/// 从文本中识别 @chart 块并解析为 ChartConfig

/// 解析 Markdown 文本，返回所有图表配置
pub fn parse_chart_configs(text : String) -> Array[ChartConfig] {
  let lines = text.split("\n")
  let line_arr : Array[StringView] = [for l in lines => l]
  let mut configs : Array[ChartConfig] = []
  let mut i = 0
  while i < line_arr.length() {
    let line = line_arr[i].trim().to_owned()
    if line.has_prefix("@chart:") || line.has_prefix("@chart ") {
      let chart_type_str = parse_chart_type_line(line)
      let chart_type = str_to_chart_type(chart_type_str)
      let mut config = ChartConfig::new(chart_type, "", 600.0, 400.0)
      i = i + 1
      while i < line_arr.length() {
        let inner = line_arr[i].trim().to_owned()
        if inner == "@end" { break }
        if inner == "" { i = i + 1; continue }
        config = apply_config_line(inner, config)
        i = i + 1
      }
      configs = configs + [config]
    }
    i = i + 1
  }
  configs
}

/// 提取 @chart: 后面的类型字符串
fn parse_chart_type_line(line : String) -> StringView {
  let trimmed = line.trim()
  if trimmed.has_prefix("@chart:") {
    trimmed[7:]
  } else if trimmed.has_prefix("@chart ") {
    trimmed[7:]
  } else {
    ""
  }
}

/// 字符串转 ChartType
fn str_to_chart_type(s : StringView) -> ChartType {
  let lower = s.to_lower()
  if lower == "line" { ChartType::LineChart }
  else if lower == "pie" { ChartType::PieChart }
  else if lower == "radar" { ChartType::RadarChart }
  else { ChartType::BarChart }
}

/// 应用单行配置到 ChartConfig，返回修改后的配置
fn apply_config_line(line : String, config : ChartConfig) -> ChartConfig {
  let idx = line.find(":")
  if idx is None { return config }
  let i = idx.unwrap()
  let key = line[:i].trim().to_lower().to_owned()
  let value = line[i + 1:].trim()

  if key == "title" { config.title = value.to_owned() }
  else if key == "width" { config.width = parse_double(value, 600.0) }
  else if key == "height" { config.height = parse_double(value, 400.0) }
  else if key == "theme" {
    let v = value.to_lower().to_owned()
    config.theme_mode = if v == "dark" { "dark" } else { "light" }
  }
  else if key == "stacked" {
    let v = value.to_lower().to_owned()
    config.stacked = v == "true" || v == "yes"
  }
  else if key == "categories" { config.categories = parse_categories(value) }
  else if key == "dataset" || key == "data" { config.datasets = config.datasets + [parse_dataset_row(value)] }
  config
}

/// 解析分类标签
fn parse_categories(value : StringView) -> Array[String] {
  let parts = [for p in value.split(",") => p.trim().to_owned()]
  let mut result : Array[String] = []
  let mut i = 0
  while i < parts.length() {
    if parts[i] != "" { result = result + [parts[i]] }
    i = i + 1
  }
  result
}

/// 解析数据集行，返回单个 DataSet
/// 格式: label, color, val1, val2, ...
fn parse_dataset_row(value : StringView) -> DataSet {
  let parts = [for p in value.split(",") => p.trim().to_owned()]
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

/// 解析数值字符串为 Double
fn parse_double(s : StringView, default : Double) -> Double {
  let str = s.trim()
  parse_double_parts(str.to_owned(), default)
}

/// 手动解析 String 中的数值（ASCII 码值硬编码）
fn parse_double_parts(s : String, default : Double) -> Double {
  let len = s.length()
  if len == 0 { return default }
  let mut i = 0
  let mut sign = 1.0
  // '-' = 45, '+' = 43
  if i < len {
    let c = s.code_unit_at(i).to_int()
    if c == 45 { sign = -1.0; i = i + 1 }
    else if c == 43 { i = i + 1 }
  }
  // integer part
  let mut int_part = 0.0
  let mut has_digit = false
  while i < len {
    let c = s.code_unit_at(i).to_int()
    // '0' = 48, '9' = 57, '.' = 46
    if 48 <= c && c <= 57 {
      int_part = int_part * 10.0 + (c - 48).to_double()
      has_digit = true
      i = i + 1
    } else if c == 46 {
      i = i + 1
      break
    } else { break }
  }
  // fractional part
  let mut frac_part = 0.0
  let mut frac_div = 1.0
  while i < len {
    let c = s.code_unit_at(i).to_int()
    if 48 <= c && c <= 57 {
      frac_part = frac_part * 10.0 + (c - 48).to_double()
      frac_div = frac_div * 10.0
      has_digit = true
      i = i + 1
    } else { break }
  }
  if !has_digit { return default }
  sign * (int_part + frac_part / frac_div)
}
