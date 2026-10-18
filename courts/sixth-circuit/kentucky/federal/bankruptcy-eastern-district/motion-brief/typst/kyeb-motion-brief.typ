// U.S. Bankruptcy Court, Eastern District of Kentucky: motion with memorandum (FRBP 9013; LBR 9013-1).
//
// Rule-driven and content-agnostic. Requirement IDs (KYEB-...) refer to ../README.md, which quotes the
// rule text (FRBP 9004, 9011, 9013, 9014; KYEB LBR 9013-1, 9014-1). No case-specific text, no coordinates
// measured off an exemplar, no forced line breaks. The body is markdown rendered by cmarker; the metadata
// comes from the YAML frontmatter of the same file (schema: ../README.md).
//
// Open choices the filed exemplar settles (usage/FILED-EXAMPLE-motion-brief.pdf, and
// see ../README.md): single-spaced body with a gap between paragraphs; numbered paragraphs; a judge line in
// the caption; the title between two rules; the "/s/" signature block with a rule under the signer's name,
// repeated in the certificate of service; NOTICE after the signature and before the certificate.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Cursor"    // KYEB-FORM-001: no E.D. Ky. bankruptcy rule sets a typeface; Cursor matches the audited exemplar (docs/FONTS.md)
#let type-size = 12pt                    // KYEB-FORM-001: a legible size (FRBP 9004(a)); 12 pt, the usual floor (Times New Roman substitute, docs/FONTS.md).
#let body-leading = 0.398em              // KYEB-FORM-003: single spacing, as the exemplar (a convention; see ../README.md).
#let single-leading = 0.398em            // caption, signature, headings, footnotes, notice.
#let gap = 12pt                          // the one vertical gap: between paragraphs, around headings and blocks.
#let margins = (top: 1in, bottom: 1in, left: 1in, right: 1in)
#let para-indent = 0.5in                 // first-line indent of an unnumbered paragraph.
#let item-indent = 0.25in                // numbered paragraph: the number sits here from the margin...
#let item-text = 0.6in                   // ...and the text hangs from here.
#let footer-size = 12pt
#let caption-left = 50%                   // the right-hand column starts at the middle of the text block.
#let rule-stroke = 0.7pt

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("kyeb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("kyeb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// The paragraph counter: numbered paragraphs run on through the whole motion, as the exemplar's do.
#let para-no = counter("kyeb-motion-para")

// ---------------------------------------------------------------------------
// Caption (FRBP 9004(b): court, title of the case, case number and adversary number if any, designation)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(need(meta, "court").map(l => [#l]).join(linebreak())))
}

#let caption-table(meta) = {
  let cap = need(meta, "caption")
  let debtors = cap.debtors
  let left-top = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [In re:]
    v(gap * 0.5)
    for n in debtors.names { inl(n); parbreak() }
    inl(debtors.designation)
  }
  let right-top = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [Case No. #need(meta, "case_number")]
    if need(meta, "jointly_administered") {
      linebreak()
      [(Jointly Administered)]
    }
    v(gap * 0.5)
    [#need(meta, "chapter")]
    if "judge" in meta {
      v(gap * 1.5)
      inl(meta.judge)
    }
  }
  // An adversary caption has parties on the left; a main-case motion has the debtors only.
  let left-bottom = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for (i, side) in cap.at("parties", default: ()).enumerate() {
      for n in side.names { inl(n); parbreak() }
      pad(left: 1.8in, inl(side.designation))
      if i < cap.at("parties", default: ()).len() - 1 {
        v(gap * 0.5)
        [v.]
        v(gap * 0.5)
      }
    }
  }
  let right-bottom = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    let adv = meta.at("adversary_number", default: "")
    if adv != "" { [Adv. No. #adv] }
  }
  let has-parties = "parties" in cap
  table(
    columns: (caption-left, 1fr),
    inset: 0pt,
    stroke: none,
    pad(right: 1.2em, top: 0.4em, bottom: 0.6em, left-top),
    pad(left: 1.2em, top: 0.4em, bottom: 0.6em, right-top),
    ..if has-parties {(
      pad(right: 1.2em, top: 0.6em, bottom: 1em, left-bottom),
      pad(left: 1.2em, top: 1.6em, bottom: 1em, right-bottom),
    )} else {(
      [], [],
    )},
  )
}

/// The title sits between two rules, bold and centred, as in the exemplar.
#let title-block(meta) = block(width: 100%, above: gap, below: gap, {
  line(length: 100%, stroke: rule-stroke)
  v(gap * 0.5)
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(need(meta, "title").join(" ")))
  v(gap * 0.5)
  line(length: 100%, stroke: rule-stroke)
})

// ---------------------------------------------------------------------------
// Notice of opportunity for hearing (LBR 9013-1(a)) and hearing date (LBR 9014-1(a))
// ---------------------------------------------------------------------------

