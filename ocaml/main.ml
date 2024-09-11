#use "topfind"

#require "yojson"

#require "pure-html"

type t = {
  url : string;
  author_name : string;
  summary : string;
  published : string;
  id : string;
  title : string;
}

let read_file file_name =
  In_channel.with_open_bin file_name In_channel.input_all

let write_to_file file_name s =
  Out_channel.with_open_bin file_name (fun oc -> Out_channel.output_string oc s)

let entries_to_exclude = [ "/about" ]

let keep_relevant_entries (entries : Yojson.Basic.t list) =
  let open Yojson.Basic.Util in
  let is_entry_relevant e =
    let entry_url = to_string (member "url" e) in
    not
      (List.exists
         (fun to_exclude -> to_exclude = entry_url)
         entries_to_exclude)
  in
  List.filter (fun e -> is_entry_relevant e) entries

let parse_json_entry (e : Yojson.Basic.t) =
  let open Yojson.Basic.Util in
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
  let entry_t = std_tag "entry"
  and title_t = std_tag "title"
  and id_t = std_tag "id"
  and link_t = std_tag "link"
  and href_attr = string_attr "href"
  and summary_t = std_tag "summary"
  and published_t = std_tag "published"
  and author_t = std_tag "author"
  and author_name_t = std_tag "name" in
  entry_t []
    [
      id_t [] [ txt "%s" entry.id ];
      title_t [] [ txt "%s" entry.title ];
      link_t [ href_attr "%s" entry.url ] [];
      published_t [] [ txt "%s" entry.published ];
      summary_t [] [ txt "%s" entry.summary ];
      author_t [] [ author_name_t [] [ txt "%s" entry.author_name ] ];
    ]

let make_feed xml_entries =
  let open Pure_html in
  let feed_t = std_tag "feed"
  and xmlns_attr = string_attr "xmlns"
  and title_t = std_tag "title"
  and link_t = std_tag "link"
  and href_attr = string_attr "href" in
  feed_t
    [ xmlns_attr "%s" "http://www.w3.org/2005/Atom" ]
    (List.append
       [
         title_t [] [ txt "%s" "All articles" ];
         link_t [ href_attr "%s" "https://bhoot.dev/articles" ] [];
       ]
       xml_entries)

let () =
  let input_file_path = Filename.concat Filename.current_dir_name "input.json" in
  let json_str = read_file input_file_path in
  let feed =
    json_str |> Yojson.Basic.from_string |> Yojson.Basic.Util.to_list
    |> keep_relevant_entries |> List.map parse_json_entry
    |> List.map to_entry_xml |> make_feed
  in
  let output_file_path = Filename.concat Filename.current_dir_name "atom-ocaml.xml" in
  let feed_string = Pure_html.to_xml feed in
  write_to_file output_file_path feed_string;
  print_endline "Done"
