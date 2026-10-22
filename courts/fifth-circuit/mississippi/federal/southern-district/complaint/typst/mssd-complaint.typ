// Complaint for the U.S. District Court for the Southern District of Mississippi (mssd).
// Rules: Fed. R. Civ. P. 8(a) and 10(a)-(b) (caption, numbered paragraphs); L.U.Civ.R. 11(a) (counsel's name, address,
// telephone, fax, e-mail and bar number on every signed paper); L.U.Civ.R. 38(a) (the jury demand is in the pleading).
// See ../README.md for the rule text, the choices and the gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a choice recorded in README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no complaint rule names a face: the house standard (and the exemplar's face, data/exemplar-fonts.json)
#let type-size = 12pt                   // 12 pt, the exemplar's size; no complaint rule sets one (L.U.Civ.R. 7(b)(5)(B), for memoranda, sets 12-point or larger)
#let margin = 1in                       // all four sides (the exemplar's margins; FRCP 10 sets none)
#let para-indent = 0.5in                // first-line indent of the lead-in and the allegations; the allegation number's box after it
#let list-left = 0.5in                  // a lettered item's label starts here; its label box is para-indent wide, the text hangs after it
#let caption-left = 3.6in               // the party column of the caption
#let caption-gutter = 0.1in             // between the party column and the case-number column
#let sig-left = 3in                     // the signature block stands in the right half of the page

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // double spacing: 27.6 pt, the exemplar's measured line pitch (README.md)
#let heading-above = pitch-double       // a heading: a double line above it (the exemplar's), none below

// The signature fields L.U.Civ.R. 11(a) requires. The template refuses to render without them.
#let required-signature-keys = ("signer", "bar_no", "firm", "address", "telephone", "fax", "email")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mssd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, smart quotes).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  body
})

/// A body paragraph at the double pitch with the first-line indent; numbered (Fed. R. Civ. P. 10(b)): the number
/// in a box of the indent after it, the text after that.
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt, if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: para-indent, [#num.])#content])
})

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = for l in meta.court {
  line-block(align(center, text(weight: "bold", upper(l))))
}

/// The caption: each party's names, then its designation; "v." between the parties, a blank line above and below
/// it. "CIVIL ACTION NO." and the case number stand at the right, from the line of the first "v." (the exemplars'
/// layout), so that both columns keep one line grid.
#let caption(meta) = {
  let rows = ()
  let v-row = none
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 {
      if v-row == none { v-row = rows.len() + 1 }
      rows.push((text: "v.", above: pitch-single))
      rows.push((text: none, above: pitch-single))
    }
    for (j, n) in (p.names + (p.designation,)).enumerate() { rows.push((text: n, above: 0pt)) }
  }
  if v-row == none { v-row = 0 }
  block(width: 100%, above: pitch-double, below: pitch-double, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    {
      let pending = 0pt
      for r in rows {
        if r.text == none { pending = r.above } else {
          line-block(above: calc.max(pending, r.above), inl(r.text))
          pending = 0pt
        }
      }
    },
    {
      pad(top: v-row * pitch-single, {
        line-block("CIVIL ACTION NO.")
        line-block(inl(meta.case_number))
      })
    },
  ))
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  line-block(below: pitch-single, align(center, underline(text(weight: "bold", upper(meta.brief_title)))))
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Signature block (L.U.Civ.R. 11(a)), in the right half of the page; it never breaks across a page.
#let signature-block(meta) = {
  let s = meta.signature
  for k in required-signature-keys {
    assert(k in s, message: "mssd-complaint: signature." + k + " is required (L.U.Civ.R. 11(a))")
  }
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, pad(left: sig-left, {
    line-block[Respectfully submitted,]
    line-block(above: pitch-single, [/s/ #inl(s.signer)])
    line-block[#upper(s.signer) (#s.bar_no)]
    line-block(inl(s.firm))
    for a in s.address { line-block(inl(a)) }
    line-block[Telephone: #s.telephone]
    line-block[Facsimile: #s.fax]
    line-block[Email: #s.email]
    if "role" in s { line-block(above: pitch-single, upper(s.role)) }
  }))
}

/// A list chunk: items lettered a., b., ... (ordered) or bulleted; the label at list-left in a box of para-indent,
/// the text hanging after it.
#let list-items(t) = {
  let items = ()
  for l in t.split(regex("\\r?\\n")) {
    let m = l.match(regex("^(\\d+\\.|[-*+])[ \\t]+(.*)$"))
    if m != none { items.push((ordered: m.captures.at(0).ends-with("."), text: m.captures.at(1))) }
    else if items.len() > 0 { items.last().text += " " + l.trim() }
  }
  for (j, it) in items.enumerate() {
    let lab = if it.ordered { numbering("a.", j + 1) } else { "\u{2022}" }
    block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: list-left, all: true),
      hanging-indent: list-left + para-indent, [#box(width: para-indent, lab)#md(it.text)]))
  }
}

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a list is one
/// numbered paragraph (Fed. R. Civ. P. 10(b)). Headings and lists are not numbered.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let n = 0
  for t in chunks {
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      list-items(t)
    } else {
      n += 1
      body-par(n, md(t))
    }
  }
}

#let mssd-complaint(meta, body) = {
  // Page numbers centered on every page, in a single-spaced line box (Word's footer at the same place).
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double spaced); lists are set by list-items.
  show: xengine.with(pitch: pitch-double, list-indent: none)

  // Headings single-spaced, centered, bold: level 1 in capitals (a section), level 2 as written (a count); a double
  // line above, kept with the block after them.
  show heading: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { upper(it.body) } else { it.body }
    block(sticky: true, width: 100%, above: heading-above, below: 0pt, align(center, text(weight: "bold", b)))
  }

  cover(meta)
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }
  allegations(body)
  signature-block(meta)
}
