// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/INPUT-ID.md \
//     typst/main.typ out.pdf
#import "meb-motion-brief.typ": meb-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-meb-motion-brief-mattson.md"))
#let (meta, body) = split-frontmatter(src)
#meb-motion-brief(meta, body)
