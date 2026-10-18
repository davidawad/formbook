// Entrypoint. Compile with the court's opening-brief folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ca7-opening-brief.typ": ca7-opening-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-ca7-opening-brief-torres.md"))
#let (meta, body) = split-frontmatter(src)
#ca7-opening-brief(meta, body)
