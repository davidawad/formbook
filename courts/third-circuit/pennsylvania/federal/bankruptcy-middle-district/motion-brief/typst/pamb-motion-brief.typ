// U.S. Bankruptcy Court, M.D. Pennsylvania: brief (memorandum of law) supporting a motion under Fed. R. Bankr. P. 9013.
//
// Rule-driven and content-agnostic. Requirement IDs (PAMB-MOT-...) refer to ../README.md, which quotes the
// rule text (FRBP 9013, 9014, 9004; L.B.R. 9004-1, 9013-1, 9013-2, 9013-3). No case-specific text, no
// coordinates measured off the exemplar, no forced line breaks. The markdown body is rendered by cmarker;
// the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"         // No M.D. Pa. font rule found (see ../README.md, gaps); Times New Roman substitute per docs/FONTS.md. Vendored in /fonts.
#let type-size = 12pt                    // FRBP 9004(a): clearly legible; no M.D. Pa. size rule. 12 pt, as the filed papers (Times New Roman 12 pt).
#let line-pitch = 24pt                   // Double spacing, as the filed brief (convention, see ../README.md).
#let body-leading = line-pitch - 0.909em // Gap between body lines: the ascender-to-descender line box set below is 0.909em in Liberation Serif, so the line pitch is line-pitch.
#let para-gap = 1.48em                   // Gap between body paragraphs: 0.909em + 1.48em = 28.7 pt at 12 pt, a little more than one double-spaced line.
#let single-leading = 0.596em            // 0.909em + 0.596em = about 18 pt at 12 pt. Caption, signature, headings, certificates.
#let page-margin = 1in                   // Style choice (no local margin rule found).
#let margins = (top: page-margin, bottom: page-margin, x: page-margin)
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let page-limit = 15                     // L.B.R. 9013-2(a): no brief may exceed 15 pages without leave of court.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("pamb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pamb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

// ---------------------------------------------------------------------------
// Headings: numbering and styles (convention: I., A., 1., a.; see ../README.md)
// ---------------------------------------------------------------------------

#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 1 { numbering("I.", k) }
  else if lv == 2 { numbering("A.", k) }
  else if lv == 3 { numbering("1.", k) }
  else if lv == 4 { numbering("a.", k) }
  else { "" }
}

// ---------------------------------------------------------------------------
// Caption (FRBP 9004(b), L.B.R. 9004-1; a contested-matter pleading)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
  align(center, strong(upper(
    need(meta, "court").map(l => [#l]).join(linebreak())
  )))
}

#let caption-table(meta) = {
  let debtor = need(meta, "debtor")
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
    [IN RE:]
    v(line-pitch * 0.5)
    for n in debtor.name { pad(left: 0.5in, inl(n)); linebreak() }
    v(line-pitch * 0.5)
    [Debtor]
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
    inl(debtor.chapter)
    v(line-pitch * 0.5)
    [Case No. #debtor.case_number]
  }
  table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1.2em, bottom: 1em, left),
    pad(left: 1.2em, top: 0.3em, right),
  )
}

// ---------------------------------------------------------------------------
// Signature block (L.B.R. 9013-1; convention for the layout, see ../README.md)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
    grid(columns: (1fr, 3.2in), [], {
      [Respectfully Submitted,]
      v(line-pitch)
      [By: /s/ #inl(sig.signer)]
      linebreak()
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

// ---------------------------------------------------------------------------
// Certificates (L.B.R. 9013-3, 9013-2(b))
// ---------------------------------------------------------------------------

/// L.B.R. 9013-3: (a) the title of the paper served; (b) the names and addresses of the persons served;
/// (c) the entities they represent; (d) when and how service was made.
#let certificate-of-service(meta) = {
  let cos = need(meta, "certificate_of_service")
  pagebreak()
  court-title(meta)
  v(line-pitch)
  caption-table(meta)
  v(line-pitch)
  align(center, strong[Certificate of Service])
  v(line-pitch * 0.5)
  par(first-line-indent: para-indent, {
    [The undersigned certifies that on #cos.date, the undersigned caused a true and correct copy of #inl(need(meta, "title")) to be served #cos.method, on the following persons:]
  })
  v(line-pitch * 0.5)
  for s in cos.served {
    block(breakable: false, below: line-pitch * 0.5, {
      set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
      pad(left: 0.5in, {
        inl(s.name)
        linebreak()
        inl(s.address)
        linebreak()
        [Represents: #inl(s.represents)]
      })
    })
  }
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
    grid(columns: (1fr, 3.2in), [Date: #cos.date], {
      [/s/ #inl(cos.signer)]
      linebreak()
      inl(cos.signer)
    })
  })
}

/// L.B.R. 9013-2(b): a brief over 15 pages must carry a certificate that it complies with the 5,000-word limit,
/// and must state the actual number of words. Printed only when the sample states the count.
#let word-count-certificate(meta) = {
  let n = meta.at("word_count", default: none)
  if n == none { return }
  pagebreak()
  align(center, strong[Certificate of Compliance with Word-Count Limit])
  v(line-pitch * 0.5)
  par(first-line-indent: para-indent, {
    [The undersigned certifies that this brief contains #n words, as counted by the word-processing system used to prepare it, and complies with the 5,000-word limit of L.B.R. 9013-2(b).]
  })
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
    grid(columns: (1fr, 3.2in), [], {
      [/s/ #inl(need(meta, "signature").signer)]
      linebreak()
      inl(need(meta, "signature").signer)
    })
  })
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let pamb-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "debtor", "title", "signature", "certificate_of_service") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margins, numbering: "1", footer: context {
    align(center, numbering("1", ..counter(page).get()))
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
    leading: body-leading, spacing: para-gap,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: heading-num)
  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = numbering(it.numbering, ..nums)
    let ind = (it.level - 1) * heading-tab
    block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true, {
      set text(size: type-size)
      hang(ind + heading-tab, {
        h(ind)
        box(width: heading-tab, lab)
        if it.level == 1 { strong(upper(it.body)) } else { strong(it.body) }
      })
    })
  }

  // ---- first page: court, caption, title, lead-in, body ----
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
  court-title(meta)
  v(line-pitch)
  caption-table(meta)
  v(line-pitch)
  align(center, strong(upper(inl(need(meta, "title")))))
  v(line-pitch * 0.5)

  set par(first-line-indent: para-indent, leading: body-leading, spacing: para-gap, justify: false)
  // The conclusion is sticky with the signature block so the signature never stands alone.
  let paras = md.trim().split("\n\n")
  cmarker.render(paras.slice(0, -1).join("\n\n"), raw-typst: false, smart-punctuation: true)
  // A block starts its first paragraph without a first-line indent; the indent is drawn as a leading space.
  block(sticky: true, h(para-indent) + cmarker.render(paras.last(), raw-typst: false, smart-punctuation: true))
  signature-block(meta)
  certificate-of-service(meta)
  word-count-certificate(meta)

  // ---- page limit (L.B.R. 9013-2(a), (d)): the template does not generate the table of contents and table of
  // authorities that a brief over 15 pages requires, so it stops rather than print a non-compliant brief. ----
  context {
    let n = counter(page).final().first()
    if n > page-limit {
      panic("pamb-motion-brief: " + str(n) + " pages. L.B.R. 9013-2(a) limits a brief to 15 pages; longer briefs need leave of court, a word-count certificate (9013-2(b)), and a table of contents and table of authorities (9013-2(d)), which this template does not generate. See ../README.md.")
    }
  }
}
