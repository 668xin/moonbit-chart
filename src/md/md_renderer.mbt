/// Markdown 内联渲染器
/// 渲染标准 Markdown 内联元素（粗体、斜体、代码、链接）

///|
/// 渲染段落文本中的内联格式
/// 支持: **粗体**, *斜体*, `代码`, [链接](url)
fn render_inline(text : String) -> String {
  let len = text.length()
  let mut result = ""
  let mut i = 0
  while i < len {
    let c = text.code_unit_at(i).to_int()
    // ** 粗体
    if c == 42 && i + 1 < len && text.code_unit_at(i + 1).to_int() == 42 {
      // 查找匹配的 **
      let end = find_next(text, i + 2, "**")
      if end >= 0 {
        let bold_text = text[i + 2:end].to_owned()
        result = result + "<strong>" + bold_text + "</strong>"
        i = end + 2
        continue
      }
    }
    // * 斜体（不是 **）
    if c == 42 {
      // 可能是 * 斜体
      let end = find_next(text, i + 1, "*")
      if end >= 0 {
        let em_text = text[i + 1:end].to_owned()
        result = result + "<em>" + em_text + "</em>"
        i = end + 1
        continue
      }
    }
    // ` 内联代码
    if c == 96 {
      let end = find_next(text, i + 1, "`")
      if end >= 0 {
        let code_text = text[i + 1:end].to_owned()
        result = result + "<code>" + code_text + "</code>"
        i = end + 1
        continue
      }
    }
    // [链接](url)
    if c == 91 {
      let close_bracket = find_next(text, i + 1, "]")
      if close_bracket >= 0 && close_bracket + 1 < len {
        let next_c = text.code_unit_at(close_bracket + 1).to_int()
        if next_c == 40 {
          let close_paren = find_next(text, close_bracket + 2, ")")
          if close_paren >= 0 {
            let link_text = text[i + 1:close_bracket].to_owned()
            let url = text[close_bracket + 2:close_paren].to_owned()
            result = result + "<a href=\"" + url + "\">" + link_text + "</a>"
            i = close_paren + 1
            continue
          }
        }
      }
    }
    // 转义 HTML 特殊字符
    if c == 38 {
      result = result + "&amp;"
    } else if c == 60 {
      result = result + "&lt;"
    } else if c == 62 {
      result = result + "&gt;"
    } else if c == 34 {
      result = result + "&quot;"
    } else {
      result = result + "\{c.unsafe_to_char()}"
    }
    i = i + 1
  }
  result
}

///|
/// 在字符串中从 start 位置开始查找 pattern，返回匹配起始位置或 -1
fn find_next(text : String, start : Int, pattern : String) -> Int {
  let text_len = text.length()
  let pat_len = pattern.length()
  if pat_len == 0 {
    return -1
  }
  let mut i = start
  while i + pat_len <= text_len {
    let mut matched = true
    let mut j = 0
    while j < pat_len {
      if text.code_unit_at(i + j) != pattern.code_unit_at(j) {
        matched = false
        break
      }
      j = j + 1
    }
    if matched {
      return i
    }
    i = i + 1
  }
  -1
}

// ==================== 测试 ====================

///|
test "render_inline_plain" {
  let r = render_inline("Hello World")
  assert_eq(r, "Hello World")
}

///|
test "render_inline_bold" {
  let r = render_inline("This is **bold** text")
  assert_eq(r.contains("<strong>bold</strong>"), true)
}

///|
test "render_inline_italic" {
  let r = render_inline("This is *italic* text")
  assert_eq(r.contains("<em>italic</em>"), true)
}

///|
test "render_inline_code" {
  let r = render_inline("Use `moon build` to compile")
  assert_eq(r.contains("<code>moon build</code>"), true)
}

///|
test "render_inline_link" {
  let r = render_inline("See [MoonBit](https://moonbitlang.com)")
  assert_eq(r.contains("<a href=\"https://moonbitlang.com\">MoonBit</a>"), true)
}

///|
test "find_next_basic" {
  let i = find_next("hello **world**", 0, "**")
  assert_eq(i, 6)
}

///|
test "find_next_not_found" {
  let i = find_next("hello world", 0, "**")
  assert_eq(i, -1)
}
