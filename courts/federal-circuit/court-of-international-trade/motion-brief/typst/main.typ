// Entry point. tools/render.sh compiles this file with this doc-type folder as --root:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "cit-motion-brief.typ": cit-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-bgh-edelstahl.md"))
#let (meta, body) = split-frontmatter(src)
#cit-motion-brief(meta, body)
