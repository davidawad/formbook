// Entry point. Compile with the court folder as --root; tools/render.sh does it:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/NAME.md \
//     typst/main.typ out.pdf
// <court-dir> is this doc-type folder (courts/fourth-circuit/west-virginia/federal/northern-district/complaint).
#import "wvnd-complaint.typ": wvnd-complaint, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-heston-complaint.md"))
#let (meta, body) = split-frontmatter(src)
#wvnd-complaint(meta, body)
