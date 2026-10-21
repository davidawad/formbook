// Entry point. tools/render.sh compiles it with --root <court-dir> and --input sample=usage/NAME.md:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ga-brief-on-the-merits.typ": ga-brief-on-the-merits, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-brief-on-the-merits.md"))
#let (meta, body) = split-frontmatter(src)
#ga-brief-on-the-merits(meta, body)
