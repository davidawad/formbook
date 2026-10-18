// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/INPUT-NAME.md \
//     typst/main.typ out.pdf
// Page and base text are set here, at top level, so they apply to the whole document.
#import "ndb-adversary-complaint.typ": ndb-adversary-complaint, split-frontmatter, font-family, type-size, body-leading

#set page(paper: "us-letter", margin: 1in, numbering: "1")
#set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
#set par(leading: body-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-adversary-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#ndb-adversary-complaint(meta, body)
