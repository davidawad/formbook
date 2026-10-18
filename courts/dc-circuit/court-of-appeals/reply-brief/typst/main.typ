// Entrypoint. Compile with the court's reply-brief folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "cadc-reply-brief.typ": cadc-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-cadc-reply-brief-rosenkellogg.md"))
#let (meta, body) = split-frontmatter(src)
#cadc-brief(meta, body)
