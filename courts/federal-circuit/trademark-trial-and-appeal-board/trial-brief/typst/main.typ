// Entrypoint. Compile with the court-doc folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "ttab-trial-brief.typ": ttab-trial-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-treefrog-rebuttal-brief.md"))
#let (meta, body) = split-frontmatter(src)
#ttab-trial-brief(meta, body)
