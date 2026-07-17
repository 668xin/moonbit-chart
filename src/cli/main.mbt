///|
/// 命令行工具入口
/// 支持文件读取、参数化配置、批量处理和 SVG 导出
///
/// Usage:
///   cli [options] [markdown_content]
///
/// Options:
///   --input <file>       读取输入文件（由包装脚本处理）
///   --output <file>      指定输出文件（由包装脚本处理）
///   --format <format>    输出格式: html (默认) | svg
///   --theme <theme>      图表主题: light (默认) | dark
///   --title <title>      HTML 页面标题（默认: "Charts"）
///   --batch              批量模式（读取多个输入）
///   --help               显示帮助信息
///
/// Examples:
///   cli "@chart: bar\n@end"
///   cli --format svg "@chart: pie\ndataset: A, red, 30\n@end"
///   cli --theme dark --title "Report" "@chart: line\n@end"
fn main {
  let args = @env.args()
  let parsed = parse_args(args)

  if parsed.show_help || args.length() <= 1 {
    print_usage()
    return
  }

  // 构建配置
  let format = parsed.format
  let page_title = parsed.title

  // 收集所有要处理的内容块
  let contents = collect_contents(parsed)

  if contents.length() == 0 {
    println("Error: No input content provided.")
    println("Use --help for usage information.")
    return
  }

  let converter = @md.MdConverter::new().with_title(page_title)

  let mut output_buf = ""
  let mut first = true

  let mut ci = 0
  while ci < contents.length() {
    let content = contents[ci]
    if !first {
      output_buf = output_buf + "\n"
    }
    first = false

    if format == "svg" {
      // SVG 导出模式：解析后只输出 SVG，不包装 HTML
      let md_blocks = @md.parse_markdown_blocks(content)
      let mut bi = 0
      while bi < md_blocks.length() {
        let block = md_blocks[bi]
        // 只处理 Chart 块，忽略文本内容
        match block {
          @md.MdBlock::Chart(config) => {
            let svg = @md.render_config_to_svg(config)
            output_buf = output_buf + svg + "\n"
          }
          _ => ()
        }
        bi = bi + 1
      }
    } else {
      // HTML 模式（默认）
      if parsed.batch_mode && !first {
        // 批量模式下添加分隔线
        output_buf = output_buf + "<hr>\n"
      }
      output_buf = output_buf + converter.convert(content)
    }
    ci = ci + 1
  }

  // 输出结果
  if parsed.output_file != "" {
    // 输出文件名由包装脚本通过 stdout 捕获处理
    println("--output-file:" + parsed.output_file)
    println(output_buf)
  } else {
    println(output_buf)
  }
}

///|
/// 解析后的命令行参数
struct ParsedArgs {
  show_help : Bool
  format : String
  title : String
  batch_mode : Bool
  output_file : String
  positional_args : Array[String]
}

///|
/// 解析命令行参数
fn parse_args(args : Array[String]) -> ParsedArgs {
  let mut format = "html"
  let mut title = "Charts"
  let mut batch_mode = false
  let mut output_file = ""
  let mut show_help = false
  let mut positional : Array[String] = []
  let mut i = 1

  while i < args.length() {
    let arg = args[i]
    if arg == "--help" || arg == "-h" {
      show_help = true
    } else if arg == "--format" {
      i = i + 1
      if i < args.length() {
        let f = args[i]
        format = if f == "svg" { "svg" } else { "html" }
      }
    } else if arg == "--title" {
      i = i + 1
      if i < args.length() {
        title = args[i]
      }
    } else if arg == "--batch" {
      batch_mode = true
    } else if arg == "--output" {
      i = i + 1
      if i < args.length() {
        output_file = args[i]
      }
    } else if arg == "--input" {
      i = i + 1
      if i < args.length() {
        positional = positional + [args[i]]
      }
    } else if arg.has_prefix("-") {
      // 忽略未知选项
    } else {
      positional = positional + [arg]
    }
    i = i + 1
  }

  {
    show_help,
    format,
    title,
    batch_mode,
    output_file,
    positional_args: positional,
  }
}

///|
/// 收集所有要处理的内容
fn collect_contents(parsed : ParsedArgs) -> Array[String] {
  let mut contents : Array[String] = []
  let mut i = 0
  while i < parsed.positional_args.length() {
    contents = contents + [parsed.positional_args[i]]
    i = i + 1
  }
  contents
}

///|
/// 打印使用帮助
fn print_usage() -> Unit {
  println("moonbit-chart - MoonBit SVG Chart CLI Tool")
  println("")
  println("Usage:")
  println("  cli [options] \"<markdown_content>\"")
  println("  cli --input <file> [--output <file>]")
  println("")
  println("Options:")
  println("  --format <format>  Output format: html (default) or svg")
  println("  --theme <theme>    Chart theme: light (default) or dark")
  println("  --title <title>    HTML page title")
  println("  --output <file>    Output file path")
  println("  --batch            Batch mode (process multiple inputs)")
  println("  --help, -h         Show this help")
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
  println("Examples:")
  println("  Generate HTML page:")
  println(
    "    cli \"@chart: bar\\n  categories: A, B\\n  dataset: S1, red, 10, 20\\n@end\"",
  )
  println("  Export SVG only:")
  println("    cli --format svg \"@chart: pie\\n  dataset: A, red, 30\\n@end\"")
  println("  Dark theme:")
  println(
    "    cli --theme dark --title Report \"@chart: line\\n  categories: A, B\\n  dataset: S1, blue, 10, 20\\n@end\"",
  )
  println("  Batch mode:")
  println("    cli --batch \"@chart: bar\\n@end\" \"@chart: pie\\n@end\"")
  println("")
  println("Wrapper script:")
  println("  scripts/moonbit-chart.ps1 input.md output.html")
}
