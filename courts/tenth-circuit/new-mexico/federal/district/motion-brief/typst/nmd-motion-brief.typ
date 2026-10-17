// Motion with its supporting brief for the United States District Court for the District of New Mexico (nmd).
// Rules: D.N.M.LR-Civ. 7.1(a) (motion states grounds, relief and the good-faith request for concurrence), 7.1(b)
// (certificate of service), 7.5 (motion and supporting brief together: 27 double-spaced pages), 10.1 (paper, margins,
// double spacing, case number and assigned judges' initials on page 1), 83.4(a) (signature block);
// Fed. R. Civ. P. 7(b)(1), 10(a), 11(a). See ../README.md for each rule's text and the interpretations.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // LR-Civ. 10.1: "at least 12 pitch", letter quality; 12 pt proportional (README.md)
#let pitch = 24pt                       // LR-Civ. 10.1: text double spaced; one double-spaced line = 24 pt at 12 pt
#let body-leading = 1.345em             // Liberation Serif's line box is 0.655em, so 1.345em + 0.655em = 2em = 24 pt at 12 pt
#let single-leading = 0.495em            // single spacing (caption, signature, certificate lists): about 13.8 pt
#let margins = (top: 1.5in, bottom: 1in, left: 1in, right: 1in)   // LR-Civ. 10.1: top at least 1 1/2 in; others at least 1 in
#let text-width = 8.5in - 1in - 1in
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let heading-hang = 0.5in               // hanging indent of numbered sub-headings (I., a.)
#let caption-left = 3.3in               // party column of the caption
#let caption-mark = 0.3in               // column of ")" marks between the parties and the case number

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Fail loudly when the sample leaves out a field the template needs (a missing field must not render as blank).
#let need(meta, key) = {
  assert(key in meta, message: "nmd-motion-brief: the sample's frontmatter must give '" + key + "'")
  meta.at(key)
}

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nmd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// First page: court title, caption, case number, title of the paper (LR-Civ. 10.1; Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  align(center, text(weight: "bold", need(meta, "court").map(l => upper(l)).join(linebreak())))
}

#let caption(meta) = {
  let rows = ()
  for (k, p) in need(meta, "caption").parties.enumerate() {
    if k > 0 { rows.push(pad(left: 1.2in, "v.")) }
    for n in p.names { rows.push(inl(n)) }
    rows.push(pad(left: 1.2in, inl(p.designation)))
  }
  let marks = rows.map(_ => ")")
  grid(
    columns: (caption-left + caption-mark, 1fr),
    block(width: caption-left + caption-mark, {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      grid(
        columns: (caption-left, caption-mark),
        row-gutter: single-leading,
        ..rows.zip(marks).flatten(),
      )
    }),
    block(inset: (left: 0.2in, top: 0pt), {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Case No. #need(meta, "case_number")]
    }),
  )
}

#let cover(meta) = {
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
  align(center, text(weight: "bold", need(meta, "brief_title")))
  v(pitch * 0.5)
}

// ---------------------------------------------------------------------------
// Body (unnumbered: a motion's paragraphs are not allegations)
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of markdown is one paragraph, with a first-line indent. Headings and lists are
/// rendered by the show rules below. A heading is kept in one unbreakable block with the paragraph after it.
#let body-text(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else {
      let piece = {
        set par(leading: body-leading)
        h(para-indent)
        inl(t)
      }
      if has-pending {
        block(breakable: false, width: text-width, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

// ---------------------------------------------------------------------------
// Signature block (LR-Civ. 83.4(a): name, firm, address, telephone, electronic address; Fed. R. Civ. P. 11(a))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: pitch, width: text-width, grid(
    columns: (1fr, 3.2in),
    [],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Respectfully submitted,]
      v(pitch * 0.5)
      line-stack(sig.firm)
      v(pitch * 0.5)
      for (k, b) in sig.blocks.enumerate() {
        if k > 0 { v(pitch * 0.5) }
        line-stack(b)
      }
      v(pitch * 0.5)
      line-stack((sig.attorneys_for,))
    },
  ))
}

// ---------------------------------------------------------------------------
// Certificate of service (LR-Civ. 7.1(b): required on each motion; the service list is the sample's)
// ---------------------------------------------------------------------------

#let certificate-block(meta) = {
  let cert = need(meta, "certificate")
  block(breakable: false, above: pitch, width: text-width, {
    align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
    v(pitch * 0.5)
    set par(leading: body-leading)
    h(para-indent)
    inl(cert.text)
    v(pitch * 0.5)
    set par(leading: single-leading, spacing: 0pt, justify: false)
    for (k, b) in cert.served.enumerate() {
      if k > 0 { v(pitch * 0.5) }
      line-stack(b)
    }
    v(pitch)
    align(right, block(width: 3.2in, line-stack(cert.signed)))
  })
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let nmd-motion-brief(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court", "caption", "brief_title", "signature", "certificate") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",
    margin: margins,
    footer: context align(center, text(size: type-size, counter(page).display())),
    footer-descent: 0.45in,
  )
  set document(title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"))
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false, fallback: false)
  // Typst adds `leading` only between the lines of one paragraph; the gap between paragraphs is `spacing`.
  // Both must be body-leading, or consecutive paragraphs overlap (measured: 7.8 pt pitch without this).
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 is a centered section (INTRODUCTION, ARGUMENT, CONCLUSION); level 2 a roman-numeral argument
  // heading ("I. ...") and level 3 a lettered sub-heading ("a. ..."): bold, hanging from the number.
  show heading.where(level: 1): it => block(width: 100%, above: 12pt, below: 12pt, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: 12pt, below: 12pt, sticky: true,
    par(hanging-indent: heading-hang, leading: single-leading, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: 12pt, below: 12pt, sticky: true,
    par(hanging-indent: heading-hang, leading: single-leading, text(size: type-size, weight: "bold", it.body)))

  cover(meta)
  body-text(body)
  signature-block(meta)
  certificate-block(meta)
}
