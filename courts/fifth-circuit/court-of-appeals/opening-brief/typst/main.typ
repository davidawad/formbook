// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
// <court-dir> here is courts/fifth-circuit/court-of-appeals/opening-brief.
#import "ca5-opening-brief.typ": ca5-opening-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-candel-opening-brief.md"))
#let (meta, body) = split-frontmatter(src)
#ca5-opening-brief(meta, body)
