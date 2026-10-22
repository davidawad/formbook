// Court of Criminal Appeals of Texas: brief on the merits (opening brief).
// Texas Rules of Appellate Procedure 9.4 (form), 9.5 (service), 38.1 and 70.3 (merits brief); see ../README.md.
// Text is 14-point and double-spaced (9.4(d), (e)); footnotes 12-point, and footnotes, block quotations, headings and
// short blocks may be single-spaced (9.4(d)); 1 in margins on letter paper (9.4(b), (c)). The identity page, contents
// and index are numbered in lower-case roman; the body starts at page 1 with the Statement Regarding Oral Argument.
// Content-agnostic: every case word comes from the sample's frontmatter or body; no coordinates, no forced breaks.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a convention; ../README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // TRAP 9.4(e): a conventional typeface; docs/FONTS.md rule 6
#let type-size = 14pt                 // TRAP 9.4(e): no smaller than 14-point
#let note-size = 12pt                 // TRAP 9.4(e): footnotes no smaller than 12-point
#let title-size = 16pt                // the brief's title on the cover
#let margin = 1in                     // TRAP 9.4(c)
#let para-indent = 0.5in              // first-line indent of every body paragraph (exemplar)
#let row-hang = 0.5in                 // a contents or index entry's second and later lines
#let page-gap = 3.5pt                 // contents and index: a space (0.25 em) between the leader and the page reference
#let footer-descent = 21.6pt          // the page number's line 21.6 pt below the text area (docx footer 686 twips)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/reference.xml sets the same twips, 20 x pt).
#let pitch-body = 32.2pt              // TRAP 9.4(d): double-spaced (Word's double line at 14 pt, 2 x 16.1)
#let pitch-single = 16.1pt            // a single line at 14 pt (1.15 x): cover, headings, identity, contents, index, signatures, page number
#let pitch-title = 18.4pt             // a single line at 16 pt: the cover title
#let pitch-note = 13.8pt              // a single line at 12 pt: footnotes
#let gap = pitch-single               // a blank single line: between identity, signature and certificate blocks, contents and index rows, below a heading
#let head-above = pitch-body          // a body line above a level-1 heading
#let note-gap = 7pt                   // between footnotes
#let note-clearance = 14pt            // the text to the footnote rule

// The body starts here (TRAP 38.1 order; the front matter before it is numbered in roman).
#let body-start = "# Statement Regarding Oral Argument"

// A contents or index entry: one paragraph, "title ..... page". The dots typed in the markdown only mark the entry;
// the template sets its own leader and keeps the page reference in a column of its own.
#let leader-entry = regex("^([^\\n]*?[^\\s.]\\S*)\\s*\\.{4,}\\s*([^\\s.][^\\n]*?)\\s*$")

// The advance of a page reference in Times New Roman (units of 1/2048 em, the font's own; the docx filter keeps the
// same table, so both engines give a row the same page column). Kerning is off (xengine).
#let advances = (
  "0": 1024, "1": 1024, "2": 1024, "3": 1024, "4": 1024, "5": 1024, "6": 1024, "7": 1024, "8": 1024, "9": 1024,
  ",": 512, " ": 512, "–": 1024, "-": 682, ".": 512, "i": 569, "v": 1024, "x": 1024, "l": 569, "c": 909,
  "n": 1024, "p": 1024, "a": 909, "s": 797, "m": 1593, "&": 1593,
)
/// The page column of a row: the page reference's width rounded up to a whole twip, plus page-gap (70 twips).
#let page-col(page) = {
  let units = page.clusters().map(c => advances.at(c, default: 1024)).sum(default: 0)
  let tw = calc.ceil(units * type-size.pt() * 20 / 2048 - 0.01)
  (tw + calc.round(page-gap.pt() * 20)) / 20 * 1pt
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let md(s) = cmarker.render(s, smart-punctuation: false, raw-typst: false)

/// One block of single lines with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, sticky: false, breakable: true, pitch: pitch-single, body) = block(
  width: 100%, above: above, below: below, sticky: sticky, breakable: breakable, {
    set text(..edges(pitch))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    body
  })

