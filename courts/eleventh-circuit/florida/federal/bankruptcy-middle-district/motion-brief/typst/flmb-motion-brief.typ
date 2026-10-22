// Motion with incorporated memorandum for the United States Bankruptcy Court, Middle District of Florida (flmb).
// Rules: Fed. R. Bankr. P. 9013(a)-(b) (written motion; grounds stated with particularity), 9004(b) and
// Fed. R. Civ. P. 10(a) (caption); Local Rules 7001-1(b) and 9004-1(a)-(c) (title: party designation, jury demand,
// injunctive relief), 7001-1(k)(1)-(3) (one form of relief; the Court's Style Guide; double spacing; a
// ten-page limit absent leave); Local Rule 5005-1(d) and the Style Guide II.A (paper, margins, font, page
// numbers). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter or body.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Style Guide II.A asks for Times New Roman 12 point; Liberation Serif is the metric-compatible substitute (docs/FONTS.md)
#let type-size = 12pt              // Style Guide II.A: 12-point font
#let para-indent = 0.5in           // first-line indent of numbered and unnumbered paragraphs
#let number-box = 0.5in            // a paragraph number stands in a half-inch box, the text after it (Word: a tab at 1 in)
#let list-box = 0.5in              // a conclusion item's number box; the item hangs after it, half an inch in
#let margin = 1in                  // Style Guide II.A; Local Rule 5005-1(d): one-inch margins on 8 1/2 x 11 paper
#let caption-left = 3.2in          // the party column of the caption; the case numbers stand after the gutter
#let caption-gutter = 0.2in
#let slash-box = 0.2in             // the "/" that closes a party block's rule
#let sig-col = 3.1in               // the signature column at the right margin
#let sig-gutter = 0.2in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt         // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-body = 2 * pitch-single  // Local Rule 7001-1(k)(2): double spaced, two single lines (Word double spacing; the exemplar's body lines are 27.6 pt apart)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flmb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in *italics*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// The title as printed: capitals, with the words the Local Rules require when they apply.
#let full-title(meta) = {
  let parts = (upper(meta.title),)
  if "injunctive_relief" in meta and meta.injunctive_relief { parts.push("INJUNCTIVE RELIEF SOUGHT") } // LR 7001-1(b), 9004-1(c)
  if "jury_demand" in meta and meta.jury_demand { parts.push("DEMAND FOR JURY TRIAL") } // LR 9004-1(b)
  parts.join("; ")
}

/// Footnote definitions (`[^key]: text`), keyed by name. Each is rendered with the paragraph that cites it.
#let footnote-defs(body) = {
  let defs = (:)
  for m in body.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.+)$")) {
    defs.insert(m.captures.at(0), m.captures.at(1))
  }
  defs
}

/// A paragraph's markdown, with the definitions of the footnotes it cites appended.
#let with-notes(t, defs) = {
  let keys = t.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0)).dedup()
  if keys.len() == 0 { t } else {
    t + "\n\n" + keys.map(k => "[^" + k + "]: " + defs.at(k)).join("\n\n")
  }
}

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  body
})

/// A double-spaced body paragraph: `first` the first-line indent.
#let body-par(first: para-indent, body) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: first, all: true), hanging-indent: 0pt, body))

// ---------------------------------------------------------------------------
// Court title and caption (Fed. R. Bankr. P. 9004(b), 7010; Local Rule 9004-1(a))
// ---------------------------------------------------------------------------

#let court-title(meta) = for (i, l) in ("UNITED STATES BANKRUPTCY COURT", "MIDDLE DISTRICT OF FLORIDA",
  upper(meta.division) + " DIVISION").enumerate() {
  line-block(align(center, text(weight: "bold", l)))
}

