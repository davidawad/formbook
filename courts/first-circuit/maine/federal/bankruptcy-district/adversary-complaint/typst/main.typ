// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/INPUT-ID.md \
//     typst/main.typ out.pdf
#import "meb-adversary-complaint.typ": meb-adversary-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-sample.md"))
#let (meta, body) = split-frontmatter(src)
#meb-adversary-complaint(meta, body)
