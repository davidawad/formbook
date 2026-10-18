// Entry point for the District of Oregon motion with memorandum. Compile with the doc-type folder as --root;
// tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "ord-motion-brief.typ": ord-motion-brief, split-frontmatter

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-ord-motion-brief-zoetisrule12motiontodismiss.md"))
#let (meta, body) = split-frontmatter(src)
#ord-motion-brief(meta, body)
