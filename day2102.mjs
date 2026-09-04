import * as $stdlib$dict from "../gleam_stdlib/gleam/dict.mjs";
import * as $int from "../gleam_stdlib/gleam/int.mjs";
import * as $list from "../gleam_stdlib/gleam/list.mjs";
import * as $rs from "../gleam_stdlib/gleam/result.mjs";
import * as $str from "../gleam_stdlib/gleam/string.mjs";
import * as $fs from "../simplifile/simplifile.mjs";
import {
  Ok,
  Empty as $Empty,
  NonEmpty as $NonEmpty,
  CustomType as $CustomType,
  makeError,
  bitArraySlice,
  bitArraySliceToInt,
  BitArray as $BitArray,
  List as $List,
  UtfCodepoint as $UtfCodepoint,
} from "./gleam.mjs";

const FILEPATH = "src\\day2102.gleam";

export class Forward extends $CustomType {
  constructor(dist) {
    super();
    this.dist = dist;
  }
}
export const Instruction$Forward = (dist) => new Forward(dist);
export const Instruction$isForward = (value) => value instanceof Forward;
export const Instruction$Forward$dist = (value) => value.dist;
export const Instruction$Forward$0 = (value) => value.dist;

export class Down extends $CustomType {
  constructor(dist) {
    super();
    this.dist = dist;
  }
}
export const Instruction$Down = (dist) => new Down(dist);
export const Instruction$isDown = (value) => value instanceof Down;
export const Instruction$Down$dist = (value) => value.dist;
export const Instruction$Down$0 = (value) => value.dist;

export class Up extends $CustomType {
  constructor(dist) {
    super();
    this.dist = dist;
  }
}
export const Instruction$Up = (dist) => new Up(dist);
export const Instruction$isUp = (value) => value instanceof Up;
export const Instruction$Up$dist = (value) => value.dist;
export const Instruction$Up$0 = (value) => value.dist;

export const Instruction$dist = (value) => value.dist;

export class Position extends $CustomType {
  constructor(hor, dep, aim) {
    super();
    this.hor = hor;
    this.dep = dep;
    this.aim = aim;
  }
}
export const Position$Position = (hor, dep, aim) => new Position(hor, dep, aim);
export const Position$isPosition = (value) => value instanceof Position;
export const Position$Position$hor = (value) => value.hor;
export const Position$Position$0 = (value) => value.hor;
export const Position$Position$dep = (value) => value.dep;
export const Position$Position$1 = (value) => value.dep;
export const Position$Position$aim = (value) => value.aim;
export const Position$Position$2 = (value) => value.aim;

function mult_position(pos) {
  let hor = pos.hor;
  let dep = pos.dep;
  return hor * dep;
}

function process_instruction(com, pos) {
  let hor = pos.hor;
  let dep = pos.dep;
  let aim = pos.aim;
  if (com instanceof Forward) {
    let dist = com.dist;
    return new Position(hor + dist, dep + aim * dist, aim);
  } else if (com instanceof Down) {
    let dist = com.dist;
    return new Position(hor, dep, aim + dist);
  } else {
    let dist = com.dist;
    return new Position(hor, dep, aim - dist);
  }
}

function process_instructions(loop$coms, loop$pos) {
  while (true) {
    let coms = loop$coms;
    let pos = loop$pos;
    if (coms instanceof $Empty) {
      return pos;
    } else {
      let first = coms.head;
      let rest = coms.tail;
      loop$coms = rest;
      loop$pos = process_instruction(first, pos);
    }
  }
}

function str_to_instruction(s) {
  let elements = $str.split(s, " ");
  let dir;
  let dist;
  if (elements instanceof $Empty) {
    throw makeError(
      "let_assert",
      FILEPATH,
      "day2102",
      32,
      "str_to_instruction",
      "line should have two elements",
      {
        value: elements,
        start: 657,
        end: 694,
        pattern_start: 668,
        pattern_end: 683
      }
    )
  } else {
    let $ = elements.tail;
    if ($ instanceof $Empty) {
      throw makeError(
        "let_assert",
        FILEPATH,
        "day2102",
        32,
        "str_to_instruction",
        "line should have two elements",
        {
          value: elements,
          start: 657,
          end: 694,
          pattern_start: 668,
          pattern_end: 683
        }
      )
    } else {
      dir = elements.head;
      dist = $.head;
    }
  }
  let _block;
  let _pipe = dist;
  let _pipe$1 = $int.parse(_pipe);
  _block = $rs.unwrap(_pipe$1, 0);
  let ndist = _block;
  if (dir === "forward") {
    return new Forward(ndist);
  } else if (dir === "down") {
    return new Down(ndist);
  } else if (dir === "up") {
    return new Up(ndist);
  } else {
    throw makeError(
      "panic",
      FILEPATH,
      "day2102",
      38,
      "str_to_instruction",
      "invalid direction",
      {}
    )
  }
}

