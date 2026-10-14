// Motion with memorandum brief for the United States Bankruptcy Court for the Northern District of Mississippi (msnb).
// Governing rules: Fed. R. Bankr. P. 9013 (a request for an order must be made by written motion; a motion must
// state its grounds with particularity and set forth the relief requested), 9004(a) (legible papers), 9004(b)
// (caption contents). The local rules of msnb (L.U.Bankr.R. 9013-1 and any format rule) were not reachable when
// this template was written; the format below is a standard-letter default flagged in ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/; no local-rule font found (see README.md)
#let type-size = 12pt
#let margin = 1in
#let body-leading = 1.35em              // double spacing at 12 pt (EB Garamond line box is 0.65em)
#let single-leading = 0.5em
#let para-indent = 0.5in
#let caption-left = 3.4in               // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("msnb-motion-brief: the sample must start with a YAML frontmatter block") }
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

/// A prose paragraph: memorandum style, first line indented, not numbered.
#let prose(c) = body-text[
  #h(para-indent)
  #c
]

/// A heading: centered bold capitals (level 1), bold (level 2), bold italic at the left (level 3).
#let heading-block(level, text-md) = {
  let t = text-md.replace(regex("^#+\\s*"), "").trim()
  if level == 1 {
    align(center, block(above: 18pt, below: 12pt, sticky: true, text(weight: "bold", upper(t))))
  } else if level == 2 {
    block(above: 12pt, below: 12pt, sticky: true, text(weight: "bold", t))
  } else {
    block(above: 12pt, below: 12pt, sticky: true, text(weight: "bold", style: "italic", t))
  }
}

/// A lettered list (the relief requested, or the grounds; markdown "- " bullets): "(a)", "(b)", ...
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

/// Counter for numbered motion paragraphs (markdown "1." lines).
#let motion-count = counter("motion")

/// Numbered motion paragraphs: each "1." line is one paragraph, numbered in order.
#let numbered(s) = {
  let items = s.split("\n").map(l => l.trim()).filter(l => l != "")
  for item in items {
    let text-item = item.replace(regex("^\\d+\\.\\s*"), "")
    motion-count.step()
    body-text[
      #h(para-indent)
      #context motion-count.display("1.")
      #h(0.25em)
      #inl(text-item)
    ]
  }
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

/// The caption: the debtor and the case number. A contested motion may name the movant and respondent
/// in the same left column when the frontmatter gives them.
#let caption(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  block(width: 100%, grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.2in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
      text(weight: "bold", [IN RE:])
      v(4pt)
      for n in meta.debtor.names {
        inl(n)
        linebreak()
      }
      v(4pt)
      inl(meta.debtor.role)
    }),
    block(inset: (left: 0.2in), {
      [CASE NO. #meta.case_number]
      if "chapter" in meta.debtor {
        linebreak()
        [Chapter #meta.debtor.chapter]
      }
    }),
  ))
  v(12pt)
}

// ---------------------------------------------------------------------------
// Signature block
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let s = meta.signature
  block(width: 100%, breakable: false, {
    v(12pt)
    align(right, block(width: 3.2in, {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Respectfully submitted,]
      v(18pt)
      inl(s.firm)
      v(18pt)
      [By: /s/ #upper(s.signer)]
      linebreak()
      for line in s.lines {
        inl(line)
        linebreak()
      }
    }))
  })
}

// ---------------------------------------------------------------------------
// Entry: the full motion and memorandum brief
// ---------------------------------------------------------------------------

#let msnb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: margin, bottom: margin, left: margin, right: margin),
    footer: context align(center, text(size: 10pt, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, justify: false, spacing: 0pt)

  counsel-block(meta)
  v(18pt)
  court-title()
  caption(meta)
  align(center, block(above: 6pt, below: 18pt, text(weight: "bold", upper(meta.title))))

  for c in chunks(body) {
    if c.starts-with("#") {
      heading-block(c.match(regex("^#+")).text.len(), c)
    } else if c.match(regex("^-\\s")) != none {
      lettered(c)
    } else if c.match(regex("^\\d+\\.\\s")) != none {
      numbered(c)
    } else {
      prose(inl(c))
    }
  }

  signature(meta)
}
