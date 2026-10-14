// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "flsd-motion-brief.typ": flsd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-slack-motion-brief.md"))
#let (meta, body) = split-frontmatter(src)
#flsd-motion-brief(meta, body)
