// United States Bankruptcy Appellate Panel for the First Circuit: one brief (doc-kind below).
//
// Rule-driven and content-agnostic. Requirement IDs (BAP-...) refer to ../README.md, which
// cites the rules and the date they were checked. No case-specific text, no coordinates measured
// off any filed brief, no forced line breaks. The markdown body is rendered by cmarker; the
// metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// The only per-document-type constant. Each doc-type folder carries its own copy with its value.
#let doc-kind = "answering"   // "opening" | "answering" | "reply"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"     // BAP-FORM-003: serif, proportional (FRBP 8015(a)(5)). Vendored in /fonts.
#let type-size = 14pt                // BAP-FORM-003: 14-point or larger (FRBP 8015(a)(5)).
#let body-leading = 0.94em           // BAP-FORM-004: double spacing (FRBP 8015(a)(4)); same metric as the CA9 template.
#let single-leading = 0.12em         // block quotations, headings, footnotes, TOC and TOA: single-spaced.
#let page-margin = 1in               // BAP-FORM-002: one inch on all four sides (FRBP 8015(a)(4)).
#let para-indent = 0.5in
#let passim-threshold = 7            // an authority cited on this many pages or more prints "passim".

#let kinds = (
  opening: (
    title: "BRIEF FOR APPELLANT",
    word-limit: 13000,               // FRBP 8015(a)(7)(A): principal brief.
    required: ("Jurisdictional Statement", "Statement of the Issues", "Statement of the Case",
      "Summary of the Argument", "Argument", "Conclusion"),        // FRBP 8014(a)
    limit-cite: "Fed. R. Bankr. P. 8015(a)(7)(A)",
  ),
  answering: (
    title: "BRIEF FOR APPELLEE",
    word-limit: 13000,               // FRBP 8015(a)(7)(A): the answering brief has the principal-brief limit.
    required: ("Argument", "Conclusion"),                           // FRBP 8014(b)
    limit-cite: "Fed. R. Bankr. P. 8015(a)(7)(A)",
  ),
  reply: (
    title: "REPLY BRIEF FOR APPELLANT",
    word-limit: 6500,                // FRBP 8015(a)(7)(B): half the principal-brief type-volume limit.
    required: ("Argument", "Conclusion"),                           // FRBP 8014(c)
    limit-cite: "Fed. R. Bankr. P. 8015(a)(7)(B)",
  ),
)
#let kind = kinds.at(doc-kind)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, smart-punctuation: true)

