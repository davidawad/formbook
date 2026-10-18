// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ncwb-adversary-complaint.typ": doc, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-ncwb-adversary-complaint-gccchase1603271.md"))
#let (meta, body) = split-frontmatter(src)
#doc(meta, body)
