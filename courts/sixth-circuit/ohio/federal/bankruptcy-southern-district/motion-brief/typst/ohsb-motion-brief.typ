// Motion with memorandum in support for the U.S. Bankruptcy Court, S.D. Ohio (FRBP 9013).
// Rules: Fed. R. Bankr. P. 9013 (a motion must be in writing, state its grounds with particularity and set forth the
// relief requested), 9004(a)-(b) (legible; caption with court, title, case number and designation); S.D. Ohio LBR
// 9004-1(b) (8 1/2 x 11, double spaced, top margin of one inch or more, 10-12 point type), LBR 9004-2 (caption),
// LBR 9013-1(a) (memorandum in support, certificate of service, 21-day notice unless exempt; the notice text is the
// sample in LBR 9013-1(a)(2)), LBR 9013-2(a) (20-page limit: not checked here), LBR 9013-3 (certificate of service).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/ (the only family vendored; no system fonts)
#let type-size = 12pt                   // LBR 9004-1(b): typed print at least 10-12 point; 12 point is used
#let body-leading = 1.35em              // double spacing: EB Garamond's line box is 0.65em, so 24 pt pitch at 12 pt
#let single-leading = 0.5em             // footnotes, signature block and caption lines: about 14 pt pitch
#let cap-line = 14pt                    // one caption or signature line (fixed height keeps the ")" column aligned)
#let para-indent = 0.5in                // first-line indent of paragraphs
#let quote-indent = 0.75in              // left indent of the lettered quotation of 11 U.S.C. § 1112(b)(4)
#let margin = 1in                       // LBR 9004-1(b): top margin not less than one inch; the sides match it
#let text-width = 8.5in - 2 * margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ohsb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Footnote definitions "[^n]: text" keyed by label. Their chunks are removed from the body and each
/// reference "[^n]" becomes a typst footnote with the definition's text.
#let footnote-defs(body) = {
  let d = (:)
  for m in body.matches(regex("(?m)^\\[\\^(\\w+)\\]:[ \\t]*(.+)$")) {
    d.insert(m.captures.at(0), m.captures.at(1))
  }
  d
}

/// Inline markdown for one text segment. Markdown drops whitespace at a segment's edges, so a space at either edge
/// is kept as a typst space (a footnote reference sits between two segments).
#let seg(s) = {
  let lead = if s.starts-with(" ") { [ ] } else { [] }
  let trail = if s.ends-with(" ") { [ ] } else { [] }
  lead + inl(s) + trail
}

/// Inline markdown with footnote references turned into typst footnotes.
#let rich(t, defs) = {
  let out = []
  let pos = 0
  for m in t.matches(regex("\\[\\^(\\w+)\\]")) {
    out += seg(t.slice(pos, m.start))
    out += footnote(inl(defs.at(m.captures.at(0))))
    pos = m.end
  }
  out + seg(t.slice(pos))
}

#let is-list(t) = t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none
#let is-quote(t) = t.match(regex("^\\([A-Za-z]\\)[ \\t]")) != none
#let is-def(t) = t.match(regex("^\\[\\^\\w+\\]:")) != none

/// A heading stays with the paragraph after it (it never ends a page).
#let heading-block(c) = block(width: text-width, above: body-leading, below: body-leading, sticky: true, c)

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// Court name (LBR 9004-2: the court and the division) in single spacing.
#let court-title(meta) = stack(dir: ttb, spacing: 0pt,
  ..("UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF OHIO", meta.division).map(l =>
    block(height: cap-line, width: 100%, align(center, text(weight: "bold", l)))))

/// Caption: the parties and the case information on either side of a column of ")" marks, one row per line.
/// Each row is a fixed-height block, so the marks line up with the parties' lines.
#let caption(meta) = grid(
  columns: (3.4in, 0.3in, 1fr),
  stack(dir: ttb, spacing: 0pt, ..meta.caption.left.map(l =>
    block(height: cap-line, width: 100%, text(l)))),
  stack(dir: ttb, spacing: 0pt, ..meta.caption.left.map(_ =>
    block(height: cap-line, width: 100%, align(center, ")")))),
  stack(dir: ttb, spacing: 0pt, ..meta.caption.right.map(r =>
    block(height: cap-line, width: 100%, inset: (left: 0.15in), text(r)))),
)

#let cover(meta) = {
  set par(leading: 0pt, spacing: 0pt)
  court-title(meta)
  v(body-leading)
  block(width: text-width, height: meta.caption.left.len() * cap-line, caption(meta))
  v(body-leading)
  block(width: text-width, below: body-leading, {
    set par(leading: single-leading)
    align(center, text(weight: "bold", meta.brief_title))
  })
}

