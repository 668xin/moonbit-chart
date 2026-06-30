/// 图表配置数据类型
/// 用于从 Markdown 解析出的图表配置

/// 图表类型
pub enum ChartType {
  BarChart
  LineChart
  PieChart
  RadarChart
}

/// 数据集（柱状图/折线图通用）
pub struct DataSet {
  label : String
  color : String
  values : Array[Double]
}

pub fn DataSet::new(label : String, color : String, values : Array[Double]) -> DataSet {
  { label, color, values }
}

/// 完整图表配置
pub struct ChartConfig {
  chart_type : ChartType
  mut title : String
  mut width : Double
  mut height : Double
  mut theme_mode : String
  mut categories : Array[String]
  mut datasets : Array[DataSet]
  mut stacked : Bool
}

pub fn ChartConfig::new(
  chart_type : ChartType,
  title : String,
  width : Double,
  height : Double
) -> ChartConfig {
  ChartConfig::{
    chart_type, title, width, height,
    theme_mode: "light", categories: [],
    datasets: [], stacked: false
  }
}
