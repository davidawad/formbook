// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "gub-motion-brief.typ": gub-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-gub-motion-brief-camposmotiontodismiss.md"))
#let (meta, body) = split-frontmatter(src)
#gub-motion-brief(meta, body)
