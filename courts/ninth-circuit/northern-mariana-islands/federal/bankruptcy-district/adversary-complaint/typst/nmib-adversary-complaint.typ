// Adversary complaint for the Bankruptcy Court of the Northern Mariana Islands (Bankruptcy Division).
// Rules: FRBP 7001 (proceeding is an adversary proceeding), 7003 (commencement; Fed. R. Civ. P. 3 applies),
// 7008 (pleading; statement of consent to final orders), 7010 (Fed. R. Civ. P. 10 applies; caption must
// substantially conform to Official Form 416D); LBR 5005-1(b) (caption: chapter), LBR 7003-1 (cover sheet,
// not generated here), LR 5.2(a) via LBR 9004-1 (see ../rules.md, NMIB-FORM-...; ../README.md, NMIB-ADV-...).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // NMIB-FORM-004: a serif font, no face named; Times New Roman, the house standard (docs/FONTS.md)
#let type-size = 12pt                   // NMIB-FORM-004: 12 point or larger
#let pitch = 24pt                       // NMIB-FORM-003: double spacing on the numbered lines
#let pitch-single = 12pt                // NMIB-FORM-003: counsel, caption, signature: two single lines per numbered line
#let single-drop = 0.8 * (pitch - pitch-single)   // a single-line block starts this far down, so its odd lines stand on the numbered lines
#let lines-per-page = 24                // NMIB-FORM-003: numbers 1 to 24 down the margin (as the filed motion in this court)
#let page-w = 8.5in
#let page-h = 11in
#let top-margin = 1.5in                 // NMIB-FORM-005: top margin 1.5 in
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 1.5 in (at least the 1 in of NMIB-FORM-005): holds the footer
#let left-margin = 1.3in                // NMIB-FORM-005: at least 1 in; room for the line numbers
#let right-margin = 1in                 // NMIB-FORM-005: at least 0.5 in
#let text-width = page-w - left-margin - right-margin
#let para-indent = 0.5in
#let num-box = 0.5in                    // the paragraph number's box: the text starts 1 in from the margin
#let list-label = 0.4in                 // the box of a list label "(a)", set at the paragraph indent
#let designation-indent = 1in           // the designation under a party's names (Form 416D)
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-pad = 10pt                 // the party column's text stands this far from its right rule
#let caption-foot = 8pt                 // and this far above its bottom rule
#let caption-gutter = 0.3in             // the right column's text starts this far right of the rule
#let sig-col = 2.8in                    // signature: the 2.6 in "Dated" column and a 0.2 in gutter
#let counsel-lines = 7                  // the court title starts after the counsel block, at least on line 8
#let footer-size = 10pt
#let footer-pitch = 12pt                // the footer's lines
#let footer-gap = 4pt                   // between the page number and the title line
#let number-col = left-margin - 0.45in  // the line numbers end 0.45 in left of the text

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nmib-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

#let need(meta, key) = {
  if key not in meta { panic("nmib-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One single-spaced line (a paragraph of its own); an empty item is a blank single line.
#let single(body, left: 0pt, above: 0pt) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if body == "" { block(width: 100%, height: pitch-single, above: 0pt, below: 0pt) } else { pad(left: left, inl(body)) }
})

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 24 down the left margin, each in the line box of its numbered line.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: number-col, height: pitch,
        align(right, text(size: type-size, ..edges(pitch), str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// The page number, centered, and under it the paper's short title and the case number, below the last numbered line.
#let footer-block(title, case-number) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 6pt,
  block(width: text-width, {
    set text(size: footer-size, ..edges(footer-pitch))
    set par(first-line-indent: 0pt, leading: 0pt)
    block(width: 100%, above: 0pt, below: 0pt, align(center, context counter(page).display()))
    block(width: 100%, above: footer-gap, below: 0pt, grid(
      columns: (1fr, auto),
      upper(title),
      [CASE NO. #case-number],
    ))
  }),
)

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-7), court title, caption (Official Form 416D), title of the paper
// ---------------------------------------------------------------------------

#let counsel-block(meta) = {
  let ls = need(meta, "counsel")
  // Lines 1-7 at least; more counsel lines push the court title down.
  context {
    let body = pad(top: single-drop, { for l in ls { single(l) } })
    let h = measure(width: text-width, body).height
    block(width: text-width, height: calc.max(counsel-lines, calc.ceil(h / pitch)) * pitch, above: 0pt, below: 0pt, body)
  }
}

