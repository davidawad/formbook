// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/INPUT-NAME.md \
//     typst/main.typ out.pdf
#import "wied-complaint.typ": wied-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-taylor-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#wied-complaint(meta, body)
