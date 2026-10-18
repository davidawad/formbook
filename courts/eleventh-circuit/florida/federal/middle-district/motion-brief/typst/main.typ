// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "flmd-motion-brief.typ": flmd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-flmd-motion-brief-phillipmotiontodismiss.md"))
#let (meta, body) = split-frontmatter(src)
#flmd-motion-brief(meta, body)
