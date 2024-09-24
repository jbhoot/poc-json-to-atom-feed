package main

import (
	"encoding/json"
	"encoding/xml"
	"fmt"
	"os"
	"path/filepath"
	"slices"
)

func cantErr(e error) {
	if e != nil {
		panic(e)
	}
}

var Exclude = []string{"/about"}

type JsonEntry struct {
	Id         string `json:"id"`
	Title      string `json:"title"`
	Link       string `json:"url"`
	Published  string `json:"timestamp"`
	Summary    string `json:"excerpt"`
	AuthorName string `json:"author_name"`
}

type Link struct {
	XMLName xml.Name `xml:"link"`
	Href    string   `xml:"href,attr"`
}

type XmlEntry struct {
	XMLName    xml.Name `xml:"entry"`
	Id         string   `xml:"id"`
	Title      string   `xml:"title"`
	Link       Link     `xml:"link"`
	Published  string   `xml:"published"`
	Summary    string   `xml:"summary"`
	AuthorName string   `xml:"author>name"`
}

type Feed struct {
	XMLName xml.Name   `xml:"feed"`
	XmlNs   string     `xml:"xmlns,attr"`
	Title   string     `xml:"title"`
	Link    Link       `xml:"link"`
	Entry   []XmlEntry `xml:"entry"`
}

func (e JsonEntry) toXmlEntry() XmlEntry {
	return XmlEntry{
		Id:         e.Id,
		Title:      e.Title,
		Link:       Link{Href: e.Link},
		Published:  e.Published,
		Summary:    e.Summary,
		AuthorName: e.AuthorName,
	}
}

func main() {
	dir, err := os.Getwd()
	cantErr(err)
	var inputFile = filepath.Join(dir, "input.json")

	b, err := os.ReadFile(inputFile)
	cantErr(err)

	var jsonEntries []JsonEntry
	err = json.Unmarshal(b, &jsonEntries)
	cantErr(err)

	var xmlEntries []XmlEntry
	for _, e := range jsonEntries {
		if !slices.Contains(Exclude, e.Link) {
			xmlEntries = append(xmlEntries, e.toXmlEntry())
		}
	}

	var feed = Feed{
		XmlNs: "http://www.w3.org/2005/Atom",
		Title: "All articles",
		Link:  Link{Href: "https://bhoot.dev/articles"},
		Entry: xmlEntries,
	}
	xmlB, err := xml.MarshalIndent(feed, "", "  ")
	cantErr(err)
	xmlDoc := slices.Concat([]byte(xml.Header), xmlB)
	os.WriteFile("atom-go.xml", xmlDoc, 0666)

	fmt.Println("Done")
}
