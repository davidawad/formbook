// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "wiwd-motion-brief.typ": wiwd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-wiwd-motion-brief-dronemotiontodismiss.md"))
#let (meta, body) = split-frontmatter(src)
#wiwd-motion-brief(meta, body)
