// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "ca2-answering-brief.typ": ca2-answering-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/finkelman-answering-brief.md"))
#let (meta, body) = split-frontmatter(src)
#ca2-answering-brief(meta, body)
