// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "tax-pretrial-memorandum.typ": tax-pretrial-memorandum, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-tax-pretrial-memorandum-generic.md"))
#let (meta, body) = split-frontmatter(src)
#tax-pretrial-memorandum(meta, body)
