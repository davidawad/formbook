// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "cal-opening-brief-on-the-merits.typ": cal-opening-brief-on-the-merits, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-opening-brief-on-the-merits.md"))
#let (meta, body) = split-frontmatter(src)
#cal-opening-brief-on-the-merits(meta, body)
