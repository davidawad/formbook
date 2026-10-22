// Motion with memorandum for the United States Bankruptcy Court, E.D. Virginia (vaeb).
// Rules: FRBP 9013 (form and service of motions: grounds stated with particularity; relief sought),
// LBR 9013-1(C) (grounds and relief), 9013-1(F) (memorandum of points and authorities, which may be combined
// with the motion), LBR 7056-1(C) (summary judgment: a "Statement of Undisputed Material Facts" in numbered
// paragraphs), LBR 5005-1(C) (letter size, one side, top margin of 1 1/2 inches, counsel on page 1, debtor,
// case number, chapter and adversary number), FRBP 7010 and Fed. R. Civ. P. 10(a) (caption). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")         // Times New Roman (vendored) per docs/FONTS.md; no E.D. Va. rule names a typeface (README.md)
#let type-size = 12pt                    // convention: 12 point, as in both filed exemplars (headings too)
#let para-indent = 0.5in                 // first-line indent of body paragraphs; a paragraph number starts here
#let number-box = 0.5in                  // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let letter-box = 0.5in                  // a list item's label box after the indent; the text hangs after it
#let page-w = 8.5in                      // LBR 5005-1(C)(3): letter size
#let top-margin = 1.5in                  // LBR 5005-1(C)(3): top margin not less than 1 1/2 inches
#let bottom-margin = 1in
#let side-margin = 1in
#let footer-distance = 0.5in             // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let text-width = page-w - 2 * side-margin
#let caption-left = 3.4in                // width of the party column of the caption
#let caption-paren = 0.3in               // width of the column of ")" marks
#let caption-right = text-width - caption-left - caption-paren
#let case-pad = 0.15in                   // the case numbers stand off the ")" column
#let party-indent = 0.5in                // the debtor's name and the designations
#let versus-indent = 0.25in              // "v." between the sides
#let blank-width = 1.3in                 // the adversary number's blank, when the sample leaves it empty
#let sig-date = 2.9in                    // the signature's right column starts here; the date sits left of it
#let service-col = (text-width - 0.3in) / 2 // the certificate's service list: two columns 0.3 in apart ...
#let service-gutter = 0.3in
#let address-indent = 0.5in              // ... each address half an inch in
#let service-sig = 3.2in                 // the certificate's signature: a block this wide at the right margin
#let table-slack = 3                     // the table: characters of room added to a column's longest cell ...
#let table-char = 6pt                    // ... at half an em each (a column's width; the last column takes the rest)
#let table-inset = 5pt                   // ... cell padding (docx: 100 twips), 0.5 pt rules

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/vaeb.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 24pt                   // double spacing: body text, headings, list items
#let pitch-single = 13.8pt               // single spacing: counsel, court, caption, title, table, signature, service list
#let block-gap = 13.8pt                  // counsel to court, court to caption, caption to title (a blank single line)
#let title-below = 12pt                  // the title to the text
#let table-space = 12pt                  // above and below the table
#let sig-above = 24pt                    // the last paragraph to the signature block
#let service-above = 24pt                // the signature to the certificate of service
#let list-above = 12pt                   // the certificate's paragraph to the service list
#let sig-gap = 13.8pt                    // a blank single line inside a signature or between service rows

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vaeb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italic names, *Counsel for ...*).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// One single-pitch line (a paragraph of its own), with an explicit space above it.
#let sline(above: 0pt, left: 0pt, centered: false, c) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set align(center) if centered
  pad(left: left, par(first-line-indent: 0pt, unloose(c)))
})

/// Single-pitch lines of markdown, one paragraph each.
#let slines(items, left: 0pt) = for i in items { sline(left: left, md(i)) }

// ---------------------------------------------------------------------------
// Page one: counsel (LBR 5005-1(C)(5)), court, caption (FRBP 7010, Form 416), title
// ---------------------------------------------------------------------------

#let court-title(meta) = block(width: 100%, above: block-gap, below: 0pt, {
  sline(centered: true, text(weight: "bold", "IN THE UNITED STATES BANKRUPTCY COURT"))
  sline(centered: true, text(weight: "bold", "FOR THE EASTERN DISTRICT OF VIRGINIA"))
  sline(centered: true, md(meta.division))
})

