// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "nvb-adversary-complaint.typ": nvb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-nvb-adversary-complaint-lovatovsassoncomplaint.md"))
#let (meta, body) = split-frontmatter(src)
#nvb-adversary-complaint(meta, body)
