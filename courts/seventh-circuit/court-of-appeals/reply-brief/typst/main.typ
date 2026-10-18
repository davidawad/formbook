// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ca7-reply-brief.typ": ca7-reply-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-ca7-reply-brief-actnow.md"))
#let (meta, body) = split-frontmatter(src)
#ca7-reply-brief(meta, body)
