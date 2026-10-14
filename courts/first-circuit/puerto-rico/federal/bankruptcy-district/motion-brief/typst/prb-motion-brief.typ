// Motion with memorandum of law for the United States Bankruptcy Court for the District of Puerto Rico (prb).
// Rules (see ../README.md): LBR 1005-1(a) (bankruptcy case name, number, judge's initials and chapter on every
// paper), 1005-1(b) (8 1/2 x 11 inch pdf), LBR 9013-1 (notice of response time: the notice text is at least
// 11 pt; the response period is 14 days plus 3 for mail, per General Order 18-02, not verified against the
// current text), FRBP 9004(b) (caption). Summary judgment in an adversary proceeding is FRBP 7056 (FRCP 56).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // no typeface rule in the PR bankruptcy LBRs; vendored serif (convention)
#let type-size = 12pt                   // convention (the filed exemplar sets 12 pt body text)
#let note-size = 11pt                   // footnotes (convention) and the response-time notice (LBR 9013-1 minimum)
#let page-w = 8.5in                     // LBR 1005-1(b): 8 1/2 x 11 inch
#let page-h = 11in
#let margin = 1in                       // convention (the filed exemplar has one-inch margins)
// Double spacing: EB Garamond's line box is 0.65em, so 1.35em of leading gives a 24 pt baseline pitch at
// 12 pt (measured, README.md). Paragraphs and blocks are separated by the same amount, so every gap between
// blocks is one double-spaced row and the text keeps one rhythm across headings, quotations and paragraphs.
#let body-leading = 1.35em
#let single-leading = 0.5em             // single spacing for the caption, the signature block, quotations and the notice
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.4in               // width of the left (parties) column of the caption
#let text-width = page-w - 2 * margin
#let title-width = 4.5in                // measure of the centered title, so a long title breaks at a phrase (convention)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("prb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for case names, *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split the markdown body into its footnote definitions ("[^n]: text") and the blocks that remain.
#let split-notes(body) = {
  let notes = (:)
  let blocks = ()
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let m = c.trim().match(regex("^\\[\\^(\\d+)\\]:[ \\t]*([\\s\\S]*)$"))
    if m == none { blocks.push(c) } else { notes.insert(m.captures.at(0), m.captures.at(1)) }
  }
  (notes, blocks)
}

/// One markdown fragment without footnotes. cmarker trims the spaces at the edges of a fragment, so a
/// space that sits next to a footnote reference is put back here.
#let frag(s) = {
  if s.trim() == "" { return if s.len() > 0 { [ ] } else { [] } }
  let lead = if s.starts-with(" ") { [ ] } else { [] }
  let trail = if s.ends-with(" ") { [ ] } else { [] }
  lead + inl(s.trim()) + trail
}

/// Inline markdown with footnote references ("[^n]") turned into typst footnotes (cmarker has no
/// footnote syntax, so the fragments on either side of each reference are joined by hand).
#let md-inline(t, notes) = {
  let out = []
  let pos = 0
  for m in t.matches(regex("\\[\\^\\d+\\]")) {
    out += frag(t.slice(pos, m.start))
    let id = m.text.slice(2, -1)
    assert(id in notes, message: "prb-motion-brief: footnote [^" + id + "] has no definition")
    out += footnote(inl(notes.at(id)))
    pos = m.end
  }
  out + frag(t.slice(pos))
}

/// Single-spaced lines, one item per line.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// A heading is kept with the block after it, so it never ends a page.
#let heading-block(c) = block(width: text-width, sticky: true, c)

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number, centered in the footer.
#let footer-number() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Caption: court, debtor, parties, case number, chapter, adversary number, title
// ---------------------------------------------------------------------------

#let court-title(meta) = align(center, stack(
  dir: ttb,
  spacing: single-leading,
  ..meta.court.map(line => text(weight: "bold", upper(line))),
))

