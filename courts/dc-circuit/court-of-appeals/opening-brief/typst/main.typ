// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "cadc-opening-brief.typ": dc-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-centro-opening-brief.md"))
#let (meta, body) = split-frontmatter(src)
#dc-brief(meta, body)
