// Complaint for the U.S. District Court for the Eastern District of Texas (txed).
// Rules: Local Rule CV-10(a) (style and number, caption with party designation, double spacing,
// 12-point minimum type, 8 1/2 x 11 paper), CV-7(a) (separate document, searchable PDF), CV-4(c) (party
// names in the caption), CV-38(a) (a jury demand in a pleading: "jury" immediately below the case number);
// Fed. R. Civ. P. 10(a) (caption) and 10(b) (numbered paragraphs). See ../README.md and ../../rules.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // vendored in fonts/; no face in the rules, the exemplars' face
#let type-size = 12pt              // CV-10(a)(5): no smaller than 12-point (footnotes and page number too)
#let page-w = 8.5in                // CV-10(a)(4): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in
#let indent = 0.5in                // first-line indent of the body; the paragraph number's box after it
#let caption-right = 2.6in         // width of the right-hand column of the caption (case number, jury demand)
#let caption-gutter = 0.25in
#let designation-indent = 1.5in    // the party's designation in the party column
#let signature-indent = 3in        // the signature block stands at the right half of the page
#let note-gap = 6pt                // between two footnotes
#let note-clearance = 7.8pt        // between the text and the footnote rule: with note-gap, Word's separator line (13.8 pt)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt         // a single line: 1.15 x the type size; court title, caption, signature, footnotes
#let pitch-double = 2 * pitch-single // CV-10(a)(5): double spaced (27.6 pt, the exemplar's pitch)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txed-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let sline(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

// ---------------------------------------------------------------------------
// Cover: court (line 1 onward), caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(lines) = for l in lines {
  sline(align(center, text(weight: "bold", upper(l))))
}

/// Parties on the left ("v." between them, each designation indented); the case number and the jury demand at the
/// foot of the right column (CV-38(a): "jury" immediately below the case number), a double line below the court.
#let caption(meta) = block(width: 100%, above: pitch-double, below: 0pt, grid(
  columns: (1fr, caption-right),
  column-gutter: caption-gutter,
  {
    for (k, p) in meta.caption.enumerate() {
      if k > 0 { sline[v.] }
      for n in p.names { sline(inl(n)) }
      sline(indent: designation-indent, inl(p.designation))
    }
  },
  align(bottom, {
    sline(inl(meta.case_number))
    if "jury_demand" in meta { sline(above: pitch-single, text(weight: "bold", meta.jury_demand)) }
  }),
))

/// The title of the paper: bold capitals, centered, a double line below the caption; the text follows on its grid.
#let title-of-paper(meta) = block(width: 100%, above: pitch-double, below: 0pt, sticky: true,
  sline(align(center, text(weight: "bold", upper(meta.brief_title)))))

// ---------------------------------------------------------------------------
// Signature block (CV-10(a)(3): signed by the lead attorney or with his or her permission), single spaced at the
// right half of the page, a double line below the text; it never breaks across a page.
// ---------------------------------------------------------------------------

#let signature(sig) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  sline(indent: signature-indent)[Respectfully submitted,]
  for (i, l) in sig.firm.enumerate() { sline(above: if i == 0 { pitch-single } else { 0pt }, indent: signature-indent, inl(l)) }
  sline(above: pitch-single, indent: signature-indent)[/s/ #sig.signer]
  sline(indent: signature-indent, inl(sig.signer))
  for l in sig.lines { sline(indent: signature-indent, inl(l)) }
  sline(above: pitch-single, indent: signature-indent, inl(sig.role))
})

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lettered prayer items
// ---------------------------------------------------------------------------

/// Level-1 headings are sections: at the body pitch, centered, bold, capitals, numbered I., II., ... by the
/// template; sticky, so a heading never ends a page.
#let section-heading(it) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  align(center, text(size: type-size, weight: "bold", [#counter("section").step()#context counter("section").display("I.") #upper(it.body)]))
})

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)): the number in a box of the indent after the first-line indent, the
/// text after it. One counter for the whole pleading; markdown's own numbers are ignored.
#let numbered(items) = for item in items {
  block(width: 100%, above: 0pt, below: 0pt,
    par(first-line-indent: (amount: indent, all: true),
      [#counter("para").step()#box(width: indent, context counter("para").display("1."))#item.body]))
}

/// A lettered list (the prayer): a. at the indent, the text hanging a further half inch. Its last item stays whole
/// with the block after it (the signature block: a signature never stands alone on a page).
#let lettered(items) = for (i, item) in items.enumerate() {
  let last = i == items.len() - 1
  block(width: 100%, above: 0pt, below: 0pt, sticky: last, breakable: not last, pad(left: indent,
    par(first-line-indent: 0pt, hanging-indent: indent, [#box(width: indent, numbering("a.", i + 1))#item.body])))
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let txed-complaint(meta, body) = {
  set document(title: meta.case_number + " " + meta.brief_title)
  // Page numbers centered at the foot, arabic, at the type size (CV-10(a)(5)); the number in a single-spaced line
  // box, so it sits at the same place on every page (Word's footer).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // Every body paragraph is indented, also after a heading or the title (as in the exemplar).
  set par(first-line-indent: (amount: indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (CV-10(a)(5): double spaced).
  show: xengine.with(pitch: pitch-double)
  // A doubled sign stays with its number ("§§ 271"), as in Word (xengine binds one sign only).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  set heading(numbering: none)
  show heading.where(level: 1): it => section-heading(it)
  // Deeper headings (none in the exemplar): bold at the margin, at the body pitch, sticky.
  show heading.where(level: 2).or(heading.where(level: 3)): it => block(width: 100%, above: 0pt, below: 0pt, sticky: true,
    par(first-line-indent: 0pt, text(size: type-size, weight: "bold", it.body)))
  show enum: it => numbered(it.children)
  show list: it => lettered(it.children)
  // Footnotes at the type size (CV-10(a)(5)) in single line boxes: the mark, a space, the note; a 0.5 pt rule a
  // third of the way across.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  court-title(meta.court)
  caption(meta)
  title-of-paper(meta)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)
  signature(meta.signature)
}
