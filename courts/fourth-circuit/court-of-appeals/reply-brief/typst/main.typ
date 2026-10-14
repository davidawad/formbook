// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "ca4-reply-brief.typ": ca4-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/de-luca-reply-brief.md"))
#let (meta, body) = split-frontmatter(src)
#ca4-brief(meta, body)
