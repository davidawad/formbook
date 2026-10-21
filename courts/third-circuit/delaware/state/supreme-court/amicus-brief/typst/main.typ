// Entry point. tools/render.sh compiles it with --root <doc-dir> and --input sample=usage/NAME.md.
#import "del-amicus-brief.typ": del-amicus-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-amicus-brief.md"))
#let (meta, body) = split-frontmatter(src)
#del-amicus-brief(meta, body)
