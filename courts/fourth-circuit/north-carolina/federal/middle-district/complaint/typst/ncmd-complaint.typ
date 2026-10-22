// U.S. District Court, Middle District of North Carolina: complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (NCMD-...) refer to ../README.md, which quotes the
// rule text (M.D.N.C. Local Civil Rules, effective June 1, 2026; Fed. R. Civ. P. 8, 10, 38). No
// case-specific text, no coordinates measured off the exemplar, no forced line breaks. The markdown body
// is rendered by cmarker; the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

// NCMD-FORM-002: a proportional font (LR 7.1(a) names no face): Times New Roman, the house face (vendored, docs/FONTS.md)
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 13pt                    // NCMD-FORM-002: proportional font "no smaller than 13 point" (LR 7.1(a))
#let lines-per-page = 27                 // NCMD-FORM-003: "no more than 27 lines of regularly spaced text on a page" (LR 7.1(a))
#let top-margin = 1.25in                 // NCMD-FORM-004: top margin "not less than one and one-quarter inches" (LR 7.1(a))
#let bottom-margin = 1in                 // NCMD-FORM-004: bottom, left and right margins "not less than one inch" (LR 7.1(a))
#let side-margin = 1in
#let para-indent = 0.5in                 // the paragraph number starts half an inch in
#let number-box = 0.5in                  // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let label-box = 0.5in                   // a list item's label box, half an inch in; the text hangs after it
#let caption-left = 3.4in                // width of the party column of the caption
#let caption-pad = 0.2in                 // the party column's text to its rule, and the rule to the case block
#let designation-indent = 1.2in          // "Plaintiff," / "Defendant." under the names
#let sig-indent = 3in                    // the signature block in the right half of the page

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/ncmd-complaint.lua sets the same twips).
#let pitch-body = 23pt                   // NCMD-FORM-003: 27 x 23 pt = 621 pt, inside the 630 pt text height
#let pitch-single = 15pt                 // single-spaced: court name, caption, signature block, footnotes, page number
#let blank = 23pt                        // one blank body line: court name to caption, caption to text, above a section
                                         // heading, the last paragraph to the signature block
#let caption-below = 15pt                // the party column's last line to its bottom rule (one single line)
#let note-gap = 4pt                      // between two footnotes (docx: Footnote Text 80 twips after)
#let note-clearance = 12pt               // the body text to the footnote rule
// NCMD-FORM-005 (LR 7.1(a): numbered at the bottom): the number in a single-spaced line box whose foot is 0.4 in above
// the bottom edge (docx: footer distance 576 twips): 72 - 28.8 - 15 = 28.2 pt below the text.
#let footer-descent = 28.2pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ncmd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, italics in titles, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

#let need(meta, key) = {
  if key not in meta { panic("ncmd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Single-spaced lines, one paragraph each; an empty item is a blank single line. `above`: space above the first.
#let line-stack(items, above: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let gap = above
  for i in items {
    if i == "" { gap += pitch-single } else {
      block(width: 100%, above: gap, below: 0pt, i)
      gap = 0pt
    }
  }
}

// ---------------------------------------------------------------------------
// Cover block: court title, caption, title of the paper (NCMD-FIRST-001..003)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  for l in need(meta, "court") { block(width: 100%, above: 0pt, below: 0pt, align(center, strong(upper(l)))) }
  if "division" in meta and meta.division != none {
    block(width: 100%, above: pitch-single, below: 0pt, align(center, strong(upper(meta.division))))
  }
}

/// The party column (closed by a right and a bottom rule) at left, the case block at right; both start on the same
/// single line. Between two parties "v." centred, a blank single line above and below it.
#let caption(meta) = {
  let sides = need(meta, "caption").parties
  let left = ()
  for (i, side) in sides.enumerate() {
    for n in side.names { left.push(inl(n)) }
    left.push(pad(left: designation-indent, inl(side.designation)))
    if i < sides.len() - 1 { left += ("", align(center)[v.], "") }
  }
  let right = ([Civil Action No. #need(meta, "case_number")], "", strong(upper(inl(need(meta, "brief_title")))))
  if "jury_demand" in meta and meta.jury_demand { right += ("", [(Jury Trial Demanded)]) }
  block(width: 100%, above: blank, below: 0pt, breakable: false, grid(
    columns: (caption-left, 100% - caption-left),
    stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) } else { none },
    pad(right: caption-pad, bottom: caption-below, line-stack(left)),
    pad(left: caption-pad, line-stack(right)),
  ))
}

