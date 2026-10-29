// Entry point. Compile with the repo root as --root; tools/render.sh does it:
//   typst compile --root <repo> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "tnmd-motion-brief.typ": tnmd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#tnmd-motion-brief(meta, body)
