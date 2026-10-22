// Motion with its supporting brief for the United States District Court for the District of New Mexico (nmd).
// Rules: D.N.M.LR-Civ. 7.1(a) (motion states grounds, relief and the good-faith request for concurrence), 7.1(b)
// (certificate of service), 7.5 (motion and supporting brief together: 27 double-spaced pages), 10.1 (paper, margins,
// double spacing, case number and assigned judges' initials on page 1), 83.4(a) (signature block);
// Fed. R. Civ. P. 7(b)(1), 10(a), 11(a). See ../README.md for each rule's text and the interpretations.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LR-Civ. 10.1 names no face ("at least 12 pitch", letter quality): Times New Roman, the house standard and the exemplar's face; vendored in fonts/
#let type-size = 12pt                   // LR-Civ. 10.1: "at least 12 pitch", letter quality; 12 pt proportional (README.md)
#let margins = (top: 1.5in, bottom: 1in, left: 1in, right: 1in)   // LR-Civ. 10.1: top at least 1 1/2 in; others at least 1 in
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let heading-hang = 0.5in               // numbered sub-headings (I., a.): the label in a box of it, the title hanging after it
#let list-indent = 0.5in                // list items: the label half an inch in
#let list-label = 0.4in                 // list items: the label's box, the text hanging after it
#let caption-left = 3.3in               // party column of the caption
#let caption-mark = 0.3in               // column of ")" marks between the parties and the case number
#let caption-inset = 1.2in              // "v." and the designations this far into the party column
#let case-gap = 0.2in                   // the case number this far right of the ")" column
#let signature-left = 3.3in             // the signature column (and the certificate's signer) stand this far from the left margin
#let gap = 12pt                         // the space between the groups of the signature block, around headings, below the title
#let footer-descent = 25.8pt            // the page number's line box ends 0.45 in above the page foot: 72 - 32.4 - 13.8 pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // LR-Civ. 10.1: text double spaced, 2 x the type size
#let pitch-single = 13.8pt              // single spacing (court title, caption, headings, signature): 1.15 x the size

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

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if type(body) == str { inl(body) } else { body }
})

// ---------------------------------------------------------------------------
// First page: court title, caption, case number, title of the paper (LR-Civ. 10.1; Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

/// The court's lines, centered bold capitals, single-spaced.
#let court-title(meta) = for l in need(meta, "court") {
  line-block(align(center, strong(upper(l))))
}

/// Caption, a double line below the court title: one row per single line, the parties' names and designations in
/// the party column ("v." and the designations indented), a ")" beside every row, and the case number beside the
/// first row. Never split.
#let caption(meta) = {
  let rows = ()
  for (k, p) in need(meta, "caption").parties.enumerate() {
    if k > 0 { rows.push(pad(left: caption-inset, line-block[v.])) }
    for n in p.names { rows.push(line-block(n)) }
    rows.push(pad(left: caption-inset, line-block(p.designation)))
  }
  let cells = ()
  for (k, r) in rows.enumerate() {
    cells += (r, line-block[)],
      if k == 0 { pad(left: case-gap, line-block("Case No. " + need(meta, "case_number"))) } else { [] })
  }
  block(width: 100%, above: pitch-double, below: 0pt, breakable: false,
    grid(columns: (caption-left, caption-mark, 1fr), column-gutter: 0pt, row-gutter: 0pt, ..cells))
}

/// The title of the paper, a double line below the caption: centered bold, at the body pitch.
#let title(meta) = block(width: 100%, above: pitch-double, below: gap, sticky: true,
  { set par(first-line-indent: 0pt); align(center, strong(inl(need(meta, "brief_title")))) })

// ---------------------------------------------------------------------------
// Body (unnumbered: a motion's paragraphs are not allegations)
// ---------------------------------------------------------------------------

/// A heading, single-spaced, 12 pt above and below, sticky so it never ends a page: level 1 a centered bold section
/// in capitals (INTRODUCTION, ARGUMENT, CONCLUSION); level 2 a roman-numeral argument heading ("I. ...") and level 3 a
/// lettered sub-heading ("a. ..."): bold, the label in a half-inch box and the title hanging after it.
#let heading-block(level, c) = block(width: 100%, above: gap, below: gap, sticky: true, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, strong(upper(inl(c)))) } else {
    let m = c.match(regex("^([IVXLC]+\\.|[A-Za-z]\\.|\\d+\\.)\\s+(.*)$"))
    if m == none { strong(inl(c)) } else {
      par(hanging-indent: heading-hang, strong[#box(width: heading-hang, m.captures.at(0))#inl(m.captures.at(1))])
    }
  }
})

