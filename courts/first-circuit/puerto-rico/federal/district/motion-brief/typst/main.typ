// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "prd-motion-brief.typ": prd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-prd-motion-brief-franklinmemorandum.md"))
#let (meta, body) = split-frontmatter(src)
#prd-motion-brief(meta, body)
