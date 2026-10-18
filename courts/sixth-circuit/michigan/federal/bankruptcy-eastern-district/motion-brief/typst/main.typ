// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "mieb-motion-brief.typ": motion-body, motion-doc, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-mieb-motion-brief-heitmann.md"))
#let (meta, body) = split-frontmatter(src)

#show: motion-doc.with(meta)
#motion-body(meta, body)