function get_instructions() {
  let $ = $fs.read("src/data.txt");
  let lines;
  if ($ instanceof Ok) {
    lines = $[0];
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "day2102",
      25,
      "get_instructions",
      "Pattern match failed, no pattern matched the value.",
      { value: $, start: 459, end: 505, pattern_start: 470, pattern_end: 479 }
    )
  }
  let _pipe = $str.split(lines, "\r\n");
  return $list.map(_pipe, str_to_instruction);
}

export function main() {
  let instructions = get_instructions();
  let pos = new Position(0, 0, 0);
  let _block;
  let _pipe = process_instructions(instructions, pos);
  _block = mult_position(_pipe);
  return echo(_block, undefined, "src\\day2102.gleam", 21);
}

function echo(value, message, file, line) {
  const grey = "\u001b[90m";
  const reset_color = "\u001b[39m";
  const file_line = `${file}:${line}`;
  const inspector = new Echo$Inspector();
  const string_value = inspector.inspect(value);
  const string_message = message === undefined ? "" : " " + message;

  if (globalThis.process?.stderr?.write) {
    // If we're in Node.js, use `stderr`
    const string = `${grey}${file_line}${reset_color}${string_message}\n${string_value}\n`;
    globalThis.process.stderr.write(string);
  } else if (globalThis.Deno) {
    // If we're in Deno, use `stderr`
    const string = `${grey}${file_line}${reset_color}${string_message}\n${string_value}\n`;
    globalThis.Deno.stderr.writeSync(new TextEncoder().encode(string));
  } else {
    // Otherwise, use `console.log`
    // The browser's console.log doesn't support ansi escape codes
    const string = `${file_line}${string_message}\n${string_value}`;
    globalThis.console.log(string);
  }

  return value;
}

class Echo$Inspector {
  #references = new globalThis.Set();

