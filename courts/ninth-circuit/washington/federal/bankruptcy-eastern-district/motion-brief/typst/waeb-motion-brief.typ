// U.S. Bankruptcy Court, Eastern District of Washington: memorandum supporting a motion.
//
// Rule-driven and content-agnostic. Requirement IDs (WAEB-MB-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed memorandum, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the
// YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"          // WAEB-MB-FORM-001: proportionally spaced serif. Vendored in /fonts.
#let type-size = 14pt                      // WAEB-MB-FORM-001: 14 points or more, everywhere (LBR 9004-1(a)(3)).
#let body-leading = 0.94em                 // WAEB-MB-FORM-002: double spacing (LBR 9004-1(a)(3)); about 2.2 x type size.
#let single-leading = 0.12em               // counsel block, caption, quotations, footnotes, signature lines.
#let page-margin = 1in                     // WAEB-MB-FORM-004: letter paper; the rules give no margin, 1 inch is used.
#let para-indent = 0.5in                   // WAEB-MB-BODY-002: numbered paragraphs.
// WAEB-MB-CAP-001: the court's own title, the same on every filing (FRCP 10(a) as applied by FRBP 7010).
#let court-title = ("UNITED STATES BANKRUPTCY COURT", "EASTERN DISTRICT OF WASHINGTON")

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Plain text of a piece of content, for comparisons and metadata only.
#let plain(c) = {
  if type(c) == str { c }
  else if c == [] { "" }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain).join() }
  else if c.has("body") { plain(c.body) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

#let need(meta, key) = {
  if key not in meta { panic("waeb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("waeb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// First page: judge, court title, counsel block, caption (FRBP 9004-1, FRCP 10(a))
// ---------------------------------------------------------------------------

/// Assigned judge, upper right, when the filing names one (optional; not a rule requirement).
#let judge-line(meta) = {
  if "judge" in meta {
    align(right, inl(meta.judge))
    v(body-leading)
  }
}

/// Counsel block, upper left, single-spaced (WAEB-MB-CAP-002: attorney name, address and
/// telephone "on the left side above line five" in LBR 9004-1(a)(6)). `counsel` is one list of
/// lines, or a list of groups (one group per firm), which then sit in side-by-side columns.
#let counsel-block(meta) = {
  let c = need(meta, "counsel")
  let groups = if type(c.first()) == array { c } else { (c,) }
  block(width: 100%, grid(
    columns: groups.map(g => 1fr), column-gutter: 0.3in,
    ..groups.map(g => block(width: 100%, {
      set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
      for line in g {
        inl(line)
        linebreak()
      }
    }))
  ))
}

/// Court title: on or below the fifth line (WAEB-MB-CAP-003: LBR 9004-1(a)(4)).
#let court-heading() = {
  v(single-leading)
  set par(leading: single-leading, spacing: single-leading)
  for line in court-title {
    align(center, text(weight: "bold", line))
    linebreak()
  }
  v(single-leading)
}

/// Caption: debtor and parties on the left, related case, adversary number, title and
/// jury demand on the right (WAEB-MB-CAP-004: LBR 9004-1(a)(5)(A)-(D)). The party list may run
/// onto the next page (a long plaintiff list does); the title block stays whole.
#let caption(meta) = grid(
  columns: (0.6fr, 0.4fr), column-gutter: 0.3in,
  block(width: 100%, inset: (right: 0.15in, bottom: 0.12in), stroke: (right: 0.7pt, bottom: 0.7pt), {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    [In re]
    linebreak()
    v(single-leading)
    for n in need(meta, "in_re") {
      pad(left: 0.5in, inl(n))
      linebreak()
    }
    v(single-leading)
    // A party (its names, its designation, the "v." before it) never splits across pages.
    let parties = need(meta, "parties")
    for (i, p) in parties.enumerate() {
      block(breakable: false, {
        if i > 0 {
          pad(left: 0.8in, inl(p.at("joiner", default: "v.")))
          v(single-leading)
        }
        for n in p.names {
          inl(n)
          linebreak()
        }
        pad(left: 1.5in, inl(p.designation))
      })
      if i < parties.len() - 1 { v(single-leading) }
    }
  }),
  block(width: 100%, inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    v(single-leading)
    inl(need(meta, "related_case"))
    linebreak()
    v(body-leading)
    inl(need(meta, "adversary_no"))
    v(body-leading)
    text(weight: "bold", inl(need(meta, "title")))
    if meta.at("jury_demand", default: false) {
      v(body-leading)
      [DEMAND FOR JURY TRIAL]
    }
  }),
)

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lettered lists, unnumbered lines
// WAEB-MB-BODY-001: numbered paragraphs (a convention the exemplar follows; see ../README.md).
// ---------------------------------------------------------------------------

