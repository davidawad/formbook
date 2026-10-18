// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir>/<doctype> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ca10-opening-brief.typ": ca10-opening-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-ca10-opening-brief-lymanvhenderson.md"))
#let (meta, body) = split-frontmatter(src)
#ca10-opening-brief(meta, body)
