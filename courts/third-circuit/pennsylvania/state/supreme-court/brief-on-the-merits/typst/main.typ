// Entry point. tools/render.sh compiles it with --root <doc-dir> and --input sample=usage/NAME.md.
#import "pa-brief-on-the-merits.typ": pa-brief-on-the-merits, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-brief-on-the-merits.md"))
#let (meta, body) = split-frontmatter(src)
#pa-brief-on-the-merits(meta, body)
