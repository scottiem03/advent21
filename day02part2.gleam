import gleam/int
import gleam/list
import gleam/result as rs
import gleam/string as str
import simplifile as fs

pub type Instruction {
  Forward(dist: Int)
  Down(dist: Int)
  Up(dist: Int)
}

pub type Position {
  Position(hor: Int, dep: Int, aim: Int)
}

pub fn main() {
  let instructions = get_instructions()
  let pos = Position(0, 0, 0)

  echo process_instructions(instructions, pos) |> mult_position
}

fn get_instructions() -> List(Instruction) {
  let assert Ok(lines) = fs.read("src/data.txt")
  str.split(lines, "\r\n")
  |> list.map(str_to_instruction)
}

fn str_to_instruction(s: String) -> Instruction {
  let elements = str.split(s, " ")
  let assert [dir, dist, ..] = elements as "line should have two elements"
  let ndist = dist |> int.parse |> rs.unwrap(0)
  case dir {
    "forward" -> Forward(ndist)
    "down" -> Down(ndist)
    "up" -> Up(ndist)
    _ -> panic as "invalid direction"
  }
}

fn process_instruction(com: Instruction, pos: Position) -> Position {
  let Position(hor, dep, aim) = pos
  case com {
    Forward(dist) -> Position(hor + dist, dep + aim * dist, aim)
    Up(dist) -> Position(hor, dep, aim - dist)
    Down(dist) -> Position(hor, dep, aim + dist)
  }
}

fn process_instructions(coms: List(Instruction), pos: Position) -> Position {
  case coms {
    [first, ..rest] ->
      process_instructions(rest, process_instruction(first, pos))
    [] -> pos
  }
}

fn mult_position(pos: Position) -> Int {
  let Position(hor, dep, _aim) = pos
  hor * dep
}
