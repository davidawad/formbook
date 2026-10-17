// U.S. Bankruptcy Court, Middle District of Georgia: motion with memorandum (FRBP 9013; LBR 9013-1,
// 9013-3; caption per Official Form 416D as the Clerk's Instructions require, LBR 9004-2).
//
// Rule-driven and content-agnostic. Requirement IDs (GAMB-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. The body is markdown rendered by cmarker; the metadata is the YAML frontmatter of the
// same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or is a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // No font rule for motions in this court (GAMB-FORM-002); Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                    // Style choice: 12 pt, the size of the filed exemplars (no rule sets a size). See ../README.md.
#let line-pitch = 24pt                   // Double spacing for the body (GAMB-FORM-003, style choice; see ../README.md).
#let body-leading = line-pitch - 1.107 * type-size  // gap between body lines: Liberation Serif's line box (hhea ascender to descender, 0.891em + 0.216em) is 1.107em, so the pitch is line-pitch.
#let single-leading = 0.398em            // Caption, headings, block quotations, signature block, footnotes.
#let margins = (top: 1in, bottom: 1in, x: 1in)  // GAMB-FORM-001 (paper and margins: style choice, no local rule).
#let para-indent = 0.5in
#let sig-column = 3.2in                  // Signature and certificate blocks sit in the right-hand column.
#let caption-left = 3.6in                // Caption: party column; the right column carries case information.
#let footnote-size = 12pt

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, quotes, section signs) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("gamb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gamb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (GAMB-CAP-001 to GAMB-CAP-004)
// ---------------------------------------------------------------------------

/// Form 416D caption: parties on the left, case information on the right, closed by a rule on the
/// right and bottom of the party column.
#let caption(meta) = {
  let parties = need(meta, "parties")
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for (i, p) in parties.enumerate() {
      // "v." between the plaintiff side and the defendant side; none between the debtor and the rest.
      if i > 0 and parties.at(i - 1).kind != "debtor" {
        v(line-pitch * 0.5)
        pad(left: 1.2in, [v.])
        v(line-pitch * 0.5)
      }
      if p.kind == "debtor" { [In re:]; v(line-pitch * 0.5) }
      stack(dir: ttb, spacing: 0pt, ..p.names.map(n => inl(n)))
      pad(left: 2.2in, inl(p.role))
    }
  }
  let adversary = need(meta, "adversary_number")
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    pad(left: 0.35in, stack(
      dir: ttb, spacing: line-pitch * 0.5,
      [Bankruptcy Case No. #need(meta, "case_number")],
      [Chapter #need(meta, "chapter")],
      [Adversary Proceeding No. #if adversary == "" { "________" } else { adversary }],
    ))
  }
  table(
    columns: (caption-left, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1.2em, bottom: 1em, left),
    pad(top: 0.3em, right),
  )
}

// ---------------------------------------------------------------------------
// Signature and certificate of service (GAMB-SIG-001 to GAMB-SIG-004)
// ---------------------------------------------------------------------------

/// One signature block per attorney (LBR 9011-1(b): name, bar number, address, telephone and email
/// in immediate proximity to the signature). The "/s/" line is the electronic signature.
#let attorney-block(s) = stack(
  dir: ttb, spacing: 0pt,
  [/s/ #s.signer],
  inl(s.signer),
  inl(s.bar),
  ..s.firm.map(l => inl(l)),
  inl(s.phone),
  inl(s.email),
  if s.role != "" { emph(inl(s.role)) },
  v(line-pitch),
)

#let signature-block(meta) = block(breakable: false, above: line-pitch, {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  [#need(meta, "dated")]
  v(line-pitch)
  pad(left: 6.5in - sig-column, stack(dir: ttb, spacing: 0pt, ..need(meta, "signature").map(attorney-block)))
})

/// Certificate of service: the parties served, the method, the date and the attorney's signature
/// (LBR 9013-3(a)). Parties served through CM/ECF need no address under that rule.
#let certificate-of-service(meta) = block(breakable: false, above: line-pitch, {
  let svc = need(meta, "service")
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong[Certificate of Service])
  v(line-pitch * 0.5)
  block(width: 100%, {
    set par(first-line-indent: para-indent, leading: body-leading)
    [I certify that on #svc.date I filed the foregoing with the Clerk of Court using the CM/ECF system, which will send notification of the filing to the parties listed below who are registered CM/ECF users. I further certify that I served by first-class United States mail, postage prepaid, the parties listed below who are not registered CM/ECF users.]
  })
  v(line-pitch * 0.5)
  stack(dir: ttb, spacing: 0pt,
    strong[Served through CM/ECF:],
    ..svc.ecf.map(l => inl(l)),
    v(line-pitch * 0.5),
    strong[Served by first-class mail:],
    ..svc.mail.map(l => inl(l)),
  )
  v(line-pitch)
  pad(left: 6.5in - sig-column, stack(dir: ttb, spacing: 0pt, ..need(meta, "signature").map(attorney-block)))
})

// ---------------------------------------------------------------------------
// The motion with memorandum
// ---------------------------------------------------------------------------

#let gamb-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "title", "case_number", "chapter", "adversary_number", "parties", "dated", "signature", "service") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margins, numbering: "1", number-align: center)
  set document(title: need(meta, "title"), author: need(meta, "signature").at(0).signer)
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: 0.891em, bottom-edge: -0.216em,  // Liberation Serif's hhea ascender and descender: a 1.107em line box
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Headings as typed by the author (no automatic numbering: the memorandum's own I., A. labels stay).
  show heading: it => {
    if it.level == 1 {
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        align(center, strong(it.body)))
    } else if it.level == 2 {
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        { set par(first-line-indent: 0pt, leading: single-leading); strong(it.body) })
    } else {
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        { set par(first-line-indent: 0pt, leading: single-leading); strong(emph(it.body)) })
    }
  }

  // Block quotations: indented, single-spaced (FRBP 9013 practice; convention, see ../README.md).
  show quote.where(block: true): it => block(
    width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5,
    inset: (x: 0.75in),
    { set par(first-line-indent: 0pt, leading: single-leading); it.body },
  )

  // ---- court title, caption, title ----
  align(center, stack(dir: ttb, spacing: 0pt, ..need(meta, "court").map(l => strong(inl(l)))))
  v(line-pitch)
  caption(meta)
  v(line-pitch)
  align(center, block(width: 90%, strong(upper(inl(need(meta, "title"))))))
  v(line-pitch * 0.5)

  // ---- body, signature, certificate of service ----
  cmarker.render(md, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
  certificate-of-service(meta)
}