// ---------------------------------------------------------------------------
// Signature block (NCMD-FIRST-004: telephone, mailing address, e-mail and state bar number)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  for k in ("firm", "signer", "bar_number", "address", "phone", "email", "role") {
    if k not in sig { panic("ncmd-complaint: signature block missing `" + k + "` (LR 7.1(b))") }
  }
  line-stack(([This the #need(meta, "date_line")],), above: blank)
  let lines = (inl(sig.firm), "", [/s/ #sig.signer], inl(sig.signer), inl(sig.bar_number))
  for l in sig.address { lines.push(inl(l)) }
  lines += (inl(sig.phone), inl(sig.email), "", emph(inl(sig.role)))
  block(width: 100%, above: blank, below: 0pt, pad(left: sig-indent, line-stack(lines)))
}

// ---------------------------------------------------------------------------
// Numbered allegations (FRCP 10(b)). Blank-line-separated markdown chunks: a heading, a list or a
// paragraph. A paragraph is numbered unless it lies under a level-1 heading named in
// `unnumbered_sections` (the prayer is not numbered); an unnumbered paragraph has its first line half an inch in.
// ---------------------------------------------------------------------------

#let list-start = regex("^(\\d+\\.|[-*+])[ \\t]")

/// A heading, kept with the block after it, on the body pitch. Level 1 centred bold capitals, a blank line above;
/// level 2 and below bold at the margin.
#let heading-block(level, s) = {
  let body = strong(if level == 1 { upper(unloose(inl(s))) } else { unloose(inl(s)) })
  block(width: 100%, sticky: true, above: if level == 1 { blank } else { 0pt }, below: 0pt,
    if level == 1 { align(center, par(first-line-indent: 0pt, body)) } else { par(first-line-indent: 0pt, body) })
}

/// The list items of a chunk: one per line that starts with a label; a line without one continues the item before.
#let list-items(t) = {
  let items = ()
  for l in t.split("\n").map(l => l.trim()).filter(l => l != "") {
    if l.starts-with(list-start) or items.len() == 0 { items.push(l) } else { items.last() += " " + l }
  }
  items
}

#let list-item(item) = {
  let m = item.match(regex("^(\\d+\\.|[-*+])[ \\t]+"))
  let label = if m.captures.at(0).ends-with(".") { m.captures.at(0) } else { [•] }
  block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent,
    par(first-line-indent: 0pt, hanging-indent: label-box, [#box(width: label-box, label)#unloose(inl(item.slice(m.end)))])))
}

/// The chunks as blocks; `n` the allegations numbered before. Returns (content, n).
#let allegations(chunks, n, unnumbered, numbered) = {
  let out = []
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      let title = t.slice(level).trim()
      if level == 1 { numbered = not (upper(title) in unnumbered) }
      out += heading-block(level, title)
    } else if t.starts-with(list-start) {
      for item in list-items(t) { out += list-item(item) }
    } else {
      let body = if numbered {
        n += 1
        par(first-line-indent: (amount: para-indent, all: true), [#box(width: number-box)[#n.]#unloose(inl(t))])
      } else {
        par(first-line-indent: (amount: para-indent, all: true), unloose(inl(t)))
      }
      // A paragraph that introduces a list ("... that this Court:") stays whole with the list.
      out += if t.ends-with(":") {
        block(width: 100%, above: 0pt, below: 0pt, breakable: false, sticky: true, body)
      } else {
        block(width: 100%, above: 0pt, below: 0pt, body)
      }
    }
  }
  (out, n, numbered)
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let ncmd-complaint(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court", "caption", "brief_title", "date_line", "signature") {
    let _ = need(meta, k)
  }
  let unnumbered = meta.at("unnumbered_sections", default: ()).map(s => upper(s))

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, x: side-margin),
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
    footer-descent: footer-descent,
  )
  set document(title: need(meta, "brief_title") + ", Civil Action No. " + need(meta, "case_number"))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch. Lists are written by allegations() (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: note-gap, clearance: note-clearance, indent: 0pt)
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // ---- cover and caption on the first page ----
  court-title(meta)
  caption(meta)

  // ---- body ----
  // The last chunk (a paragraph, or the whole closing list) stays on the page with the signature block: a signature
  // never starts a page alone. A paragraph that introduces that list is kept with it (allegations()).
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let (main, n, numbered) = allegations(chunks.slice(0, -1), 0, unnumbered, true)
  main
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    allegations(chunks.slice(-1), n, unnumbered, numbered).at(0)
    signature-block(meta)
  })
}
