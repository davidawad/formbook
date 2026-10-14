// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "tnwb-motion-brief.typ": memorandum, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-kenney-motion-memorandum.md"))
#let (meta, body) = split-frontmatter(src)
#memorandum(meta, body)
