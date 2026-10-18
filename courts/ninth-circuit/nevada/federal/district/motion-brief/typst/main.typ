// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "nvd-motion-brief.typ": nvd-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-nvd-motion-brief-lynchmotiontodismiss.md"))
#let (meta, body) = split-frontmatter(src)
#nvd-motion-brief(meta, body)
