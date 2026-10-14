// U.S. Bankruptcy Court, Central District of Illinois: motion with memorandum of law.
//
// Rule-driven and content-agnostic. Governing sources (see ../README.md):
//   FRBP 9013(a)-(b) (written motion; grounds stated with particularity), FRBP 7012(b) (Civil Rule 12(b)
//   motions in an adversary proceeding), FRBP 7010 (caption: Rule 10 Civil; Form 416),
//   FRBP 9004(a)-(b) (legible; caption contents), ILCB LR 9013-1 (motion practice),
//   Practice Guide (Dec. 1, 2025): certificate of service for each paper served, signature "/s/".
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let court-lines = ("UNITED STATES BANKRUPTCY COURT", "CENTRAL DISTRICT OF ILLINOIS")  // FRBP 7010, Form 416
#let font-family = "EB Garamond"          // vendored in /fonts (the only serif face there)
#let type-size = 13pt                      // no CDIL typography rule (FRBP 9004(a): legible only).
                                           // 13 pt EB Garamond has the x-height of 12 pt Times, the
                                           // face and size the exemplars use (see README, gaps).
#let body-leading = 0.88em                 // with this line box, baseline pitch is about 27 pt: double
                                           // spacing, as in all three exemplars (README, tier 2)
#let single-leading = 0.12em               // captions, headings, quotations, footnotes, certificates
#let page-margin = 1in                     // exemplars all use 1 in; no rule sets it (tier 2)
#let para-indent = 0.5in                   // first-line indent of body paragraphs
#let caption-left-width = 3.4in
#let caption-paren-width = 0.3in

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Same, but an empty string is an empty cell.
#let cell(s) = if s == "" { [] } else { inl(s) }

#let need(meta, key) = {
  if key not in meta { panic("ilcb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilcb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Plain text of a piece of content, for comparisons only.
#let plain(c) = {
  if type(c) == str { c }
  else if c == [] { "" }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain).join() }
  else if c.has("body") { plain(c.body) }
  else { "" }
}

// ---------------------------------------------------------------------------
// Caption (FRBP 7010: name of court, parties, bankruptcy case number and chapter,
// adversary number; the ")" column is the convention in the exemplars)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let cap = need(meta, "caption")
  let party-lines = cap.at("left")
  let case-lines = cap.at("right")
  let rows = calc.max(party-lines.len(), case-lines.len())
  block(breakable: false, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
    for i in range(rows) {
      grid(
        columns: (caption-left-width, caption-paren-width, 1fr),
        align(left, cell(party-lines.at(i, default: ""))),
        align(center, ")"),
        align(left, cell(case-lines.at(i, default: ""))),
      )
    }
  })
}

/// The court's name, centered, in capitals (as printed in the rule's own form).
#let court-heading() = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
  stack(dir: ttb, spacing: 0pt, ..court-lines.map(l => align(center, strong(l))))
  v(1.5em)
}

/// The title of the paper (centered, bold). Wraps naturally: no forced line breaks.
#let title-block(meta) = {
  let t = need(meta, "document_title")
  block(breakable: false, above: 1.5em, below: 1.5em, width: 85%, align(center, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
    strong(inl(t))
  }))
}

// ---------------------------------------------------------------------------
// Headings
// Level 1: centered bold (section, e.g. Introduction, Argument, Conclusion).
// Level 2: bold, left (numbered by the author, e.g. "I. ..." or "A. ...").
// Level 3: bold italic, left. Level 4: italic, left.
// Numbers are typed by the author.
// ---------------------------------------------------------------------------

#let style-heading(h) = {
  let body = h.body
  if h.level == 1 {
    block(above: 1.6em, below: 1em, sticky: true, align(center, strong(body)))
  } else if h.level == 2 {
    block(above: 1.2em, below: 0.9em, sticky: true, strong(body))
  } else if h.level == 3 {
    block(above: 1em, below: 0.8em, sticky: true, strong(emph(body)))
  } else {
    block(above: 0.9em, below: 0.7em, sticky: true, emph(body))
  }
}

