// Entrypoint. tools/render.sh compiles it with the document-type folder as --root:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/INPUT-NAME.md typst/main.typ out.pdf
#import "vib-motion-brief.typ": motion, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-prosser-motion-to-dismiss.md"))
#let (meta, body) = split-frontmatter(src)
#motion(meta, body)
