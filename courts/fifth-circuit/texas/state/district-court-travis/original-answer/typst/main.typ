// Entrypoint. tools/render.sh compiles it with the repository as --root:
//   typst compile --root <repo> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=<court dir>/usage/NAME.md typst/main.typ out.pdf
#import "txdistrict-travis-original-answer.typ": txdistrict-travis-original-answer, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "courts/fifth-circuit/texas/state/district-court-travis/original-answer/usage/INPUT-original-answer.md"))
#let (meta, body) = split-frontmatter(src)
#txdistrict-travis-original-answer(meta, body)
