// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "cod-motion-brief.typ": cod-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-cod-motion-brief-sussmanmotiontodismiss.md"))
#let (meta, body) = split-frontmatter(src)
#cod-motion-brief(meta, body)
