// Entrypoint. Compile with the court's opening-brief folder as --root; tools/render.sh does it:
//   typst compile --root <doctype-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "ca4-opening-brief.typ": ca4-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-netchoice-opening-brief.md"))
#let (meta, body) = split-frontmatter(src)
#ca4-brief(meta, body)
