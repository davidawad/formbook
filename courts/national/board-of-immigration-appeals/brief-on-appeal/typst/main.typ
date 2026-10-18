// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "bia-brief-on-appeal.typ": bia-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-brief-on-appeal.md"))
#let (meta, body) = split-frontmatter(src)
#bia-brief(meta, body)
