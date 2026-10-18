// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "okeb-adversary-complaint.typ": okeb-adversary-complaint, split-frontmatter, inl

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-okeb-adversary-complaint-apachecomplaint.md"))
#let (meta, body) = split-frontmatter(src)
#okeb-adversary-complaint(meta, inl(body))
