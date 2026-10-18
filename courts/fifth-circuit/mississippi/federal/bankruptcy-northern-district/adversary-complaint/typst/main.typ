// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "msnb-adversary-complaint.typ": msnb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-msnb-adversary-complaint-communitybankloancare.md"))
#let (meta, body) = split-frontmatter(src)
#msnb-adversary-complaint(meta, body)
