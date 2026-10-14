// U.S. Bankruptcy Court, W.D. Ky.: memorandum of law in support of a motion (Fed. R. Bankr. P. 9013;
// W.D. Ky. L.B.R. 9004-1, 9013-1).
//
// Rule-driven and content-agnostic. Requirement IDs (KYWB-...) refer to ../README.md, which quotes
// or paraphrases the rule text. No case-specific text, no coordinates measured off the exemplar,
// no forced line breaks. The body is rendered by cmarker from the markdown below the YAML
// frontmatter of the sample. Paragraph numbers and heading numerals are typed by the author, as
// filed; this template adds neither.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"         // No W.D. Ky. type rule; vendored in /fonts (style choice, see ../README.md).
#let type-size = 13pt                    // 13 pt EB Garamond sets about as large as 12 pt Times (style choice).
#let pitch = 24pt                        // Double spacing: the convention of the filed exemplar (style choice).
#let body-leading = 0.54em               // Gap between lines of body text; tuned so the line pitch is `pitch`.
#let single-leading = 0.2em              // Caption, counsel, signature, certificate, footnotes.
#let margins = (top: 1in, bottom: 1in, x: 1in)
#let para-indent = 0.5in                 // First-line indent of body paragraphs.
#let subheading-indent = 0.5in           // Left edge of a level-3 heading's label.
#let page-size = "us-letter"             // Fed. R. Bankr. P. 9004(a) (legibility); letter paper is the convention.
#let footer-size = 11pt                  // Page number only.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("kywb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("kywb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 7010 and 9004(b): court, title of the case, case number and adversary
// number, and the title of the document). Layout follows the caption of the filed exemplar.
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(for l in need(meta, "court") { upper(inl(l)); linebreak() }))
}

/// The debtor block (In re) and the bankruptcy identifiers, side by side.
#let debtor-block(meta) = {
  let c = need(meta, "caption")
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  table(
    columns: (3.5in, 1fr),
    inset: 0pt,
    stroke: none,
    pad(right: 1.2em, bottom: 0.4em, {
      for (i, l) in c.debtor_names.enumerate() {
        if i == 0 { inl(l) } else { pad(left: 0.5in, inl(l)) }
        linebreak()
      }
      v(pitch * 0.5)
      pad(left: 1.8in, inl(c.debtor_designation))
    }),
    pad(left: 1.2em, bottom: 0.4em, {
      for l in c.bankruptcy_lines { inl(l); linebreak() }
    }),
  )
}

/// The adversary block: parties on the left, the adversary number and judge on the right.
#let adversary-block(meta) = {
  let c = need(meta, "caption")
  let number = if c.adversary_number == "" { "Adv. Proc. No. " + "_" * 12 } else { "Adv. Proc. No. " + c.adversary_number }
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  table(
    columns: (3.5in, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1.2em, bottom: 0.6em, top: 0.4em, {
      for (i, side) in c.parties.enumerate() {
        for n in side.names { inl(n); parbreak() }
        pad(left: 1.8in, inl(side.designation))
        if i < c.parties.len() - 1 { v(pitch * 0.5); pad(left: 0.9in, [v.]); v(pitch * 0.5) }
      }
    }),
    pad(left: 1.2em, top: 0.4em, {
      number
      if "judge" in c { linebreak(); v(pitch * 0.5); inl(c.judge) }
    }),
  )
}

#let caption(meta) = {
  court-title(meta)
  v(pitch)
  debtor-block(meta)
  adversary-block(meta)
  v(pitch)
  align(center, strong(upper(inl(need(meta, "title")))))
  v(pitch * 0.5)
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service (no local rule sets their form; L.B.R. 9004-1 requires
// the filer's address, telephone and email; L.B.R. 9011-4 requires a proper signature). See ../README.md.
// ---------------------------------------------------------------------------

/// One signing block: "Dated" on the left, the signature and the counsel groups on the right.
#let signing-block(date, signer, groups, attorneys-for: none) = block(breakable: false, above: pitch * 0.5, {
  // Signature lines are set at zero leading so a counsel block of this length fits one page.
  set par(first-line-indent: 0pt, leading: 0em, justify: false)
  grid(
    columns: (3.0in, 1fr),
    [Dated: #date],
    {
      [By: /s/ #signer]
      linebreak()
      for (gi, g) in groups.enumerate() {
        for l in g { inl(l); linebreak() }
        if gi < groups.len() - 1 { v(pitch * 0.25) }
      }
      if attorneys-for != none {
        v(pitch * 0.25)
        for l in attorneys-for { inl(l); linebreak() }
      }
    },
  )
})

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  signing-block(need(sig, "date"), need(sig, "signer"), need(sig, "groups"),
    attorneys-for: sig.at("attorneys_for", default: none))
}

#let certificate(meta) = {
  let cert = meta.at("certificate", default: none)
  if cert != none {
    pagebreak(weak: true)
    align(center, strong(upper(inl(cert.heading))))
    v(pitch * 0.5)
    block(width: 100%, above: 0pt, below: 0pt, {
      set par(first-line-indent: para-indent, leading: body-leading)
      inl(cert.text)
    })
    signing-block(cert.date, cert.signer, cert.groups)
  }
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let kywb-motion-brief(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(paper: page-size, margin: margins, numbering: "1", footer: context {
    set text(size: footer-size)
    align(center, [#"- "#counter(page).display()#" -"])
  })
  set document(
    title: need(meta, "title"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Headings: level 2 is a centered Roman-numeral heading; level 3 a hanging sub-heading. The numerals
  // are part of the text as filed, so nothing here numbers them.
  show heading.where(level: 2): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    align(center, text(size: type-size, strong(upper(it.body)))))
  show heading.where(level: 3): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    pad(left: subheading-indent, par(first-line-indent: 0pt, hanging-indent: subheading-indent,
      text(size: type-size, strong(it.body)))))

  caption(meta)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
  certificate(meta)
}
