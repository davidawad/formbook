// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ca11-reply-brief.typ": ca11-reply-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-ca11-reply-brief-jgvnorthfield.md"))
#let (meta, body) = split-frontmatter(src)
#ca11-reply-brief(meta, body)
