// Memorandum of law for a motion in the United States District Court for the District of Minnesota.
// Rules: D. Minn. LR 5.2(a) (double-spaced, pages numbered at the bottom, case number and judge
// initials on the front page above the title), LR 7.1(f) (12,000-word limit; certificate of
// compliance), LR 7.1(h) (13-point type including footnotes, 8 1/2 by 11 in, text inside 6 1/2 by 9 in).
// Fed. R. Civ. P. 10(a) caption. See ../README.md for the verified rule text and the open choices.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LR 7.1(f)(1)(A): word limit for a proportional font; vendored in fonts/
#let type-size = 13pt                   // LR 7.1(h)(1): at least 13-point, footnotes included
#let page-w = 8.5in                     // LR 7.1(h)(1): 8 1/2 by 11 inches
#let page-h = 11in
#let margin = 1in                       // LR 7.1(h)(1): no text outside 6 1/2 by 9 inches, so 1 inch on every side
#let para-indent = 0.5in                // first-line indent of body paragraphs; headings hang by it
#let quote-indent = 0.5in               // block quotations: indented from both margins
#let caption-left = 3.3in               // the party column of the caption
#let caption-gutter = 0.3in             // between the party column and the file-number column
#let caption-pad = 8pt                  // the party column's rules stand off the text
#let right-inset = 0.1in                // the file-number column stands off the gutter
#let vs-indent = 0.3in                  // "v." in the party column
#let designation-indent = 1.2in         // the party's designation in the party column
#let sig-left = 2.6in                   // signature grid: the "Dated" column, a gutter, the signature column
#let sig-gutter = 0.2in
#let note-gap = 7pt                     // between two footnotes
#let note-clearance = 13pt              // the footnote separator stands this far below the text
#let word-limit = 12000                 // LR 7.1(f)(1)(A)
#let court-lines = ("UNITED STATES DISTRICT COURT", "DISTRICT OF MINNESOTA")  // the court's name, not the case's

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 14.95pt             // a single line: 1.15 x the type size; headings, quotations, footnotes (LR 7.1(h)(1))
#let pitch-double = 2 * pitch-single    // LR 7.1(h)(1): double-spaced (29.9 pt)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mnd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for case names in captions and signature blocks).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

// ---------------------------------------------------------------------------
// Front page: court name, caption (party column, case number and title), no cover page
// ---------------------------------------------------------------------------

#let court-title() = for l in court-lines { line-block(align(center, text(weight: "bold", l))) }

#let caption(meta) = block(above: pitch-double, below: pitch-double, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  // The party column's rules run at the top and foot of the caption row (as a Word table cell's borders do).
  grid.cell(stroke: (top: 0.75pt, bottom: 0.75pt), inset: (top: caption-pad, bottom: caption-pad), {
    // Each party: its names, then its designation, indented; "v." between the parties.
    for (k, p) in meta.caption.enumerate() {
      if k > 0 { line-block(indent: vs-indent, "v.") }
      for n in p.names { line-block(inl(n)) }
      line-block(indent: designation-indent, inl(p.designation))
    }
  }),
  // The court file number level with the first party line (LR 5.2(a)), then the title and the rule line, a single
  // line apart.
  pad(left: right-inset, top: caption-pad, {
    line-block[Court File No. #meta.case_number]
    line-block(above: pitch-single, align(center, text(weight: "bold", upper(meta.brief_title))))
    line-block(above: pitch-single, align(right, inl(meta.rule_line)))
  }),
))

// ---------------------------------------------------------------------------
// Signature and certificate
// ---------------------------------------------------------------------------

/// The date on the left, single-spaced lines on the right ("" a blank line); the block never breaks across a page.
#let dated(date, lines, above) = block(width: 100%, breakable: false, above: above, below: 0pt, grid(
  columns: (sig-left, 1fr),
  column-gutter: sig-gutter,
  line-block[Dated: #date],
  for l in lines { line-block(if l == "" { "\u{00A0}" } else { inl(l) }) },
))

/// Certificate of compliance: its own page; excluded from the word count (LR 7.1(f)(1)(C)(v)).
#let certificate(meta) = {
  assert(int(meta.word_count) <= word-limit, message: "mnd-motion-brief: word_count is over the LR 7.1(f)(1)(A) limit of 12,000")
  pagebreak()
  line-block(below: pitch-single, align(center, text(weight: "bold", "CERTIFICATE OF COMPLIANCE")))
  block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true))[I hereby certify that this memorandum complies with the word limit of D. Minn. LR 7.1(f)(1)(A) and the type-size requirement of D. Minn. LR 7.1(h)(1). The memorandum contains #meta.word_count words, counted with #meta.word_software, which was applied to include all text, including headings, footnotes, and quotations. The count excludes the caption, the signature block, and this certificate (LR 7.1(f)(1)(C)).])
  dated(meta.date, (meta.certificate_signer,), pitch-double)
}

#let mnd-motion-brief(meta, body) = {
  // Page numbers centred at the bottom (LR 5.2(a)); the number in a single-spaced line box, so it sits at the same
  // place on every page (Word's footer).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (LR 7.1(h)(1): double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // A web address breaks only after "?", "=", "&", a hyphen or a slash that no digit (nor a second slash) follows:
  // each part is a box, so the PDF text keeps the author's characters. Without this typst breaks a URL at any
  // character, which Word does not (the docx filter sets the same break points; ca8 briefs).
  show regex("(https?://|www\\.)\\S+"): it => {
    let parts = ("",)
    let cs = it.text.clusters()
    for (i, c) in cs.enumerate() {
      parts.last() += c
      let next = cs.at(i + 1, default: "")
      let prev = cs.at(i - 1, default: "")
      if c in ("?", "=", "&") or (c in ("/", "-") and next != "/" and not (c == "/" and prev == "/")
        and next.match(regex("^[0-9]$")) == none) { parts.push("") }
    }
    parts.filter(p => p != "").map(p => box(p)).join()
  }

  // Headings (LR 7.1(h)(1) lets them be single-spaced): bold, a single line above and below; level 1 centred,
  // level 2 hanging by the paragraph indent, level 3 a further half inch in. Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: if it.level == 1 { 0pt } else { para-indent })
    let b = text(weight: "bold", it.body)
    let b = if it.level == 1 { align(center, b) } else if it.level == 2 { b } else { pad(left: para-indent, b) }
    block(sticky: true, width: 100%, above: pitch-single, below: pitch-single, b)
  }

  // Block quotations longer than two lines: indented from both margins and single-spaced (LR 7.1(h)(1)).
  show quote.where(block: true): it => block(width: 100%, above: pitch-single, below: pitch-single,
    pad(x: quote-indent, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt, spacing: pitch-single)
      it.body
    }))

  // Footnotes are text too: 13-point (LR 7.1(h)(1)), single-spaced, the mark and a space before the note.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)  // the entry does not inherit the body's leading
    [#super(num) #note.body]
  }

  court-title()
  caption(meta)
  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
  dated(meta.date, meta.signature, pitch-double)
  certificate(meta)
}
