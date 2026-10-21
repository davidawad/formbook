// Entry point. tools/render.sh compiles it with --root <doc-dir> and --input sample=usage/NAME.md.
#import "va-reply-brief.typ": va-reply-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-reply-brief.md"))
#let (meta, body) = split-frontmatter(src)
#va-reply-brief(meta, body)
