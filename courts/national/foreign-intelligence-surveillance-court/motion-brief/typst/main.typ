// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "fisc-motion-brief.typ": fisc-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-fisc-motion-brief-accuracyconcernsmisc1902.md"))
#let (meta, body) = split-frontmatter(src)
#fisc-motion-brief(meta, body)
