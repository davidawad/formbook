// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "ca8-reply-brief.typ": ca8-reply-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-delgado-midland.md"))
#let (meta, body) = split-frontmatter(src)
#ca8-reply-brief(meta, body)
