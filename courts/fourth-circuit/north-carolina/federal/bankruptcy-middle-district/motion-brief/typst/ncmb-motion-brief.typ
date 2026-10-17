// U.S. Bankruptcy Court, Middle District of North Carolina: brief or memorandum of law in support of a written
// motion in an adversary proceeding (LR 7007-1(c)); the same form serves a contested-matter motion (LR 9013-1(e)).
// Rules: LR 7007-1(a) (motion: facts, relief, rules cited, service), 7007-1(c) (brief filed and served with the
// motion; 20-page limit), LR 9013-1(b) and (e), LR 9011-4 (signature block: state bar number, telephone, email),
// LR 9004-1 (certificate of service: recipient, method, address, person who served), Fed. R. Bankr. P. 9004(a)
// (clearly legible) and 9004(b) and 7010 (caption, Official Form 416D). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice; see ../README.md)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"        // the local rules set no typeface; Times New Roman substitute per docs/FONTS.md, vendored in fonts/
#let type-size = 12pt                   // FRBP 9004(a): "clearly legible"; no local size rule, so the 12 pt convention (docs/FONTS.md)
#let pitch = 24pt                       // the double-spaced line pitch of the filed exemplar
#let body-leading = pitch - 1.15em     // gap between body lines: the text runs in a 1.15em line box (top-edge 0.9em, bottom-edge -0.25em), so the line pitch is `pitch` (double spacing)
#let single-leading = 0.2em             // single spacing: caption, headings, signature block, footnotes
#let cap-row = 16pt                     // one single-spaced caption row; the parenthesis column aligns row by row
#let page-margin = 1in
#let para-indent = 0.5in
#let heading-tab = 0.5in                // hanging indent of numbered headings
#let caption-left = 3.2in               // party column of the caption
#let caption-paren = 0.35in             // the ")" column
#let signature-indent = 3.25in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ncmb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names, citations, section symbols) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A required frontmatter field: a missing one fails the build with its name.
#let need(d, key) = {
  if key not in d { panic("ncmb-motion-brief: missing required field `" + key + "`") }
  d.at(key)
}

/// A single-spaced paragraph whose continuation lines hang under the first.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// A stack of single-spaced lines (each item is inline markdown).
#let lines(items) = stack(dir: ttb, spacing: single-leading, ..items.map(l => inl(l)))

// ---------------------------------------------------------------------------
// Headings: numbering and styles (the order of the brief: I., A., 1., a.)
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 2 "I.", 3 "A.", 4 "1.", 5 "a.". Level 1 is unnumbered.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 2 { numbering("I.", k) }
  else if lv == 3 { numbering("A.", k) }
  else if lv == 4 { numbering("1.", k) }
  else if lv == 5 { numbering("a.", k) }
  else { "" }
}

// ---------------------------------------------------------------------------
// Caption (Form 416D: court, parties, case numbers, title of the paper)
// ---------------------------------------------------------------------------

/// A caption row is a string, or a dictionary {t: text, a: "l" | "c" | "r"} for its alignment in the column.
#let cap-cell(item) = {
  let t = if type(item) == dictionary { item.t } else { item }
  let a = if type(item) == dictionary { item.at("a", default: "l") } else { "l" }
  let al = if a == "c" { center } else if a == "r" { right } else { left }
  block(width: 100%, height: cap-row, align(al, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    inl(t)
  }))
}

/// The caption: left column (parties), a ")" column in every row, right column (case numbers). The number of rows
/// is the longer column; a shorter column is padded with empty rows, so the ")" marks run the full height.
#let caption(meta) = {
  let cap = need(meta, "caption")
  let left = need(cap, "left")
  let right = cap.at("right", default: ())
  let n = calc.max(left.len(), right.len())
  block(width: 100%, stroke: (bottom: 0.75pt), inset: (bottom: 9pt), {
    stack(dir: ttb, ..range(n).map(i => grid(
      columns: (caption-left, caption-paren, 1fr),
      cap-cell(if i < left.len() { left.at(i) } else { "" }),
      block(height: cap-row, width: 100%, align(center, [)])),
      pad(left: 0.25in, cap-cell(if i < right.len() { right.at(i) } else { "" })),
    )))
  })
}

