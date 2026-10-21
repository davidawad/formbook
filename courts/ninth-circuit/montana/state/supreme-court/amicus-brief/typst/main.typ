// Entry point. tools/render.sh compiles it with --root <court-dir> and --input sample=usage/NAME.md:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "mont-amicus-brief.typ": mont-brief-amicus, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-amicus-brief.md"))
#let (meta, body) = split-frontmatter(src)
#mont-brief-amicus(meta, body)