#let caption(meta) = {
  assert("bankruptcy_case" in meta, message: "prb-motion-brief: LBR 1005-1(a) requires the bankruptcy case number and judge's initials in the frontmatter (bankruptcy_case)")
  assert("chapter" in meta, message: "prb-motion-brief: LBR 1005-1(a) requires the chapter in the frontmatter (chapter)")
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.2in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
      // "In re:" and the debtor, then a rule, then the parties; "v." between the parties.
      line-stack(("In re:",) + meta.debtor.names + (meta.debtor.designation,))
      v(single-leading)
      line(length: 100%, stroke: 0.75pt)
      v(single-leading)
      let rows = ()
      for (k, p) in meta.parties.enumerate() {
        if k > 0 { rows.push("v.") }
        rows += p.names + (p.designation,)
      }
      line-stack(rows)
    }),
    block(inset: (left: 0.15in), {
      // An adversary number that is not yet assigned prints as a blank to fill in.
      let adv = meta.at("adversary", default: "")
      line-stack((
        "Bankr. Case No. " + meta.bankruptcy_case,
        meta.chapter,
        "Adv. Proceeding No. " + if adv == "" { "__________" } else { adv },
      ))
    }),
  )
}

#let cover(meta) = {
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, block(width: title-width, align(center, text(weight: "bold", inl(meta.title)))))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: headings, first-line-indented paragraphs, block quotations, single-spaced notices
// ---------------------------------------------------------------------------

/// Body text is not numbered (the filed motion practice does not number memorandum paragraphs).
/// Each blank-line-separated chunk of markdown is one block: a heading, a block quotation (">"),
/// a single-spaced passage ("(single) " prefix, used for the notice and the certificate of service),
/// or a double-spaced paragraph with a first-line indent. Paragraphs are breakable on purpose:
/// a long paragraph must be able to run across pages.
#let body-blocks(chunks, notes) = {
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      heading-block(cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
    } else if t.starts-with(">") {
      // Block quotation: indented 0.5 in each side, single spaced, no first-line indent.
      set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
      pad(left: 0.5in, right: 0.5in, cmarker.render(t.replace(regex("(?m)^> ?"), ""), raw-typst: false, smart-punctuation: true, h1-level: 1))
    } else if t.starts-with("(single) ") {
      // Single-spaced inside, but separated from the block before and after by the body spacing.
      set par(leading: single-leading, spacing: body-leading, first-line-indent: 0pt)
      cmarker.render(t.slice(9), raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else {
      set par(first-line-indent: para-indent)
      md-inline(t, notes)
    }
  }
}

#let signature-block(meta) = {
  assert("signature" in meta, message: "prb-motion-brief: the frontmatter needs a signature block")
  assert("signer" in meta.signature, message: "prb-motion-brief: the signature block needs the signer's name (/s/ name)")
  v(body-leading)
  block(breakable: false, width: text-width, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    v(body-leading)
    [#meta.signature.date]
    v(body-leading)
    pad(left: 3.0in, line-stack(("/s/ " + meta.signature.signer,) + meta.signature.lines))
  })
}

#let prb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-number(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  // Footnotes are set smaller than the text (convention; the filed exemplar's notes are smaller than its body).
  show footnote.entry: set text(size: note-size)
  set footnote.entry(separator: line(length: 1in, stroke: 0.5pt))

  // Headings: level 1 is a bold capitals section ("I. INTRODUCTION"); level 2 bold; level 3 bold italic.
  show heading.where(level: 1): it => heading-block(text(size: type-size, weight: "bold", upper(it.body)))
  show heading.where(level: 2): it => heading-block(text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => heading-block(text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)

  block(width: text-width, text(weight: "bold", "TO THE HONORABLE COURT:"))

  if "lead_in" in meta {
    block(width: text-width, {
      set par(first-line-indent: para-indent)
      inl(meta.lead_in)
    })
  }

  let (notes, chunks) = split-notes(body)
  body-blocks(chunks, notes)

  signature-block(meta)
}
