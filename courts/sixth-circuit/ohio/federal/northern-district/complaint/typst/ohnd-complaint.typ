// Complaint for the U.S. District Court for the Northern District of Ohio (ohnd).
// Rules: Fed. R. Civ. P. 8(a) (short and plain statement), 10(a) (caption), 10(b) (numbered paragraphs),
// 38(b) (jury demand, when made); N.D. Ohio L.R. 10.1 (8 1/2 x 11 white paper, double spacing except
// quotations, a 1 1/2 inch top margin on the first page, consecutive page numbers, signature details);
// L.R. 3.13(a) (civil cover sheet, filed separately). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // L.R. 10.1 names no face; Times New Roman (vendored, docs/FONTS.md), as both filed exemplars
#let type-size = 12pt                  // convention for federal filings; no N.D. Ohio font rule in L.R. 10.1
#let page-w = 8.5in                    // L.R. 10.1: 8 1/2 x 11 inch paper
#let margin = 1in                      // convention: one inch on all sides
#let first-page-top = 1.5in            // L.R. 10.1: top margin of the first page, for the clerk's file stamp
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in               // first-line indent of every body paragraph
#let number-box = 0.5in                // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let item-indent = 0.5in               // a lettered item's letter starts half an inch in ...
#let letter-box = 0.5in                // ... in a box of its own; the text hangs 1 in from the margin (docx: a tab)
#let caption-left = 3.3in              // width of the party column of the caption
#let caption-paren = 0.3in             // the column of ")" marks
#let caption-right-inset = 0.3in       // the case number and judge stand this far right of the ")" column
#let sig-col = 2.8in                   // the signature column starts here; the date sits left of it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/ohnd-complaint.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-single = 13.8pt             // single spacing (1.15 x the type size): court title, caption, title, signature, footer
#let pitch-body = 2 * pitch-single     // L.R. 10.1: double-spaced, 27.6 pt (the Hammill exemplar's measured pitch)
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ohnd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, the signature lines, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if type(body) != content or body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One single-spaced paragraph of its own, `above` the space before it.
#let line-block(above: 0pt, left: 0pt, hanging: 0pt, center: false, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  set align(if center { std.center } else { std.left })
  pad(left: left, par(hanging-indent: hanging, unloose(body)))
})

/// A body paragraph at the body pitch.
#let body-par(content, indent: para-indent, sticky: false) = block(width: 100%, above: 0pt, below: 0pt,
  sticky: sticky, par(first-line-indent: (amount: indent, all: true), unloose(content)))

// ---------------------------------------------------------------------------
// Page 1: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// Court title, centered, single-spaced.
#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "NORTHERN DISTRICT OF OHIO")
  if "division" in meta { lines.push(upper(meta.division)) }
  for l in lines { line-block(center: true, l) }
}

/// The caption: one row per line of the party column (a name, a designation, "v." between parties with a blank
/// line on each side), a ")" on every line of it (a name that wraps takes one per line), and right of the marks the
/// case number on the first row and the judge on the third. A row is as tall as its name.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows += ("", "v.", "") }
    rows += p.names + (p.designation,)
  }
  let judge = if "judge" in meta and meta.judge != none { meta.judge } else { "" }
  let cells = ()
  for (i, r) in rows.enumerate() {
    let name = line-block(if r == "" { box() } else { inl(r) })  // a blank row is one empty line
    let parens = context {
      let k = calc.max(1, int(calc.round(measure(width: caption-left, name).height / pitch-single)))
      for _ in range(k) { line-block[)] }
    }
    let right = if i == 0 { "Case No. " + meta.case_number } else if i == 2 { "Judge: " + judge } else { "" }
    cells += (name, parens, line-block(left: caption-right-inset, right))
  }
  block(width: 100%, above: pitch-body, below: 0pt, breakable: false,
    grid(columns: (caption-left, caption-paren, 1fr), ..cells))
}

/// The title of the paper, bold and centered, a double line below the caption and above the text.
#let title-block(meta) = line-block(above: pitch-body, center: true, text(weight: "bold", inl(meta.title)))

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Markdown marker for a paragraph the filing does not number: a chunk that starts with it is unnumbered.
#let unnumbered-marker = "<!--u-->"