/// The caption as a grid: the party column, a column of ")" marks, and the bankruptcy and adversary
/// numbers. Every row is one grid row, so the three columns stay level line for line.
#let caption(meta) = {
  let left = (sline[In re:], sline(left: party-indent)[#md(meta.debtor.name),], sline(left: party-indent)[Debtor.], [])
  let party-start = left.len()
  for (k, p) in meta.parties.enumerate() {
    if k > 0 { left.push(sline(left: versus-indent)[v.]) }
    for n in p.names { left.push(sline(md(n))) }
    left.push(sline(left: party-indent, md(p.designation)))
  }
  let adversary-row = party-start + 1
  let right = range(left.len()).map(i => {
    if i == 0 [Chapter #meta.debtor.chapter]
    else if i == 1 [Case No. #meta.debtor.case_number]
    else if i == adversary-row [Adversary Proceeding]
    else if i == adversary-row + 1 {
      if "adversary_number" in meta and meta.adversary_number != "" [Case No. #meta.adversary_number]
      else [Case No. #box(width: blank-width, height: 0.8em, stroke: (bottom: 0.5pt))]
    }
    else { none }
  })
  let cells = ()
  for i in range(left.len()) {
    cells.push(left.at(i))
    cells.push(sline[)])
    cells.push(if right.at(i) == none [] else { sline(left: case-pad, right.at(i)) })
  }
  block(width: 100%, above: block-gap, below: 0pt,
    grid(columns: (caption-left, caption-paren, caption-right), ..cells))
}

#let cover(meta) = {
  slines(meta.counsel)
  court-title(meta)
  caption(meta)
  block(width: 100%, above: block-gap, below: title-below,
    sline(centered: true, text(weight: "bold", upper(meta.title))))
}

// ---------------------------------------------------------------------------
// Headings, body, signature and service
// ---------------------------------------------------------------------------

/// Heading levels, on the body pitch with no space of their own, kept with the text after them: 1 centered bold
/// capitals; 2 bold; 3 bold italic (docx: Heading 1 to 3 in docx/reference.xml).
#let heading-block(level, t) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  // a heading typed "1) ..." or "2. ..." is a heading, not a list: the mark is escaped for cmarker
  let t = t.replace(regex("^(\\d+)([.)])"), m => m.captures.at(0) + "\\" + m.captures.at(1))
  set align(center) if level == 1
  par(first-line-indent: 0pt, if level == 1 { text(weight: "bold", upper(unloose(md(t)))) }
    else if level == 2 { text(weight: "bold", unloose(md(t))) }
    else { text(weight: "bold", style: "italic", unloose(md(t))) })
})

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(c) = block(width: 100%, above: 0pt, below: 0pt, par(unloose(c)))

/// A list item: its label ("(a)" or a bullet) in a box after the indent, the text hanging after it (docx: Lettered).
#let list-item(label, c) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: 0pt, hanging-indent: para-indent + letter-box,
    [#h(para-indent)#box(width: letter-box, label)#unloose(c)]))

/// A pipe table, single-spaced with 0.5 pt rules, the width of the text less the paragraph indent, indented by it.
/// A column is `table-char` per character of its longest cell (emphasis marks not counted) plus `table-slack`; the
/// last column takes the rest (docx/vaeb.lua does the same arithmetic). Kept on one page.
#let pipe-table(t) = {
  let row(l) = {
    let s = l.trim()
    if s.starts-with("|") { s = s.slice(1) }
    if s.ends-with("|") { s = s.slice(0, -1) }
    s.split("|").map(c => c.trim())
  }
  let lines = t.split("\n").map(l => l.trim()).filter(l => l != "")
  let rows = lines.enumerate().filter(((i, l)) => i != 1).map(((i, l)) => row(l))
  let ncol = rows.first().len()
  let chars(c) = c.replace("*", "").clusters().len()
  let width = text-width - para-indent
  let widths = range(ncol - 1).map(j => (calc.max(..rows.map(r => chars(r.at(j, default: "")))) + table-slack) * table-char)
  widths.push(width - widths.sum(default: 0pt))
  v(table-space)
  block(width: 100%, above: 0pt, below: 0pt, breakable: false, pad(left: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    table(columns: widths, inset: table-inset, stroke: 0.5pt, align: left,
      ..rows.map(r => range(ncol).map(j => unloose(md(r.at(j, default: ""))))).flatten())
  }))
  v(table-space)
}

/// The body. Each blank-line-separated chunk of markdown is a heading, a table, a list (its items lettered (a),
/// (b), ... or bulleted), or a paragraph. Paragraphs are numbered (FRCP 10(b)) only under the level 1 sections the
/// frontmatter names in `numbered_sections` (LBR 7056-1(C): the Statement of Undisputed Material Facts).
#let render-body(body, meta) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let numbered-sections = meta.at("numbered_sections", default: ()).map(s => upper(s))
  let item-re = regex("(?m)^(\\d+\\.|[-*+])[ \\t]+")
  let in-numbered = false
  let n = 0
  for t in chunks {
    if t.starts-with("#") {
      let m = t.match(regex("^(#+)[ \\t]+([\\s\\S]*)$"))
      let level = m.captures.at(0).len()
      if level == 1 { in-numbered = numbered-sections.contains(upper(m.captures.at(1).trim())) }
      heading-block(level, m.captures.at(1))
    } else if t.starts-with("|") {
      pipe-table(t)
    } else if t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
      let ordered = t.match(regex("^\\d+\\.")) != none
      let items = t.split(item-re).map(s => s.trim()).filter(s => s != "")
      for (i, item) in items.enumerate() {
        list-item(if ordered { numbering("(a)", i + 1) } else { [•] }, md(item))
      }
    } else if in-numbered {
      n += 1
      body-par[#box(width: number-box)[#n.]#unloose(md(t))]
    } else {
      body-par(md(t))
    }
  }
}

