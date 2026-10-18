// Entry point. tools/render.sh compiles it with --root <court-dir> and --input sample=usage/NAME.md:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ga-answering-brief.typ": ga-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-ga-answering-brief-clark.md"))
#let (meta, body) = split-frontmatter(src)
#ga-brief(meta, body)