// ---------------------------------------------------------------------------
// Signature block (the court's guidance: "/s/" then the typed name)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.5em, width: 100%, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
    if "dated" in meta { [Dated: #inl(meta.dated)] ; v(1.2em) }
    pad(left: 45%, stack(
      dir: ttb, spacing: single-leading,
      [Respectfully submitted,],
      v(1em, weak: true),
      strong(inl(sig.firm)),
      v(1em, weak: true),
      [By: /s/ #inl(sig.signer)],
      [One of Its Attorneys],
    ))
    // counsel of record: left margin, one line each (as the exemplars print it)
    v(1.2em)
    stack(dir: ttb, spacing: single-leading, ..sig.at("counsel", default: ()).map(inl))
  })
}

// ---------------------------------------------------------------------------
// Certificate of service (Practice Guide: "a signed certificate of service must be included or
// filed with all documents required to be served"; it must name each party served in full,
// identify the document served and include the case caption)
// ---------------------------------------------------------------------------

#let certificate-of-service(meta) = {
  let svc = meta.at("service", default: none)
  if svc == none { return }
  let sig = need(meta, "signature")
  block(breakable: false, above: 2em, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
    align(center, strong[CERTIFICATE OF SERVICE])
    v(1em)
    [The undersigned certifies that on #inl(svc.date), a copy of the foregoing #inl(svc.document) was filed and thereafter served using the Court's electronic filing system on the following counsel of record:]
    v(1em)
    stack(dir: ttb, spacing: single-leading, ..svc.recipients.map(r => stack(
      dir: ttb, spacing: single-leading,
      ..r.lines.map(inl),
      v(0.9em, weak: true),
    )))
    v(1.2em)
    pad(left: 45%, [/s/ #inl(sig.signer)])
  })
}

// ---------------------------------------------------------------------------
// Entry: the motion with memorandum
// ---------------------------------------------------------------------------

#let ilcb-motion-brief(meta, md) = {
  let _ = need(meta, "caption")
  let _ = need(meta, "document_title")
  let _ = need(meta, "signature")

  set document(
    title: plain(inl(need(meta, "document_title"))),
    author: need(meta, "signature").signer,
  )
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center, footer-descent: 30%)
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: none)
  set footnote.entry(
    gap: 0.5em, clearance: 0.9em, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: 11pt)
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(left: para-indent, right: para-indent, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
    it.body
  }))
  show heading: style-heading
  // Never break inside a token of adjacent parentheses ("60(b)(5)") or between section signs and numbers.
  show regex("\\S*\\)\\(\\S*"): it => box(it)
  show regex("[§¶]+ \\S+"): it => box(it)

  // ---- first page: court, caption, title (no cover page; the caption starts page 1) ----
  court-heading()
  caption(meta)
  title-block(meta)

  // ---- body: introduction, argument, conclusion ----
  // Footnote definitions sit at the end of the file, but a reference and its definition must be in
  // the same cmarker call, so the definitions travel with every call (they print only where referenced).
  // The signature block never stands alone on a page: the last paragraph is kept with it.
  let defs-at = md.match(regex("(?m)^\\[\\^[^\\]]+\\]:"))
  let defs = if defs-at == none { "" } else { md.slice(defs-at.start) }
  let main = (if defs-at == none { md } else { md.slice(0, defs-at.start) }).trim(at: end)
  let breaks = main.matches(regex("\n[ \t]*\n"))
  let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
  let head = main.slice(0, cut)
  let tail = main.slice(cut)
  let keep = tail.len() > 0 and not tail.starts-with("#")
  let render(s) = cmarker.render(s + "\n\n" + defs, raw-typst: false, smart-punctuation: true, h1-level: 1)
  if keep {
    render(head)
    block(breakable: false, { render(tail); signature-block(meta) })
  } else {
    render(main)
    signature-block(meta)
  }

  // ---- certificate of service (the document served is named in the certificate) ----
  certificate-of-service(meta)
}
