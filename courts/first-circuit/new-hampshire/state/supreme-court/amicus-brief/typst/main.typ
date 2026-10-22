// Entry point. tools/render.sh compiles it with --root <doc-dir> and --input sample=usage/NAME.md:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "nh-amicus-brief.typ": nh-amicus-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-amicus-brief.md"))
#let (meta, body) = split-frontmatter(src)
#nh-amicus-brief(meta, body)
