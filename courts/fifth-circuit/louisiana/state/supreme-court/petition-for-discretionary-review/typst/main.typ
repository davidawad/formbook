// Entry point. tools/render.sh compiles it with --root <court-dir> and --input sample=usage/NAME.md:
//   typst compile --root <court-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/NAME.md \
//     typst/main.typ out.pdf
#import "la-petition-for-discretionary-review.typ": la-petition-for-discretionary-review, split-frontmatter

// Link show rule at document top level: a show rule set inside a function does not reach footnote bodies,
// so toa: hits in footnotes would be missing from the index of authorities.
#show link: l => {
  if type(l.dest) == str and l.dest.starts-with("toa:") {
    [#l.body#metadata((key: l.dest.slice(4)))<toa-hit>]
  } else if type(l.dest) == str {
    l.body
  } else {
    l
  }
}

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-petition-for-discretionary-review.md"))
#let (meta, body) = split-frontmatter(src)
#la-petition-for-discretionary-review(meta, body)
