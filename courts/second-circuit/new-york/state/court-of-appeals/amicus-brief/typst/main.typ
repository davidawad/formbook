// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ny-amicus-brief.typ": ny-amicus-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-amicus-brief.md"))
#let (meta, body) = split-frontmatter(src)
#ny-amicus-brief(meta, body)
