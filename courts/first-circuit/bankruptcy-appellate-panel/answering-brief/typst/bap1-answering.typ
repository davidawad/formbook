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
#let body-leading = 0.94em           // BAP-FORM-004: double spacing (FRBP 8015(a)(4)), with the ascender/descender line box set below.
#let single-leading = 0.12em         // block quotations, headings, footnotes, TOC and TOA: single-spaced.
#let line-gap = 0.35em             // gap between the single-spaced lines of the cover, captions and signature blocks.
#let form-leading = 0.65em          // plain single spacing (typst's default) for signature blocks and the L.R. 8014-1 statements.
#let page-margin = 1in               // BAP-FORM-002: one inch on all four sides (FRBP 8015(a)(4)).
#let para-indent = 0.5in
#let passim-threshold = 7            // an authority cited on this many pages or more prints "passim".

#let kinds = (
  opening: (
    title: "BRIEF FOR APPELLANT",
    word-limit: 13000,               // FRBP 8015(a)(7)(A): principal brief.
    // FRBP 8014(a) fixes the content of each section, not its title: each entry lists the titles
    // it accepts (filers write "Summary of Argument", "Statement of Appellate Jurisdiction").
    required: (
      ("Jurisdictional Statement", "Statement of Jurisdiction", "Statement of Appellate Jurisdiction",
        "Statement of the Basis for Appellate Jurisdiction"),
      ("Statement of the Issues", "Statement of Issues", "Statement of the Issues Presented",
        "Issues Presented"),
      ("Statement of the Case",),
      ("Summary of the Argument", "Summary of Argument"),
      ("Argument",),
      ("Conclusion",),
    ),
    limit-cite: "Fed. R. Bankr. P. 8015(a)(7)(A)",
  ),
  answering: (
    title: "BRIEF FOR APPELLEE",
    word-limit: 13000,               // FRBP 8015(a)(7)(A): the answering brief has the principal-brief limit.
    required: (("Argument",), ("Conclusion",)),                     // FRBP 8014(b)
    limit-cite: "Fed. R. Bankr. P. 8015(a)(7)(A)",
  ),
  reply: (
    title: "REPLY BRIEF FOR APPELLANT",
    word-limit: 6500,                // FRBP 8015(a)(7)(B): half the principal-brief type-volume limit.
    required: (("Argument",), ("Conclusion",)),                     // FRBP 8014(c)
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
/// The title of the case (FRBP 8015(a)(2)(C)): the debtor ("In re") when given, then the
/// parties with their designations. Each line is its own block: in code mode, adjacent content
/// blocks would otherwise run together.
#let case-title(meta) = {
  if "debtor" in meta {
    for name in meta.debtor.names { block(inl(name)) }
    block[#meta.debtor.designation]
    v(0.6em)
  }
  for (i, side) in need(meta, "caption").enumerate() {
    for name in side.names { block(inl(name)) }
    block[#side.designation]
    if i == 0 { v(0.4em); block[v.]; v(0.4em) }
  }
}

#let court-name = (
  block[UNITED STATES BANKRUPTCY APPELLATE PANEL],
  block[FOR THE FIRST CIRCUIT],
)

/// The brief's title, identifying the party for whom it is filed (FRBP 8015(a)(2)(E)).
#let brief-title(meta) = if "party" in meta { kind.title + ", " + upper(meta.party) } else { kind.title }

#let cover(meta) = {
  set align(center)
  set par(leading: single-leading)
  set block(spacing: line-gap)
  // FRBP 8015(a)(2)(A): the number of the case centered at the top.
  block[BAP No. #need(meta, "case_number")]
  v(1.2fr)
  court-name.join()
  // The bankruptcy case number sits above the title of the case, as on 1st Cir. BAP Official
  // Forms 1 and 2 (and on both filed bap1 exemplars).
  if "bankruptcy_case" in meta { v(0.6em); block[Bankruptcy Case No. #meta.bankruptcy_case] }
  v(0.8fr)
  case-title(meta)
  v(0.8fr)
  block(inl(need(meta, "proceeding")))
  v(1fr)
  block(text(weight: "bold", brief-title(meta)))
  v(1fr)
  set align(left)
  // Counsel (FRBP 8015(a)(2)(F)). Several counsel groups are set side by side in two columns so the
  // cover stays one page; a single group keeps the full width.
  let groups = need(meta, "counsel").map(group => {
    for name in group.names { block(text(weight: "bold", upper(name))) }
    for line in group.lines { block(inl("*" + line + "*")) }
  })
  grid(columns: if groups.len() > 1 { (1fr, 1fr) } else { (1fr,) }, column-gutter: 1em, row-gutter: 0.7em, ..groups)
  v(0.7em)
  if "phone" in meta { block[Telephone: #meta.phone] }
}

/// A front-matter page title (not an outline entry).
#let front-title(s) = align(center, block(below: 1.2em, text(weight: "bold", upper(s))))

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let bap1-brief(meta, md) = {
  // Required sections (FRBP 8014) must appear as level-1 headings.
  // Titles are compared case-insensitively (filers set them in capitals or in title case).
  let md-lower = lower("\n" + md)
  for titles in kind.required {
    if titles.all(h => not md-lower.contains("\n# " + lower(h) + "\n")) {
      panic("bap1-brief: the " + doc-kind + " brief needs a level-1 heading titled one of `"
        + titles.join("`, `") + "` (FRBP 8014)")
    }
  }

  let body = cmarker.render(md, smart-punctuation: true)
  let words = plain(body).split(regex("\\s+")).filter(w => w.find(regex("[A-Za-z0-9]")) != none).len()
  if words > kind.word-limit {
    panic("bap1-brief: " + str(words) + " words exceeds the " + str(kind.word-limit) + "-word limit (" + kind.limit-cite + ")")
  }

  set document(title: kind.title + " (BAP No. " + need(meta, "case_number") + ")")
  set page(paper: "us-letter", margin: page-margin, numbering: "1")
  // BAP-FORM-004: the metric-aligned line box (ascender to descender) with body-leading gives a
  // baseline pitch of about 2.2 x the type size, i.e. double spacing (as in the CA9 template).
  set text(font: font-family, size: type-size, lang: "en", ligatures: true,
    top-edge: "ascender", bottom-edge: "descender")
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
  // Headings are single-spaced (FRBP 8015(a)(4): "Headings and footnotes may be single-spaced").
  show heading: set par(leading: single-leading)
  // Headings at the body size: both filed bap1 exemplars (different filers) set them so; the rules leave it open.
  show heading: set text(size: type-size)
  show heading.where(level: 1): it => block(above: 1.2em, below: 1em, width: 100%,
    align(center, text(weight: "bold", upper(plain(it.body)))))
  // Level 2 (I., II.): left, bold, with its number, as in the contents. Both filed bap1 exemplars
  // (different filers) set the argument points this way; the rules leave it open.
  show heading.where(level: 2): it => block(above: 1em, below: 1em, width: 100%,
    par(first-line-indent: 0pt, hanging-indent: para-indent, text(weight: "bold",
      [#context counter(heading).display(it.numbering)#h(0.6em)#it.body])))
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
  // Single-spaced entries with a gap between them (FRBP 8015(a)(4) asks double spacing of the text only).
  {
    set par(leading: single-leading)
    show outline.entry: set block(spacing: 0.8em)
    context outline(title: none, depth: 4, indent: auto)
  }
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
        // One entry: single-spaced, wrapped lines indented, dot leaders to the pages (both filed bap1
        // exemplars, different filers, set their tables this way; the rules leave it open).
        let name = if e.name != none and g.kind == "case" { [#emph(e.name), #e.cite] } else if e.name != none { [#e.name, #e.cite] } else { [#e.cite] }
        // The pages sit in their own column, level with the entry's last line.
        block(below: 0.8em, grid(columns: (1fr, auto), column-gutter: 0.3em, align: (left, bottom),
          par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1em,
            [#name #box(width: 1fr, repeat(gap: 0.2em)[.])]),
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
  // Plain single spacing (as in the L.R. 8014-1 statements below), so the block stays compact.
  block(breakable: false, {
    set text(top-edge: "cap-height", bottom-edge: "baseline")
    set par(leading: form-leading)
    set block(spacing: form-leading)
    block[Respectfully submitted,]
    if "date" in meta { block[#meta.date] }
    v(0.8em)
    block[s/ #upper(need(meta, "signature").signer)]
    for line in need(meta, "signature").lines { block(inl("*" + line + "*")) }
  })

  // Certificate of compliance (FRBP 8015(h)); wording follows Form 417C in substance.
  pagebreak()
  front-title("Certificate of Compliance")
  par(first-line-indent: para-indent, [This brief complies with the type-volume limitation of #kind.limit-cite because it contains #words words, excluding the parts of the brief exempted under Fed. R. Bankr. P. 8015(g).])
  par(first-line-indent: para-indent, [This brief complies with the typeface and type-style requirements of Fed. R. Bankr. P. 8015(a)(5) and (6) because it has been prepared in a proportionally spaced typeface, #font-family #str(type-size / 1pt)-point, using the vendored font.])
  v(1.2em)
  // Plain single spacing (as in the L.R. 8014-1 statements below), so the block stays compact.
  block(breakable: false, {
    set text(top-edge: "cap-height", bottom-edge: "baseline")
    set par(leading: form-leading)
    set block(spacing: form-leading)
    block[s/ #upper(need(meta, "signature").signer)]
    for line in need(meta, "signature").lines.slice(0, 1) { block(inl("*" + line + "*")) }
    if "date" in meta { block[Dated: #meta.date] }
  })

  // The two statements of 1st Cir. BAP L.R. 8014-1(a)(2) and (3) are "attached to the last page"
  // of the brief, "substantially in the form of" Official Forms 1 and 2: each repeats the caption
  // (court, BAP No., bankruptcy case number, title of the case), then the statement, then the
  // signature of the attorney or pro se party with address and telephone.
  // Each statement is one page: it is set in plain single spacing (the font's default line box,
  // form-leading between lines), which these statements may use (they are not brief text).
  let form-statement(title, rule, statement) = {
    pagebreak()
    set text(top-edge: "cap-height", bottom-edge: "baseline")
    let single-leading = form-leading
    let line-gap = form-leading
    {
      set align(center)
      set par(leading: single-leading)
      set block(spacing: line-gap)
      court-name.join()
      v(0.6em)
      block[BAP No. #need(meta, "case_number")]
      if "bankruptcy_case" in meta { block[Bankruptcy Case No. #meta.bankruptcy_case] }
      v(0.6em)
      case-title(meta)
      v(0.6em)
      block(below: 0.2em, text(weight: "bold", upper(title)))
      block(below: 1.2em, rule)
    }
    {
      set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.2em)
      statement
    }
    v(1.2em)
    block(breakable: false, width: 100%, inset: (left: 50%), {
      set par(leading: single-leading, first-line-indent: 0pt)
      set block(spacing: line-gap)
      block[s/ #upper(need(meta, "signature").signer)]
      for line in need(meta, "signature").lines { block(inl(line)) }
      if "date" in meta { block[Dated: #meta.date] }
    })
  }

  // Statement regarding related cases (L.R. 8014-1(a)(2), Official Form 1): every party filing a brief.
  let rc = meta.at("related_cases", default: (status: "none"))
  form-statement("Statement Regarding Related Cases", [1st Cir. BAP L.R. 8014-1(a)(2)], {
    block(below: 0.8em, [#checkbox(rc.status == "pending") The undersigned certifies that the following are known related cases and appeals:])
    if rc.status == "pending" {
      for c in rc.cases { block(below: 0.4em, pad(left: 0.5in, [#c.number, #c.name (#c.relationship)])) }
    }
    block(below: 0.8em, [#checkbox(rc.status == "none") The undersigned certifies that the undersigned knows of no related cases or appeals as that term is defined in 1st Cir. BAP L.R. 8014-1(a)(2)(A).])
  })

  // Statement regarding interested parties (L.R. 8014-1(a)(3), Official Form 2): every party filing
  // a brief "other than governmental parties". Filing it satisfies FRBP 8012 (L.R. 8012-1(a)).
  if not meta.at("governmental_party", default: false) {
    let ip = meta.at("interested_parties", default: (status: "none"))
    form-statement("Statement Regarding Interested Parties", [1st Cir. BAP L.R. 8014-1(a)(3)], {
      block(below: 0.8em, [#checkbox(ip.status == "listed") The undersigned certifies that the following parties have an interest in the outcome of this appeal. These representations are made to enable the judges of the Panel to evaluate possible disqualification or recusal.])
      if ip.status == "listed" {
        for p in ip.parties { block(below: 0.4em, pad(left: 0.5in, inl(p))) }
      }
      block(below: 0.8em, [#checkbox(ip.status == "none") The undersigned certifies that the undersigned knows of no interested party as that term is defined in 1st Cir. BAP L.R. 8014-1(a)(3)(A).])
    })
  }
}
