// Adversary complaint for the United States Bankruptcy Court for the Northern District of Mississippi (msnb).
// Governing rules: Fed. R. Bankr. P. 7010 (Fed. R. Civ. P. 10 applies; caption substantially conforms to
// Official Form 416A), 9004(a) (legible papers), 9004(b) (caption contents), Fed. R. Civ. P. 10(b)
// (numbered paragraphs, one set of circumstances each). The local rules of msnb were not reachable when this
// template was written, so the format choices below are standard-letter defaults flagged in ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no local-rule font found; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt
#let page-w = 8.5in
#let page-h = 11in
#let margin = 1in
#let body-leading = 1.345em             // double spacing at 12 pt (Liberation Serif line box is 0.655em)
#let single-leading = 0.495em
#let para-indent = 0.5in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("msnb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, emphasis).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Double-spaced body text: the leading is set here, inside the block, so it survives the paragraphs
/// that cmarker creates.
#let body-text(c) = {
  set par(leading: body-leading, spacing: body-leading, justify: false)
  c
}

/// Blank-line-separated chunks of the body, trimmed, with empty chunks dropped.
#let chunks(body) = body.split("\n\n").map(s => s.trim()).filter(s => s != "")

/// Counter for numbered allegations (Fed. R. Civ. P. 10(b)).
#let para-count = counter("para")

/// A numbered allegation: "1." then the text, first line indented.
#let allegation(c) = {
  para-count.step()
  body-text[
    #h(para-indent)
    #context para-count.display("1.")
    #h(0.25em)
    #c
  ]
}

/// An unnumbered paragraph (a markdown blockquote in the sample): e.g. the WHEREFORE lead-in.
#let unnumbered(c) = body-text[
  #h(para-indent)
  #c
]

/// A heading: centered bold capitals (level 1) or bold (level 2).
#let heading-block(level, text-md) = {
  let t = text-md.replace(regex("^#+\\s*"), "").trim()
  if level == 1 {
    align(center, block(above: 18pt, below: 12pt, sticky: true, text(weight: "bold", upper(t))))
  } else {
    align(center, block(above: 12pt, below: 12pt, sticky: true, text(weight: "bold", t)))
  }
}

/// A lettered list (a markdown "- " list): sub-items under a numbered allegation, "(a)", "(b)", ...
#let lettered(s) = {
  let letters = "abcdefghijklmnopqrstuvwxyz"
  let items = s.split("\n").map(l => l.trim()).filter(l => l != "")
  body-text[
    #for (i, item) in items.enumerate() {
      let text-item = item.replace(regex("^-\\s*"), "")
      grid(
        columns: (0.5in + para-indent, 1fr),
        [#h(para-indent) (#letters.at(i))],
        inl(text-item),
      )
    }
  ]
}

/// A numbered list (a markdown "1." list): the prayer for relief, "1.", "2.", ...
#let numbered-items(s) = {
  let items = s.split("\n").map(l => l.trim()).filter(l => l != "")
  body-text[
    #for item in items {
      let m = item.match(regex("^(\\d+)\\.\\s*"))
      grid(
        columns: (0.5in + para-indent, 1fr),
        [#h(para-indent) #(m.captures.at(0) + ".")],
        inl(item.slice(m.end)),
      )
    }
  ]
}

// ---------------------------------------------------------------------------
// Cover: counsel, court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let counsel-block(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  for line in meta.counsel {
    inl(line)
    linebreak()
  }
}

#let court-title() = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  align(center, text(weight: "bold", [UNITED STATES BANKRUPTCY COURT])) + linebreak()
  align(center, text(weight: "bold", [NORTHERN DISTRICT OF MISSISSIPPI]))
  v(12pt)
}

/// The caption, as the filed exemplar sets it: full-width rows, party labels flush right, one rule under the
/// debtor row. The debtor and the case number share the first row; the adversary parties follow.
#let caption(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  let names(list) = for (i, n) in list.enumerate() {
    if i > 0 { linebreak() }
    inl(n)
  }
  grid(
    columns: (1fr, auto),
    column-gutter: 0.5in,
    [IN RE: #names(meta.debtor.names)],
    align(right, [NO. #meta.case_number]),
  )
  v(6pt)
  line(length: 100%, stroke: 0.75pt)
  v(12pt)
  grid(
    columns: (1fr, auto),
    column-gutter: 0.5in,
    names(meta.plaintiffs),
    align(right, [PLAINTIFF#if meta.plaintiffs.len() > 1 [S]]),
  )
  v(18pt)
  grid(
    columns: (1fr, auto),
    column-gutter: 0.5in,
    [VS.],
    align(right, [ADVERSARY NO. #meta.adv_number]),
  )
  v(18pt)
  grid(
    columns: (1fr, auto),
    column-gutter: 0.5in,
    names(meta.defendants),
    align(right, [#meta.at("defendants_label", default: "DEFENDANT")]),
  )
  v(12pt)
}

// ---------------------------------------------------------------------------
// Signature block
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let s = meta.signature
  block(width: 100%, breakable: false, {
    v(12pt)
    if "dated" in meta {
      h(para-indent)
      [DATED: #meta.dated]
      v(12pt)
    }
    // The firm, the signature line and the title sit in the right column; the counsel block that
    // follows is flush left, as in the filed exemplar.
    align(right, block(width: 3.2in, {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      text(weight: "bold", inl(s.firm))
      v(24pt)
      [By: #underline[/s/ #s.signer]]
      linebreak()
      h(0.5in)
      [#s.title]
    }))
    v(18pt)
    set par(leading: single-leading, spacing: 0pt, justify: false)
    for line in s.lines {
      inl(line)
      linebreak()
    }
  })
}

// ---------------------------------------------------------------------------
// Entry: the full complaint
// ---------------------------------------------------------------------------

#let msnb-adversary-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: margin, bottom: margin, left: margin, right: margin),
    footer: context align(center, text(size: 10pt, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, justify: false, spacing: 0pt)

  if meta.counsel.len() > 0 {
    counsel-block(meta)
    v(18pt)
  }
  court-title()
  caption(meta)
  align(center, block(above: 6pt, below: 18pt, text(weight: "bold", upper(meta.title))))

  for c in chunks(body) {
    if c.starts-with("#") {
      heading-block(c.match(regex("^#+")).text.len(), c)
    } else if c.starts-with(">") {
      unnumbered(inl(c.replace(regex("^>\\s*"), "")))
    } else if c.starts-with("- ") {
      lettered(c)
    } else if c.match(regex("^\\d+\\.\\s")) != none {
      numbered-items(c)
    } else {
      allegation(inl(c))
    }
  }

  signature(meta)
}
