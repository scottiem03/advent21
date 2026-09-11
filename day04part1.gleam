import gleam/int
import gleam/io
import gleam/list
import gleam/result as rs
import gleam/string as str
import simplifile as fs

// positions are denoted with top left as (0, 0)
pub type BingoNum {
  BingoNum(num: Int, marked: Bool, posx: Int, posy: Int)
}

pub type BingoCard =
  List(BingoNum)

pub fn main() {
  let nums_called_out = get_nums_called_out()
  // print_int_list(nums_called_out)

  let bcs = get_bingo_cards()

  let #(winner, winning_num) = process_nums(nums_called_out, bcs)
  io.print(show_bingo_card(winner))
  io.println("Winning number: " <> int.to_string(winning_num))

  io.println("Sum unmarked: " <> int.to_string(sum_unmarked(winner)))
  io.println(
    "Game outcome: " <> int.to_string(winning_num * sum_unmarked(winner)),
  )
}

//
//------------- Getting the data

/// the easy one; get the first line of the data file as a list of Int
fn get_nums_called_out() -> List(Int) {
  let assert Ok(file) = fs.read("src/data.txt")
  let lines = file |> str.split("\r\n")
  let assert Ok(first_line) = list.first(lines)
  first_line
  |> str.split(",")
  |> list.map(fn(x) { int.parse(x) |> rs.unwrap(-1) })
}

/// print a list of numbers, delimited with commas
fn print_int_list(data: List(Int)) -> Nil {
  data |> list.map(int.to_string) |> str.join(",") |> io.print
}

/// return the bingo cards from the data file in a List
fn get_bingo_cards() -> List(BingoCard) {
  let assert Ok(file) = fs.read("src/data.txt")
  let assert Ok(lines) = file |> str.split("\r\n") |> list.rest
  get_bingo_cards_internal(lines, [], []) |> list.drop(1)
}

/// converts a string containing space-delimited numbers to a list of BingoNums;
/// defaults to unmarked with posx: 0, posy: 0
fn line_to_bingo_nums(s: String) -> List(BingoNum) {
  let nums =
    chunk_string(s)
    |> list.map(str.trim)
    |> list.map(int.parse)
    |> list.map(rs.unwrap(_, -1))
  nums |> list.map(BingoNum(_, False, 0, 0))
}

/// hides the accumulators for get_bingo_cards
fn get_bingo_cards_internal(
  lines: List(String),
  single_accum: BingoCard,
  total_accum: List(BingoCard),
) -> List(BingoCard) {
  case lines {
    [] -> total_accum
    [first, ..rest] if first == "" ->
      get_bingo_cards_internal(
        rest,
        [],
        list.append(total_accum, [update_bingo_positions(single_accum, 0, [])]),
      )
    [first, ..rest] ->
      get_bingo_cards_internal(
        rest,
        list.append(single_accum, line_to_bingo_nums(first)),
        total_accum,
      )
  }
}

/// sets the posx and posy for all BingoNums in the BingoCard
fn update_bingo_positions(bc: BingoCard, index: Int, accum: BingoCard) {
  let assert Ok(posx) = int.modulo(index, 5)
  let assert Ok(posy) = int.divide(index, 5)
  case bc {
    [] -> accum
    [first, ..rest] ->
      update_bingo_positions(
        rest,
        index + 1,
        list.append(accum, [BingoNum(first.num, False, posx, posy)]),
      )
  }
}

//
//------------- Running the game
fn process_nums(nums: List(Int), bcs: List(BingoCard)) -> #(BingoCard, Int) {
  let assert [this_num, ..rest_nums] = nums
  let mbcs = mark_all_cards(bcs, this_num)
  let is_winning = check_any_winner(mbcs)

  case is_winning {
    True -> #(get_winner(mbcs) |> rs.unwrap([]), this_num)
    False -> process_nums(rest_nums, mbcs)
  }
}

fn sum_unmarked(bc: BingoCard) -> Int {
  let unmarked = list.filter(bc, fn(x) { x.marked == False })
  let nums_to_sum = unmarked |> list.map(fn(x) { x.num })
  sum_nums(nums_to_sum)
}

fn sum_nums(nums: List(Int)) -> Int {
  list.reduce(nums, fn(x, y) { x + y }) |> rs.unwrap(-1)
}

//
//------------- Functions for BingoNums

/// return a 3-width string, X if marked, num if not
fn show_bingo_num(bn: BingoNum) -> String {
  case bn.marked {
    True -> " X "
    False if bn.num < 10 -> " " <> int.to_string(bn.num) <> " "
    False -> int.to_string(bn.num) <> " "
  }
}

/// return a marked version of the given BingoNum
fn mark_bingo_num(bn: BingoNum) -> BingoNum {
  BingoNum(bn.num, True, bn.posx, bn.posy)
}

