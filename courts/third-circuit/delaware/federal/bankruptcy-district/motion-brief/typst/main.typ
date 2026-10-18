// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "deb-motion-brief.typ": deb-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-deb-motion-brief-bumblebee.md"))
#let (meta, body) = split-frontmatter(src)
#deb-motion-brief(meta, body)
