// United States Bankruptcy Appellate Panel for the First Circuit: one brief (doc-kind below).
//
// Rule-driven and content-agnostic. Requirement IDs (BAP-...) refer to ../README.md, which
// cites the rules and the date they were checked. No case-specific text, no coordinates measured
// off any filed brief, no forced line breaks. The markdown body is rendered by cmarker; the
// metadata comes from the YAML frontmatter of the same file (schema: ../README.md).
//
// The reference of the cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"):
// the docx engine (../docx/bap1.lua) breaks every line and page where this template does. Every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between two blocks is the larger of the
// space below the one and above the other (Word's exact line spacing).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// The only per-document-type constant. Each doc-type folder carries its own copy with its value.
#let doc-kind = "reply"   // "opening" | "answering" | "reply"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // BAP-FORM-003: serif, proportional (FRBP 8015(a)(5)); no rule names a face, the exemplar is Times New Roman (docs/FONTS.md rules 3 and 6; fb-9fyu)
#let type-size = 14pt                // BAP-FORM-003: 14-point or larger (FRBP 8015(a)(5)); footnotes too.
#let pitch-double = 31.4pt           // BAP-FORM-004: double spacing (FRBP 8015(a)(4)), about 2.24 x the type size.
#let pitch-single = 20pt             // block quotations, headings, footnotes, cover, TOC and TOA: single-spaced.
#let pitch-form = 18.4pt             // signature blocks and the L.R. 8014-1 statements: plain single spacing.
#let cover-gap = 3.2pt               // between the single-spaced lines of the cover and captions.
#let page-margin = 1in               // BAP-FORM-002: one inch on all four sides (FRBP 8015(a)(4)).
#let para-indent = 0.5in             // paragraph indent, heading label box, list label box.
#let box-col = 1.6em                 // the check-box column of the L.R. 8014-1 statements.
#let toc-page-col = 36pt             // TOC: the page numbers keep the last 36 pt of the line to themselves.
#let toa-page-col = 56pt             // TOA: page lists such as 1, 4, 6, 8 (a longer list widens its own row's column).
#let tab-room = 4.5pt                // a table row keeps this much room after its text besides the leader's three spaces:
                                     // LibreOffice sets the docx engine's right tab (beyond the right indent) only
                                     // with 90 twips to spare, so typst breaks the row's text where it does.
#let passim-threshold = 7           // an authority cited on this many pages or more prints "passim".

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
#let face = if type(font-family) == array { font-family.first() } else { font-family }

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, smart-punctuation: true)

