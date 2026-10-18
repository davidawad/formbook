// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ca11-opening-brief.typ": ca11-opening-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-opening-brief.md"))
#let (meta, body) = split-frontmatter(src)
#ca11-opening-brief(meta, body)
