// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/INPUT-NAME.md \
//     typst/main.typ out.pdf
#import "ncwd-complaint.typ": ncwd-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-bell-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#ncwd-complaint(meta, body)
