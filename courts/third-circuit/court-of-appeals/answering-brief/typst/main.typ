// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ca3-answering-brief.typ": ca3-answering-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-ca3-answering-brief-binder.md"))
#let (meta, body) = split-frontmatter(src)
#ca3-answering-brief(meta, body)