/// The first page: court title, caption, title of the paper. The body starts on the same page.
#let cover(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, stack(dir: ttb, spacing: single-leading, ..need(meta, "court").map(l => [#l])))
  v(pitch)
  caption(meta)
  v(pitch * 0.5)
  align(center, strong(need(meta, "title")))
  v(pitch * 0.5)
}

// ---------------------------------------------------------------------------
// Signature block (LR 9011-4: state bar number, telephone and email on every paper)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let signers = need(sig, "signers")
  block(breakable: false, above: pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    inl(need(sig, "dated"))
    v(pitch * 0.5)
    pad(left: signature-indent, {
      "/s/ " + need(sig, "signed_by")
      v(pitch * 0.5)
      for s in signers {
        lines((
          need(s, "name"),
          "N.C. State Bar No. " + need(s, "bar"),
          "Email: " + need(s, "email"),
        ))
        v(pitch * 0.5)
      }
      lines(need(sig, "firm"))
      v(single-leading)
      lines(need(sig, "address"))
      v(single-leading)
      "Telephone: " + need(sig, "phone")
      v(pitch * 0.5)
      lines(need(sig, "role"))
    })
  })
}

// ---------------------------------------------------------------------------
// Certificate of service (LR 9004-1: recipient, method, address if not electronic, and who served)
// ---------------------------------------------------------------------------

#let certificate(meta) = {
  let svc = need(meta, "service")
  let sig = need(meta, "signature")
  pagebreak(weak: true)
  align(center, strong("CERTIFICATE OF SERVICE"))
  v(pitch * 0.5)
  block(width: 100%, {
    set par(first-line-indent: para-indent, leading: body-leading, justify: false)
    inl(need(svc, "statement"))
  })
  v(pitch * 0.5)
  for r in need(svc, "recipients") {
    block(breakable: false, above: 0.6em, below: 0.6em, width: 100%, {
      set par(first-line-indent: 0pt, leading: single-leading, justify: false)
      pad(left: 0.5in, lines(need(r, "lines")))
      v(0.3em)
      pad(left: 0.5in, emph(inl(need(r, "method"))))
    })
  }
  block(breakable: false, above: pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    inl(if "dated" in svc { svc.dated } else { sig.dated })
    v(pitch * 0.5)
    pad(left: signature-indent, {
      "/s/ " + need(sig, "signed_by")
    })
  })
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ncmb-motion-brief(meta, md) = {
  for k in ("court", "caption", "title", "signature") { let _ = need(meta, k) }

  set document(title: need(meta, "title"), author: need(need(meta, "signature"), "signed_by"))
  // No page number on the first page (the caption page); the others are numbered at the foot, centered.
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    footer: context {
      if counter(page).get().first() > 1 { align(center, text(size: 11pt, counter(page).display("1"))) }
    },
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    // A 1.15em line box (a word-processor single line); Liberation Serif's ascender-descender box is only 0.909em,
    // so single-spaced lines with no gap would touch.
    top-edge: 0.9em, bottom-edge: -0.25em,
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.5in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.5in, spacing: body-leading)
  set heading(numbering: heading-num)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Headings: level 1 is a centered section (unnumbered); level 2 and deeper are numbered, bold, hanging.
  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    if it.level == 1 {
      block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
        text(size: type-size, align(center, strong(upper(it.body)))))
    } else {
      let ind = (it.level - 2) * heading-tab
      block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
        text(size: type-size, hang(ind + heading-tab, {
          h(ind)
          box(width: heading-tab, lab)
          strong(it.body)
        })))
    }
  }

  // Block quotations: single-spaced, indented half an inch on each side.
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, block(width: 100%, above: body-leading, below: body-leading, {
    set par(leading: single-leading, first-line-indent: 0pt)
    it.body
  }))

  cover(meta)
  cmarker.render(md, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
  if "service" in meta { certificate(meta) }
}
