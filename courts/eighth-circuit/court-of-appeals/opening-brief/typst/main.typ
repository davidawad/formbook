// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "ca8-opening-brief.typ": ca8-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-wolters-opening-brief.md"))
#let (meta, body) = split-frontmatter(src)
#ca8-brief(meta, body)
