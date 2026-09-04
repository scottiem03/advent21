import gleam/int
import gleam/io
import gleam/list
import gleam/result as rs
import gleam/string as str
import simplifile as fs

pub fn main() {
  let nums = get_nums_list()

  count_increases(nums, 0)
  |> int.to_string()
  |> io.println()
}

fn get_nums_list() -> List(Int) {
  let assert Ok(records) = fs.read(from: "src/data.txt")
  records
  |> str.split("\r\n")
  |> list.map(fn(x) { rs.unwrap(int.parse(x), 0) })
}

fn count_increases(l: List(Int), accum: Int) -> Int {
  case l {
    [first, second, ..rest] if second > first ->
      count_increases([second, ..rest], accum + 1)
    [_, second, ..rest] -> count_increases([second, ..rest], accum)
    [_] -> accum
    [] -> accum
  }
}