/// Plain text of a piece of content, for comparisons and word counts only. Block elements (paragraphs,
/// headings, list items, quotations, footnotes) are set off by spaces, so their words never run together:
/// the count is block by block, as the docx engine counts.
#let block-funcs = (heading, footnote, list.item, enum.item, quote, par, terms.item)
#let plain(c) = {
  if type(c) == str { c }
  else if c == [] { "" }
  else if c.func() in block-funcs and c.has("body") { " " + plain(c.body) + " " }
  else if c.func() == parbreak or c.func() == linebreak { " " }
  else if c.has("text") { if type(c.text) == str { c.text } else { plain(c.text) } }
  else if c.has("children") { c.children.map(plain).join() }
  else if c.has("body") { plain(c.body) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

#let need(meta, key) = {
  if key not in meta { panic("bap1-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A check box: a ruled box around a literal X (nothing when unchecked), in a column of its own.
#let checkbox(checked) = box(width: box-col, box(
  // the box hugs the capitals (its line box is the line's own), so it does not make its line taller
  stroke: 0.6pt, inset: (x: 1pt), outset: (y: 1.5pt),
  { set text(top-edge: "cap-height", bottom-edge: "baseline"); if checked [X] else { hide("\u{a0}\u{a0}\u{a0}") } },
))

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("bap1-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Front matter
// ---------------------------------------------------------------------------

/// The title of the case (FRBP 8015(a)(2)(C)): the debtor ("In re") when given, then the
/// parties with their designations. Each line is its own block.
#let case-title(meta) = {
  if "debtor" in meta {
    for name in meta.debtor.names { block(inl(name)) }
    block(below: 8.4pt)[#meta.debtor.designation]
  }
  for (i, side) in need(meta, "caption").enumerate() {
    for name in side.names { block(inl(name)) }
    block[#side.designation]
    if i == 0 { block(above: 5.6pt, below: 5.6pt)[v.] }
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
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  set block(spacing: cover-gap)
  // FRBP 8015(a)(2)(A): the number of the case centered at the top.
  block[BAP No. #need(meta, "case_number")]
  v(1.2fr)
  court-name.join()
  // The bankruptcy case number sits above the title of the case, as on 1st Cir. BAP Official
  // Forms 1 and 2 (and on both filed bap1 exemplars).
  if "bankruptcy_case" in meta { block(above: 11.2pt)[Bankruptcy Case No. #meta.bankruptcy_case] }
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
    for line in group.at("lines", default: ()) { block(inl("*" + line + "*")) }
  })
  grid(columns: if groups.len() > 1 { (1fr, 1fr) } else { (1fr,) }, column-gutter: 1em, row-gutter: 9.8pt, ..groups)
  if "phone" in meta { block(above: 9.8pt)[Telephone: #meta.phone] }
}

/// A citation of the table of authorities: its text, with a marker (metadata labelled <toa-ref>, value the link's
/// destination) boxed with its first word, so the marker sits on the page where the citation's first word is (a
/// link's own location can fall at the end of the line before, a page early, when the citation opens a line).
#let toa-marked(body, dest) = {
  let mark = [#metadata(dest)<toa-ref>]
  // (content, done): `c` with the marker boxed with its first word, when it has one
  let walk(c) = {
    if c.func() == text {
      let s = c.text
      let m = s.match(regex("^(\\s*)([§¶]\\s+\\S+|\\S+)"))
      if m == none { return (c, false) }
      let (lead, word) = m.captures
      return ([#text(lead)#box[#mark#text(word)]#text(s.slice(m.end))], true)
    }
    if c.has("children") {
      let out = ()
      let done = false
      for ch in c.children {
        if done { out.push(ch) } else {
          let (x, d) = walk(ch)
          out.push(x)
          done = d
        }
      }
      return (out.join(), done)
    }
    if c.func() == emph or c.func() == strong {
      let (x, d) = walk(c.body)
      return ((c.func())(x), d)
    }
    (c, false)
  }
  let (x, done) = walk(body)
  if done { x } else { [#mark#body] }
}

/// A front-matter page title (not an outline entry); it opens its page.
#let front-title(s) = block(above: 0pt, below: 16.8pt, width: 100%, sticky: true,
  align(center, text(..edges(pitch-single), weight: "bold", upper(s))))

/// The label of a numbered heading (I., A., 1., a.) as the body and the contents print it.
#let heading-label(hd) = numbering(hd.numbering, ..counter(heading).at(hd.location()))

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
  // The page number: centered in a single-spaced line box (Word's footer), the same place on every page.
  let footer = context align(center, text(..edges(pitch-single), counter(page).display()))
  set page(paper: "us-letter", margin: page-margin, numbering: "1", footer-descent: 30%, footer: footer)
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set par(first-line-indent: para-indent)
  // The cross-engine layout model (lib/typst/xengine.typ): first fit, no kerning or ligatures, no hyphenation, line
  // boxes of the body pitch (BAP-FORM-004), footnote marks at 58 %, lists with the number in a half-inch box.
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // Footnote marks scaled from the regular digits (as Word and LibreOffice set them), never the font's own
  // superscript glyphs (Liberation Serif has them; their advances differ).
  set super(typographic: false)
  // No break after a slash inside a word ("and/or"): Unicode line breaking allows one there, LibreOffice (the docx
  // engine) does not.
  show regex("\\S+/\\S+"): it => box(it)
  // A loose list (items separated by blank lines) gives each item a paragraph break of its own, which may not sit
  // inside the item's hanging paragraph: the item is its one paragraph, as in the docx engine's list items.
  let tight(b) = if b.func() == [].func() { b.children.filter(c => c.func() != parbreak).join() } else { b }
  show enum: it => if it.children.all(i => tight(i.body) == i.body) { it } else {
    enum(..it.children.map(i => enum.item(..if i.has("number") { (i.number,) } else { () }, tight(i.body))),
      start: it.start, numbering: it.numbering)
  }
  show list: it => if it.children.all(i => tight(i.body) == i.body) { it } else {
    list(..it.children.map(i => list.item(tight(i.body))))
  }
  set footnote.entry(gap: 7pt, clearance: 12.6pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))   // FRBP 8015(a)(4): footnotes may be single-spaced
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 7pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show link: it => if type(it.dest) == str and it.dest.starts-with("toa:") { toa-marked(it.body, it.dest) } else { it }

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
  // Headings are single-spaced (FRBP 8015(a)(4): "Headings and footnotes may be single-spaced"), at the body
  // size: both filed bap1 exemplars (different filers) set them so; the rules leave it open.
  show heading: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    if it.level == 1 {
      block(above: 16.8pt, below: 14pt, width: 100%, sticky: true,
        align(center, text(weight: "bold", upper(plain(it.body)))))
    } else {
      // Level 2 on (I., A., 1., a.): left, with the label in a half-inch box and the text hanging after it. Both
      // filed bap1 exemplars (different filers) set the argument points this way; the rules leave it open.
      let (above, below) = if it.level <= 3 { (14pt, if it.level == 2 { 14pt } else { 11.2pt }) } else { (11.2pt, 8.4pt) }
      let st = if it.level >= 5 { (style: "italic") } else { (weight: "bold") }
      block(above: above, below: below, width: 100%, sticky: true,
        par(hanging-indent: para-indent, text(..st, { box(width: para-indent, heading-label(it)); it.body })))
    }
  }
  // Block quotations: indented a half inch both sides, single-spaced (FRBP 8015(a)(4)).
  show quote.where(block: true): it => block(above: 14pt, below: 14pt, pad(left: para-indent, right: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: 14pt)
    it.body
  }))

  // Page 1: cover. No page number.
  {
    set page(footer: none)
    cover(meta)
  }

  // Corporate disclosure statement (FRBP 8012), only when the case needs one.
  if "disclosure" in meta {
    front-title("Corporate Disclosure Statement")
    inl(meta.disclosure)
    pagebreak()
  }

  // Table of contents (FRBP 8014(a)(2)): every heading to level 4, the page in a column of its own.
  front-title("Table of Contents")
  {
    set text(..edges(pitch-single))
    show outline.entry: it => {
      let hd = it.element
      let ind = if hd.level <= 2 { 0pt } else { (hd.level - 2) * para-indent }
      listing-row(hd.location(), {
        h(ind)
        if hd.level >= 2 { box(width: para-indent, heading-label(hd)) }
        hd.body
        h(tab-room)
      }, it.page(), toc-page-col, if hd.level >= 2 { ind + para-indent } else { 0pt }, 11.2pt)
    }
    outline(title: none, depth: 4)
  }
  pagebreak()

  // Table of authorities (FRBP 8014(a)(3)): built from toa: links in the body, with the pages they start on.
  front-title("Table of Authorities")
  context {
    set text(..edges(pitch-single))
    let ls = query(<toa-ref>)
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
      let entries = keys.map(k => {
        let a = auths.at(k)
        let pages = ls.filter(l => l.value == "toa:" + k).map(l => l.location().page())
          .sorted().dedup().map(str)
        let refs = if pages.len() == 0 { "" }
          else if pages.len() >= passim-threshold { "passim" }
          else { pages.join(", ") }
        (sort: a.at("sort", default: a.at("name", default: a.cite)), name: a.at("name", default: none), cite: a.cite, refs: refs)
      }).filter(e => e.refs != "").sorted(key: e => lower(e.sort))
      // An authority the body never cites has no page to point to: it is left out, as is an empty group.
      if entries.len() == 0 { continue }
      block(above: 14pt, below: 5.6pt, sticky: true, text(weight: "bold", g.title))
      for e in entries {
        // One entry: single-spaced, wrapped lines indented, a dot leader to the pages, which keep a column of
        // their own (both filed bap1 exemplars, different filers, set their tables this way).
        let name = if e.name != none and g.kind == "case" { [#emph(inl(e.name)), #inl(e.cite)] } else if e.name != none { [#inl(e.name), #inl(e.cite)] } else { inl(e.cite) }
        listing-row(none, { name; h(tab-room) }, e.refs, calc.max(toa-page-col, measure(e.refs).width), 1em, 3.5pt)
      }
    }
  }
  pagebreak()

  // Statement regarding oral argument (1st Cir. BAP L.R. 8019-1(a)): after the tables, before the first page.
  if "oral-argument" in meta {
    front-title("Statement Regarding Oral Argument")
    inl(meta.at("oral-argument"))
    pagebreak()
  }

  // The brief itself.
  body

  // Signature block (after the conclusion), plain single spacing, kept whole.
  let sig = need(meta, "signature")
  block(above: 16.8pt, breakable: false, {
    set text(..edges(pitch-form))
    set par(first-line-indent: 0pt)
    set block(spacing: 0pt)
    block[Respectfully submitted,]
    if "date" in meta { block[#meta.date] }
    block(above: 11.2pt)[s/ #upper(sig.signer)]
    for line in sig.lines { block(inl("*" + line + "*")) }
  })

  // Certificate of compliance (FRBP 8015(h)); wording follows Form 417C in substance.
  pagebreak()
  front-title("Certificate of Compliance")
  par[This brief complies with the type-volume limitation of #kind.limit-cite because it contains #words words, excluding the parts of the brief exempted under Fed. R. Bankr. P. 8015(g).]
  par[This brief complies with the typeface and type-style requirements of Fed. R. Bankr. P. 8015(a)(5) and (6) because it has been prepared in a proportionally spaced typeface, #face #str(type-size / 1pt)-point, using the vendored font.]
  block(above: 16.8pt, breakable: false, {
    set text(..edges(pitch-form))
    set par(first-line-indent: 0pt)
    set block(spacing: 0pt)
    block[s/ #upper(sig.signer)]
    for line in sig.lines.slice(0, calc.min(1, sig.lines.len())) { block(inl("*" + line + "*")) }
    if "date" in meta { block[Dated: #meta.date] }
  })

  // The two statements of 1st Cir. BAP L.R. 8014-1(a)(2) and (3) are "attached to the last page"
  // of the brief, "substantially in the form of" Official Forms 1 and 2: each repeats the caption
  // (court, BAP No., bankruptcy case number, title of the case), then the statement, then the
  // signature of the attorney or pro se party with address and telephone.
  // Each statement is one page: it is set in plain single spacing (pitch-form), which these
  // statements may use (they are not brief text).
  let form-statement(title, rule, statement) = {
    pagebreak()
    set text(..edges(pitch-form))
    set par(first-line-indent: 0pt)
    set block(spacing: 0pt)
    {
      set align(center)
      court-name.join()
      block(above: 8.4pt)[BAP No. #need(meta, "case_number")]
      if "bankruptcy_case" in meta { block[Bankruptcy Case No. #meta.bankruptcy_case] }
      block(above: 8.4pt, case-title(meta))
      block(above: 8.4pt, text(weight: "bold", upper(title)))
      block(below: 16.8pt, rule)
    }
    statement
    block(above: 16.8pt, breakable: false, width: 100%, inset: (left: 50%), {
      block[s/ #upper(sig.signer)]
      for line in sig.lines { block(inl(line)) }
      if "date" in meta { block[Dated: #meta.date] }
    })
  }
  // One check-box line of a statement: the box in its column, the text hanging after it.
  let option(checked, body) = block(below: 11.2pt, par(hanging-indent: box-col, { checkbox(checked); body }))

  // Statement regarding related cases (L.R. 8014-1(a)(2), Official Form 1): every party filing a brief.
  let rc = meta.at("related_cases", default: (status: "none"))
  form-statement("Statement Regarding Related Cases", [1st Cir. BAP L.R. 8014-1(a)(2)], {
    option(rc.status == "pending", [The undersigned certifies that the following are known related cases and appeals:])
    if rc.status == "pending" {
      for c in rc.cases { block(below: 5.6pt, pad(left: para-indent, [#c.number, #inl(c.name) (#inl(c.relationship))])) }
    }
    option(rc.status == "none", [The undersigned certifies that the undersigned knows of no related cases or appeals as that term is defined in 1st Cir. BAP L.R. 8014-1(a)(2)(A).])
  })

  // Statement regarding interested parties (L.R. 8014-1(a)(3), Official Form 2): every party filing
  // a brief "other than governmental parties". Filing it satisfies FRBP 8012 (L.R. 8012-1(a)).
  if not meta.at("governmental_party", default: false) {
    let ip = meta.at("interested_parties", default: (status: "none"))
    form-statement("Statement Regarding Interested Parties", [1st Cir. BAP L.R. 8014-1(a)(3)], {
      option(ip.status == "listed", [The undersigned certifies that the following parties have an interest in the outcome of this appeal. These representations are made to enable the judges of the Panel to evaluate possible disqualification or recusal.])
      if ip.status == "listed" {
        for p in ip.parties { block(below: 5.6pt, pad(left: para-indent, inl(p))) }
      }
      option(ip.status == "none", [The undersigned certifies that the undersigned knows of no interested party as that term is defined in 1st Cir. BAP L.R. 8014-1(a)(3)(A).])
    })
  }
}
