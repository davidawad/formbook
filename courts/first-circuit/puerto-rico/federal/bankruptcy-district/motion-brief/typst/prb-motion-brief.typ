// Motion brief (memorandum of law in support of a motion) for the United States Bankruptcy Court for the
// District of Puerto Rico (prb). Rules (see ../README.md): LBR 9013-2(a) (supporting memorandum with points and
// authorities, citing the Code, the Rules, the LBRs and controlling authority), LBR 9013-1(c)(1) (response-time
// NOTICE, at least 11 point, in single or double space), LBR 9013-1(c)(2) (14, 21 or 30 day periods),
// LBR 1005-1(a) (case name, number, judge's initials and chapter on every paper), 1005-1(b) (8 1/2 x 11 inch pdf),
// 1005-1(c) (signature block), LBR 9013-3(a) (certificate of service); L.Cv.R. 7(e) through LBR 1001-1(b) (12 point,
// double spacing, page numbers at the bottom center; ../rules.md, Finding 2). Not generated: the notice of motion,
// certifications, proposed order and the certificate of service's list of parties (separate papers or
// frontmatter, see README.md).
// Content-agnostic: every case-specific word comes from the sample's frontmatter and body, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no typeface rule (../rules.md, Finding 3); Times New Roman, the house default and the face of the Oriental Bank exemplar (docs/FONTS.md); Liberation Serif its metric twin
#let type-size = 12pt                   // L.Cv.R. 7(e) via LBR 1001-1(b): no less than 12 points; LBR 9013-1(c)(1): the notice at least 11
#let margin = 1in                       // convention (the exemplar has one-inch margins)
#let para-indent = 0.5in                // first-line indent of body paragraphs; quotations stand this far in on both sides
#let caption-left = 3.4in               // width of the left (parties) column of the caption
#let caption-gutter = 0.2in             // between the parties column and the case-number column
#let caption-pad = 10pt                 // the parties' text stands off the column's right and bottom rules
#let right-pad = 0.15in                 // the case-number column's text stands in from its left
#let sig-indent = 3in                   // the signer's lines stand this far in
#let rule = 0.75pt
#let response-periods = (14, 21, 30)    // LBR 9013-1(c)(1) and (c)(2): days allowed to respond

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // double spacing (L.Cv.R. 7(e)): two 12 pt lines
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let half-gap = pitch-single / 2        // around the rule between the debtor and the parties
#let quote-gap = pitch-double / 2       // above and below a quotation
#let note-gap = 7pt                     // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 7.5pt            // from the text to the footnote rule: with note-gap, the space LibreOffice keeps above its separator (7 to 8 pt set every page as the docx; 5 and 8.5 do not)

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

/// One single-spaced line block (a paragraph of its own), with explicit space above it; `ruled`: a rule below it.
#let line-block(above: 0pt, indent: 0pt, ruled: false, body) = block(width: 100%, above: above, below: 0pt,
  stroke: if ruled { (bottom: rule) } else { none }, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(left: indent, body)
  })

/// A body paragraph at the double pitch, the first line half an inch in.
#let body-par(c) = block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), c))

// ---------------------------------------------------------------------------
// Caption: court, debtor, parties, case number, chapter, adversary number, title
// ---------------------------------------------------------------------------

#let court-title(meta) = for l in meta.court { line-block(align(center, strong(upper(inl(l))))) }

#let caption(meta) = {
  assert("bankruptcy_case" in meta, message: "prb-motion-brief: LBR 1005-1(a) requires the bankruptcy case number and judge's initials in the frontmatter (bankruptcy_case)")
  assert("chapter" in meta, message: "prb-motion-brief: LBR 1005-1(a) requires the chapter in the frontmatter (chapter)")
  // An adversary number that is not yet assigned prints as a blank to fill in.
  let adv = meta.at("adversary", default: "")
  block(above: pitch-double, below: 0pt, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    // "In re:" and the debtor, a rule, then the parties with "v." between them; ruled at the right and below.
    block(width: 100%, stroke: (right: rule, bottom: rule), inset: (right: caption-pad, bottom: caption-pad), {
      line-block[In re:]
      for n in meta.debtor.names { line-block(inl(n)) }
      line-block(ruled: true, inl(meta.debtor.designation))
      for (k, p) in meta.parties.enumerate() {
        if k > 0 { line-block[v.] }
        for (i, n) in p.names.enumerate() { line-block(above: if k == 0 and i == 0 { half-gap } else { 0pt }, inl(n)) }
        line-block(inl(p.designation))
      }
    }),
    pad(left: right-pad, {
      line-block[Bankr. Case No. #inl(meta.bankruptcy_case)]
      line-block(inl(meta.chapter))
      line-block[Adv. Proceeding No. #if adv == "" { "__________" } else { inl(adv) }]
    }),
  ))
}

// ---------------------------------------------------------------------------
// Body: unnumbered paragraphs with footnotes, headings, block quotations
// ---------------------------------------------------------------------------

