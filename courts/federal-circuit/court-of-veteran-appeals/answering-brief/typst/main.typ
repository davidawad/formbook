// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "cavc-answering-brief.typ": cavc-answering-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-fulton-answering-brief.md"))
#let (meta, body) = split-frontmatter(src)
#cavc-answering-brief(meta, body)
