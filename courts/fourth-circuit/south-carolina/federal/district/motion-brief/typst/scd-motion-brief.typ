// D.S.C. memorandum in support of a motion (FRCP 12(b)). Rules: FRCP 7(b), 10(a)-(b); D.S.C. Local
// Civ. Rule 1.05 (format of filed motions and supporting memoranda); Local Civ. Rule 7.05(A)-(B)
// (contents; 35 double-spaced pages for an initial brief). Content-agnostic: everything case-specific
// comes from the sample's frontmatter and body.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Rule parameters
// ---------------------------------------------------------------------------
// L.R. 1.05(B) requires Times New Roman, Arial or Courier New. Times New Roman is the face used here;
// its vendored metric-compatible substitute is Liberation Serif (docs/FONTS.md, substitution table).
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 12pt                 // L.R. 1.05(C): minimum 12-point type, caption, text and footnotes alike
#let margin = 1in                     // L.R. 1.05(A): minimum one-inch margins
#let text-width = 8.5in - 2 * margin
#let para-indent = 0.5in              // first-line indent of every body paragraph
#let quote-indent = 0.5in             // an indented quotation, both sides
#let party-step = 0.5in               // a caption party line's indent per level (the frontmatter's `indent`)
#let paren-w = 0.3in                  // the caption's column of ")" marks ...
#let case-w = 2.6in                   // ... and the case number column at its right
#let sig-w = 3.2in                    // the signers' column of the signature block, at the right margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/scd-motion-brief.lua and docx/reference.xml set
// the same twips).
#let pitch-body = 27.6pt              // L.R. 1.05(E): double-spaced text (Word's double spacing of 12 pt Times, the filer's)
#let pitch-single = 13.8pt            // single spaced (L.R. 1.05(E) excepts indented quotations and footnotes): court
                                      // name, caption, title, headings, quotations, footnotes, signature, page number
#let court-below = 18pt               // the court name to the caption
#let row-gap = 10.8pt                 // between two caption party lines
#let title-above = 18pt               // the caption to the title of the paper ...
#let title-below = 14.4pt             // ... and the title to the text
#let heading-above = 14.4pt           // a section heading (levels 1 and 2): the space above it ...
#let heading-below = 10.8pt           // ... and below it (every heading level)
#let subheading-above = 12pt          // a subsection heading (level 3): the space above it
#let quote-gap = 12pt                 // above and below an indented quotation
#let sig-above = 18pt                 // the last paragraph to the signature block
#let firm-gap = 7.2pt                 // the signers to the firm lines
#let note-gap = 6pt                   // between two footnotes (docx: Footnote Text 120 twips after)
#let note-clearance = 8pt             // the text to the footnote rule (with typst's 6 pt from the rule to the note, the
                                      // 14 pt LibreOffice keeps)
// L.R. 1.05(D): the page number may sit in the margin. It is centred in a single-spaced line box whose foot is
// 0.5 in above the bottom edge (docx: footer distance 720 twips): 72 - 36 - 13.8 = 22.2 pt below the text.
#let footer-descent = 22.2pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the YAML frontmatter from the markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("scd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, quotations, footnote references with their definitions appended).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Single-spaced lines, one paragraph each; an empty item is a blank line (the next line sits a line lower).
/// `gap`: the space between two lines; `left`: each line's indent (a function of the item's index).
#let line-stack(items, gap: 0pt, left: i => 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let blank = 0pt
  for (k, t) in items.enumerate() {
    if t == "" { blank += pitch-single } else {
      block(width: 100%, above: if k == 0 { 0pt } else { calc.max(gap, blank) }, below: 0pt,
        pad(left: left(k), unloose(inl(t))))
      blank = 0pt
    }
  }
}

// ---------------------------------------------------------------------------
// Cover: court name, caption, title of the paper
// ---------------------------------------------------------------------------

