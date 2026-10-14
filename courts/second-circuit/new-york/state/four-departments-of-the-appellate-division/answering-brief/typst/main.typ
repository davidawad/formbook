#import "nyappdiv-answering-brief.typ": nyappdiv-answering-brief, split-frontmatter

// Entrypoint. tools/render.sh compiles it with the court folder as --root (here the doc-type folder).
#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-nyappdiv-answering-brief-sample.md"))
#let (meta, body) = split-frontmatter(src)
#nyappdiv-answering-brief(meta, body)
