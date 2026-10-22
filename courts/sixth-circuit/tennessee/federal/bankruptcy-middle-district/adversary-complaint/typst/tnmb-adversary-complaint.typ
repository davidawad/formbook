// Adversary complaint for the United States Bankruptcy Court, M.D. Tennessee (tnmb).
// Rules: LBR 5005-3(a) (8 1/2 x 11, 12-point, one-inch margins), 5005-3(b) (page numbers at the bottom with
// room for the CM/ECF footer), 9004-2(a)-(b) (caption: case number, chapter, judge, adversary number, title),
// 7003-1 (adversary cover sheet, filed separately and not produced here); FRBP 7010 (Civil Rule 10 applies,
// so allegations are numbered, Civil Rule 10(b)). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to the filed exemplar; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // no family is named by the rules; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                 // LBR 5005-3(a): clearly legible in 12-point font (footnotes and page number too)
#let margin = 1in                     // LBR 5005-3(a): one-inch margins throughout, 8 1/2 x 11 inch paper
#let footer-descent = 0.6in           // LBR 5005-3(b): the page number low in the bottom margin, clear of the text
#let para-indent = 0.5in              // first-line indent of paragraphs (exemplar)
#let number-box = 0.5in               // an allegation's number in a box at the indent: the text starts 1 in in
#let prayer-box = 0.5in               // a prayer item's letter in a box at the indent, the text hanging after it
#let quote-indent = 0.5in             // block quotations, both sides (exemplar)
#let caption-left = 3.7in             // party column of the caption: a party name must fit one row (README.md)
#let caption-mid = 0.3in              // the ")" column
#let designation-indent = 0.5in       // "Debtor." / "Plaintiff," / "Defendant." under the names (exemplar)
#let sig-indent = 3.25in              // the signature block at the right half (exemplar)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt                // double spacing at 12 pt (exemplar): body, headings and the prayer
#let pitch-single = 13.8pt            // a single line (Word's single line at 12 pt, 1.15 x): court title, caption, title, quotations, signature, footnotes, page number
#let gap = pitch-body / 2             // around a block quotation
#let note-gap = 7pt                   // between footnotes
#let note-clearance = 7pt             // the text to the footnote rule

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tnmb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in *italics*, section symbols, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, right: 0pt, sticky: false, body) = block(width: 100%,
  above: above, below: below, sticky: sticky, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    pad(left: left, right: right, body)
  })

/// A body paragraph: the body pitch, no space of its own (double spacing runs on).
#let body-par(body, indent: true, sticky: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: sticky,
  par(first-line-indent: (amount: if indent { para-indent } else { 0pt }, all: true), body))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (LBR 9004-2)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE MIDDLE DISTRICT OF TENNESSEE")
  if "division" in meta { lines.push(upper(meta.division)) }
  for (i, l) in lines.enumerate() {
    line-block(below: if i == lines.len() - 1 { pitch-body } else { 0pt }, align(center, strong(l)))
  }
}

/// The caption: the debtor and the parties in the left column, a ")" column, and on the right the
/// case number, chapter, judge and adversary number (LBR 9004-2(a)(1), (b)). One single line per row.
#let caption(meta) = {
  let c = meta.caption
  // (text, indent); none is a blank row
  let left = (("IN RE:", 0pt), none)
  for d in c.debtor { left.push((d, 0pt)) }
  left += (("Debtor.", designation-indent), none)
  for (k, p) in c.parties.enumerate() {
    if k > 0 { left += (("v.", 0pt), none) }
    for n in p.names { left.push((n, 0pt)) }
    left += ((p.designation, designation-indent), none)
  }
  let adv = if "adv_proc_no" in meta and meta.adv_proc_no != "" { meta.adv_proc_no } else { "_" * 8 }
  let right = (
    "Case No. " + str(meta.case_number),
    "Chapter " + str(meta.chapter),
    "Judge " + str(meta.judge),
    none,
    "Adv. Proc. No. " + str(adv),
  )
  let n = calc.max(left.len(), right.len())
  let cells = ()
  for i in range(n) {
    let l = left.at(i, default: none)
    let r = right.at(i, default: none)
    cells.push(if l == none { line-block[] } else { line-block(left: l.at(1), inl(l.at(0))) })
    cells.push(line-block[)])
    cells.push(if r == none { line-block[] } else { line-block(inl(r)) })
  }
  block(above: 0pt, below: 0pt, grid(columns: (caption-left, caption-mid, 1fr), ..cells))
}

