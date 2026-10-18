// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "mdb-motion-brief.typ": mdb-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-mdb-motion-brief-engelhornmemorandum.md"))
#let (meta, body) = split-frontmatter(src)
#mdb-motion-brief(meta, body)