#let court-title(meta) = {
  for l in need(meta, "court") {
    block(width: 100%, above: 0pt, below: 0pt, align(center, text(weight: "bold", upper(l))))
  }
}

/// Form 416D: each side is a block (In re debtor; plaintiff; defendant) with its designation under it.
#let caption(meta) = {
  let sides = need(meta, "caption")
  let left = {
    for (i, side) in sides.enumerate() {
      if i > 0 { single("") }
      for n in side.names { single(n) }
      single(side.designation, left: designation-indent)
    }
  }
  // The clerk assigns the adversary number; a blank is printed until it is known.
  let adv = meta.at("adv_number", default: "\\_" * 8)
  let right = {
    single("Case No. " + need(meta, "case_number"))
    single("Chapter " + need(meta, "chapter"))
    single("")
    single("Adv. Proc. No. " + adv)
    single("")
    block(width: 100%, above: 0pt, below: 0pt, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      text(weight: "bold", inl(need(meta, "brief_title")))
    })
    if "jury_demand" in meta and meta.jury_demand {
      single("")
      block(width: 100%, above: 0pt, below: 0pt, {
        set text(..edges(pitch-single))
        text(weight: "bold", "DEMAND FOR JURY TRIAL")
      })
    }
  }
  block(width: 100%, above: pitch, below: 0pt, grid(
    columns: (caption-left, 1fr),
    grid.cell(stroke: (right: 0.75pt, bottom: 0.75pt), inset: (top: single-drop, right: caption-pad, bottom: caption-foot), left),
    grid.cell(inset: (top: single-drop, left: caption-gutter), right),
  ))
}

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  caption(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, above: pitch, below: 0pt, breakable: false, grid(
    columns: (sig-col, 1fr),
    inset: (top: single-drop),
    single("Dated: " + need(meta, "date")),
    {
      single("Respectfully submitted,")
      single("")
      for l in sig.firm { single(l) }
      single("")
      single("By: /s/ " + sig.signer)
      single(sig.signer)
      for l in sig.lines { single(l) }
    },
  ))
}

/// A markdown list as lettered items (a), (b), ...: the label in a box at the paragraph indent, the text hanging after it.
#let list-items(t) = {
  show enum: it => {
    let n = 0
    for item in it.children {
      n += 1
      block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent,
        par(hanging-indent: list-label, first-line-indent: 0pt, [#box(width: list-label, numbering("(a)", n))#item.body])))
    }
  }
  show list: it => {
    for item in it.children {
      block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent,
        par(hanging-indent: list-label, first-line-indent: 0pt, [#box(width: list-label, [•])#item.body])))
    }
  }
  md(t)
}

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph (Fed. R. Civ. P. 10(b)). Headings and lists are rendered unnumbered.
/// A paragraph that starts with "~ " is unnumbered (a lead-in such as WHEREFORE); the marker is not printed.
/// Headings are kept with the first lines of what follows them (sticky).
#let allegations(body) = {
  let n = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      list-items(t)
    } else if t.starts-with("~ ") {
      block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), md(t.slice(2).trim())))
    } else {
      n += 1
      block(width: 100%, above: 0pt, below: 0pt,
        par(first-line-indent: 0pt, [#h(para-indent)#box(width: num-box, [#n.])#md(t)]))
    }
  }
}

#let nmib-adversary-complaint(meta, body) = {
  let footer-title = need(meta, "footer_title")

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(footer-title, need(meta, "case_number")),
  )
  set document(
    title: need(meta, "brief_title") + ", Adv. Proc. No. " + meta.at("adv_number", default: "(blank)"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the numbered-line pitch (double spaced); the docx engine sets the same twips.
  show: xengine.with(pitch: pitch, list-indent: none)
  // A doubled sign stays with its number too ("§§ 1334(b)"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Headings: level 1 a centered bold capital line; level 2 centered bold; level 3 bold italic at the margin.
  // One numbered line each (the numbered-line pitch), kept with what follows.
  show heading: it => block(sticky: true, width: 100%, above: 0pt, below: 0pt, {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      align(center, text(weight: "bold", it.body))
    } else { text(weight: "bold", style: "italic", it.body) }
  })

  cover(meta)
  // Body: numbered allegations (Fed. R. Civ. P. 10(b)); markdown lists become (a), (b), ...
  allegations(body)
  signature-block(meta)
}
