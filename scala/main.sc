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

val json = ujson.read(os.read(os.pwd / os.up / "input.json"))

val jsonEntryToXmlEntry = (e: Value) => {
  val id = e("id").str
  val title = e("title").str
  val link = baseUrl ++ e("url").str
  val published = e("timestamp").str
  val summary = e("excerpt").str
  val authorName = e("author_name").str
  tag("entry")(
    tag("id")(id),
    tag("title")(title),
    tag("link")(href := link),
    tag("published")(published),
    tag("summary")(summary),
    tag("author")(tag("name")(authorName))
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
  .map(jsonEntryToXmlEntry)

println(makeFeed(xmlEntries))
