// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "wyd-complaint.typ": wyd-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-wyd-complaint-onq.md"))
#let (meta, body) = split-frontmatter(src)
#wyd-complaint(meta, body)
