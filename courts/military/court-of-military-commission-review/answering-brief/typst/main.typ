// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/INPUT-NAME.md \
//     typst/main.typ out.pdf
#import "mc-answering-brief.typ": mc-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-hicks-answering-brief.md"))
#let (meta, body) = split-frontmatter(src)
#mc-brief(meta, body)
