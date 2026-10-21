// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ny-reply-brief.typ": ny-reply-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-reply-brief.md"))
#let (meta, body) = split-frontmatter(src)
#ny-reply-brief(meta, body)
