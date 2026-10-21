// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "mo-reply-brief.typ": mo-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-reply-brief.md"))
#let (meta, body) = split-frontmatter(src)
#mo-brief(meta, body)