/// A body paragraph at the double pitch with the first-line indent. `keep`: kept whole on the page of the block
/// after it (the last block stays with the signature).
#let body-par(content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep, par(first-line-indent: (amount: para-indent, all: true), content))

/// A list item at the double pitch: the label half an inch in, in a box of 0.4 in, the text hanging after it.
#let list-item(label, content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep, pad(left: list-indent,
    par(first-line-indent: 0pt, hanging-indent: list-label, [#box(width: list-label, label)#content])))

/// The items of a list chunk: `-` items with a bullet, `1.` items with their number.
#let list-items(t) = {
  let items = ()
  for l in t.split(regex("\\r?\\n")) {
    let n = l.match(regex("^(\\d+)\\.[ \\t]+(.*)$"))
    let b = l.match(regex("^[-*+][ \\t]+(.*)$"))
    if n != none { items.push((n.captures.at(0) + ".", n.captures.at(1))) }
    else if b != none { items.push(([•], b.captures.at(0))) }
    else { items.last().at(1) += " " + l.trim() }
  }
  items
}

/// The body in order: each blank-line-separated chunk is a `#` heading, a list or a paragraph.
#let body-text(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  for (k, t) in chunks.enumerate() {
    let keep = k == chunks.len() - 1
    let h = t.match(regex("^(#+)\\s+(.*)$"))
    if h != none {
      heading-block(h.captures.at(0).len(), h.captures.at(1))
    } else if t.starts-with(regex("(\\d+\\.|[-*+])[ \\t]")) {
      let items = list-items(t)
      for (i, (label, c)) in items.enumerate() {
        list-item(label, inl(c), keep: keep and i == items.len() - 1)
      }
    } else {
      body-par(inl(t), keep: keep)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (LR-Civ. 83.4(a): name, firm, address, telephone, electronic address; Fed. R. Civ. P. 11(a))
// ---------------------------------------------------------------------------

/// A double line below the body, 3.3 in from the left margin: "Respectfully submitted,", the firm's lines, each
/// attorney group and the attorneys' line, single spaced, 12 pt between the groups. Never split.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let col = (line-block[Respectfully submitted,],)
  for (i, l) in sig.firm.enumerate() { col.push(line-block(above: if i == 0 { gap } else { 0pt }, l)) }
  for b in sig.blocks {
    for (i, l) in b.enumerate() { col.push(line-block(above: if i == 0 { gap } else { 0pt }, l)) }
  }
  col.push(line-block(above: gap, sig.attorneys_for))
  block(width: 100%, above: pitch-double, below: 0pt, breakable: false, pad(left: signature-left, col.join()))
}

// ---------------------------------------------------------------------------
// Certificate of service (LR-Civ. 7.1(b): required on each motion; the service list is the sample's)
// ---------------------------------------------------------------------------

/// A double line below the signature: the centered bold title, 12 pt below it the statement at the body pitch, 12 pt
/// below that each served list (single lines, 12 pt apart), and a double line below them the signers' lines 3.3 in
/// from the left margin. Never split.
#let certificate-block(meta) = {
  let cert = need(meta, "certificate")
  let parts = (line-block(align(center, strong[CERTIFICATE OF SERVICE])),)
  parts.push(block(width: 100%, above: gap, below: 0pt,
    par(first-line-indent: (amount: para-indent, all: true), inl(cert.text))))
  for b in cert.served {
    for (i, l) in b.enumerate() { parts.push(line-block(above: if i == 0 { gap } else { 0pt }, l)) }
  }
  for (i, l) in cert.signed.enumerate() {
    parts.push(line-block(above: if i == 0 { pitch-double } else { 0pt }, pad(left: signature-left, inl(l))))
  }
  block(width: 100%, above: pitch-double, below: 0pt, breakable: false, parts.join())
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
  // Pages numbered at the bottom, centered, in a single-spaced line box 0.45 in above the page foot (where Word's
  // footer sets it).
  set page(paper: "us-letter", margin: margins, footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set document(title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (LR-Civ. 10.1: double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: list-label)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  court-title(meta)
  caption(meta)
  title(meta)
  body-text(body)
  signature-block(meta)
  certificate-block(meta)
}
