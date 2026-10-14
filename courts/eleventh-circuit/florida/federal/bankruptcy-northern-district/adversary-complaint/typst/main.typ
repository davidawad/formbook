// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "flnb-adversary-complaint.typ": complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-ochlockonee.md"))
#let (meta, body) = split-frontmatter(src)
#complaint(meta, body)
