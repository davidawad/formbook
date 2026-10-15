// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "calsuperct-sandiego-motion-brief.typ": calsuperct-sandiego-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-synthetic-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#calsuperct-sandiego-motion-brief(meta, body)
