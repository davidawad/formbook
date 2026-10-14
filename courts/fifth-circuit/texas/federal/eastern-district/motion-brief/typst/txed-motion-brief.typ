// Motion to dismiss with memorandum for the U.S. District Court for the Eastern District of Texas (txed).
// Rules: Local Rule CV-10(a) (style and number, caption with party designation and statement of the
// document's character, signature, double spacing, 12-point minimum, 8 1/2 x 11 paper); CV-7(a) (separate
// document; statement of the issues for a case dispositive motion; 30-page limit, excluding attachments,
// CV-7(a)(1)); CV-5(c) (certificate of service showing date and method); CV-7(i) (certificate of conference
// is not required for a motion to dismiss). Fed. R. Civ. P. 12(b)(6). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"   // vendored in fonts/; the only font the build can see (render.sh)
#let type-size = 13pt              // CV-10(a)(5): no smaller than 12-point; 13 pt because EB Garamond's x-height is small
#let page-w = 8.5in                // CV-10(a)(4): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in
#let text-width = page-w - 2 * margin
#let body-leading = 1.47em         // CV-10(a)(5): double spaced; EB Garamond's line box is 0.65em, so this is a 27.6 pt pitch at 13 pt (the same grid as the complaint template, measured there)
#let body-gap = body-leading       // space above each block: typst's leading only goes between lines, so a block needs this above it to stay on the grid
#let single-pitch = 13.8pt         // single spacing (caption, counsel, signature, certificates): half the double-spaced pitch
#let single-leading = 0.41em       // the leading that gives single-pitch lines in a paragraph (0.65em line box + 0.41em = 1.06em, 13.8 pt)
#let indent = 0.5in                // first-line indent of body paragraphs
#let caption-right = 2.6in         // width of the right-hand column of the caption
#let page-limit = 30               // CV-7(a)(1): case dispositive motions shall not exceed thirty pages, excluding attachments

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txed-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line (or wrapped lines): one single pitch per line, so lines stack on a fixed pitch.
/// A name that wraps grows the block by one pitch per extra line instead of overprinting the next line.
#let sline(c) = block(width: 100%, above: 0pt, below: 0pt, {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  c
  v(single-leading)
})

// ---------------------------------------------------------------------------
// Cover: court (line 1 onward), caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(lines) = for l in lines {
  sline(align(center, text(weight: "bold", upper(l))))
}

#let caption(meta) = grid(
  columns: (1fr, caption-right),
  column-gutter: 0.25in,
  {
    // Each party: its names, then its designation; "v." between the parties (Fed. R. Civ. P. 10(a)).
    for (k, p) in meta.caption.enumerate() {
      if k > 0 {
        sline([v.])
      }
      for n in p.names {
        sline(inl(n))
      }
      sline(pad(left: 1.5in, inl(p.designation)))
    }
  },
  align(bottom, {
    sline(inl(meta.case_number))
    v(single-pitch)
    if "jury_demand" in meta { sline(text(weight: "bold", meta.jury_demand)) }
  }),
)

/// The title states the filer and the character of the document (CV-10(a)(2)), e.g.
/// "Defendant John Doe's Motion to Dismiss under Rule 12(b)(6)". The sample supplies it whole.
#let title-of-paper(meta) = block(width: 100%, above: body-gap, below: body-gap, {
  set par(leading: single-leading, justify: false)
  align(center, text(weight: "bold", upper(meta.brief_title)))
})

// ---------------------------------------------------------------------------
// Signature block (CV-10(a)(3): signed by the lead attorney or with his or her permission)
// ---------------------------------------------------------------------------

#let signature(sig) = block(width: 100%, breakable: false, above: body-gap, {
  pad(left: 3.0in, {
    sline([Respectfully submitted,])
    v(single-pitch)
    for l in sig.firm { sline([#l]) }
    v(single-pitch)
    sline([/s/ #sig.signer])
    sline([#sig.signer])
    for l in sig.lines { sline(inl(l)) }
    v(single-pitch)
    sline(inl(sig.role))
  })
})

/// Certificate of service (CV-5(c): the date and the method of service). Generated from frontmatter, so
/// the text is not typed per case. Not a certificate of conference: CV-7(i) exempts motions to dismiss.
#let certificate-of-service(service) = block(width: 100%, breakable: false, above: body-gap * 2, {
  align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
  v(body-gap)
  block(width: 100%, {
    set par(first-line-indent: indent, leading: body-leading)
    [I hereby certify that on #service.date, the foregoing document was served on all counsel of record #service.method.]
  })
})

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, lettered lists
// ---------------------------------------------------------------------------

/// Level-1 headings are sections: centered, bold, capitals, numbered I., II., ... by the template.
#let section-heading(it) = block(width: 100%, above: body-gap, below: body-gap, sticky: true, {
  align(center, text(size: type-size, weight: "bold", [#counter("section").step()#counter("subsection").update(0)#context counter("section").display("I.") #upper(it.body)]))
})

/// Level-2 headings are subsections: bold, A., B., ... within the section, numbered by the template.
#let subsection-heading(it) = block(width: 100%, above: body-gap, below: body-gap, sticky: true, {
  set par(first-line-indent: 0pt, leading: body-leading)
  text(size: type-size, weight: "bold", [#counter("subsection").step()#context counter("subsection").display("A.") #it.body])
})

/// A lettered list: (a) at the indent, the text hangs after it.
#let lettered(items) = for (i, item) in items.enumerate() {
  block(width: 100%, above: body-gap, {
    set par(first-line-indent: 0pt, leading: body-leading)
    grid(
      columns: (indent * 2, 1fr),
      pad(left: indent, numbering("a.", i + 1)),
      item.body,
    )
  })
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let txed-motion-brief(meta, body) = {
  // CV-7(a)(1): a case dispositive motion states the issues to be decided by the court.
  // An excerpt sample (frontmatter `excerpt: true`) is a transcription of part of a filing; its check is skipped.
  if not meta.at("excerpt", default: false) and not lower(body).contains("statement of the issue") {
    panic("txed-motion-brief: CV-7(a)(1) requires a statement of the issues to be decided (a level-1 heading 'Statement of the Issue(s)')")
  }

  set document(title: meta.case_number + " " + meta.brief_title)
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer: context align(center, text(size: 11pt, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false)
  set par(justify: false, leading: body-leading, spacing: body-gap, first-line-indent: indent)
  set heading(numbering: none)
  show heading.where(level: 1): it => section-heading(it)
  show heading.where(level: 2): it => subsection-heading(it)
  show heading.where(level: 3): it => block(width: 100%, above: body-gap, below: body-gap, sticky: true, {
    set par(first-line-indent: 0pt, leading: body-leading)
    text(size: type-size, style: "italic", weight: "bold", it.body)
  })
  show list: it => lettered(it.children)

  court-title(meta.court)
  v(body-gap)
  caption(meta)
  title-of-paper(meta)

  set par(first-line-indent: indent)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  signature(meta.signature)
  if "service" in meta { certificate-of-service(meta.service) }

  // CV-7(a)(1): 30 pages, excluding attachments (attachments are not part of this build).
  context {
    let n = counter(page).final().first()
    if n > page-limit {
      panic("txed-motion-brief: " + str(n) + " pages; CV-7(a)(1) limits a case dispositive motion to " + str(page-limit) + " pages, excluding attachments")
    }
  }
}