// Footnotes: each definition line "[^n]: text" is taken out of the body, and each reference "[^n]" becomes a token
// that a show rule turns into a footnote with the rendered text.
#let footnote-split(body) = {
  let defs = (:)
  let kept = ()
  for line in body.split("\n") {
    let m = line.match(regex("^\\[\\^([0-9A-Za-z]+)\\]:\\s*(.*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1)) } else { kept.push(line) }
  }
  let text = kept.join("\n").replace(regex("\\[\\^([0-9A-Za-z]+)\\]"), m => "ZQFN" + m.captures.at(0) + "ZQ")
  (text, defs)
}

/// The blocks of one part (front matter or body), one blank-line-separated chunk at a time:
///   * a heading: level 1 centered bold capitals, level 2 bold, level 3 italic; single lines, kept with what
///     follows; in the front matter every level-1 heading but the first opens a page;
///   * a contents or index entry ("title ..... page"): a listing row;
///   * a single-spaced block (a hard line break, as in the identity, signature and certificate blocks, or a
///     paragraph that opens with a bold label): single lines, a blank single line above, kept whole; in the body a
///     run of them is kept together (a signature never splits);
///   * anything else (paragraphs, lists): double-spaced, every paragraph indented half an inch.
#let render-part(chunks, front: false) = {
  let chunks = chunks.map(c => c.trim()).filter(c => c != "")
  let single(c) = c.contains("\\\n") or c.starts-with("**")
  for (i, c) in chunks.enumerate() {
    let next = chunks.at(i + 1, default: none)
    let hd = c.match(regex("^(#{1,6})[ \\t]+([\\s\\S]*)$"))
    let row = c.match(leader-entry)
    if hd != none {
      let level = hd.captures.at(0).len()
      let txt = md(hd.captures.at(1))
      if level == 1 {
        if front and i > 0 { pagebreak(weak: true) }
        line-block(above: head-above, below: gap, sticky: true, align(center, strong(upper(txt))))
      } else if level == 2 {
        line-block(above: gap, below: gap, sticky: true, strong(txt))
      } else {
        line-block(above: gap, below: gap, sticky: true, emph(txt))
      }
    } else if row != none and not c.contains("\n") {
      let (title, page) = row.captures
      { set text(..edges(pitch-single)); listing-row(none, md(title), page, page-col(page), row-hang, gap) }
    } else if single(c) {
      line-block(above: gap, below: gap, breakable: false,
        sticky: not front and next != none and single(next), md(c))
    } else {
      // a lone paragraph is inline content to typst: set it as a paragraph, so that it takes the first-line indent
      let plain = not c.starts-with(regex("(\\d+[.)]|[-*+>])[ \\t]"))
      block(width: 100%, above: 0pt, below: 0pt, if plain { par(md(c)) } else { md(c) })
    }
  }
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let opening-brief(source) = {
  let fm = source.match(regex("^---\\r?\\n([\\s\\S]*?)\\r?\\n---[ \\t]*\\r?\\n"))
  if fm == none { panic("opening brief sample requires YAML frontmatter") }
  let meta = yaml(bytes(fm.captures.at(0)))
  let body = source.slice(fm.end)
  let required = ("case_number", "style_petitioner", "style_respondent", "filing_party", "brief_title", "appeal_from", "lead_counsel", "counsel_lines")
  for key in required { if key not in meta { panic("opening brief sample missing frontmatter field: " + key) } }
  set document(title: meta.brief_title, author: meta.filing_party)
  // The page number centered in a single line box (Word's footer); the cover has none.
  set page(paper: "us-letter", margin: margin, footer-descent: footer-descent,
    footer: context if page.numbering != none {
      align(center, text(..edges(pitch-single), counter(page).display(page.numbering)))
    })
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number, no break inside "44.2(a)(1)".
  show: xengine.with(pitch: pitch-body, list-indent: para-indent)
  // A doubled sign stays with its number ("§§ 13"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Footnotes: 12 pt in single lines, the mark and a space before the text (Word's footnote layout), 7 pt apart,
  // under a 30 % rule.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num) #note.body]
  }

  // The cover (TRAP 9.4(g)): case number, court, parties, the court below, title, filing party, counsel, date;
  // centered single lines, unnumbered.
  {
    set align(center)
    v(28.8pt)
    line-block(strong(meta.case_number))
    line-block(above: 14.4pt, strong("IN THE COURT OF CRIMINAL APPEALS OF TEXAS"))
    line-block(above: 21.6pt, strong(meta.style_petitioner))
    line-block(above: 6pt, [v.])
    line-block(above: 6pt, strong(meta.style_respondent))
    line-block(above: 14.4pt, meta.appeal_from)
    line-block(above: 23pt, pitch: pitch-title, text(size: title-size, weight: "bold", upper(meta.brief_title)))
    line-block(above: 25.2pt, meta.filing_party)
    line-block(above: 9pt, meta.lead_counsel)
    for l in meta.counsel_lines { line-block(l) }
    if "filed_date" in meta { line-block(above: 18pt, meta.filed_date) }
  }

  let (text, defs) = footnote-split(body)
  show regex("ZQFN[0-9A-Za-z]+ZQ"): it => footnote(md(defs.at(it.text.slice(4, -2))))
  let chunks = text.split(regex("\\r?\\n[ \\t]*\\r?\\n"))
  let start = chunks.position(b => b.trim().starts-with(body-start))
  if start == none { panic("opening brief sample must contain the heading: " + body-start) }

  // front matter (identity, contents, index) in roman numerals, then the body from page 1
  pagebreak()
  set page(numbering: "i")
  counter(page).update(1)
  render-part(chunks.slice(0, start), front: true)
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  render-part(chunks.slice(start))
}
