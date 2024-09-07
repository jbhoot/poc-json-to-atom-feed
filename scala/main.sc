//> using dep com.lihaoyi::os-lib:0.10.5
//> using dep com.lihaoyi::upickle:4.0.1
//> using dep com.lihaoyi::scalatags:0.13.1

import scalatags.Text.TypedTag
import ujson.Value
import scalatags.Text.all._

var baseUrl = "https://bhoot.dev"

val exclude = List(
  "/about"
)

case class Entry(
    id: String,
    title: String,
    link: String,
    published: String,
    summary: String,
    authorName: String
)

val json = ujson.read(os.read(os.pwd / os.up / "input.json"))

val parseFromJson = (e: Value) => {
  Entry(
    id = e("id").str,
    title = e("title").str,
    link = baseUrl ++ e("url").str,
    published = e("timestamp").str,
    summary = e("excerpt").str,
    authorName = e("author_name").str
  )
}

val toXmlEntry = (e: Entry) => {
  tag("entry")(
    tag("id")(e.id),
    tag("title")(e.title),
    tag("link")(href := e.link),
    tag("published")(e.published),
    tag("summary")(e.summary),
    tag("author")(tag("name")(e.authorName))
  )
}

val makeFeed = (entries: List[TypedTag[String]]) => {
  val body = tag("feed")(
    xmlns := "http://www.w3.org/2005/Atom",
    tag("title")("All articles"),
    tag("link")(href := "https://bhoot.dev/articles"),
    xmlEntries
  )
  """<?xml version="1.0" encoding="utf-8"?>""" ++ body.render
}

val xmlEntries = json.arr.toList
  .filter(e => !exclude.contains(e("url").str))
  .map(parseFromJson)
  .map(toXmlEntry)

os.write.over(os.pwd / "atom.xml", makeFeed(xmlEntries))
