// Entrypoint. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "waeb-motion-brief.typ": memorandum, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-1min-motion-to-dismiss-memorandum.md"))
#let (meta, body) = split-frontmatter(src)
#memorandum(meta, body)
