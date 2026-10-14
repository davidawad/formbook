// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir>/<doctype> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "ca10-opening-brief.typ": ca10-opening-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-lyman-v-henderson-opening-brief.md"))
#let (meta, body) = split-frontmatter(src)
#ca10-opening-brief(meta, body)
