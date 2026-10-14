// Motion with supporting brief for the United States Bankruptcy Court, Southern District of Iowa (iasb).
// Rules (primary sources, verified 2026-10-14; see ../README.md):
//   Fed. R. Bankr. P. 9013: a request for an order is made by written motion; the motion states its grounds with
//     particularity and sets forth the relief requested; it is served on the parties the rules specify.
//   Fed. R. Bankr. P. 9014(a), (b): in a contested matter, reasonable notice and an opportunity to be heard; the motion
//     is served within the time of Rule 9006(d) and in the manner for serving a summons and complaint under Rule 7004.
//   Fed. R. Bankr. P. 9004(a), (b): legible; caption with the court's name, the title of the case, the case number (and the
//     adversary-proceeding number, if any), and a brief designation of the document.
//   Fed. R. Bankr. P. 9011(a): signed by an attorney of record, with the signer's address and telephone number.
// The court's local rules were abolished effective 2003-08-04 (court website), so there is no local rule on motion form,
// brief length, typeface or page limit. The brief in support is part of the same document (a convention the exemplar
// follows); no rule requires a separate memorandum. Typography is tier 2; see ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each is a convention or a rule; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"     // no typeface is mandated; EB Garamond is the vendored serif (fonts/)
#let type-size = 12pt                // convention: 12 point, the size the exemplar uses
#let footnote-size = 10pt            // convention: footnotes one size smaller
#let body-leading = 1.35em           // convention: double-spaced body text, as the exemplar's body
#let single-leading = 0.5em          // single-spaced caption, declarations, certificate and signature block
#let para-indent = 0.5in             // first-line indent of numbered paragraphs
#let page-w = 8.5in                  // 8 1/2 x 11 is the court's paper (FRBP 9004 leaves size to the local practice)
#let page-h = 11in
#let margin = 1in                    // convention: one inch on all sides
#let text-width = page-w - 2 * margin
#let caption-left = 3.4in            // width of the party column of the caption
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF IOWA")  // FRBP 9004(b)(1)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("iasb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, quotations).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced lines, one per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if type(i) == str { inl(i) } else { i }))
}

// ---------------------------------------------------------------------------
// Caption: court, debtor on the left; case number, chapter and the document's title on the right.
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let left = ("In re:",) + meta.debtors + (meta.debtor_role,)
  let right = ("Case No. " + meta.case_number, "Chapter " + meta.chapter)
  if "adv_number" in meta and meta.adv_number != "" {
    right.push("Adv. Proc. No. " + meta.adv_number)
  }
  if "label" in meta and meta.label != "" {
    right.push(text(weight: "bold", meta.label))
  }
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), line-stack(left)),
    block(inset: (left: 0.1in, top: 0pt), {
      line-stack(right)
      v(12pt)
      text(weight: "bold", inl(meta.brief_title))
      if "hearing" in meta and meta.hearing != "" {
        v(12pt)
        line-stack((meta.hearing,))
      }
    }),
  )
}

#let cover(meta) = {
  stack(dir: ttb, spacing: single-leading, ..court-name.map(line => align(center, text(weight: "bold", line))))
  v(18pt)
  caption(meta)
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lettered lists, block quotations, footnotes
// ---------------------------------------------------------------------------

/// A heading is kept with the block after it, so it never ends a page. Level 1: a centered section in capitals.
/// Level 2: a bold sub-heading with a hanging indent (its letter is part of the text, as filed).
#let heading-block(level, s) = block(width: text-width, sticky: true, above: 12pt, below: 12pt, {
  if level == 1 {
    align(center, text(weight: "bold", upper(s)))
  } else if level == 2 {
    set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    text(weight: "bold", inl(s))
  } else {
    text(weight: "bold", style: "italic", inl(s))
  }
})

/// The footnote definitions of the body ("[^n]: text"). They are appended to each chunk that refers to them, because
/// cmarker resolves a reference only against the definitions in the same string.
#let footnote-definitions(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c.starts-with("[^")).join("\n\n")

/// The body in document order. Numbered paragraphs run 1, 2, ...; WHEREFORE paragraphs are unnumbered.
#let body-content(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = footnote-definitions(body)
  let n = 0
  let out = []
  for t in chunks {
    if t.starts-with("[^") {
      // A footnote definition is rendered with the paragraph that refers to it.
    } else if t.starts-with("#") {
      let level = t.match(regex("^(#+)")).captures.at(0).len()
      out += heading-block(level, t.replace(regex("^#+[ \t]*"), ""))
    } else if t.starts-with(">") {
      out += block(width: text-width, {
        set par(leading: single-leading, spacing: 0pt, justify: true)
        pad(left: 0.75in, right: 0.75in, top: 6pt, bottom: 12pt, inl(t.replace(regex("(?m)^>[ \t]?"), "")))
      })
    } else if t.starts-with("WHEREFORE") {
      // Sticky: the conclusion stays on the page with the signature block that follows it.
      out += block(width: text-width, sticky: true, {
        set par(leading: body-leading, first-line-indent: 0pt, justify: false)
        h(para-indent)
        inl(t + if t.contains("[^") { "\n\n" + defs } else { "" })
      })
    } else {
      n += 1
      let text-of = t + if t.contains("[^") { "\n\n" + defs } else { "" }
      out += block(width: text-width, {
        set par(leading: body-leading, first-line-indent: 0pt, justify: false)
        h(para-indent)
        [#(n).#h(0.25in)]
        inl(text-of)
      })
    }
  }
  out
}

/// Signature block: the date (left), the signer's electronic signature and counsel lines (FRBP 9011(a)) on the right.
#let signature-block(meta) = block(width: text-width, breakable: false, {
  v(body-leading)
  grid(
    columns: (2.8in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    line-stack(("/s/ " + meta.signature.signer,) + meta.signature.lines),
  )
})

/// Verifications (declarations under penalty of perjury), each with its own title, body and signature.
#let declarations-block(decls) = for d in decls {
  block(width: text-width, sticky: true, above: 24pt, below: 12pt,
    align(center, text(weight: "bold", upper(d.title))))
  block(width: text-width, {
    set par(leading: body-leading, first-line-indent: 0pt, justify: false)
    inl(d.body)
  })
  block(width: text-width, breakable: false, {
    v(body-leading)
    grid(
      columns: (2.8in, 1fr),
      column-gutter: 0.2in,
      [Dated: #d.date],
      line-stack(("/s/ " + d.signer, d.signer)),
    )
  })
}

/// Certificate of service, last in the document.
#let certificate-block(svc) = block(width: text-width, breakable: false, {
  block(width: text-width, sticky: true, above: 24pt, below: 12pt,
    align(center, text(weight: "bold", upper(svc.title))))
  set par(leading: body-leading, first-line-indent: 0pt, justify: false)
  h(para-indent)
  inl(svc.text)
  v(body-leading)
  align(right, line-stack(("/s/ " + svc.signer, svc.signer)))
})

#let iasb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, first-line-indent: 0pt, justify: false)
  show footnote.entry: set text(size: footnote-size)

  cover(meta)

  if "lead_in" in meta {
    block(width: text-width, {
      set par(leading: body-leading, first-line-indent: 0pt, justify: false)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  body-content(body)
  signature-block(meta)
  if "declarations" in meta { declarations-block(meta.declarations) }
  if "service" in meta { certificate-block(meta.service) }
}
