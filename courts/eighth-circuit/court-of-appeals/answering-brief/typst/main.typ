// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ca8-answering-brief.typ": ca8-answering-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-ca8-answering-brief-bankscostarresponse.md"))
#let (meta, body) = split-frontmatter(src)
#ca8-answering-brief(meta, body)
