/// I/O 工具
/// 注意：MoonBit 在 native 目标下 C FFI 存在兼容性问题，
/// 因此文件 I/O 由 PowerShell 包装脚本处理。
/// 本模块仅提供字符编码转换工具函数（纯 MoonBit 实现）。

/// 将 MoonBit String 转为 UTF-8 编码的 Bytes
pub fn string_to_utf8(str : String) -> Bytes {
  let res : Array[Byte] = []
  let len = str.length()
  let mut i = 0
  while i < len {
    let mut c = str.code_unit_at(i).to_int()
    if 0xD800 <= c && c <= 0xDBFF {
      let l = str.code_unit_at(i + 1).to_int() - 0xDC00
      c = (c - 0xD800) * 0x400 + l + 0x10000
      i = i + 1
    }
    if c < 0x80 {
      res.push(c.to_byte())
    } else if c < 0x800 {
      res.push((0xC0 | (c >> 6)).to_byte())
      res.push((0x80 | (c & 0x3F)).to_byte())
    } else if c < 0x10000 {
      res.push((0xE0 | (c >> 12)).to_byte())
      res.push((0x80 | ((c >> 6) & 0x3F)).to_byte())
      res.push((0x80 | (c & 0x3F)).to_byte())
    } else {
      res.push((0xF0 | (c >> 18)).to_byte())
      res.push((0x80 | ((c >> 12) & 0x3F)).to_byte())
      res.push((0x80 | ((c >> 6) & 0x3F)).to_byte())
      res.push((0x80 | (c & 0x3F)).to_byte())
    }
    i = i + 1
  }
  Bytes::from_array(res)
}