/// Court heading, centered bold capitals (FRCP 10(a): name of the court).
#let court-heading(meta) = {
  set text(..edges(pitch-single))
  for line in meta.court {
    block(width: 100%, above: 0pt, below: 0pt, align(center, par(first-line-indent: 0pt, strong(upper(line)))))
  }
}

/// Caption (FRCP 10(a)): parties on the left, a column of ")" marks, the case number on the right.
#let caption(meta) = block(width: 100%, above: court-below, below: 0pt, breakable: false, grid(
  columns: (text-width - paren-w - case-w, paren-w, case-w),
  line-stack(meta.parties.map(r => r.text), gap: row-gap, left: k => meta.parties.at(k).indent * party-step),
  {
    set align(center)
    line-stack(meta.parties.map(r => ")"), gap: row-gap)
  },
  line-stack(("CASE NO.: " + meta.case_number,)),
))

/// The title of the paper: centered bold capitals, single spaced.
#let doc-title(meta) = {
  set text(..edges(pitch-single))
  block(width: 100%, above: title-above, below: title-below,
    align(center, par(first-line-indent: 0pt, strong(upper(meta.doc_title)))))
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// The footnote definitions of a text ("[^n]: text"). They are appended to each chunk that refers to them, because
/// cmarker resolves a reference only against the definitions in the same string.
#let footnote-definitions(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c.starts-with("[^")).join("\n\n")

/// Markdown blocks in document order. Each blank-line-separated chunk is one of:
///   `#`/`##` heading: centered bold capitals; `###`: bold at the margin; single spaced, kept with the next block;
///   `>` an indented quotation: single spaced, indented on both sides;
///   `[^n]:` a footnote definition (set with the paragraph that refers to it);
///   anything else: a body paragraph, double spaced, its first line indented.
#let blocks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = footnote-definitions(body)
  let with-notes(t) = t + if t.contains("[^") { "\n\n" + defs } else { "" }
  for t in chunks {
    if t.starts-with("[^") {
    } else if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      // A title that starts "2. " is a heading, not a list item: the period is escaped for the markdown reader.
      let s = t.slice(level).trim().replace(regex("^(\\d+)\\."), m => m.captures.at(0) + "\\.")
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      if level <= 2 {
        block(width: 100%, sticky: true, above: heading-above, below: heading-below,
          align(center, par(strong(upper(unloose(inl(s)))))))
      } else {
        block(width: 100%, sticky: true, above: subheading-above, below: heading-below, par(strong(unloose(inl(s)))))
      }
    } else if t.starts-with(">") {
      set text(..edges(pitch-single))
      block(width: 100%, above: quote-gap, below: quote-gap, pad(x: quote-indent,
        par(first-line-indent: 0pt, unloose(inl(with-notes(t.replace(regex("(?m)^>[ \t]?"), "")))))))
    } else {
      block(width: 100%, above: 0pt, below: 0pt, par(unloose(inl(with-notes(t)))))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block
// ---------------------------------------------------------------------------

/// Signature block: the place and date at the left; the signing attorneys (FRCP 11(a)), then the firm, in a column
/// at the right margin. Single spaced, kept on one page.
#let signature(meta) = block(width: 100%, breakable: false, above: sig-above, below: 0pt, grid(
  columns: (text-width - sig-w, sig-w),
  line-stack((meta.signature.location, meta.signature.dated)),
  {
    line-stack(meta.signature.signers)
    block(above: firm-gap, below: 0pt, line-stack(meta.signature.firm))
  },
))

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let scd-motion-brief(meta, md) = {
  set document(title: meta.doc_title + ", " + meta.case_number)
  // Every page numbered, bottom centre, in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number. No markdown lists reach typst's list
  // layout (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  // Footnotes: 12 pt (L.R. 1.05(C)), single spaced (L.R. 1.05(E)), a short rule above them (docx: Footnote Text).
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: note-gap, clearance: note-clearance, indent: 0pt)
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  court-heading(meta)
  caption(meta)
  doc-title(meta)
  blocks(md)
  signature(meta)
}
