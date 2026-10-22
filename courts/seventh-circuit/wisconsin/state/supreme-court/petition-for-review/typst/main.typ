// Entrypoint. Compile with the doc-type folder as --root; `fb render` does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --input sample=usage/NAME.md typst/main.typ out.pdf
#import "wis-petition-for-review.typ": wis-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-review.md"))
#let (meta, body) = split-frontmatter(src)
#wis-brief(meta, body)
