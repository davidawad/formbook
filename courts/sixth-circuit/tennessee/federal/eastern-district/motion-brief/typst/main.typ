// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "tned-motion-brief.typ": tned-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-tned-motion-brief-brockington.md"))
#let (meta, body) = split-frontmatter(src)
#tned-motion-brief(meta, body)
