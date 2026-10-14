// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "ilnb-motion-brief.typ": ilnb-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-honda-707-memorandum.md"))
#let (meta, body) = split-frontmatter(src)
#ilnb-motion-brief(meta, body)
