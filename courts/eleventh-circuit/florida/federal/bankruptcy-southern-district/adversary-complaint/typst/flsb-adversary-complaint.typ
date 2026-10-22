// Adversary complaint for the United States Bankruptcy Court, Southern District of Florida.
// Rules (verified 2026-10-14; see ../README.md): Fed. R. Bankr. P. 7001 (adversary proceedings), 7008(a)
// (jurisdiction, core/non-core and consent to final orders), 7010 (Fed. R. Civ. P. 10 applies: numbered
// paragraphs, caption), 9004(b) (caption contents); S.D. Fla. Bankr. L.R. 9004-1(a)(2)-(4) (1-inch margins,
// 12-point type, double spacing except captions, headings, quotations over 50 words, footnotes and signature
// blocks), 9004-1(e)(2) (adversary caption form).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // L.R. 9004-1(a)(3): 12-point font, no face named; Times New Roman, the house standard (docs/FONTS.md)
#let type-size = 12pt                   // L.R. 9004-1(a)(3)
#let margin = 1in                       // L.R. 9004-1(a)(2): at least one inch on every side
#let para-indent = 0.5in                // first-line indent of paragraphs; the paragraph number's box after it
#let item-indent = 0.5in                // lettered WHEREFORE items stand this far in
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-gutter = 0.2in
#let quote-inset = 0.5in                // block quotations are indented on both sides
#let sig-left = 2.6in                   // signature grid: the "Dated" column, a gutter, the signature column
#let sig-gutter = 0.2in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // L.R. 9004-1(a)(4): double spacing, two 12 pt lines
#let pitch-single = 13.8pt              // single-spaced caption, title, headings, quotations, signature: 1.15 x 12 pt
#let gap-half = 12pt                    // half a double line: inside the caption and the signature, around quotations and headings

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flsb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline and block markdown (names with *et al.*, the sample's emphasis).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// Single lines, the first with space above it.
#let line-group(above, items) = for (i, l) in items.enumerate() { line-block(above: if i == 0 { above } else { 0pt }, md(l)) }

// ---------------------------------------------------------------------------
// Caption (Form 416 / L.R. 9004-1(e)(2)): court, division, debtor and case, parties and adversary number
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  line-block(align(center, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT")))
  line-block(align(center, text(weight: "bold", meta.district)))
  // The division is printed as a blank line when the sample does not name one (L.R. 9004-1(e)(2)).
  let division = if "division" in meta { upper(meta.division) } else { "___________" }
  line-block(above: pitch-double, align(center, text(weight: "bold", division + " DIVISION")))
}

/// The caption: two rows. The debtor ("In re:") with the case number and chapter; then the parties with the
/// adversary number at the first party's line. Each row closes with the rule "____/".
#let caption(meta) = {
  let rule = "_" * 36 + "/"
  let parties = ()
  for (k, p) in meta.parties.enumerate() {
    if k > 0 { parties.push("vs.") }
    parties += p.names + (p.designation,)
  }
  block(width: 100%, above: pitch-double, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    row-gutter: gap-half,
    {
      line-group(0pt, ("In re:", ..meta.debtor.names, meta.debtor.designation))
      line-block(above: gap-half, rule)
    },
    [],
    line-group(0pt, ("CASE NO.: " + meta.case_number, "CHAPTER " + meta.chapter)),
    {
      line-group(0pt, parties)
      line-block(above: gap-half, rule)
    },
    [],
    line-block("ADV. CASE NO.: " + meta.adv_number),
  ))
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  line-block(above: pitch-double, below: pitch-double, align(center, text(weight: "bold", md(meta.title))))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Civil Rule 10(b), via Rule 7010); headings, block quotations, lettered items
// and the WHEREFORE clause are not numbered.
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch, first-line indented; a numbered one has its number in a box of the
/// paragraph indent after the indent.
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), if num == none { content } else {
    [#box(width: para-indent, [#num.])#content]
  }))

/// Body chunks: each blank-line-separated chunk is a heading, a block quotation (single-spaced, indented on both
/// sides), a lettered item ("(a) ...", indented), or a paragraph. Paragraphs after the first heading are numbered,
/// except a WHEREFORE paragraph and a "Dated" line; the opening paragraph before the first heading is not
/// (the exemplar; Rule 10(b) numbers allegations).
#let allegations(body, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  let seen-heading = false
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let piece = if t.starts-with("#") {
      seen-heading = true
      md(t)
    } else if t.starts-with(">") {
      line-block(above: gap-half, below: gap-half, pad(x: quote-inset, md(t.replace(regex("(?m)^>[ \t]?"), ""))))
    } else if t.starts-with(regex("^\\([a-z]+\\)[ \\t]")) {
      block(width: 100%, above: 0pt, below: 0pt, pad(left: item-indent, par(first-line-indent: 0pt, md(t))))
    } else if seen-heading and not t.starts-with("WHEREFORE") and not t.starts-with("Dated") {
      n += 1
      body-par(n, md(t))
    } else {
      body-par(none, md(t))
    }
    // The last block stays on one page with the signature block, so a signature never stands alone.
    if i == chunks.len() - 1 { block(width: 100%, breakable: false, above: 0pt, below: 0pt, { piece; tail }) } else { piece }
  }
}

/// The signature block: "Dated" at the left; "Respectfully submitted,", the firm and the signer's lines at the right.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
  columns: (sig-left, 1fr),
  column-gutter: sig-gutter,
  line-block[Dated: #meta.date],
  {
    line-block[Respectfully submitted,]
    line-group(gap-half, meta.signature.firm)
    line-group(gap-half, ("By: /s/ " + meta.signature.signer, meta.signature.signer, ..meta.signature.lines))
  },
))

#let flsb-adversary-complaint(meta, body) = {
  // The page number: centered in a single-spaced line box, at the same place on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled sign stays with its number too ("¶¶ 20", "§§ 157"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)
  // A quotation mark right after sentence punctuation closes a quotation (cmarker reads an unmatched one as
  // opening; pandoc, the docx reader, as closing).
  show regex("[.,;:!?][\u{201C}]"): it => it.text.replace("\u{201C}", "\u{201D}")
  // Headings (single-spaced, L.R. 9004-1(a)(4)): 12 pt, half a double line above and below, kept with the text
  // after them; level 1 centered bold capitals, level 2 centered bold, level 3 bold italic.
  show heading: it => block(sticky: true, width: 100%, above: gap-half, below: gap-half, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      align(center, text(weight: "bold", it.body))
    } else { text(weight: "bold", style: "italic", it.body) }
  })

  cover(meta)
  allegations(body, signature-block(meta))
}