// ---------------------------------------------------------------------------
// Body: numbered allegations, headings, prayer, quotations, signature
// ---------------------------------------------------------------------------

/// The body, one blank-line-separated chunk at a time:
///  - `#` / `##` / `###` headings (centered underlined / centered / bold italic at the margin), kept with what follows;
///  - a chunk of `1.` items: the prayer, lettered A., B., ... (the letter in a box at the indent, the text hanging);
///  - `>`: a block quotation, single-spaced, indented both sides;
///  - `~ `: an unnumbered paragraph (the marker is dropped), set flush left right after a quotation (its citation);
///    one that starts "WHEREFORE" is kept with the prayer after it;
///  - every other chunk: a numbered allegation (Civil Rule 10(b)); the number is the template's.
/// Footnote definitions ("[^n]: text") go with the chunk that cites them.
#let body-flow(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = (:)
  for c in chunks {
    let key = c.match(regex("^\\[\\^([^\\]]+)\\]:"))
    if key != none { defs.insert(key.captures.at(0), c) }
  }
  let md(t) = {
    let tail = ""
    for (key, d) in defs {
      if t.contains("[^" + key + "]") { tail += "\n\n" + d }
    }
    cmarker.render(t + tail, raw-typst: false, smart-punctuation: true, h1-level: 1)
  }
  let counter-par = counter("tnmb-allegation")
  let after-quote = false
  for t in chunks.filter(c => not c.starts-with("[^")) {
    let is-quote = false
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      // the prayer: one item per "N. " line, lettered
      let items = ()
      for line in t.split(regex("\\r?\\n")) {
        let m = line.match(regex("^\\d+\\.[ \\t]+(.*)$"))
        if m != none { items.push(m.captures.at(0)) } else { items.at(-1) += " " + line.trim() }
      }
      for (i, it) in items.enumerate() {
        block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true),
          hanging-indent: para-indent + prayer-box, [#box(width: prayer-box, numbering("A.", i + 1))#md(it)]))
      }
    } else if t.starts-with(">") {
      is-quote = true
      block(width: 100%, above: gap, below: gap, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        show quote.where(block: true): it => it.body
        pad(left: quote-indent, right: quote-indent, md(t))
      })
    } else if t.starts-with("~ ") {
      let s = t.slice("~ ".len())
      body-par(md(s), indent: not after-quote, sticky: s.starts-with("WHEREFORE"))
    } else {
      counter-par.step()
      body-par[#box(width: number-box, context counter-par.display("1."))#md(t)]
    }
    after-quote = is-quote
  }
}

/// "Respectfully submitted," and the signer's lines at the right half, a blank single line between; kept together.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-single, below: 0pt, {
  line-block(left: sig-indent)[Respectfully submitted,]
  for (i, l) in meta.signature.enumerate() {
    line-block(above: if i == 0 { pitch-single } else { 0pt }, left: sig-indent, inl(l))
  }
})

#let tnmb-adversary-complaint(meta, body) = {
  // LBR 5005-3(b): every page numbered at the bottom, centered, in a single line box (Word's footer).
  set page(paper: "us-letter", margin: margin, footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body)
  // A doubled sign stays with its number ("§§ 541"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Footnotes: 12 pt (LBR 5005-3(a)), single-spaced; the mark, a space, the note (Word's footnote layout).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num) #note.body]
  }

  // Headings in the body's double-spaced line, kept with the text after them: level 1 centered and underlined,
  // level 2 centered (as filed), level 3 bold italic at the margin.
  show heading: it => block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set text(size: type-size, weight: "regular")
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, underline(upper(it.body))) }
    else if it.level == 2 { align(center, it.body) }
    else { strong(emph(it.body)) }
  })

  court-title(meta)
  caption(meta)
  for (i, l) in meta.title.enumerate() {
    line-block(above: if i == 0 { pitch-body } else { 0pt }, below: if i == meta.title.len() - 1 { pitch-body } else { 0pt },
      align(center, strong(underline(upper(l)))))
  }

  body-flow(body)

  signature-block(meta)
}