/// Footnote definitions are `[^n]: text` chunks; they are removed from the body and returned by number.
/// Returns (body without definitions, dictionary of number -> text).
#let split-footnotes(body) = {
  let defs = (:)
  let kept = ()
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")) {
    let m = c.trim().match(regex("^\\[\\^(\\d+)\\]:[ \\t]*([\\s\\S]*)$"))
    if m != none {
      defs.insert(m.captures.at(0), m.captures.at(1).trim())
    } else {
      kept.push(c)
    }
  }
  (kept.join("\n\n"), defs)
}

/// One paragraph's inline markdown. Each `[^n]` marker becomes a typst footnote whose text is definition n.
/// Typst numbers footnotes in order of appearance, so the sample's numbers must run in order too.
#let para-content(t, defs) = {
  let pos = 0
  let out = []
  for m in t.matches(regex("\\[\\^(\\d+)\\]")) {
    let n = m.captures.at(0)
    assert(n in defs, message: "prb-motion-brief: footnote [^" + n + "] has no definition in the sample")
    out += inl(t.slice(pos, m.start))
    out += footnote(inl(defs.at(n)))
    pos = m.end
    // a space after the mark stays (each piece is rendered on its own, which trims it)
    if t.slice(pos).starts-with(regex("\\s")) { out += [ ] }
  }
  out + inl(t.slice(pos))
}

/// Body blocks: each blank-line-separated chunk of markdown is a heading, a block quotation or one paragraph.
/// Paragraphs are not numbered (a memorandum of law, unlike a complaint, does not number its paragraphs).
#let body-blocks(body, defs) = {
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") or t.starts-with(">") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else {
      body-par(para-content(t, defs))
    }
  }
}

// ---------------------------------------------------------------------------
// Notice of response time (LBR 9013-1(c)), certificate of service (LBR 9013-3(a)), signature (LBR 1005-1(c))
// ---------------------------------------------------------------------------

/// LBR 9013-1(c)(1): the notice is required on an initial motion and may be single or double spaced, in at
/// least 11 point type. The period is 14 days unless (c)(2) substitutes another; the text follows the rule.
#let response-notice(meta) = {
  let days = meta.at("response_days", default: 14)
  assert(days in response-periods, message: "prb-motion-brief: LBR 9013-1(c)(2) gives a response period of 14, 21 or 30 days (response_days)")
  let words = (
    "14": "fourteen (14)",
    "21": "twenty-one (21)",
    "30": "thirty (30)",
  ).at(str(days))
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    line-block(align(center, strong[NOTICE]))
    line-block(above: pitch-single)[Within #words days after service as evidenced by the certification, and an additional three (3) days pursuant to Fed. R. Bank. P. 9006(f) if you were served by mail, any party against whom this paper has been served, or any other party to the action who objects to the relief sought herein, shall serve and file an objection or other appropriate response to this paper with the clerk’s office of the United States Bankruptcy Court for the District of Puerto Rico. If no objection or other response is filed within the time allowed herein, the paper will be deemed unopposed and may be granted unless: (i) the requested relief is forbidden by law; (ii) the requested relief is against public policy; or (iii) in the opinion of the court, the interest of justice requires otherwise.]
  })
}

#let certificate-of-service(meta) = if "certificate" in meta {
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt,
    par(first-line-indent: 0pt)[#strong[CERTIFICATE OF SERVICE:] #inl(meta.certificate)])
}

#let signature-block(meta) = {
  assert("signature" in meta, message: "prb-motion-brief: the frontmatter needs a signature block (LBR 1005-1(c))")
  assert("signer" in meta.signature, message: "prb-motion-brief: the signature block needs the signer's name (LBR 5005-4(b)(2)(C)(ii): /s/ name)")
  block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
    line-block[Respectfully submitted,]
    line-block(above: pitch-single, inl(meta.signature.date))
    line-block(above: pitch-single, indent: sig-indent)[/s/ #inl(meta.signature.signer)]
    for l in meta.signature.lines { line-block(indent: sig-indent, inl(l)) }
  })
}

#let prb-motion-brief(meta, body) = {
  // Page numbers centered at the foot of every page (L.Cv.R. 7(e): preferably at the bottom center), in a single
  // line box, so the number sits at the same place on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-double)
  // A doubled section sign stays with its number ("§§ 1391"; the docx filter binds it with a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at the text size (the exemplar's), single lines, under a 30 % rule, 7 pt between notes; the mark and
  // a space before the text (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  // Quotations single-spaced, half an inch in on both sides, half a double line off the text.
  show quote.where(block: true): it => block(width: 100%, above: quote-gap, below: quote-gap, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(x: para-indent, it.body)
  })
  // Headings at the body size and pitch, at the margin: level 1 bold capitals, level 2 bold, level 3 bold italic
  // (the exemplar's sub-point). No space of their own; sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { upper(it.body) } else if it.level == 3 { emph(it.body) } else { it.body }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, strong(b))
  }

  court-title(meta)
  caption(meta)
  block(sticky: true, width: 100%, above: pitch-double, below: pitch-single, line-block(align(center, strong(inl(meta.title)))))
  block(sticky: true, width: 100%, above: 0pt, below: 0pt, strong[TO THE HONORABLE COURT:])

  let (text-body, defs) = split-footnotes(body)
  if "lead_in" in meta { body-par(inl(meta.lead_in)) }
  body-blocks(text-body, defs)

  response-notice(meta)
  certificate-of-service(meta)
  signature-block(meta)
}
