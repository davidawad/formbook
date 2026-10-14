// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "mieb-adversary-complaint.typ": complaint-body, complaint-doc, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-griffin-adversary-complaint.md"))
#let (meta, md) = split-frontmatter(src)

#show: complaint-doc.with(meta)
#complaint-body(meta, md)
