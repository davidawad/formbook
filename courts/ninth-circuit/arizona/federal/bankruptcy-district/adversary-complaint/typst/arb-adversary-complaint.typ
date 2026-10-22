// Adversary complaint, United States Bankruptcy Court, District of Arizona (arb).
// Rules: FRBP 7001 (an adversary proceeding is commenced by complaint), 7008(a) (jurisdiction reference
// and a statement of consent to final orders), 7010 (caption substantially conforms to Official Form 416A;
// Fed. R. Civ. P. 10 applies, so allegations are numbered); LRBP 1005-1(a) (court title), LRBP 9004-1
// (a) first-page filer block, (c) dual caption, (e) hearing if known, (g) form of papers, (h) length.
// See ../README.md for the quoted rule text, the date verified and the known gaps.
// Content-agnostic: every case word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let court-title = ("UNITED STATES BANKRUPTCY COURT", "DISTRICT OF ARIZONA")  // LRBP 1005-1(a)
#let font-family = ("Times New Roman", "Liberation Serif")        // proportional, standard; vendored in fonts/ (LRBP 9004-1(g))
#let type-size = 13pt                   // LRBP 9004-1(g): "a proportional font size no smaller than 13 point"
#let footnote-size = 12pt               // LRBP 9004-1(g): footnotes may be 12 point
#let footer-size = 11pt                 // the footer: page number, the paper's title and the adversary number
#let lines-per-page = 27                // LRBP 9004-1(g): no more than 28 lines per page
#let page-h = 11in                      // LRBP 9004-1(g): paper 8 1/2 by 11 inches
#let top-margin = 72pt                  // numbered line 1 sits on the top margin
#let left-margin = 1.5in                // LRBP 9004-1(g): left margin at least 1 1/2 inches
#let right-margin = 1in                 // LRBP 9004-1(g): right margin at least 1/2 inch
#let para-indent = 0.5in                // first-line indent; an allegation's number stands here
#let number-box = 0.5in                 // the allegation number's box: the text starts an inch in
#let item-indent = 0.5in                // relief items: the label half an inch in, the text a box after it
#let caption-left = 3.1in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the party column and the right column
#let caption-inset = 10pt               // the party text stands off the column's right rule
#let right-inset = 0.1in                // the right column's text stands this far in
#let sig-left = 2.6in                   // the signature block: "Dated" left, the signer in a column right of it
#let sig-gutter = 0.2in
#let filer-lines = 7                    // the court title starts on line 8 (convention; LRBP 9004-1(a) only fixes line 1)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch = 24pt                       // LRBP 9004-1(g): double spacing; the numbered lines are this pitch
#let pitch-single = 16pt                // filer block, caption, signature: single-spaced at 13 pt; two thirds of the pitch
#let pitch-note = 13.8pt                // footnotes: single-spaced at 12 pt
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the footer
#let footer-gap = 6pt                   // the footer stands this far below the last numbered line
#let pitch-footer = 13pt                // the footer's lines
#let footer-line-gap = 4pt              // between the page number and the title line
// A run of single lines starts this far below a numbered line, so that every single line's baseline stands on a
// numbered line's baseline or 8 pt off it (0.8 x 24 - 0.8 x 16): never half-way, where the PDF text of the two
// engines would read a line number with another line (their glyph boxes differ in height).
#let single-offset = 6.4pt
#let caption-pad = 9.6pt                // below each caption row: the rows, and the text after them, end on a
                                        // multiple of the single pitch, a numbered line or a third of one off it

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("arb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics for case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

#let need(meta, key) = {
  if key not in meta { panic("arb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One single-spaced line block (a paragraph of its own); `none` is an empty line.
#let line-block(body) = block(width: 100%, above: 0pt, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if body == none { box(height: pitch-single) } else if type(body) == str { inl(body) } else { body }
})

/// A run of single lines, `single-offset` below where it starts.
#let line-run(items, inset: (:)) = block(width: 100%, above: 0pt, below: 0pt,
  inset: (top: single-offset) + inset, for i in items { line-block(i) })