// ---------------------------------------------------------------------------
// Signature block: "Dated:" at the left, the closing (if any), the firm and the signer's lines at the right
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: text-width, breakable: false, above: body-leading, grid(
  columns: (2.6in, 1fr),
  column-gutter: 0.2in,
  if "date" in meta and meta.date != none { [Dated: #meta.date] } else { [] },
  {
    let sig = meta.signature
    if "closing" in sig and sig.closing != "" {
      block(height: cap-line, width: 100%, text(sig.closing))
      v(cap-line)
    }
    if "firm" in sig {
      stack(dir: ttb, spacing: 0pt, ..sig.firm.map(l => block(height: cap-line, width: 100%, text(l))))
      v(cap-line)
    }
    stack(dir: ttb, spacing: 0pt, ..sig.lines.map(l => block(height: cap-line, width: 100%, text(l))))
  },
))

// ---------------------------------------------------------------------------
// The 21-day notice (LBR 9013-1(a)(2)): the rule's sample text with the movant's name and the relief filled in
// from the frontmatter. Rendered where the sample carries {{NOTICE_21_DAY}}.
// ---------------------------------------------------------------------------

#let notice-21-day(meta) = {
  let movant = meta.notice.movant
  let relief = meta.notice.relief
  let rep(s) = s.replace("(Name)", movant).replace("(relief sought in motion/objection)", relief)
  heading-block(align(center, text(weight: "bold", "NOTICE OF MOTION/OBJECTION")))
  for p in (
    rep("(Name) has filed papers with the court to obtain (relief sought in motion/objection)."),
    "Your rights may be affected. You should read these papers carefully and discuss them with your attorney, if you have one in this bankruptcy case. If you do not have an attorney, you may wish to consult one.",
    "If you do not want the court to grant the relief sought in the motion/objection, then on or before twenty-one (21) days from the date set forth in the certificate of service for the motion/objection, you must file with the court a response explaining your position by mailing your response by first class mail to " + meta.notice.clerk_address + " OR your attorney must file a response using the court’s ECF System.",
    "The court must receive your response on or before the above date.",
    "You must also send a copy of your response either by 1) the court’s ECF System or by 2) first class mail to " + meta.notice.movant_address + " and " + meta.notice.others + ".",
    "If you or your attorney do not take these steps, the court may decide that you do not oppose the relief sought in the motion/objection and may enter an order granting that relief without further hearing or notice.",
  ) {
    par[#p]
  }
}

// ---------------------------------------------------------------------------
// Body: paragraphs (unnumbered), headings, lists, lettered quotations, centered asterisks, signature directive
// ---------------------------------------------------------------------------

/// Renders the body chunks in order. A chunk is a heading ("#"/"##"), a markdown list, a lettered quotation "(A)",
/// the signature directive, the notice directive, the centered asterisks, or a paragraph.
#let render-body(chunks, meta, defs) = {
  for t in chunks {
    if t.starts-with("## ") {
      heading-block(align(center, text(weight: "bold", t.slice(3))))
    } else if t.starts-with("# ") {
      heading-block(align(center, text(weight: "bold", upper(t.slice(2)))))
    } else if t == "{{SIGNATURE}}" {
      signature-block(meta)
    } else if t == "{{NOTICE_21_DAY}}" {
      notice-21-day(meta)
    } else if t == "***" {
      block(width: text-width, above: body-leading, below: body-leading, align(center, [\*\*\*]))
    } else if is-list(t) {
      block(width: text-width, {
        set par(leading: body-leading)
        set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true)
      })
    } else if is-quote(t) {
      pad(left: quote-indent, par[#rich(t, defs)])
    } else if t.contains("\\\n") {
      // Hard-broken lines (an address block or a signature line): single spaced, not indented.
      par(leading: single-leading)[#rich(t, defs)]
    } else {
      par[#h(para-indent) #rich(t, defs)]
    }
  }
}

// ---------------------------------------------------------------------------
// Entry: the whole motion with memorandum
// ---------------------------------------------------------------------------

#let motion-brief(meta, body) = {
  let defs = footnote-defs(body)
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "" and not is-def(c))

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  // Paragraph spacing equals the leading: typst adds leading only between the lines of one paragraph, so the
  // gap between paragraphs carries the second half of the double-spaced pitch.
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: 0.4em)
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading, spacing: 0.4em)
  set table(stroke: 0.5pt, inset: 5pt)

  cover(meta)

  render-body(chunks, meta, defs)
}
