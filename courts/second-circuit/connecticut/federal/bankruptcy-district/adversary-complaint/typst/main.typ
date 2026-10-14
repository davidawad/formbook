// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=samples/INPUT-NAME.md \
//     typst/main.typ out.pdf
// Page and text settings live here (set rules inside a function do not reach the page).
#import "ctb-adversary-complaint.typ": ctb-adversary-complaint, split-frontmatter, font-family, type-size, body-leading, margin

#let src = read("/" + sys.inputs.at("sample", default: "samples/INPUT-1stdibs-complaint.md"))
#let (meta, body) = split-frontmatter(src)

#set page(
  width: 8.5in,
  height: 11in,
  margin: (top: 1in, bottom: 1in, left: margin, right: margin),
  // L. Civ. R. 10 (via Local Bankr. R. 5005-1): the docket number with the judge's initials on every
  // pleading, and page numbers in the bottom margin after page 1.
  header: context {
    if counter(page).get().first() > 1 {
      align(right, text(size: 10pt, "Adv. Pro. No. " + meta.adv_number + " (" + meta.judge + ")"))
    }
  },
  footer: context {
    if counter(page).get().first() > 1 {
      align(center, text(size: type-size, counter(page).display()))
    }
  },
)
#set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
#set par(justify: false, leading: body-leading, spacing: body-leading)

#ctb-adversary-complaint(meta, body)
