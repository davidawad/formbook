// Entrypoint. Compile with the court's doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "nywb-motion-brief.typ": nywb-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-nywb-motion-brief-continentalrochestermemo.md"))
#let (meta, body) = split-frontmatter(src)
#nywb-motion-brief(meta, body)
