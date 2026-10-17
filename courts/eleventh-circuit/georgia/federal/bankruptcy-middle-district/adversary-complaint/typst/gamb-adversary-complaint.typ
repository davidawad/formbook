// U.S. Bankruptcy Court, Middle District of Georgia: adversary complaint (FRBP 7001, 7003, 7008, 7010;
// caption per Official Form 416D as the Clerk's Instructions require, LBR 9004-2).
//
// Rule-driven and content-agnostic. Requirement IDs (GAMB-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. The body is markdown rendered by cmarker; the metadata is the YAML frontmatter of the
// same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or is a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"    // No font rule for pleadings in this court (GAMB-FORM-002); Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                    // Style choice: 12 pt, the size of the filed exemplars (no rule sets a size). See ../README.md.
#let line-pitch = 24pt                   // Double spacing for the body (GAMB-FORM-003, style choice; see ../README.md).
#let body-leading = line-pitch - 1.107 * type-size  // gap between body lines: Liberation Serif's line box (hhea ascender to descender, 0.891em + 0.216em) is 1.107em, so the pitch is line-pitch.
#let single-leading = 0.398em            // Caption, headings, signature block, footnotes.
#let margins = (top: 1in, bottom: 1in, x: 1in)  // GAMB-FORM-001 (paper and margins: style choice, no local rule).
#let para-indent = 0.5in
#let number-gap = 0.3in
#let sub-label-width = 0.5in             // Lettered sub-items "(a)": label offset from the margin.
#let sig-column = 3.2in                  // Signature block sits in the right-hand column.
#let caption-left = 3.6in                // Caption: party column; the right column carries case information.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics, quotes, section signs) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("gamb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gamb-adversary-complaint: the sample must start with a YAML frontmatter block") }
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
// Body blocks (GAMB-CONT-001 to GAMB-CONT-004)
// ---------------------------------------------------------------------------

/// Split the markdown body into blank-line-separated chunks.
#let chunks(md) = md.split("\n\n").map(s => s.trim()).filter(s => s != "")

/// Heading level = number of leading "#"; the text is the rest of the chunk.
#let heading-level(s) = {
  let lv = 0
  let t = s
  while t.starts-with("#") {
    lv += 1
    t = t.slice(1)
  }
  lv
}

/// Heading styles: level 1 centered capitals; level 2 bold; level 3 bold italic. Unnumbered (GAMB-CONT-002).
#let heading-block(lv, text) = block(
  width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
  if lv == 1 { align(center, strong(upper(inl(text)))) }
  else if lv == 2 { strong(inl(text)) }
  else { strong(emph(inl(text))) },
)

/// The body. Paragraphs after the first heading are numbered 1, 2, ... (FRCP 10(b), via FRBP 7010);
/// a paragraph before the first heading is the unnumbered lead-in; a chunk beginning "(a)", "(1)"
/// and so on is a lettered sub-item, not a numbered paragraph.
#let body(md) = {
  let k = 0
  let seen-heading = false
  for s in chunks(md) {
    if s.starts-with("#") {
      seen-heading = true
      let lv = heading-level(s)
      heading-block(lv, s.slice(lv).trim())
    } else if s.starts-with(">") {
      block(width: 100%, inset: (left: 0.75in, right: 0.75in), above: line-pitch * 0.5, below: line-pitch * 0.5,
        { set par(leading: single-leading); inl(s) })
    } else if s.match(regex("^\\([a-zA-Z0-9]+\\)")) != none {
      let label = s.match(regex("^\\([a-zA-Z0-9]+\\)")).text
      block(width: 100%, grid(
        columns: (sub-label-width + para-indent, 1fr),
        pad(left: para-indent, inl(label)),
        inl(s.slice(label.len()).trim()),
      ))
    } else if not seen-heading {
      block(width: 100%, { set par(first-line-indent: 0pt); h(para-indent); inl(s) })
    } else {
      k += 1
      block(width: 100%, {
        set par(first-line-indent: 0pt)
        h(para-indent)
        [#k.]
        h(number-gap)
        inl(s)
      })
    }
  }
}

// ---------------------------------------------------------------------------
// Prayer and signature (GAMB-SIG-001 to GAMB-SIG-003)
// ---------------------------------------------------------------------------

/// One signature block per attorney (LBR 9011-1(b): name, bar number, address, telephone and email
/// in immediate proximity to the signature). The "/s/" line is the electronic signature.
#let signature-block(meta) = {
  let sigs = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [#need(meta, "date")]
    v(line-pitch)
    pad(left: 6.5in - sig-column, stack(
      dir: ttb, spacing: 0pt,
      [Respectfully submitted,],
      v(line-pitch),
      ..sigs.map(s => stack(
        dir: ttb, spacing: 0pt,
        [/s/ #s.signer],
        inl(s.signer),
        inl(s.bar),
        ..s.firm.map(l => inl(l)),
        inl(s.phone),
        inl(s.email),
        emph(inl(s.role)),
        v(line-pitch),
      )),
    ))
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let gamb-adversary-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "title", "case_number", "chapter", "adversary_number", "parties", "wherefore", "date", "signature") {
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
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // ---- court title, caption, complaint title ----
  align(center, stack(dir: ttb, spacing: 0pt, ..need(meta, "court").map(l => strong(inl(l)))))
  v(line-pitch)
  caption(meta)
  v(line-pitch)
  align(center, block(width: 90%, strong(upper(inl(need(meta, "title"))))))
  v(line-pitch * 0.5)

  // ---- body, prayer, signature ----
  body(md)
  block(width: 100%, sticky: true, { set par(first-line-indent: 0pt); h(para-indent); inl(need(meta, "wherefore")) })
  signature-block(meta)
}
