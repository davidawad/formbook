// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "pawb-adversary-complaint.typ": pawb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-snyder-adversary-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#pawb-adversary-complaint(meta, body)
