// Motion with memorandum for the U.S. Bankruptcy Court, District of New Mexico (nmb).
// Rules: Fed. R. Bankr. P. 9013 (motion states the grounds with particularity), 7010 and 9004 (caption as in the
// complaint), NM LBR 9013-1(a) (the title describes the relief sought), 9013-1(i) and 7007-1 (briefs optional in
// adversary proceedings unless ordered), 9013-1(j) (certificate of service for every motion), 9011-1(a) (contact
// block under the signature). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // no typeface rule in FRBP or NM LBR; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // convention (no size rule); matches the filed exemplar's body
#let body-leading = 1.345em             // double spacing: about 24 pt baseline pitch at 12 pt (convention)
#let single-leading = 0.6em             // counsel, caption, block quotations and signature block
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let margin = 1in                       // all four sides (convention; the rules give no margin)
#let footer-size = 10pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nmb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names, citations, amounts).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A paragraph body with `[^n]` markers replaced by footnotes whose text is in the frontmatter.
#let with-notes(s, notes) = {
  let ms = s.matches(regex("\\[\\^(\\d+)\\]"))
  let pos = 0
  let out = []
  for m in ms {
    out += inl(s.slice(pos, m.start))
    out += footnote(inl(notes.at(m.captures.at(0))))
    pos = m.end
  }
  out + inl(s.slice(pos))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

#let page-footer(title) = context {
  let p = counter(page).get().first()
  let total = counter(page).final().first()
  set text(size: footer-size)
  grid(columns: (1fr, auto), title, [Page #p of #total])
}

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 7010; Official Form 416 layout: court, debtor and case, parties and adversary number, title)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  for l in meta.court {
    align(center, text(weight: "bold", l))
  }
  v(single-leading * 2)
  // Contested matter in the main case (no adversary parties): the debtor sits in a box and the chapter and case
  // number sit to its right, as in the filed exemplar (FILED-EXAMPLE, p. 1). Adversary captions keep the parties box.
  if meta.at("parties", default: ()).len() == 0 {
    grid(
      columns: (3.4in, 1fr),
      gutter: 0.25in,
      block(width: 100%, inset: 0.12in, stroke: 0.6pt, [
        #for l in meta.debtor [#l \ ]
      ]),
      align(top + right, [
        #if meta.at("chapter", default: none) != none [#meta.chapter \ ]
        #meta.case_number
      ]),
    )
  } else {
    grid(
      columns: (1fr, 1fr),
      block(width: 100%, [
        #for l in meta.debtor [#l \ ]
      ]),
      align(top + right, [#meta.case_number]),
    )
    v(single-leading * 2)
    grid(
      columns: (3.4in, 1fr),
      gutter: 0.25in,
      block(width: 100%, inset: (right: 0.12in, bottom: 0.12in), stroke: (right: 0.6pt, bottom: 0.6pt), [
        #for p in meta.parties [
          #p.names \
          #p.role \ #v(single-leading)
        ]
      ]),
      align(horizon, [#meta.adv_number]),
    )
  }
  v(single-leading * 2)
  align(center, text(weight: "bold", meta.title))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Signature block (NM LBR 9011-1(a): name, address, telephone and e-mail below the signature line)
// ---------------------------------------------------------------------------

#let signature(sig) = block(breakable: false, [
  #pad(left: 3.25in, [
    Respectfully Submitted,
    #v(single-leading)
    #text(weight: "bold", sig.firm)
    #v(body-leading)
    By: #box(width: 2.6in, line(length: 100%, stroke: 0.5pt))
    #v(0pt)
    #sig.signer \
    #for l in sig.lines [
      #l \
    ]
    #sig.email \
    #sig.role
  ])
])

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

// Certificate of service (NM LBR 9013-1(j)): present when the frontmatter carries a `certificate` block.
#let certificate(c) = block(breakable: false, [
  #v(body-leading)
  #align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
  #v(body-leading * 0.5)
  #block(width: 100%, [#h(para-indent) #inl(c)])
])

#let nmb-motion-brief(meta, body) = {
  set page(paper: "us-letter", margin: margin, footer: page-footer(meta.footer_title))
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, justify: false, first-line-indent: 0pt)
  set block(spacing: body-leading)
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: set text(size: 10pt)

  caption(meta)

  // Unnumbered lead-in paragraph, from the frontmatter.
  block(width: 100%, [#h(para-indent) #with-notes(meta.lead_in, meta.footnotes)])

  let para = 0
  let letter = 0
  for chunk in body.replace("\r\n", "\n").split("\n\n") {
    let t = chunk.trim()
    if t == "" { continue }

    // Heading: one or more '#'. Level 1 and 2 are centered bold; level 3 is centered bold as well (claim sub-heading).
    let hm = t.match(regex("^(#+)\\s+([\\s\\S]*)$"))
    if hm != none {
      letter = 0
      block(sticky: true, width: 100%, align(center, text(weight: "bold", inl(hm.captures.at(1)))))
      continue
    }

    // Blockquote: lines starting with '>'; rendered single-spaced and indented.
    if t.starts-with(">") {
      letter = 0
      let inner = t.split("\n").map(l => l.replace(regex("^>\\s?"), "")).join("\n")
      pad(left: 0.75in, right: 0.75in, block(width: 100%, {
        set par(leading: single-leading)
        inl(inner)
      }))
      continue
    }

    // Indented markdown list: sub-items of the preceding numbered paragraph, lettered (a), (b), ...
    let lm = chunk.match(regex("^[ \t]+\\d+\\.\\s+"))
    if lm != none {
      letter += 1
      let letters = "abcdefghijklmnopqrstuvwxyz"
      pad(left: para-indent, grid(columns: (0.4in, 1fr), gutter: 0pt,
        [(#letters.at(letter - 1))],
        with-notes(chunk.slice(lm.end).trim(), meta.footnotes)))
      v(body-leading * 0.5)
      continue
    }

    letter = 0

    // Numbered paragraph: the template numbers the paragraphs; typed numbers are dropped.
    let nm = t.match(regex("^\\d+\\.\\s+"))
    if nm != none {
      para += 1
      block(width: 100%, [#h(para-indent)#para.#h(0.4em)#with-notes(t.slice(nm.end), meta.footnotes)])
      continue
    }

    // Anything else is an unnumbered paragraph: first-line indent, as the filed memorandum's introduction and argument.
    block(width: 100%, [#h(para-indent) #with-notes(t, meta.footnotes)])
  }

  block(width: 100%, [#h(para-indent) #with-notes(meta.prayer, meta.footnotes)])

  v(body-leading)
  signature(meta.signature)
  if meta.at("certificate", default: none) != none {
    certificate(meta.certificate)
  }
}
