import gleam/int
import gleam/list
import gleam/result as rs
import gleam/string as str
import simplifile as fs

pub type Binary =
  List(Int)

pub fn main() {
  let ba = get_data()
  let gamma =
    ba |> transpose([]) |> list.map(reduce_to_most_common) |> binary_to_int(1)
  let epsilon =
    ba |> transpose([]) |> list.map(reduce_to_least_common) |> binary_to_int(1)
  echo gamma
  echo epsilon
  echo gamma * epsilon
}

fn get_data() -> List(Binary) {
  let assert Ok(lines) = fs.read("src/data.txt")
  str.split(lines, "\r\n")
  |> list.map(string_to_binary(_, []))
}

/// call to this function should pass an empty list for accum
fn string_to_binary(s: String, accum: Binary) -> Binary {
  case str.pop_grapheme(s) {
    Error(Nil) -> accum
    Ok(#(first, rest)) ->
      string_to_binary(
        rest,
        list.prepend(accum, rs.unwrap(int.parse(first), -1)),
      )
  }
}

/// call to this function should pass an empty list for accum
fn first_digits(data: List(Binary), accum: Binary) -> Binary {
  case data {
    [] -> accum
    [first, ..rest] ->
      first_digits(rest, list.append(accum, [rs.unwrap(list.first(first), -1)]))
  }
}

/// returns a List(Binary) without the first digit (i.e. the "rest" of them)
fn rest_digits(data: List(Binary)) -> List(Binary) {
  case rs.unwrap(list.first(data), [-1]) {
    [] -> []
    _ -> data |> list.map(list.rest) |> list.map(rs.unwrap(_, []))
  }
}

/// call to this function should pass an empty list for accum
fn transpose(data: List(Binary), accum: List(Binary)) -> List(Binary) {
  let r = rest_digits(data)
  case r {
    [] -> accum
    _ -> transpose(r, list.append(accum, [first_digits(data, [])]))
  }
}

fn sum(datum: Binary, accum: Int) -> Int {
  case datum {
    [] -> accum
    [first, ..rest] -> sum(rest, accum + first)
  }
}

fn reduce_to_most_common(datum: Binary) -> Int {
  let half = list.length(datum) / 2
  let total = sum(datum, 0)
  case total < half {
    True -> 0
    False -> 1
  }
}

fn reduce_to_least_common(datum: Binary) -> Int {
  let half = list.length(datum) / 2
  let total = sum(datum, 0)
  case total < half {
    True -> 1
    False -> 0
  }
}

/// call the function with starting value of 1 for the power
fn binary_to_int(datum: Binary, power: Int) -> Int {
  case datum {
    [] -> 0
    [first, ..rest] -> first * power + binary_to_int(rest, power * 2)
  }
}
