// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "wawd-motion-brief.typ": wawd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-wawd-motion-brief-hoffmanmotiontodismiss.md"))
#let (meta, body) = split-frontmatter(src)
#wawd-motion-brief(meta, body)
