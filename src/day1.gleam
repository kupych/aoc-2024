import gleam/io
import gleam/list
import gleam/regexp

pub fn main() {
  let file: String = erlang_file_read("files/1")
  let options = (multi_line: True)
  let regex = regexp.compile("\\s+", with: options)
  let numbers = file
    

  let numbers = regexp.split(with: regex, content: file)
    |> list.chunk(2)
    |> list.unzip()
  io.print("First list: #{numbers}")
  }

  @external(erlang, "file", "read")
  pub fn erlang_file_read(file: String) -> String
