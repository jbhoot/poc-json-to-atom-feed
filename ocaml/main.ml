#use "topfind"

#require "yojson"

#require "pure-html"

open Yojson.Basic
open Yojson.Basic.Util

type t = {
  url : string;
  author_name : string;
  summary : string;
  published : string;
  id : string;
  title : string;
}

let exclude = [ "/about" ]

let contains entry =
  List.exists (fun u -> u = to_string (member "url" entry)) exclude

let filter_out_entries (entries : Yojson.Basic.t list) =
  List.filter (fun e -> not (contains e)) entries

let read_file file_name =
  In_channel.with_open_bin file_name In_channel.input_all

let parse_json_entry (e : Yojson.Basic.t) =
  {
    url = e |> member "url" |> to_string;
    author_name = e |> member "author_name" |> to_string;
    summary = e |> member "excerpt" |> to_string;
    published = e |> member "timestamp" |> to_string;
    id = e |> member "id" |> to_string;
    title = e |> member "title" |> to_string;
  }

let to_entry_xml entry =
  let open Pure_html in
  let entry_t = std_tag "entry" and title_t = std_tag "title" in
  entry_t [] [ title_t [] [ txt "%s" entry.title ] ]

let () =
  let file_path = Filename.concat Filename.parent_dir_name "input.json" in
  let json_str = read_file file_path in
  let hd =
    json_str |> from_string |> to_list |> filter_out_entries
    |> List.map (fun entry -> entry |> parse_json_entry)
    |> List.map to_entry_xml |> List.map Pure_html.to_xml |> List.hd
  in
  print_endline hd
