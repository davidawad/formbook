// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/INPUT-NAME.md \
//     typst/main.typ out.pdf
#import "nyeb-motion-brief.typ": nyeb-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-bmt-memorandum-motion-to-dismiss.md"))
#let (meta, body) = split-frontmatter(src)
#nyeb-motion-brief(meta, body)
