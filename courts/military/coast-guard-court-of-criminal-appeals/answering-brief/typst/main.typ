// Entrypoint. tools/render.sh compiles it with the doc-type folder as --root:
//   sh tools/render.sh courts/military/coast-guard-court-of-criminal-appeals/answering-brief samples/<id>.md
#import "uscgcoca-answering-brief.typ": uscgcoca-brief

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-smoke.md"))
#let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
#if m == none { panic("uscgcoca: the sample must start with a YAML frontmatter block") }
#uscgcoca-brief(yaml(bytes(m.captures.at(0))), src.slice(m.end))
