// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "ca3-reply-brief.typ": ca3-reply-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/afp-reply-brief.md"))
#let (meta, body) = split-frontmatter(src)
#ca3-reply-brief(meta, body)
