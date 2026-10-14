// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "ca1-opening-brief.typ": ca1-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/figueroa-opening-brief.md"))
#let (meta, body) = split-frontmatter(src)
#ca1-brief(meta, body)
