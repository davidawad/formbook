// Adversary complaint for the U.S. Bankruptcy Court, S.D.N.Y. (nysb).
// Rules: Fed. R. Bankr. P. 7010 (Fed. R. Civ. P. 10 applies; the caption substantially conforms to Official Form 416D);
// Fed. R. Civ. P. 10(a) (caption) and 10(b) (numbered paragraphs); Fed. R. Bankr. P. 9004(a) (legible) and (b) (caption);
// Local Bankruptcy Rule 9004-1(a) (typed, not bound or stapled; attorney name, office address and telephone on the face).
// See ../README.md for the rule text, the verification date and the measured exemplar values.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule, the exemplar, or a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF NEW YORK")  // Form 416D; Fed. R. Bankr. P. 9004(b)
#let font-family = ("Times New Roman", "Liberation Serif")  // Times New Roman (vendored, docs/FONTS.md), as both exemplars are set; no font rule in LBR 9004-1 (README.md)
#let type-size = 12pt                   // exemplar: 12 pt (measured), text, headings and footnotes alike; LBR 9004-1 is adapted from Civil Rule 11.1 (README.md)
#let margin = 1in                       // exemplar margins: 72 pt on all sides (measured)
#let page-w = 8.5in
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in                // first-line indent of every body paragraph; a paragraph number starts here
#let number-box = 0.5in                 // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let letter-box = 0.5in                 // a heading letter's box, and a list label's box after the indent
#let caption-left = 3.35in              // width of the party column of the caption (Form 416D: parties left, case data right)
#let caption-gutter = 0.2in             // between the party column and the case-data column
#let caption-inset = 0.15in             // the party text stands off the column's right rule, the rule below it off the text,
                                        // and the case data off the gutter
#let sig-left = 2.8in                   // signature: the "Dated" column, a gutter, the signature column
#let sig-gutter = 0.2in
#let note-gap = 7pt                     // between footnotes (docx: Footnote Text 140 twips after)
#let note-clearance = 10pt              // between the body and the footnote rule: where LibreOffice's separator leaves the body

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/nysb-adversary-complaint.lua and
// docx/reference.xml set the same twips: 20 x pt).
#let pitch-single = 13.8pt              // single spacing: counsel, court, caption, title, signature, footnotes (exemplar: 13.8 pt)
#let pitch-body = 2 * pitch-single      // double spacing: body text, headings, list items (the exemplar's pitch, 27.6 pt)
#let group-gap = pitch-single / 2       // between two counsel groups, and before "counsel for"
#let block-gap = pitch-single           // a blank single line: counsel to the court, the court to the caption
#let party-gap = pitch-single / 2       // between the parties of the caption, and around "against"
#let title-above = pitch-single         // the caption to the title (a blank single line)
#let sig-above = pitch-body             // the last paragraph to the signature block (a blank double line)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nysb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, smart quotes, and the like).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-pitch line (a paragraph of its own), with an explicit space above it. No overhang: a line set against the
/// right edge ends at it, its final period included, as Word ends it.
#let sline(above: 0pt, align-to: left, it) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single), overhang: false)
  set align(align-to)
  par(first-line-indent: 0pt, it)
})

/// Footnote definitions in the body ("[^key]: text" in its own chunk), keyed by the key.
#let footnote-defs(body) = {
  let defs = (:)
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")) {
    let m = c.trim().match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*([\\s\\S]*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1)) }
  }
  defs
}

/// Markdown inline text, with each "[^key]" mark replaced by a typst footnote of the definition.
/// A piece that starts with a space keeps it (the markdown renderer trims it), so the word after a mark is spaced.
#let text-piece(s) = {
  let lead = if s.starts-with(regex("\\s")) { " " } else { "" }
  lead + inl(s)
}
#let with-footnotes(t, defs) = {
  let refs = t.matches(regex("\\[\\^([^\\]]+)\\]"))
  if refs.len() == 0 { return inl(t) }
  let out = []
  let pos = 0
  for r in refs {
    out += text-piece(t.slice(pos, r.start))
    out += footnote(inl(defs.at(r.captures.at(0))))
    pos = r.end
  }
  out + text-piece(t.slice(pos))
}

// ---------------------------------------------------------------------------
// Cover: counsel (LBR 9004-1(a)(4)), court name, caption (Form 416D), title
// ---------------------------------------------------------------------------

#let counsel-block(meta) = {
  for (k, g) in meta.counsel.enumerate() {
    for (i, l) in g.enumerate() { sline(above: if k > 0 and i == 0 { group-gap } else { 0pt }, inl(l)) }
  }
  if "counsel_for" in meta { sline(above: group-gap, emph(inl(meta.counsel_for))) }
}

#let court-title() = {
  sline(above: block-gap, align-to: center, strong(court-name.at(0)))
  sline(align-to: center, strong(court-name.at(1)))
}

/// One party: its names, then its designation against the right edge of the column. An optional `note` (the
/// debtors' tax-identification note, as in the exemplar) is a footnote on the last name, marked "*" (the body's notes
/// are numbered from 1; docx: the cover's footer).
#let party(p, above) = {
  let names = p.names.map(n => inl(n))
  if "note" in p and p.note != none {
    let k = names.len() - 1
    names.at(k) = names.at(k) + footnote(numbering: "*", inl(p.note))
  }
  for (i, n) in names.enumerate() { sline(above: if i == 0 { above } else { 0pt }, n) }
  sline(align-to: right, inl(p.designation))
}

