// U.S. Bankruptcy Court, S.D. Alabama: adversary complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (ALSB-...) refer to ../README.md, which records the
// rule text and the date verified. Governing rules: Fed. R. Bankr. P. 7001 (adversary proceeding), 7008(a)
// (statement of consent to final orders), 7010 (Fed. R. Civ. P. 10 applies; caption must substantially conform
// to Official Form 416), 9004(a)-(b) (legibility, caption). S.D. Ala. LBR 7026-1 (Rule 26(a)(1) statement in
// every complaint). The S.D. Ala. Local Bankruptcy Rules (effective December 1, 2009) set no font or layout
// format for complaints. Font, size, margins and spacing are convention choices (see ../README.md). No case-specific text, no
// coordinates measured off an exemplar, no forced line breaks. The markdown body is rendered by cmarker;
// the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"    // no S.D. Ala. type rule; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                    // Convention: 12 pt, the size of the filed exemplars (no rule sets a size).
#let body-leading = 1.345em              // Gap between lines of body text; 0.655em line box + 1.345em = 24 pt pitch, double-spaced.
#let single-leading = 0.495em            // Caption, headings, signature block, footnotes: single spacing, 0.655em line box + 0.495em = 1.15em pitch.
#let page-margin = 1in                   // Convention: 1 inch on all sides.
#let para-indent = 0.5in                 // First-line indent of body paragraphs.
#let footer-size = 11pt                  // Page number only; not body text.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("alsb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("alsb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 7010, Fed. R. Civ. P. 10(a), Official Form 416A; Fed. R. Bankr. P. 9004(b))
// ---------------------------------------------------------------------------

/// One party group: the names, one per line, then the designation ("Plaintiff," and so on).
#let party(p) = {
  block(above: 0pt, below: 0pt, {
    set par(leading: single-leading, first-line-indent: 0pt)
    for n in p.names { text(inl(n)) + linebreak() }
  })
  h(0.3in)
  block(above: 0.2em, below: 0.7em, p.designation)
}

#let caption(meta) = {
  let cap = need(meta, "caption")
  for l in need(meta, "court") {
    align(center, block(above: 0pt, below: 0.15em, strong(upper(l))))
  }
  v(1.6em)
  grid(
    columns: (3.4in, 1fr),
    rect(width: 100%, stroke: (right: 0.6pt, rest: none), inset: (right: 0.2in, bottom: 0.4em, top: 0.3em), {
      party(cap.debtor)
      party(cap.plaintiff)
      v(0.2em)
      align(left, "v.")
      v(0.2em)
      party(cap.defendant)
    }),
    block(inset: (left: 0.3in, top: 0.3em), {
      "Case No. " + need(meta, "case_number")
      v(0.6em)
      "Chapter " + need(meta, "chapter")
      v(0.6em)
      "Adv. Pro. No. " + need(meta, "adversary_number")
    }),
  )
  v(1.4em)
  align(center, block(above: 0pt, below: 1.4em, strong(upper(need(meta, "title")))))
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Bankr. P. 9011 signature; counsel block)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  v(1.2em)
  block(breakable: false, width: 100%, {
    grid(
      columns: (1fr, 3.0in),
      [Dated: #meta.at("date", default: "__________, 20__")],
      [
        Respectfully submitted,
        #v(1.2em)
        #set par(leading: single-leading, first-line-indent: 0pt)
        /s/ #sig.signer \
        #for l in sig.lines { text(size: 0.92em, inl(l)) + linebreak() }
      ],
    )
  })
}

// ---------------------------------------------------------------------------
// Template entry point
// ---------------------------------------------------------------------------

/// Numbered paragraphs run continuously through the complaint (Fed. R. Civ. P. 10(b)).
#let para-no = counter("alsb-complaint-para")

#let alsb-adversary-complaint(meta, body) = {
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: footer-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(justify: false, leading: body-leading, first-line-indent: para-indent)

  // Level 1 = centered caps section heading; level 2 = bold run-in sub-heading. Not numbered by the template.
  show heading.where(level: 1): it => align(center, block(above: 1.2em, below: 0.9em, strong(upper(it.body))))
  show heading.where(level: 2): it => block(above: 1em, below: 0.7em, strong(it.body))

  // Numbered paragraphs: each markdown list item becomes one paragraph numbered from the running counter.
  show enum: it => for item in it.children {
    para-no.step()
    block(width: 100%, context [#h(para-indent) #para-no.display("1.") #h(0.3em) #item.body])
  }

  caption(meta)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)
  // LBR 7026-1: the complaint must state whether the pleader stipulates that Fed. R. Civ. P. 26(a)(1) will not apply.
  block(above: 1em, below: 0pt, width: 100%, [#h(para-indent) #inl(need(meta, "stipulation-26-1"))])
  signature-block(meta)
  // Optional certificate of service (markdown), after the signature block as filed.
  if "certificate-of-service" in meta {
    v(1.2em)
    cmarker.render(meta.at("certificate-of-service"), raw-typst: false, smart-punctuation: true)
  }
}