/// One numbered line (the double pitch) of unindented text.
#let grid-line(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set par(first-line-indent: 0pt)
  body
})

/// A body paragraph: double-spaced, first-line indent.
#let body-par(above: 0pt, content) = block(width: 100%, above: above, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

// ---------------------------------------------------------------------------
// Page furniture: pleading paper (LRBP 9004-1(g))
// ---------------------------------------------------------------------------

/// Numbers 1 to 27 down the left margin, one per numbered line, each in a line box of the pitch.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.42in, height: pitch,
        align(right, text(size: type-size, ..edges(pitch), str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: 8.5in - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// Footer in the bottom margin: the page number, then the paper's title left and the adversary number right.
#let footer-block(meta) = {
  set text(size: footer-size, ..edges(pitch-footer))
  set par(first-line-indent: 0pt)
  block(width: 100%, above: 0pt, below: 0pt, align(center, context counter(page).display("1")))
  let adv = str(need(meta, "adversary_number"))
  block(width: 100%, above: footer-line-gap, below: 0pt, grid(
    columns: (1fr, auto),
    upper(need(meta, "footer_title")),
    if adv != "" { [ADV. NO. #adv] } else { [] },
  ))
}

// ---------------------------------------------------------------------------
// First page: filer block (line 1), court title, dual caption (LRBP 9004-1(a), (c), (e); FRBP 7010)
// ---------------------------------------------------------------------------

/// Filer block from line 1: counsel, firm, address, email, State Bar number, telephone and the party
/// represented (LRBP 9004-1(a)). Occupies at least `filer-lines` numbered lines (counted from its lines, as the
/// Word filter counts them); longer blocks push the court title down (the rule gives no line for the title).
#let filer-block(meta) = {
  let items = need(meta, "filer")
  line-run(items)
  let used = single-offset + items.len() * pitch-single
  v(calc.max(filer-lines, calc.ceil(used / pitch)) * pitch - used, weak: false)
}

#let court-title-block() = for l in court-title { grid-line(align(center, strong(l))) }

/// Dual caption (LRBP 9004-1(c)): the first caption names the debtor and the case; the second names the
/// adversary parties and the adversary number. The right column carries the title and the relief sought
/// (LRBP 9004-1(a)) and the hearing, when one is known (LRBP 9004-1(e)).
#let dual-caption(meta) = {
  let debtor = need(meta, "debtor")
  let parties = need(meta, "parties")
  let left-cell(rows) = block(width: 100%, inset: (right: caption-inset, bottom: caption-pad), line-run(rows))
  let right-cell(rows) = block(width: 100%, inset: (left: right-inset, bottom: caption-pad), line-run(rows))

  // Row 1: the debtor (the case, chapter and complete case number; LRBP 9004-1(b)).
  let debtor-rows = ("In re:", none) + debtor.names + (none, emph("Debtor."))
  let case-rows = ("Chapter " + str(debtor.chapter), none, "Case No. " + debtor.case_number)

  // Row 2: the adversary parties and the adversary number.
  let party-rows = ()
  for (k, p) in parties.enumerate() {
    if k > 0 { party-rows += (none, "v.", none) }
    party-rows += p.names
    party-rows += (none, emph(p.designation))
  }
  let adv-rows = ("Adv. No. " + need(meta, "adversary_number"), none)
  adv-rows += (strong(upper(inl(need(meta, "title")))),)
  adv-rows += (none, inl(need(meta, "relief")))
  if "hearing" in meta and meta.hearing != none {
    let hr = meta.hearing
    adv-rows += (none, "Hearing date: " + hr.at("date", default: ""), "Time: " + hr.at("time", default: ""),
      "Place: " + hr.at("place", default: ""))
  }

  block(width: 100%, above: pitch, below: 0pt, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    // the party column ruled right and below over the whole row, as a Word table cell is
    stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) },
    left-cell(debtor-rows),
    right-cell(case-rows),
    left-cell(party-rows),
    right-cell(adv-rows),
  ))
}

