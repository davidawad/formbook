// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "gactapp-petition-for-rehearing.typ": gactapp-petition-for-rehearing, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-rehearing-sample.md"))
#let (meta, body) = split-frontmatter(src)
#gactapp-petition-for-rehearing(meta, body)
