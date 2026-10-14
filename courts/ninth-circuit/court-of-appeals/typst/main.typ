// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "ca9-brief.typ": ca9-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-sweet-opening-brief.md"))
#let (meta, body) = split-frontmatter(src)
#ca9-brief(meta, body)
