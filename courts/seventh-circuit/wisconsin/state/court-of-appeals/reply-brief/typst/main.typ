// Entrypoint. Compile with the doc-type folder as --root; `fb render` does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --input sample=usage/NAME.md typst/main.typ out.pdf
#import "wisctapp-reply-brief.typ": wisctapp-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-reply-brief.md"))
#let (meta, body) = split-frontmatter(src)
#wisctapp-brief(meta, body)
