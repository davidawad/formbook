// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "nyappdiv-answering-brief.typ": nyappdiv-answering-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-nycla-2022-03908-answering.md"))
#let (meta, body) = split-frontmatter(src)
#nyappdiv-answering-brief(meta, body)