/// The caption: the party column (names, the designation half an inch in, a rule closed by "/") and the case
/// numbers beside it, one grid row per line; each party block a single line below the one before.
#let caption(meta) = {
  // the rule runs on the line's baseline, just below it (Word: an underlined tab), to the "/" at the column's end
  let rule = [#box(width: 1fr, move(dy: 1.5pt, line(length: 100%, stroke: 0.75pt)))#box(width: slash-box, align(right)[/])]
  let ind(x) = pad(left: para-indent, x)
  let group(above, rows) = block(width: 100%, above: above, below: 0pt, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    grid(columns: (caption-left, caption-gutter, 1fr), ..rows.map(r => (r.at(0), [], r.at(1))).flatten())
  })
  let side(names, designation) = names.map(n => (inl(n), [])) + ((ind(inl(designation)), []),)
  let label = meta.at("adversary_label", default: "Adv. Case No.")
  let in-re = (([In re:], [Case No. #meta.case_number]),) + meta.in_re.map(n => (inl(n), [])) + (([], []),)
  in-re.at(1).at(1) = inl(meta.chapter)
  in-re.at(-1) = (ind([Debtor.]), [])
  group(0pt, in-re + ((rule, []),))
  group(pitch-single, side(meta.caption.at(0).names, meta.caption.at(0).designation))
  group(pitch-single, (([v.], [#label #meta.adversary_number]),))
  group(pitch-single, side(meta.caption.at(1).names, meta.caption.at(1).designation) + ((rule, []),))
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Civ. P. 11(a) as applied; Local Rule 9004-1)
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: 100%, above: pitch-body, below: 0pt, grid(
  columns: (1fr, sig-col),
  column-gutter: sig-gutter,
  line-block(if "date" in meta { [Dated: #meta.date] } else { [] }),
  {
    line-block[Respectfully submitted,]
    for (i, n) in meta.signature.firm.enumerate() { line-block(above: if i == 0 { pitch-single } else { 0pt }, inl(n)) }
    line-block(above: pitch-single, inl("By: /s/ " + meta.signature.signer))
    line-block(inl(meta.signature.signer))
    for n in meta.signature.lines { line-block(inl(n)) }
  },
))

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)); unnumbered paragraphs are marked with a leading ^
// in the sample (the introduction, the conclusion lead-in); the conclusion list is numbered 1., 2., ...
// ---------------------------------------------------------------------------

/// The items of a markdown list (`1.`, `2.`, ...; one line each), each double-spaced, its number in a box half an
/// inch in and its text hanging after it.
#let list-items(src, defs) = {
  let items = src.split("\n").map(l => l.trim()).filter(l => l != "")
  items.enumerate().map(((i, l)) => {
    let m = l.match(regex("^(\\d+\\.|[-*+])[ \\t]+(.*)$"))
    let lab = if m.captures.at(0).ends-with(".") { str(i + 1) + "." } else { [•] }
    block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent,
      par(first-line-indent: 0pt, hanging-indent: list-box, { box(width: list-box, lab); inl(with-notes(m.captures.at(1), defs)) })))
  })
}

// `tail` is the signature block. When the body ends with a list (the conclusion), its last item is set with the
// signature block as one unbreakable block, so the signature never stands alone on a page.
#let body-chunks(body, para-counter, defs, tail) = {
  // Footnote definitions are not body blocks.
  let blocks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim())
    .filter(c => c != "" and not c.starts-with("[^"))
  let list-rx = regex("^(\\d+\\.|[-*+])[ \\t]")
  let closes-with-list = blocks.len() > 0 and blocks.last().starts-with(list-rx)
  for (i, t) in blocks.enumerate() {
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(list-rx) {
      let items = list-items(t, defs)
      if closes-with-list and i == blocks.len() - 1 {
        for it in items.slice(0, -1) { it }
        block(width: 100%, breakable: false, above: 0pt, below: 0pt, { items.last(); tail })
      } else {
        for it in items { it }
      }
    } else if t.starts-with("^") {
      body-par(inl(with-notes(t.slice(1).trim(), defs)))
    } else {
      para-counter.step()
      body-par({ box(width: number-box, context para-counter.display()); inl(with-notes(t, defs)) })
    }
  }
  if not closes-with-list { tail }
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let flmb-motion-brief(meta, body) = {
  let para-counter = counter("allegation")
  let defs = footnote-defs(body)

  // The page number: centered in a single-spaced line box on every page but the first (Style Guide II.A), at the
  // same place on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context if counter(page).get().first() > 1 {
      align(center, text(..edges(pitch-single), counter(page).display()))
    },
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too ("¶¶ 41–73"; the docx filter binds it with a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes: 12 pt, single-spaced, the mark and a space before the note (Word's footnote).
  set footnote.entry(gap: 7pt, clearance: 12.6pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 7pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Headings: single-spaced, a double line above, kept with the text after them; level 1 centered bold capitals;
  // level 2 bold, flush left (A., B.); level 3 bold italic, half an inch in (a., b.).
  show heading: it => block(sticky: true, width: 100%, above: pitch-body, below: 0pt, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      text(weight: "bold", it.body)
    } else { pad(left: para-indent, text(weight: "bold", style: "italic", it.body)) }
  })

  court-title(meta)
  block(width: 100%, above: pitch-body, below: 0pt, caption(meta))
  line-block(above: pitch-body, align(center, text(weight: "bold", full-title(meta))))
  body-chunks(body, para-counter, defs, signature-block(meta))
}