/// Plain text of a piece of content, for comparisons and word counts only.
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
  if key not in meta { panic("bap1-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A drawn check box (no font glyph needed, so no fallback can occur).
#let checkbox(checked) = box(
  width: 0.72em, height: 0.72em, baseline: 0.05em, stroke: 0.7pt, inset: 0pt,
  if checked {
    place(top + left, line(start: (0pt, 0pt), end: (100%, 100%), stroke: 0.9pt))
    place(top + left, line(start: (0pt, 100%), end: (100%, 0pt), stroke: 0.9pt))
  },
)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("bap1-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Front matter
// ---------------------------------------------------------------------------

/// Cover (FRAP 32(a)(2) conventions applied by the BAP's cover sheet; see README.md "Cover").
#let cover(meta) = {
  set align(center)
  // Each line is its own block: in code mode, adjacent content blocks would otherwise run together.
  block[BAP No. #need(meta, "case_number")]
  v(1.2fr)
  block[UNITED STATES BANKRUPTCY APPELLATE PANEL]
  block[FOR THE FIRST CIRCUIT]
  v(0.8fr)
  for (i, side) in need(meta, "caption").enumerate() {
    for name in side.names { block(inl(name)) }
    block[#side.designation]
    if i == 0 { v(0.4em); block[v.]; v(0.4em) }
  }
  v(0.8fr)
  block(inl(need(meta, "proceeding")))
  if "bankruptcy_case" in meta { block[Bankruptcy Case No. #meta.bankruptcy_case] }
  v(1fr)
  block(text(weight: "bold", kind.title))
  v(1fr)
  set align(left)
  for group in need(meta, "counsel") {
    for name in group.names { block(text(weight: "bold", upper(name))) }
    for line in group.lines { block(inl("*" + line + "*")) }
    v(0.7em)
  }
  if "phone" in meta { block[Telephone: #meta.phone] }
}

/// A front-matter page title (not an outline entry).
#let front-title(s) = align(center, block(below: 1.2em, text(weight: "bold", upper(s))))

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let bap1-brief(meta, md) = {
  // Required sections (FRBP 8014) must appear as level-1 headings.
  for h in kind.required {
    if not md.contains("\n# " + h + "\n") and not md.starts-with("# " + h + "\n") {
      panic("bap1-brief: the " + doc-kind + " brief needs a level-1 heading `" + h + "` (FRBP 8014)")
    }
  }

  let body = cmarker.render(md, smart-punctuation: true)
  let words = plain(body).split(regex("\\s+")).filter(w => w.find(regex("[A-Za-z0-9]")) != none).len()
  if words > kind.word-limit {
    panic("bap1-brief: " + str(words) + " words exceeds the " + str(kind.word-limit) + "-word limit (" + kind.limit-cite + ")")
  }

  set document(title: kind.title + " (BAP No. " + need(meta, "case_number") + ")")
  set page(paper: "us-letter", margin: page-margin, numbering: "1")
  set text(font: font-family, size: type-size, lang: "en", ligatures: true)
  set par(justify: false, leading: body-leading, first-line-indent: para-indent, spacing: body-leading)
  show footnote.entry: set text(size: type-size)
  show link: it => if type(it.dest) == str and it.dest.starts-with("toa:") { it.body } else { it }

  // Numbering: argument points I., A., 1., a. (level 2 on); level 1 sections are unnumbered.
  set heading(numbering: (..nums) => {
    let p = nums.pos()
    let n = p.last()
    if p.len() == 1 { none }
    else if p.len() == 2 { numbering("I.", n) }
    else if p.len() == 3 { numbering("A.", n) }
    else if p.len() == 4 { numbering("1.", n) }
    else { numbering("a.", n) }
  })
  show heading.where(level: 1): it => block(above: 1.2em, below: 1em, width: 100%,
    align(center, text(weight: "bold", upper(plain(it.body)))))
  show heading.where(level: 2): it => block(above: 1em, below: 1em, width: 100%,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(above: 1em, below: 0.8em, text(weight: "bold", it))
  show heading.where(level: 4): it => block(above: 0.8em, below: 0.6em, text(weight: "bold", it))
  show heading.where(level: 5): it => block(above: 0.8em, below: 0.6em, text(style: "italic", it))
  show quote: it => block(inset: (left: 0.5in, right: 0.5in), par(leading: single-leading, first-line-indent: 0pt, it.body))
  show heading.where(level: 1): set block(sticky: true)

  // Page 1: cover. No page number.
  set page(numbering: none)
  cover(meta)
  pagebreak()
  set page(numbering: "1")

  // Corporate disclosure statement (FRBP 8012), only when the case needs one.
  if "disclosure" in meta {
    front-title("Corporate Disclosure Statement")
    par(first-line-indent: para-indent, inl(meta.disclosure))
    pagebreak()
  }

  // Table of contents (FRBP 8014(a)(2)); level-2 and deeper are outline entries.
  front-title("Table of Contents")
  context outline(title: none, depth: 4, indent: auto)
  pagebreak()

  // Table of authorities (FRBP 8014(a)(3)): built from toa: links in the body, with the pages they start on.
  front-title("Table of Authorities")
  context {
    let ls = query(link).filter(l => type(l.dest) == str and l.dest.starts-with("toa:"))
    let auths = meta.at("authorities", default: (:))
    let groups = (
      (kind: "case", title: "Cases"),
      (kind: "constitution", title: "Constitutional Provisions"),
      (kind: "statute", title: "Statutes"),
      (kind: "regulation", title: "Regulations"),
      (kind: "rule", title: "Rules"),
      (kind: "other", title: "Other Authorities"),
    )
    for g in groups {
      let keys = auths.keys().filter(k => auths.at(k).kind == g.kind)
      if keys.len() == 0 { continue }
      let entries = keys.map(k => {
        let a = auths.at(k)
        let pages = ls.filter(l => l.dest == "toa:" + k).map(l => l.location().page())
          .sorted().dedup().map(str)
        let refs = if pages.len() == 0 { "" }
          else if pages.len() >= passim-threshold { "passim" }
          else { pages.join(", ") }
        (sort: a.at("sort", default: a.at("name", default: a.cite)), name: a.at("name", default: none), cite: a.cite, refs: refs)
      }).sorted(key: e => lower(e.sort))
      text(weight: "bold", g.title)
      v(0.4em)
      for e in entries {
        block(below: 0.6em, grid(columns: (1fr, auto), column-gutter: 0.4em,
          if e.name != none and g.kind == "case" { [#emph(e.name), #e.cite] } else if e.name != none { [#e.name, #e.cite] } else { [#e.cite] },
          e.refs))
      }
      v(0.4em)
    }
  }
  pagebreak()

  // Statement regarding oral argument (1st Cir. BAP L.R. 8019-1(a)): after the tables, before the first page.
  if "oral-argument" in meta {
    front-title("Statement Regarding Oral Argument")
    par(first-line-indent: para-indent, inl(meta.at("oral-argument")))
    pagebreak()
  }

  // The brief itself.
  body

  // Signature block (after the conclusion).
  v(1.2em)
  block(breakable: false, {
    block[Respectfully submitted,]
    if "date" in meta { block[#meta.date] }
    v(0.8em)
    block[s/ #upper(need(meta, "signature").signer)]
    for line in need(meta, "signature").lines { block(inl("*" + line + "*")) }
  })

  // Statement regarding related cases (1st Cir. BAP L.R. 8014-1(a)(2)); attached to the last page.
  pagebreak()
  front-title("Statement Regarding Related Cases")
  let rc = meta.at("related_cases", default: (status: "none"))
  par(first-line-indent: para-indent, [1st Cir. BAP L.R. 8014-1(a)(2)])
  block(below: 0.8em, [#checkbox(rc.status == "pending") The undersigned certifies that the following are known related cases and appeals:])
  if rc.status == "pending" {
    for c in rc.cases { block(below: 0.4em, pad(left: 0.5in, [#c.number, #c.name (#c.relationship)])) }
  }
  block(below: 0.8em, [#checkbox(rc.status == "none") The undersigned certifies that the undersigned knows of no related cases or appeals as that term is defined in 1st Cir. BAP L.R. 8014-1(a)(2)(A).])

  // Certificate of compliance (FRBP 8015(h)); wording follows Form 417C in substance.
  pagebreak()
  front-title("Certificate of Compliance")
  par(first-line-indent: para-indent, [This brief complies with the type-volume limitation of #kind.limit-cite because it contains #words words, excluding the parts of the brief exempted under Fed. R. Bankr. P. 8015(g).])
  par(first-line-indent: para-indent, [This brief complies with the typeface and type-style requirements of Fed. R. Bankr. P. 8015(a)(5) and (6) because it has been prepared in a proportionally spaced typeface, #font-family #str(type-size / 1pt)-point, using the vendored font.])
  v(1.2em)
  block(breakable: false, {
    block[s/ #upper(need(meta, "signature").signer)]
    for line in need(meta, "signature").lines.slice(0, 1) { block(inl("*" + line + "*")) }
    if "date" in meta { block[Dated: #meta.date] }
  })
}