/// The signature block, single-spaced and kept on one page: "Respectfully submitted," and, a blank line below it,
/// the firm, "By: /s/" and the signer's lines, in a column from `sig-date` (docx: a tab and a hanging indent there);
/// the date (if given) at the left of the first line.
#let signature-block(meta) = {
  let sig = meta.signature
  let firm = sig.at("firm", default: ())
  let lines = ([Respectfully submitted,],) + firm.map(md)
  lines.push(if firm.len() > 0 [By: /s/ #sig.signer] else [/s/ #sig.signer])
  lines += sig.lines.map(md)
  let date = if "date" in meta and meta.date != none [Date: #meta.date] else []
  v(sig-above)
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    set text(..edges(pitch-single))
    for (i, l) in lines.enumerate() {
      block(width: 100%, above: if i == 1 { sig-gap } else { 0pt }, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-date,
        [#box(width: sig-date, if i == 0 { date })#unloose(l)]))
    }
  })
}

/// Certificate of service (FRBP 7005; Fed. R. Civ. P. 5(b)): form wording, the service list from the frontmatter.
#let service-block(meta) = if "service" in meta and meta.service != none {
  let s = meta.service
  let mailed = s.at("mailed", default: ())
  block(width: 100%, above: service-above, below: 0pt, sticky: true,
    align(center, par(first-line-indent: 0pt, text(weight: "bold", "CERTIFICATE OF SERVICE"))))
  body-par[I hereby certify that on the #s.date, I caused a copy of the foregoing to be served by electronic means through the ECF system#if mailed.len() > 0 [ and a copy mailed to the following:] else [.]]
  if mailed.len() > 0 {
    let cell(addr) = if addr == none { [] } else { slines(addr, left: address-indent) }
    let rows = range(0, mailed.len(), step: 2).map(i => (mailed.at(i), mailed.at(i + 1, default: none)))
    block(width: 100%, above: list-above, below: 0pt, grid(
      columns: (service-col, service-gutter, service-col), row-gutter: sig-gap,
      ..rows.map(((a, b)) => (cell(a), [], cell(b))).flatten()))
  }
  block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
    sline(left: text-width - service-sig)[/s/ #s.signer]
    sline(left: text-width - service-sig)[#s.signer]
  })
} else { none }

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let vaeb-motion-brief(meta, body) = {
  // Tier 1 (the rules' mandated form): every element LBR 5005-1(C) and FRBP 7010 name must be present.
  assert(meta.kind == "motion-brief", message: "vaeb-motion-brief: frontmatter kind must be motion-brief")
  assert("counsel" in meta and meta.counsel.len() > 0, message: "LBR 5005-1(C)(5): counsel, State Bar number and address are required on page 1")
  assert("division" in meta, message: "FRBP 7010 (Form 416): the division of the court is required in the caption")
  assert("debtor" in meta and "name" in meta.debtor and "chapter" in meta.debtor and "case_number" in meta.debtor,
    message: "LBR 5005-1(C)(2): the debtor's name, chapter and case number must appear on the document")
  assert("parties" in meta and meta.parties.len() > 0, message: "FRCP 10(a): the caption must name the parties")
  assert("title" in meta, message: "FRCP 10(a): the title of the paper is required")
  assert(upper(body).contains("WHEREFORE"), message: "LBR 9013-1(C): the motion must state the relief sought")
  assert(not meta.at("summary_judgment", default: false) or upper(body).contains("STATEMENT OF UNDISPUTED MATERIAL FACTS"),
    message: "LBR 7056-1(C): a summary judgment memorandum must include a Statement of Undisputed Material Facts")
  assert(not meta.at("summary_judgment", default: false) or meta.at("numbered_sections", default: ()).len() > 0,
    message: "LBR 7056-1(C): the Statement of Undisputed Material Facts must be in numbered paragraphs")

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, x: side-margin),
    // the page number centered in a single-pitch line box that ends footer-distance above the page edge
    footer-descent: bottom-margin - footer-distance - pitch-single,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  cover(meta)
  render-body(body, meta)
  signature-block(meta)
  service-block(meta)
}