/// Printed under the title when the motion is set for hearing or with an objection deadline.
#let hearing-notice(meta) = {
  let h = meta.at("hearing", default: none)
  if h != none {
    block(width: 100%, above: gap, below: gap, {
      set par(first-line-indent: 0pt, leading: single-leading, justify: false)
      if "date" in h { [Hearing: #h.date] ; linebreak() }
      if "time" in h { [Time: #h.time] ; linebreak() }
      if "place" in h { [Place: #h.place] ; linebreak() }
      if "objection_deadline" in h { [Objections due: #h.objection_deadline] ; linebreak() }
    })
  }
}

// ---------------------------------------------------------------------------
// Body: unnumbered paragraphs are first-line indented; numbered paragraphs run on through the motion;
// headings are typed by the author
// ---------------------------------------------------------------------------

#let footnote-def = regex("^\\[\\^([^\\]]+)\\]:[ \\t]*([\\s\\S]*)$")
#let footnote-ref = regex("\\[\\^([^\\]]+)\\]")

/// Inline content of a paragraph. Each `[^key]` becomes a footnote whose text is the definition `key`.
#let with-notes(t, notes) = {
  let out = []
  let rest = t
  let m = rest.match(footnote-ref)
  while m != none {
    out += inl(rest.slice(0, m.start))
    out += footnote(inl(notes.at(m.captures.at(0))))
    rest = rest.slice(m.end)
    // Markdown trims the leading space of the text after a footnote mark, so the space is put back here.
    if rest.starts-with(" ") {
      out += [ ]
      rest = rest.slice(1)
    }
    m = rest.match(footnote-ref)
  }
  out + inl(rest)
}

/// Split a chunk of "N. text" lines into its items. A line that does not start with a number continues the
/// item above it, so a wrapped line of markdown stays in its paragraph.
#let numbered-items(t) = {
  let items = ()
  for line in t.split(regex("\\r?\\n")) {
    let m = line.match(regex("^\\s*\\d+\\.[ \\t]+"))
    if m != none {
      items.push(line.slice(m.end).trim())
    } else if items.len() > 0 {
      let last = items.pop()
      items.push(last + " " + line.trim())
    }
  }
  items
}

/// One numbered paragraph. The number is set by the counter, not by the author's markdown, so the sequence
/// stays right when a chunk of the body is split by a heading.
#let numbered-item(t, notes) = block(width: 100%, below: gap, pad(left: item-indent, grid(
  columns: (item-text - item-indent, 1fr),
  column-gutter: 0pt,
  [#para-no.step()#context para-no.display("1.")],
  with-notes(t, notes),
)))

#let body-blocks(body, notes) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.match(footnote-def) != none { continue }
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
      continue
    }
    let piece = none
    if t.match(regex("^\\d+\\.[ \\t]")) != none {
      piece = stack(dir: ttb, spacing: 0pt, ..numbered-items(t).map(it => numbered-item(it, notes)))
    } else if t.starts-with(regex("^[-*+][ \\t]")) {
      piece = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(gap)
      }
    } else {
      // Each paragraph is its own block, so consecutive paragraphs never run together on one line.
      piece = block(width: 100%, below: gap, [#h(para-indent)#with-notes(t, notes)])
    }
    if has-pending {
      block(breakable: false, width: 100%, { pending; piece })
    } else {
      piece
    }
    pending = []
    has-pending = false
  }
  if has-pending { pending }
}

// ---------------------------------------------------------------------------
// Signature block (FRBP 9011(a)), NOTICE, and certificate of service (FRBP 9014(b), by convention)
// ---------------------------------------------------------------------------

/// The "/s/" block at the right of the page, with a rule under the signer's name. The exemplar repeats it in
/// the certificate of service, so it is one function; `opening` adds "Respectfully Submitted,".
#let signature-block(meta, opening: true) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: gap, below: gap, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 1fr), [], {
      if opening [Respectfully Submitted,]
      v(if opening { gap } else { gap * 0.5 })
      [/s/ #sig.signer]
      v(0.2em)
      line(length: 100%, stroke: rule-stroke)
      if "firm" in sig { [#sig.firm]; linebreak() }
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

#let notice-block(meta) = {
  let n = meta.at("notice", default: none)
  if n != none {
    block(width: 100%, above: gap, below: gap, {
      set par(first-line-indent: 0pt, leading: body-leading, justify: false)
      block(sticky: true, width: 100%, below: gap, align(center, strong[NOTICE]))
      inl(n)
    })
  }
}

#let certificate-block(meta) = {
  let cert = meta.at("certificate_of_service", default: none)
  if cert != none {
    block(breakable: false, above: gap, {
      set par(first-line-indent: 0pt, leading: body-leading, spacing: gap * 0.25, justify: false)
      align(center, strong(upper("Certificate of Service")))
      v(gap)
      cmarker.render(cert.text, raw-typst: false, smart-punctuation: true)
      signature-block(meta, opening: false)
    })
  }
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let kyeb-motion-brief(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "chapter", "case_number", "jointly_administered", "title", "date", "signature") {
    let _ = need(meta, k)
  }
  let notes = (:)
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")) {
    let m = c.trim().match(footnote-def)
    if m != none { notes.insert(m.captures.at(0), m.captures.at(1)) }
  }

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",
    margin: margins,
    numbering: "1",
    footer: context align(center, text(size: footer-size, counter(page).display())),
  )
  set document(
    title: need(meta, "title").join(" ") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: 0.891em, bottom-edge: -0.216em,  // Liberation Serif's hhea ascender and descender: a 1.107em line box
  )
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Headings: level 1 centered capitals; level 2 centered bold; level 3 bold at the margin.
  show heading: set text(size: type-size)
  show heading.where(level: 1): it => block(width: 100%, above: gap, below: gap, sticky: true,
    align(center, strong(upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: gap, below: gap, sticky: true,
    align(center, strong(it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: gap, below: gap, sticky: true,
    strong(it.body))

  // ---- first page: court, caption, title, hearing notice ----
  court-title(meta)
  v(gap * 1.5)
  caption-table(meta)
  title-block(meta)
  hearing-notice(meta)

  // ---- body ----
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  body-blocks(body, notes)

  signature-block(meta)
  notice-block(meta)
  certificate-block(meta)
}
