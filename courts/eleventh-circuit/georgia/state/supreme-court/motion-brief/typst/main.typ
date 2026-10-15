// Entrypoint. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
#import "ga-motion-brief.typ": ga-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-dpg-opposition-to-emergency-petition.md"))
#let (meta, body) = split-frontmatter(src)
#ga-motion-brief(meta, body)
