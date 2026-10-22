// U.S. District Court, District of New Jersey: complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (NJD-...) refer to ../README.md, which quotes the
// rule text (Fed. R. Civ. P. 8, 10, 38; D.N.J. L.Civ.R. 10.1, 11.1, 11.2, 38.1; the D.N.J. ECF
// Policies ¶ 12(a) on the "s/" signature line). No case-specific text, no coordinates measured off the
// exemplar, no forced line breaks. The markdown body is rendered by cmarker; the metadata comes from
// the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // NJD-FORM-002: a standard proportional serif, vendored
#let type-size = 12pt                   // NJD-FORM-002: 12 point, the size both filed exemplars use
#let margin = 1in                       // NJD-FORM-001: no complaint margin rule; 1 inch, as in both exemplars
#let para-indent = 0.5in                // first-line indent; a paragraph's number starts here ...
#let num-box = 0.5in                    // ... in a box this wide: the text starts 1 in in (docx: a tab at 1440)
#let list-indent = 0.5in                // a prayer item's letter starts half an inch in ...
#let list-box = 0.4in                   // ... in a box of its own; the text hangs at 0.9 in
#let cap-left = 3.2in                   // the caption's party column, ruled at its right and foot ...
#let cap-rule = 0.75pt                  // ... with a rule this thick ...
#let cap-pad-right = 10pt               // ... its text this far from the rule ...
#let cap-pad-below = 10pt               // ... and its last line this far above it
#let cap-desig = 1.8in                  // a party's designation this far in
#let cap-right = 0.35in                 // the case column's text this far right of the rule (0.25 in gutter + 0.1 in)
#let blank-number = "_" * 14            // the Clerk assigns the Civil Action No. (L.Civ.R. 10.1(b)): a blank to fill
#let sig-col = 3.2in                    // the signature column; "Dated:" sits left of it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/njd-complaint.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-body = 27.6pt                // NJD-FORM-003: double spacing, measured in the exemplars (docx 552)
#let pitch-single = 13.8pt              // counsel, court, caption, signatures, footer (docx 276)
#let gap = 27.6pt                       // a blank double line: counsel to court, court to caption, caption to text
#let sig-above = 27.6pt                 // the last paragraph to a signature block
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("njd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Inline markdown (for names with *et al.*, italic attorney lines, and so on). A straight double quote right after
/// a closing parenthesis closes a quotation (typst's smart quotes open one there; pandoc, the docx reader, closes).
#let inl(s) = unloose(cmarker.render(str(s).replace(")\"", ")\u{201D}"), raw-typst: false, smart-punctuation: true))

#let need(meta, key) = {
  if key not in meta { panic("njd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A single-pitch line (one paragraph; it wraps on single lines). `above`: the space before it.
#let sline(content, above: 0pt, align-to: left, indent: 0pt) = block(width: 100%, above: above, below: 0pt,
  align(align-to, pad(left: indent, par(first-line-indent: 0pt, content))))

/// Single-pitch lines, one paragraph each; an empty item is a blank single line.
#let lines(items, align-to: left) = {
  let g = 0pt
  for i in items {
    if i == "" { g += pitch-single } else {
      sline(if type(i) == str { inl(i) } else { i }, above: g, align-to: align-to)
      g = 0pt
    }
  }
}

/// A body paragraph on the double pitch: its first line indented, `label` (a number) in a box `num-box` wide.
#let body-par(label, content) = block(width: 100%, above: 0pt, below: 0pt, par({
  if label != none { box(width: num-box, label) }
  content
}))

/// Headings at the type size on the body pitch, bold and centered, with no space of their own, kept with the block
/// after them: level 1 in capitals.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true,
  align(center, par(first-line-indent: 0pt, text(weight: "bold", if level == 1 { upper(inl(s)) } else { inl(s) }))))

// ---------------------------------------------------------------------------
// Cover: counsel (first page, upper left), court title, caption, title of the paper (L.Civ.R. 10.1(b))
// ---------------------------------------------------------------------------

