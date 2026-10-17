// U.S. Bankruptcy Court, Eastern District of Washington: adversary complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (WAEB-AC-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed complaint, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the
// YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")          // WAEB-AC-FORM-001: proportionally spaced serif. Vendored in /fonts.
#let type-size = 14pt                      // WAEB-AC-FORM-001: 14 points or more, everywhere (LBR 9004-1(a)(3)).
#let body-leading = 0.94em                 // WAEB-AC-FORM-002: double spacing (LBR 9004-1(a)(3)); about 2.2 x type size.
#let single-leading = 0.12em               // counsel block, caption, quotations, footnotes, signature lines.
#let page-margin = 1in                     // WAEB-AC-FORM-004: letter paper; the rules give no margin, 1 inch is used.
#let para-indent = 0.5in                   // WAEB-AC-BODY-002: numbered paragraphs.
// WAEB-AC-CAP-001: the court's own title, the same on every filing (FRCP 10(a) as applied by FRBP 7010).
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
  if key not in meta { panic("waeb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("waeb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// First page: counsel block, court title, caption (FRBP 9004-1(a)(4)-(6), FRCP 10(a))
// ---------------------------------------------------------------------------

/// Counsel block, upper left, single-spaced (WAEB-AC-CAP-002: attorney name, address and
/// telephone "on the left side above line five" in LBR 9004-1(a)(6)). `counsel` is one list of
/// lines, or a list of groups (one group per firm), which then sit in side-by-side columns so the
/// caption stays on page 1.
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

/// Court title: on or below the fifth line (WAEB-AC-CAP-003: LBR 9004-1(a)(4)).
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
/// jury demand on the right (WAEB-AC-CAP-004: LBR 9004-1(a)(5)(A)-(D)).
#let caption(meta) = block(breakable: false, grid(
  columns: (0.6fr, 0.4fr), column-gutter: 0.3in,
  block(width: 100%, inset: (right: 0.15in, bottom: 0.12in), stroke: (right: 0.7pt, bottom: 0.7pt), {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    [In re:]
    linebreak()
    for n in need(meta, "in_re") {
      pad(left: 0.5in, inl(n))
      linebreak()
    }
    v(single-leading)
    for (i, p) in need(meta, "parties").enumerate() {
      if i > 0 {
        pad(left: 0.8in, [v.])
        v(single-leading)
      }
      for n in p.names {
        inl(n)
        linebreak()
      }
      pad(left: 1.5in, inl(p.designation))
      if i < need(meta, "parties").len() - 1 { v(single-leading) }
    }
  }),
  block(width: 100%, inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    inl(need(meta, "related_case"))
    linebreak()
    inl(need(meta, "adversary_no"))
    v(body-leading)
    text(weight: "bold", inl(need(meta, "title")))
    if meta.at("jury_demand", default: false) {
      v(body-leading)
      [DEMAND FOR JURY TRIAL]
    }
  }),
))

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lettered lists, unnumbered centered lines
// ---------------------------------------------------------------------------

/// Split the markdown body into blank-line-separated chunks.
#let chunks(md) = md.split(regex("\n\\s*\n")).map(s => s.trim()).filter(s => s != "")

/// Body of the complaint. Every chunk is one of:
///   `# Heading`        centered bold caps (no number); `# EXHIBIT ...` starts a new page.
///   `## Heading`       lettered A., B., ... (counter restarts under each `#` heading).
///   `**Line**`         unnumbered, centered bold line (cause-of-action subtitles, WHEREFORE lead-ins).
///   `- item` lines     lettered (a), (b), ... ; used for the prayer and sub-allegations.
///   `| table |`        a markdown table (exhibits).
///   `~ text`           an unnumbered paragraph, first line indented (WHEREFORE, the closing lines).
///   anything else      a numbered paragraph (FRCP 10(b)): numbered 1, 2, ... by the template.
#let complaint-body(md) = {
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
        if t.starts-with("EXHIBIT") { out.push(pagebreak(weak: true)) }
        out.push(block(width: 100%, sticky: true, above: body-leading, below: body-leading, align(center, text(weight: "bold", inl(t)))))
      } else {
        sub-n += 1
        out.push(block(width: 100%, sticky: true, above: body-leading, below: body-leading, text(weight: "bold", [#numbering("A.", sub-n)#h(0.5em)#inl(t)])))
      }
    } else if bold != none {
      out.push(block(width: 100%, sticky: true, above: body-leading, below: body-leading, align(center, text(weight: "bold", inl(bold.captures.at(0))))))
    } else if lines.all(l => l.starts-with("- ")) {
      let li = 0
      for item in lines {
        li += 1
        out.push(pad(left: para-indent, grid(columns: (0.5in, 1fr), [#numbering("(a)", li)], inl(item.slice(2)))))
      }
    } else if c.starts-with("|") {
      out.push(block(above: body-leading, below: body-leading, inl(c)))
    } else if c.starts-with("~ ") {
      out.push(block(width: 100%, sticky: true, [#h(para-indent)#inl(c.slice(2))]))
    } else {
      para-n += 1
      out.push(block(width: 100%, [#h(para-indent)#numbering("1.", para-n)#h(0.5em)#inl(c)]))
    }
  }
  out.join()
}

// ---------------------------------------------------------------------------
// Signature block (WAEB-AC-SIG-001: FRBP 9011 and LBR 9004-1(a)(4): name typed under each signature)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let s = need(meta, "signature")
  block(breakable: false, above: body-leading, width: 100%, {
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    grid(columns: (1fr, 3.0in), [#s.date], [#inl(s.firm)])
    v(body-leading)
    pad(left: 3.0in, [/s/ #inl(s.signer)])
    for line in s.lines {
      pad(left: 3.0in, inl(line))
    }
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let complaint(meta, md) = {
  for k in ("in_re", "parties", "related_case", "adversary_no", "title", "counsel", "signature") { let _ = need(meta, k) }

  set document(
    title: plain(inl(need(meta, "title"))),
    author: need(meta, "signature").signer,
  )
  set page(
    paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context [
      #set text(size: type-size)
      #align(left)[#meta.at("footer_title", default: "COMPLAINT")#h(1em)#counter(page).display()]
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
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show regex("\\S*\\)\\(\\S*"): it => box(it)   // "548(a)(1)(A)" never breaks inside
  show regex("[§¶] \\S+"): it => box(it)        // a section sign never ends a line

  // ---- first page ----
  counsel-block(meta)
  court-heading()
  if "division" in meta { align(center, inl(meta.division)); v(body-leading) }
  caption(meta)
  v(body-leading)

  // ---- body, signature (after the prayer), then the exhibits on their own pages ----
  let ex = md.match(regex("(?m)^# EXHIBIT"))
  let body-md = if ex == none { md } else { md.slice(0, ex.start) }
  let exhibits-md = if ex == none { "" } else { md.slice(ex.start) }
  complaint-body(body-md)
  signature-block(meta)
  complaint-body(exhibits-md)
}