#let caption(meta) = block(width: 100%, above: block-gap, below: 0pt, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-inset), {
    // The debtors, then the plaintiffs, then "against" (or the frontmatter's separator), then the defendants (Form 416D).
    party(meta.caption.debtors, 0pt)
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { sline(above: party-gap, align-to: center, inl(meta.caption.at("separator", default: "against"))) }
      party(p, party-gap)
    }
  }),
  pad(left: caption-inset, {
    sline[Chapter #meta.chapter]
    sline(above: block-gap)[Case No. #meta.case_number]
    if "jointly_administered" in meta and meta.jointly_administered { sline[(Jointly Administered)] }
    sline(above: block-gap)[Adv. Pro. No. #meta.adv_proc_no]
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title()
  caption(meta)
  sline(above: title-above, align-to: center, strong(inl(meta.title)))
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// A body paragraph at the body pitch: unnumbered (first-line indent), or numbered (Fed. R. Civ. P. 10(b)): the
/// indent, the number in its box, the text. `last`: the paragraph before the signature, kept whole and on the page of
/// the signature (a signature never starts a page alone). A paragraph stands straight in the flow, so that typst
/// moves a line with its footnote to the next page, as Word does (inside a block it moves the note alone).
#let body-par(num, content, last: false) = {
  let p = par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: number-box, [#num.])#content] })
  if last { block(width: 100%, above: 0pt, below: 0pt, sticky: true, breakable: false, p) } else { p }
}

/// A list item (the prayer's relief): its label "(a)" (or a bullet) in a box after the indent, the text hanging after it.
#let list-item(label, content, last: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: last, breakable: not last,
  par(first-line-indent: 0pt, hanging-indent: para-indent + letter-box,
    [#h(para-indent)#box(width: letter-box, label)#content]))

/// Headings on the body pitch, kept with the text after them (a heading never ends a page): level 1 centered bold
/// capitals, level 2 bold with its letter (A., B., ...) in a box, the title hanging after it.
#let heading-block(level, label, content) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  if level == 1 { align(center, par(first-line-indent: 0pt, strong(upper(content)))) }
  else { par(first-line-indent: 0pt, hanging-indent: letter-box, strong[#box(width: letter-box, label)#content]) }
})

/// The items of a markdown list chunk, one string per item (a continuation line belongs to the item above it).
#let list-items(t) = {
  let items = ()
  for line in t.split("\n") {
    let m = line.match(regex("^\\s*(\\d+\\.|[-*+])\\s+"))
    if items.len() == 0 or m != none {
      items.push(if m == none { line } else { line.slice(m.end) })
    } else {
      let k = items.len() - 1
      items.at(k) = items.at(k) + "\n" + line
    }
  }
  items
}

/// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither a
/// heading nor a list is one numbered paragraph; a chunk marked "^" is not numbered; headings and lists are not
/// numbered (list items are lettered (a), (b), ...); footnote definitions are not paragraphs. The last paragraph or
/// list item is kept with the signature block.
#let allegations(body) = {
  let defs = footnote-defs(body)
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim())
    .filter(c => c != "" and not c.starts-with(regex("^\\[\\^[^\\]]+\\]:")))
  let n = 0
  let sub = 0
  for (i, t) in chunks.enumerate() {
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      let m = t.match(regex("^(#+)[ \\t]+([\\s\\S]*)$"))
      let level = calc.min(m.captures.at(0).len(), 2)
      if level == 1 { sub = 0 } else { sub += 1 }
      heading-block(level, numbering("A.", calc.max(sub, 1)), inl(m.captures.at(1)))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      let ordered = t.starts-with(regex("^\\d+\\."))
      let items = list-items(t)
      for (k, item) in items.enumerate() {
        list-item(if ordered { numbering("(a)", k + 1) } else { [•] }, with-footnotes(item, defs),
          last: last and k == items.len() - 1)
      }
    } else if t.starts-with("^") {
      body-par(none, with-footnotes(t.slice(1).trim(), defs), last: last)
    } else {
      n += 1
      body-par(n, with-footnotes(t, defs), last: last)
    }
  }
}

/// Signature block: "Dated:" at the left; the firm, "By: /s/" and the signer's lines at the right, single-spaced.
/// It never breaks across a page.
#let signature-block(meta) = block(width: 100%, breakable: false, above: sig-above, below: 0pt, grid(
  columns: (sig-left, 1fr),
  column-gutter: sig-gutter,
  sline[Dated: #inl(meta.date)],
  {
    for l in meta.signature.firm { sline(inl(l)) }
    sline(above: block-gap, inl("By: /s/ " + meta.signature.signer))
    sline(inl(meta.signature.signer))
    for l in meta.signature.lines { sline(inl(l)) }
  },
))

#let nysb-adversary-complaint(meta, body) = {
  // The cover carries no page number; the body is numbered from 1 after it, centered in a single-pitch line box
  // (docx: footer distance 735 twips, where typst sets it with footer-descent 30 %).
  set page(paper: "us-letter", margin: margin, footer-descent: 30%, footer: none)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 544"; xengine binds one sign): Word does not break between them either.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  // Footnotes at the type size in single-pitch lines (as the exemplar sets them): the mark, a space, the note; the
  // rule as long as Word's separator in LibreOffice (30 % of the measure).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)   // the entry does not inherit the body's leading
    [#super(num)#h(0.25em)#note.body]
  }

  cover(meta)
  pagebreak()

  set page(footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  counter(page).update(1)
  // The body numbers its footnotes from 1 (the cover's note is marked "*"; Gate 0 reads the body's notes as 1, 2, ...).
  counter(footnote).update(0)
  allegations(body)
  signature-block(meta)
}