/// Split the markdown body into blank-line-separated chunks.
#let chunks(md) = md.split(regex("\n\\s*\n")).map(s => s.trim()).filter(s => s != "")

/// Body of the memorandum. Every chunk is one of:
///   `# Heading`        centered bold caps (no number).
///   `## Heading`       lettered A., B., ... (counter restarts under each `#` heading).
///   `**Line**`         unnumbered, centered bold line.
///   `- item` lines     lettered (a), (b), ...
///   `~ text`           an unnumbered paragraph, first line indented (the opening paragraph,
///                      the excerpt note).
///   anything else      a numbered paragraph (FRCP 10(b) as applied; memoranda number their
///                      paragraphs in the filed practice): numbered 1, 2, ... by the template.
#let memo-body(md) = {
  let out = ()
  let para-n = 0
  let sub-n = 0
  for c in chunks(md) {
    let hd = c.match(regex("^(#{1,2})\\s+([\\s\\S]*)$"))
    let bold = c.match(regex("^\\*\\*([^*]+)\\*\\*$"))
    let lines = c.split("\n")
    if hd != none {
      let lvl = hd.captures.at(0).len()
      let t = hd.captures.at(1).trim()
      if lvl == 1 {
        sub-n = 0
        out.push(block(width: 100%, sticky: true, above: body-leading, below: body-leading, align(center, text(weight: "bold", inl(t)))))
      } else {
        sub-n += 1
        out.push(block(width: 100%, sticky: true, above: body-leading, below: body-leading, pad(left: para-indent, text(weight: "bold", grid(columns: (0.5in, 1fr), [#numbering("A.", sub-n)], inl(t))))))
      }
    } else if bold != none {
      out.push(block(width: 100%, sticky: true, above: body-leading, below: body-leading, align(center, text(weight: "bold", inl(bold.captures.at(0))))))
    } else if lines.all(l => l.starts-with("- ")) {
      let li = 0
      for item in lines {
        li += 1
        out.push(pad(left: para-indent, grid(columns: (0.5in, 1fr), [#numbering("(a)", li)], inl(item.slice(2)))))
      }
    } else if c.starts-with("~ ") {
      out.push(block(width: 100%, [#h(para-indent)#inl(c.slice(2))]))
    } else {
      para-n += 1
      out.push(block(width: 100%, [#h(para-indent)#numbering("1.", para-n)#h(0.5em)#inl(c)]))
    }
  }
  out.join()
}

// ---------------------------------------------------------------------------
// Signature block (WAEB-MB-SIG-001: FRBP 9011 and LBR 9004-1(a)(4): name typed under each
// signature). One block per firm; blocks after the first are joined by "-and-".
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let s = need(meta, "signature")
  block(breakable: false, above: body-leading, width: 100%, {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    [#s.date]
    v(body-leading)
    for (i, b) in s.blocks.enumerate() {
      if i > 0 {
        pad(left: 3.0in, [-and-])
        v(single-leading)
      }
      pad(left: 3.0in, inl(b.firm))
      if "signer" in b {
        v(body-leading)
        pad(left: 3.0in, [/s/ #inl(b.signer)])
      }
      for line in b.lines {
        pad(left: 3.0in, inl(line))
      }
      v(body-leading)
    }
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let memorandum(meta, md) = {
  for k in ("in_re", "parties", "related_case", "adversary_no", "title", "counsel", "signature") { let _ = need(meta, k) }

  set document(
    title: plain(inl(need(meta, "title"))),
    author: need(meta, "signature").blocks.at(0).signer,
  )
  set page(
    paper: "us-letter", margin: page-margin, footer-descent: 30%,
    // WAEB-MB-FOOT-001: LBR 9004-1(a)(7), abbreviated document name then page number, bottom left.
    footer: context [
      #set text(size: type-size)
      #align(left)[#meta.at("footer_title", default: "MEMORANDUM")#h(1em)#counter(page).display()]
    ],
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: body-leading,
    first-line-indent: 0pt, justify: false,
  )
  set heading(numbering: none)
  set footnote.entry(
    gap: 0.5em, clearance: 0.9em, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size)   // typst's default is 0.85em; the rules allow nothing under 14 pt
    // WAEB-MB-FORM-003: LBR 9004-1(a)(3) requires footnotes double-spaced (only quotations may be single spaced).
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: body-leading, spacing: body-leading)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show regex("\\S*\\)\\(\\S*"): it => box(it)   // "548(a)(1)(A)" never breaks inside
  show regex("[§¶] \\S+"): it => box(it)        // a section sign never ends a line

  // ---- first page ----
  judge-line(meta)
  counsel-block(meta)
  court-heading()
  caption(meta)
  v(body-leading)

  // ---- body, then the signature block after the last paragraph ----
  memo-body(md)
  signature-block(meta)
}
