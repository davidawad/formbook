// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "ny-answering-brief.typ": ny-answering-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/ny-answering-brief-sample.md"))
#let (meta, body) = split-frontmatter(src)
#ny-answering-brief(meta, body)
