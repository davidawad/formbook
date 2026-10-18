// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "cacb-motion-brief.typ": cacb-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-cacb-motion-brief-jamescapitaladvisors.md"))
#let (meta, body) = split-frontmatter(src)
#cacb-motion-brief(meta, body)
