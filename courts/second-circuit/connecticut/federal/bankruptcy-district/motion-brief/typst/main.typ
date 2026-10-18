// Entry point. Compile with the doc-type folder as --root; tools/render.sh does it:
//   typst compile --root <doc-type-dir> --font-path <repo>/fonts --ignore-system-fonts \
//     --package-cache-path <repo>/vendor/typst-packages --input sample=usage/INPUT-NAME.md \
//     typst/main.typ out.pdf
// Page sequence: cover (no number), table of contents and table of authorities (roman), body (arabic from 1).
// Page and text settings live here (set rules inside a function do not reach the page).
#import "ctb-motion-brief.typ": cover, toc, toa, body-text, signature, split-frontmatter, font-family, type-size, body-leading, margin

#let src = read("/" + sys.inputs.at("sample", default: "usage/INPUT-ctb-motion-brief-pillsburymemorandum.md"))
#let (meta, body) = split-frontmatter(src)

// Each heading is shown as its body, with block spacing: a heading never ends a page (sticky).
#show heading: it => block(width: 100%, above: body-leading, below: body-leading, sticky: true, {
  if it.level == 1 { align(center, text(weight: "bold", it.body)) } else { text(weight: "bold", it.body) }
})

#let docket-header = context {
  align(right, text(size: 10pt, "Adv. Pro. No. " + meta.adv_number + " (" + meta.judge + ")"))
}
#let page-number = context {
  align(center, text(size: type-size, counter(page).display()))
}

#set page(
  width: 8.5in,
  height: 11in,
  margin: (top: 1in, bottom: 1in, left: margin, right: margin),
  numbering: none,
  header: none,
  footer: none,
)
#set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
#set par(justify: false, leading: body-leading, spacing: body-leading)

// Cover: no number, no header or footer.
#cover(meta)
#pagebreak()

// Front matter: roman numerals.
#set page(numbering: "i", header: docket-header, footer: page-number)
#counter(page).update(1)
#toc()
#pagebreak()
#toa(meta)
#pagebreak()

// Body: arabic numerals from 1.
#set page(numbering: "1", header: docket-header, footer: page-number)
#counter(page).update(1)
#body-text(body)
#signature(meta)