#let cover(meta) = {
  filer-block(meta)
  court-title-block()
  dual-caption(meta)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Headings on the numbered lines, kept with the text after them: level 1 a centered section in capitals; level 2
/// a bold centered sub-heading; level 3 bold italic.
#let heading-rule(it) = {
  set text(size: type-size)
  let b = if it.level == 1 { align(center, strong(upper(it.body))) } else if it.level == 2 {
    align(center, strong(it.body))
  } else { strong(emph(it.body)) }
  block(sticky: true, width: 100%, above: 0pt, below: 0pt, { set par(first-line-indent: 0pt); b })
}

/// "Dated" left and the signer's block right of it, single-spaced, back on the numbered lines after it.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let rows = ("Respectfully submitted,", none, "/s/ " + sig.signer) + sig.lines
  grid(
    columns: (sig-left, 1fr),
    column-gutter: sig-gutter,
    line-run(([Dated: #need(meta, "date")],)),
    line-run(rows),
  )
  let used = single-offset + rows.len() * pitch-single
  v(calc.ceil(used / pitch) * pitch - used, weak: false)
}

/// Numbered allegations (Fed. R. Civ. P. 10(b), applied by FRBP 7010). Each blank-line-separated chunk of
/// markdown that is neither a heading nor a list is one numbered paragraph. Headings and lists are
/// unnumbered. The last chunk is kept with `tail` (the jury demand and the signature block), so a signature
/// never stands alone on a page. Numbering is applied per chunk, not with a `show par` rule: a show rule that
/// re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  for (idx, c) in chunks.enumerate() {
    let t = c.trim()
    let piece = if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // relief items: the label half an inch in, the text a box after it
      pad(left: item-indent, md(t))
    } else {
      n += 1
      body-par([#box(width: number-box, [#n.])#md(t)])
    }
    if idx == chunks.len() - 1 { block(breakable: false, above: 0pt, below: 0pt, { piece; tail }) } else { piece }
  }
  if chunks.len() == 0 { tail }
}

#let arb-adversary-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("filer", "debtor", "adversary_number", "parties", "title", "relief", "footer_title", "date", "signature", "consent_to_final_orders") {
    let _ = need(meta, k)
  }
  // FRBP 7008(a): the pleader must state whether it consents to entry of final orders or judgment by the
  // bankruptcy court. The template requires the answer in frontmatter; the wording is written in the body.
  assert(meta.consent_to_final_orders in ("yes", "no"), message: "arb-adversary-complaint: consent_to_final_orders must be \"yes\" or \"no\" (FRBP 7008(a))")

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    footer: footer-block(meta),
    footer-descent: footer-gap,
  )
  let document-title = upper(need(meta, "title"))
  let document-title = if str(need(meta, "adversary_number")) != "" {
    document-title + ", Adv. No. " + need(meta, "adversary_number")
  } else { document-title }
  set document(title: document-title, author: need(meta, "signature").signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch; relief items as a label box with the text hanging.
  show: xengine.with(pitch: pitch, list-indent: number-box)
  // A doubled sign stays with its number ("§§ 547(b)"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  show heading: heading-rule
  // Relief items are lettered (a), (b), ...
  set enum(numbering: "(a)")

  // Footnotes: 12 point, single-spaced (LRBP 9004-1(g)).
  set footnote.entry(gap: 0pt, clearance: 12pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size, ..edges(pitch-note))
  show footnote.entry: set par(first-line-indent: 0pt, leading: 0pt)

  cover(meta)

  // Unnumbered lead-in paragraph (for example, "Plaintiff alleges as follows."), if the sample has one.
  if "lead_in" in meta { body-par(above: pitch, inl(meta.lead_in)) }

  let jury = if "jury_demand" in meta and meta.jury_demand {
    body-par[Plaintiff demands a trial by jury on all claims so triable. Fed. R. Civ. P. 38, as applied by FRBP 9015.]
  } else { [] }
  allegations(body, {
    jury
    signature-block(meta)
  })
}
