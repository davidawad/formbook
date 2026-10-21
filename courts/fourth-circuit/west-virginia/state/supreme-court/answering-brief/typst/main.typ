// Entry point. tools/render.sh compiles it with --root <doc-dir> and --input sample=usage/NAME.md.
#import "wva-answering-brief.typ": wva-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-answering-brief.md"))
#let (meta, body) = split-frontmatter(src)
#wva-brief(meta, body)