/// The caption: the parties (each designation 1.8 in in, "v." between them) ruled at the right and foot of their
/// column; the Civil Action No., the judge and the title right of the rule (docx: a one-row table). Grid cell
/// strokes and insets: the rule runs the height of the row, with the space below it under both columns (LibreOffice
/// takes a cell's bottom margin for the whole row).
#let caption(meta) = {
  let left = {
    for (k, p) in need(meta, "caption").parties.enumerate() {
      if k > 0 { sline[v.] }
      lines(p.names)
      sline(inl(p.designation), indent: cap-desig)
    }
  }
  let cn = need(meta, "case_number")
  let judge = need(meta, "judge")
  let right = ([Civil Action No. #(if cn == "" { blank-number } else { cn })],)
  if judge != "" { right.push("Hon. " + judge + ", U.S.D.J.") }
  right += ("", text(weight: "bold", upper(inl(need(meta, "title")))))
  block(width: 100%, above: gap, below: 0pt, breakable: false, grid(
    columns: (cap-left, 1fr),
    stroke: (x, y) => if x == 0 { (right: cap-rule, bottom: cap-rule) },
    inset: (x, y) => if x == 0 { (right: cap-pad-right, bottom: cap-pad-below) } else {
      (left: cap-right, bottom: cap-pad-below) },
    left, lines(right),
  ))
}

#let cover(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  lines(need(meta, "counsel"))
  block(above: gap, below: 0pt, for l in need(meta, "court") { sline(align-to: center, text(weight: "bold", upper(l))) })
  caption(meta)
  v(gap)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, lettered prayer items
// ---------------------------------------------------------------------------

/// A markdown list chunk: one paragraph per item, lettered a., b., ...; the letter `list-indent` in, in a
/// `list-box`, the text hanging after it.
#let list-items(t) = {
  let items = ()
  for l in t.split(regex("\\r?\\n")) {
    let m = l.match(regex("^(?:\\d+\\.|[-*+])[ \\t]+([\\s\\S]*)$"))
    if m != none { items.push(m.captures.at(0)) } else if items.len() > 0 { items.at(-1) += " " + l.trim() }
  }
  for (k, item) in items.enumerate() {
    block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent, par(first-line-indent: 0pt,
      hanging-indent: list-box, [#box(width: list-box, numbering("a.", k + 1))#inl(item)])))
  }
}

/// One chunk: a heading, a list (lettered), a paragraph that starts with one of `unnumbered_prefixes` in the
/// frontmatter (WHEREFORE clauses, the jury demand: unnumbered), or a numbered paragraph.
#let render-chunk(t, prefixes, para) = {
  let h = t.match(regex("^(#{1,2})[ \\t]+(.*)$"))
  if h != none {
    heading-block(h.captures.at(0).len(), h.captures.at(1))
  } else if t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
    list-items(t)
  } else if prefixes.any(p => t.starts-with(p)) {
    body-par(none, inl(t))
  } else {
    para.step()
    context body-par(str(para.get().first()) + ".", inl(t))
  }
}

// ---------------------------------------------------------------------------
// Signature blocks (L.Civ.R. 10.1(b), 11.1; "s/" line per the D.N.J. ECF Policies ¶ 12(a)): "Dated:" left of
// the first line, the firm, a blank line, "By: /s/" and the signer's lines in the signature column; kept whole
// ---------------------------------------------------------------------------

#let signature-lines(date, sig) = {
  let rows = sig.firm + ("", "By: /s/ " + sig.signer) + sig.lines
  set text(..edges(pitch-single))
  let g = 0pt
  let first = true
  for r in rows {
    if r == "" { g += pitch-single } else {
      block(width: 100%, above: g, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
        [#box(width: sig-col, if first [Dated: #inl(date)])#inl(r)]))
      g = 0pt
      first = false
    }
  }
}

#let signature-block(date, sig) = block(width: 100%, breakable: false, above: sig-above, below: 0pt,
  signature-lines(date, sig))

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let njd-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("counsel", "court", "caption", "case_number", "judge", "title", "jury_demand", "date", "signature") {
    let _ = need(meta, k)
  }
  // L.Civ.R. 38.1: a jury demand endorsed on a pleading puts "and Demand for Jury Trial" in its title.
  if meta.jury_demand and not lower(meta.title).contains("demand for jury trial") {
    panic("njd-complaint: a jury demand needs `and Demand for Jury Trial` in the title (L.Civ.R. 38.1)")
  }
  let prefixes = meta.at("unnumbered_prefixes", default: ())
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let para = counter("allegation")

  // ---- document-wide settings ----
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  set page(paper: "us-letter", margin: margin, footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (NJD-FORM-003), a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 2, 6"; xengine binds a single sign; docx: a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  cover(meta)
  // The last chunk is kept on one page with the signature block, so a signature never starts a page alone.
  for (i, t) in chunks.enumerate() {
    if i + 1 == chunks.len() {
      block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
        render-chunk(t, prefixes, para)
        signature-block(need(meta, "date"), need(meta, "signature"))
      })
    } else {
      render-chunk(t, prefixes, para)
    }
  }

  // Certification (L.Civ.R. 11.2): a separate section with its own signature, on its own page.
  if "certification" in meta {
    let cert = meta.certification
    pagebreak(weak: true)
    heading-block(1, cert.title)
    body-par(none, inl(cert.text.trim()))
    signature-block(cert.date, cert.signature)
  }
}