/// Headings at the type size on the body pitch, with no space of their own, kept with the block after them:
/// level 1 centered bold capitals; level 2 centered bold; level 3 bold italic at the margin.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set align(center) if level <= 2
  par(first-line-indent: 0pt, if level == 1 { text(weight: "bold", upper(unloose(inl(s)))) }
    else if level == 2 { text(weight: "bold", unloose(inl(s))) }
    else { text(weight: "bold", style: "italic", unloose(inl(s))) })
})

/// A lettered sub-item (A., B., ...: the markdown number is the letter's position, so a group can continue a
/// letter run): the letter half an inch in, in a box, the text hanging after it.
#let lettered(n, s) = block(width: 100%, above: 0pt, below: 0pt, pad(left: item-indent,
  par(first-line-indent: 0pt, hanging-indent: letter-box,
    [#box(width: letter-box, numbering("A.", n))#unloose(inl(s))])))

/// The body as a list of pieces, one per blank-line-separated chunk of markdown (a list gives one piece per item):
/// a `#` heading (levels 1 to 3) or a chunk that is only `**bold**` (an unnumbered run-in label), both kept with the
/// next piece; a `1.` list, lettered; a chunk starting `<!--u-->`, unnumbered (the WHEREFORE clause); anything else
/// a paragraph numbered 1, 2, ... (Fed. R. Civ. P. 10(b)).
#let item-re = regex("^(\\d+)\\.[ \\t]+")
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let out = ()
  let n = 0
  for t in chunks {
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      out.push(heading-block(calc.min(level, 3), t.slice(level).trim()))
    } else if t.starts-with("**") and t.ends-with("**") and not t.slice(2, -2).contains("**") {
      out.push(body-par(text(weight: "bold", inl(t.slice(2, -2))), indent: 0pt, sticky: true))
    } else if t.starts-with(item-re) {
      // One item per line that starts with a number; a line without one continues the item before it.
      let items = ()
      for l in t.split("\n").map(l => l.trim()).filter(l => l != "") {
        let m = l.match(item-re)
        if m != none or items.len() == 0 {
          items.push((if m != none { int(m.captures.at(0)) } else { 1 }, if m != none { l.slice(m.end) } else { l }))
        } else { items.last().at(1) += " " + l }
      }
      for (k, s) in items { out.push(lettered(k, s)) }
    } else if t.starts-with(unnumbered-marker) {
      out.push(body-par(inl(t.slice(unnumbered-marker.len()).trim())))
    } else {
      n += 1
      out.push(body-par[#box(width: number-box)[#n.]#unloose(inl(t))])
    }
  }
  out
}

/// Jury demand (Fed. R. Civ. P. 38(b)); printed only when the frontmatter asks for it.
#let jury-demand(meta) = if "jury_demand" in meta and meta.jury_demand {
  heading-block(1, "JURY DEMAND")
  body-par[Plaintiff demands a trial by jury on all issues so triable.]
}

/// Signature block, single-spaced, a double line below the text: "Dated:" and the date (when given) at the left of
/// the first line, "Respectfully submitted," and, after a blank line, the signature lines in a column from `sig-col`
/// (L.R. 10.1: the typed name, address, telephone, facsimile, e-mail and Ohio Bar Registration Number go in the
/// lines; docx: a tab and a hanging indent there).
#let signature-block(meta) = {
  let date = if "date" in meta and meta.date != none [Dated: #meta.date] else []
  line-block(above: pitch-body, hanging: sig-col, [#box(width: sig-col, date)Respectfully submitted,])
  for (i, l) in meta.signature.lines.enumerate() {
    line-block(above: if i == 0 { pitch-single } else { 0pt }, left: sig-col, inl(l))
  }
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let ohnd-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: footer-descent,
    footer: context align(center, par(first-line-indent: 0pt, text(..edges(pitch-single), counter(page).display()))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("¶¶ 1-16"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  // First page: the top margin is 1 1/2 inches (L.R. 10.1), so the first page starts with the extra 1/2 inch.
  v(first-page-top - margin)
  court-title(meta)
  caption(meta)
  title-block(meta)
  // The text a single line below the title (its first line box, at the body pitch, adds the rest of the double line).
  block(width: 100%, above: pitch-single, below: 0pt, if "lead_in" in meta { body-par(inl(meta.lead_in)) })

  // The last piece, the jury demand and the signature block share one unbreakable block, so the signature never
  // stands alone on a page (the WHEREFORE clause stays with it).
  let pieces = allegations(body)
  pieces.slice(0, -1).join()
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    pieces.last()
    jury-demand(meta)
    signature-block(meta)
  })
}
