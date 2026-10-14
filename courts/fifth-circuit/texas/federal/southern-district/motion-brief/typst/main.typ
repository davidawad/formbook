// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/INPUT-NAME.md \
//     typst/main.typ out.pdf
#import "txsd-motion-brief.typ": txsd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-dangelas-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#txsd-motion-brief(meta, body)
