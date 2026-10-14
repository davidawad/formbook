// Entrypoint. tools/render.sh compiles this with --root <doctype-dir> and --input sample=<md>:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "ganb-adversary-complaint.typ": ganb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-fletcher-25-05046.md"))
#let (meta, body) = split-frontmatter(src)
#ganb-adversary-complaint(meta, body)