  #isDict(value) {
    try {
      // We can only check if an object is a stdlib Dict if it is one of the
      // project's dependencies.
      // We import the public gleam/dict module, so to check if something is a
      // dict we compare the `constructor` field on the object with that of a
      // new dict.
      const empty_dict = $stdlib$dict.new$();
      const dict_class = empty_dict.constructor;
      return value instanceof dict_class;
    } catch {
      // If stdlib is not one of the project's dependencies then `$stdlib$dict`
      // will not have been imported and the check will throw an exception meaning
      // we can't check if something is actually a `Dict`.
      return false;
    }
  }

  #float(float) {
    const string = float.toString().replace("+", "");
    if (string.indexOf(".") >= 0) {
      return string;
    } else {
      const index = string.indexOf("e");
      if (index >= 0) {
        return string.slice(0, index) + ".0" + string.slice(index);
      } else {
        return string + ".0";
      }
    }
  }

  inspect(v) {
    const t = typeof v;
    if (v === true) return "True";
    if (v === false) return "False";
    if (v === null) return "//js(null)";
    if (v === undefined) return "Nil";
    if (t === "string") return this.#string(v);
    if (t === "bigint" || globalThis.Number.isInteger(v)) return v.toString();
    if (t === "number") return this.#float(v);
    if (v instanceof $UtfCodepoint) return this.#utfCodepoint(v);
    if (v instanceof $BitArray) return this.#bit_array(v);
    if (v instanceof globalThis.RegExp) return `//js(${v})`;
    if (v instanceof globalThis.Date) return `//js(Date("${v.toISOString()}"))`;
    if (v instanceof globalThis.Error) return `//js(${v.toString()})`;
    if (v instanceof globalThis.Function) {
      const args = [];
      for (const i of globalThis.Array(v.length).keys())
        args.push(globalThis.String.fromCharCode(i + 97));
      return `//fn(${args.join(", ")}) { ... }`;
    }

    if (this.#references.size === this.#references.add(v).size) {
      return "//js(circular reference)";
    }

    let printed;
    if (globalThis.Array.isArray(v)) {
      printed = `#(${v.map((v) => this.inspect(v)).join(", ")})`;
    } else if (v instanceof $List) {
      printed = this.#list(v);
    } else if (v instanceof $CustomType) {
      printed = this.#customType(v);
    } else if (this.#isDict(v)) {
      printed = this.#dict(v);
    } else if (v instanceof Set) {
      return `//js(Set(${[...v].map((v) => this.inspect(v)).join(", ")}))`;
    } else {
      printed = this.#object(v);
    }
    this.#references.delete(v);
    return printed;
  }

  #object(v) {
    const name =
      globalThis.Object.getPrototypeOf(v)?.constructor?.name || "Object";
    const props = [];
    for (const k of globalThis.Object.keys(v)) {
      props.push(`${this.inspect(k)}: ${this.inspect(v[k])}`);
    }
    const body = props.length ? " " + props.join(", ") + " " : "";
    const head = name === "Object" ? "" : name + " ";
    return `//js(${head}{${body}})`;
  }

  #dict(map) {
    let body = "dict.from_list([";
    let first = true;

    let key_value_pairs = $stdlib$dict.fold(map, [], (pairs, key, value) => {
      pairs.push([key, value]);
      return pairs;
    });

    key_value_pairs.sort();
    key_value_pairs.forEach(([key, value]) => {
      if (!first) body = body + ", ";
      body = body + "#(" + this.inspect(key) + ", " + this.inspect(value) + ")";
      first = false;
    });
    return body + "])";
  }

  #customType(record) {
    const props = globalThis.Object.keys(record)
      .map((label) => {
        const value = this.inspect(record[label]);
        return isNaN(parseInt(label)) ? `${label}: ${value}` : value;
      })
      .join(", ");
    return props
      ? `${record.constructor.name}(${props})`
      : record.constructor.name;
  }

  #list(list) {
    if (list instanceof $Empty) {
      return "[]";
    }

    let char_out = 'charlist.from_string("';
    let list_out = "[";

    let current = list;
    while (current instanceof $NonEmpty) {
      let element = current.head;
      current = current.tail;

      if (list_out !== "[") {
        list_out += ", ";
      }
      list_out += this.inspect(element);

      if (char_out) {
        if (
          globalThis.Number.isInteger(element) &&
          element >= 32 &&
          element <= 126
        ) {
          char_out += globalThis.String.fromCharCode(element);
        } else {
          char_out = null;
        }
      }
    }

    if (char_out) {
      return char_out + '")';
    } else {
      return list_out + "]";
    }
  }

  #string(str) {
    let new_str = '"';
    for (let i = 0; i < str.length; i++) {
      const char = str[i];
      switch (char) {
        case "\n":
          new_str += "\\n";
          break;
        case "\r":
          new_str += "\\r";
          break;
        case "\t":
          new_str += "\\t";
          break;
        case "\f":
          new_str += "\\f";
          break;
        case "\\":
          new_str += "\\\\";
          break;
        case '"':
          new_str += '\\"';
          break;
        default:
          if (char < " " || (char > "~" && char < "\u{00A0}")) {
            new_str +=
              "\\u{" +
              char.charCodeAt(0).toString(16).toUpperCase().padStart(4, "0") +
              "}";
          } else {
            new_str += char;
          }
      }
    }
    new_str += '"';
    return new_str;
  }

  #utfCodepoint(codepoint) {
    return `//utfcodepoint(${globalThis.String.fromCodePoint(codepoint.value)})`;
  }

  #bit_array(bits) {
    if (bits.bitSize === 0) {
      return "<<>>";
    }

    let acc = "<<";

    for (let i = 0; i < bits.byteSize - 1; i++) {
      acc += bits.byteAt(i).toString();
      acc += ", ";
    }

    if (bits.byteSize * 8 === bits.bitSize) {
      acc += bits.byteAt(bits.byteSize - 1).toString();
    } else {
      const trailingBitsCount = bits.bitSize % 8;
      acc += bits.byteAt(bits.byteSize - 1) >> (8 - trailingBitsCount);
      acc += `:size(${trailingBitsCount})`;
    }

    acc += ">>";
    return acc;
  }
}

