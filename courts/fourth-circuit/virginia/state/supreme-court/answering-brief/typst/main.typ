// Entry point. tools/render.sh compiles it with --root <doc-dir> and --input sample=usage/NAME.md.
#import "va-answering-brief.typ": va-answering-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-answering-brief.md"))
#let (meta, body) = split-frontmatter(src)
#va-answering-brief(meta, body)
