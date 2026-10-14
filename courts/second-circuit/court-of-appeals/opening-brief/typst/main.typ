// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "ca2-opening-brief.typ": ca2-opening-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/munafo-opening-brief.md"))
#let (meta, body) = split-frontmatter(src)
#ca2-opening-brief(meta, body)
