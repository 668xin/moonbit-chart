/// 命令行工具入口
/// 接收 Markdown 图表配置内容作为命令行参数，输出完整 HTML 到 stdout。
/// 文件 I/O 由 PowerShell 包装脚本处理。
///
/// Usage:
///   moonbit-chart "<markdown_content>"  [output_name]
///
/// Or via PowerShell wrapper:
///   scripts/moonbit-chart.ps1 input.md [output.html]

fn main {
  let args = @env.args()
  if args.length() < 2 {
    println("Usage: moonbit-chart \"<markdown_content>\" [output_name]")
    println("  Converts Markdown chart config blocks to an HTML visualization page.")
    println("  Output is written to stdout. File I/O is handled by the wrapper script.")
    println("")
    println("Chart config format:")
    println("  @chart: bar|line|pie|radar")
    println("  title: Chart Title")
    println("  width: 600")
    println("  height: 400")
    println("  categories: Cat1, Cat2, Cat3")
    println("  dataset: Label, #color, val1, val2, val3")
    println("  @end")
    println("")
    println("Example:")
    println("  scripts/moonbit-chart.ps1 charts.md report.html")
    println("")
    println("Or directly:")
    println("  moonbit-chart \"@chart: bar\"")
    return
  }

  // First argument is the raw Markdown content
  let content = args[1]

  // Convert Markdown to HTML
  let converter = @md.MdConverter::new()
  let html = converter.convert(content)

  // Output HTML to stdout
  println(html)
}
