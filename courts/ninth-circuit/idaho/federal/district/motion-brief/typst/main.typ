// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "idd-motion-brief.typ": idd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample"))
#let (meta, body) = split-frontmatter(src)
#idd-motion-brief(meta, body)