//
//------------- Functions for BingoCards

/// show a bingo card as 5 lines of bingo numbers (string output)
fn show_bingo_card(bc: BingoCard) -> String {
  show_bingo_card_internal(bc, 0)
}

/// hides the accumulator for show_bingo_card
fn show_bingo_card_internal(bc: BingoCard, index: Int) -> String {
  let assert Ok(five_counter) = int.modulo(index, 5)

  case bc {
    [] -> "\n"
    [first, ..rest] if five_counter == 0 ->
      "\n" <> show_bingo_num(first) <> show_bingo_card_internal(rest, index + 1)
    [first, ..rest] ->
      show_bingo_num(first) <> show_bingo_card_internal(rest, index + 1)
  }
}

fn show_all_cards(bcs: List(BingoCard)) -> String {
  bcs |> list.map(show_bingo_card) |> str.join("")
}

/// marks the given number for each occurrence in the card
fn mark_bingo_card(bc: BingoCard, num: Int) {
  mark_bingo_card_internal(bc, num, [])
}

/// hides the accumulator for mark_bingo_card
fn mark_bingo_card_internal(
  bc: BingoCard,
  num: Int,
  accum: BingoCard,
) -> BingoCard {
  case bc {
    [] -> accum
    [first, ..rest] if first.num == num ->
      mark_bingo_card_internal(
        rest,
        num,
        list.append(accum, [mark_bingo_num(first)]),
      )
    [first, ..rest] ->
      mark_bingo_card_internal(rest, num, list.append(accum, [first]))
  }
}

/// checks a set of five BingoNums to see if they are all marked
fn check_five(bns: List(BingoNum)) -> Bool {
  list.all(bns, fn(x) { x.marked == True })
}

fn check_winning_card(bc: BingoCard) -> Bool {
  let sets = twelve_sets(bc)
  list.any(sets, check_five)
}

fn check_any_winner(bcs: List(BingoCard)) -> Bool {
  list.any(bcs, check_winning_card)
}

fn get_winner(bcs: List(BingoCard)) -> Result(BingoCard, Nil) {
  let winners = list.filter(bcs, check_winning_card)
  case winners {
    [] -> Error(Nil)
    [first, ..] -> Ok(first)
  }
}

/// return the five rows of a BingoCard
fn get_rows(bc: BingoCard) -> List(List(BingoNum)) {
  get_rows_internal(bc, [])
}

/// hides the accumulator for get_rows
fn get_rows_internal(
  bc: BingoCard,
  accum: List(List(BingoNum)),
) -> List(List(BingoNum)) {
  case bc {
    [] -> accum
    [n1, n2, n3, n4, n5, ..rest] ->
      get_rows_internal(rest, list.append(accum, [[n1, n2, n3, n4, n5]]))
    _ -> panic as "invalid # of BingoNums on card"
  }
}

/// return the five columns of a bingocard
fn get_columns(bc: BingoCard) {
  get_columns_internal(bc, 0, [])
}

/// hides the accumulator for get_columns
fn get_columns_internal(
  bc: BingoCard,
  xval: Int,
  accum: List(List(BingoNum)),
) -> List(List(BingoNum)) {
  case xval >= 5 {
    True -> accum
    False ->
      get_columns_internal(
        bc,
        xval + 1,
        list.append(accum, [list.filter(bc, fn(a) { a.posx == xval })]),
      )
  }
}

// fn get_diagonals(bc: BingoCard) -> List(List(BingoNum)) {
//   let first_diag = list.filter(bc, fn(a) { a.posx == a.posy })
//   let second_diag = list.filter(bc, fn(a) { a.posx + a.posy == 4 })
//   list.append([first_diag], [second_diag])
// }

fn mark_all_cards(bcs: List(BingoCard), num: Int) -> List(BingoCard) {
  bcs |> list.map(mark_bingo_card(_, num))
}

fn twelve_sets(bc: BingoCard) -> List(List(BingoNum)) {
  let rows = get_rows(bc)
  let cols = get_columns(bc)
  // let diags = get_diagonals(bc)
  list.append(rows, cols)
}

//
//------------- Utility Functions

/// returns a list of 3-char strings from one starting string
fn chunk_string(s: String) -> List(String) {
  let chars = str.to_graphemes(s)
  let result = chunk_string_internal(chars, [])
  result |> list.map(str.join(_, ""))
}

/// internal function to hide the accumulator for chunk_string
fn chunk_string_internal(
  chars: List(String),
  accum: List(List(String)),
) -> List(List(String)) {
  let this_chunk = chars |> list.take(3)
  let rest_of_string = chars |> list.drop(3)
  case this_chunk {
    [] -> accum
    _ -> chunk_string_internal(rest_of_string, list.append(accum, [this_chunk]))
  }
}
