// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "ny-opening-brief.typ": ny-opening-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/tei-opening-brief.md"))
#let (meta, body) = split-frontmatter(src)
#ny-opening-brief(meta, body)
