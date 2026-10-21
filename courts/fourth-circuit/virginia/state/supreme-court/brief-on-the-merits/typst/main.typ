// Entry point. tools/render.sh compiles it with --root <doc-dir> and --input sample=usage/NAME.md.
#import "va-brief-on-the-merits.typ": va-brief-on-the-merits, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-brief-on-the-merits.md"))
#let (meta, body) = split-frontmatter(src)
#va-brief-on-the-merits(meta, body)
