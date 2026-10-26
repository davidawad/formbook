// Entrypoint. tools/render.sh compiles it with the repository as --root:
//   typst compile --root <repo> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=<court dir>/usage/NAME.md typst/main.typ out.pdf
#import "txdistrict-travis-rule-11-agreement.typ": txdistrict-travis-rule-11-agreement, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "courts/fifth-circuit/texas/state/district-court-travis/rule-11-agreement/usage/INPUT-rule-11-agreement.md"))
#let (meta, body) = split-frontmatter(src)
#txdistrict-travis-rule-11-agreement(meta, body)
