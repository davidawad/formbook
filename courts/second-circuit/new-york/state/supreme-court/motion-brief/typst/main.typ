// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "nysupct-motion-brief.typ": nysupct-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-nysupct-motion-brief-valentino.md"))
#let (meta, body) = split-frontmatter(src)
#nysupct-motion-brief(meta, body)
