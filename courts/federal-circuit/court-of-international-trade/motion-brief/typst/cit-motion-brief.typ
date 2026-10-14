// United States Court of International Trade (cit): motion for judgment on the agency record with its
// brief in support (the "motion-brief" doc type).
//
// Rule-driven and content-agnostic. Requirement IDs (CIT-...) refer to ../README.md, which quotes the
// rule text: USCIT Rule 56.2(c)(1)-(2) (single document; statement of the determination, issues and relief;
// table of contents and table of authorities), Rule 7(b)(1) (grounds and argument in one document; relief
// sought; proposed order), Rule 10(a) (caption), Rule 11(a) (signer's contact details), Rule 81(b), (d),
// (f), (g) (PDF, page numbers, paper, type size, double spacing, status of case), and Standard Chambers
// Procedures 2(A), 2(B) (single document; 14,000-word limit; exclusions; certificate of compliance).
// No case-specific text, no coordinates measured off the exemplar, no forced line breaks. The body is
// markdown, rendered by cmarker; the metadata is the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"         // vendored in /fonts; the only font this template uses
#let type-size = 12pt                    // CIT-TYPE-001: Rule 81(f), 12 point or larger, footnotes included
#let pitch = 24pt                        // CIT-SPACE-001: Rule 81(f), double spaced: 24 pt baseline pitch at 12 pt
#let body-leading = 0.695em              // EB Garamond's line box is 1.3em at 12 pt; this gives a 24 pt pitch (see ../README.md)
#let single-leading = 0em                // caption, headings, quotations, counsel lines: single spaced
#let margin-x = 1in                      // CIT-PAPER-002: typed matter 6 1/2 in wide and at most 9 1/2 in tall
#let margin-y = 1in
#let margins = (top: margin-y, bottom: margin-y, x: margin-x)
#let para-indent = 0.5in                 // first-line indent of body paragraphs
#let caption-left = 3.4in                // width of the party column of the caption
#let caption-paren = 0.3in               // width of the column of ")" marks
#let word-limit = 14000                  // Chambers Procedures 2(B)(1)(a): movant's brief, Rule 56.2 motion
#let passim-threshold = 7                // authority cited on this many pages or more: "passim"

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the YAML frontmatter from the markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cit-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italic case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown (paragraphs, lists, quotations) with the body paragraph style.
#let blk(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Plain text of a piece of content, for comparisons only.
#let plain(c) = {
  if type(c) == str { c }
  else if c == [] { "" }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain).join() }
  else if c.has("body") { plain(c.body) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

/// A required metadata field; a missing one fails the build with its name.
#let need(meta, key) = {
  if key not in meta { panic("cit-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// 11622 -> "11,622"
#let group-digits(n) = {
  let s = str(n)
  let out = ""
  for (i, c) in s.clusters().enumerate() {
    if i > 0 and calc.rem(s.len() - i, 3) == 0 { out += "," }
    out += c
  }
  out
}

/// Word count of markdown source, whitespace-delimited like a word processor (Chambers 2(B)(1)(c)):
/// headings, footnotes and quotations count; markup is removed first; links keep their text.
#let count-words(md) = {
  let s = md
  s = s.replace(regex("<!--[\\s\\S]*?-->"), " ")
  s = s.replace(regex("(?m)^\\[\\^[^\\]]+\\]:"), " ")      // footnote definition labels
  s = s.replace(regex("\\[\\^[^\\]]+\\]"), "")             // footnote references
  let keep(m) = m.captures.at(0)
  s = s.replace(regex("\\[([^\\]]*)\\]\\([^)]*\\)"), keep)  // links keep their text
  s = s.replace(regex("(?m)^#{1,6}[ \t]+"), "")
  s = s.replace(regex("(?m)^>[ \t]?"), "")
  s = s.replace(regex("(?m)^[ \t]*([-*+]|[0-9]+[.)])[ \t]+"), "")   // list markers are not words
  s = s.replace(regex("\\\\(.)"), keep)
  s = s.replace(regex("[*]"), "")
  s = s.replace(regex("(^|[\\s(\\[\u{201C}\"])_"), keep)
  s = s.replace(regex("_([\\s.,;:)\\]\u{201D}\"!?]|$)"), keep)
  s.split(regex("\\s+")).filter(w => w != "").len()
}

/// Tag the first word of a link's text with a metadata label (for the table of authorities).
#let tag-after-first-word(c, tag) = {
  if type(c) == str or c.func() == text {
    let t = if type(c) == str { c } else { c.text }
    let m = t.match(regex("^\\s*\\S+"))
    if m == none { return (c, false) }
    return ([#m.text#tag#t.slice(m.end)], true)
  }
  if c.func() == emph { let r = tag-after-first-word(c.body, tag); return (emph(r.first()), r.last()) }
  if c.func() == strong { let r = tag-after-first-word(c.body, tag); return (strong(r.first()), r.last()) }
  if c.func() == [].func() {
    let out = ()
    let placed = false
    for ch in c.children {
      if placed { out.push(ch) }
      else { let r = tag-after-first-word(ch, tag); out.push(r.first()); placed = r.last() }
    }
    return (out.join(), placed)
  }
  (c, false)
}

// ---------------------------------------------------------------------------
// Caption (Rule 10(a)): every party on a side, a designation, a ")" mark on each line, the court
// number on the right. A side may name the word that joins it to the next side (default "v.").
// ---------------------------------------------------------------------------

#let caption(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  let sides = need(meta, "caption")
  let rows = ()
  for (i, side) in sides.enumerate() {
    for n in side.names { rows.push(inl(n)) }
    rows.push(pad(left: 1.2in, inl(side.designation)))
    if i < sides.len() - 1 { rows.push(align(center, inl(side.at("between", default: "v.")))) }
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    pad(left: 0.2in, {
      [Ct. No. #need(meta, "court_no")]
      if "before" in meta { linebreak(); [Before: #meta.before] }
    })
  }
  let cells = ()
  for (k, r) in rows.enumerate() {
    if k == 0 {
      cells.push(r)
      cells.push([)])
      cells.push(grid.cell(rowspan: rows.len(), align(top, right)))
    } else {
      cells.push(r)
      cells.push([)])
    }
  }
  grid(columns: (caption-left, caption-paren, 1fr), row-gutter: 0pt, ..cells)
}

// ---------------------------------------------------------------------------
// Signature block (Rule 11(a): signer's address, e-mail and telephone are in the lines)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (2.6in, 1fr), column-gutter: 0.2in,
      [Dated: #need(meta, "date")],
      {
        [Respectfully submitted,]
        v(pitch * 0.5)
        [/s/ #sig.signer]
        linebreak()
        for l in sig.lines { inl(l); linebreak() }
      })
  })
}

// ---------------------------------------------------------------------------
// Covers: the motion's cover, then the memorandum's cover (same caption, different title)
// ---------------------------------------------------------------------------

#let cover-page(meta, title) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(need(meta, "court").map(l => [#l]).join(linebreak()))))
  v(pitch)
  caption(meta)
  v(pitch)
  align(center, strong(upper(inl(need(meta, "party")))))
  v(pitch * 0.5)
  align(center, strong(upper(inl(title))))
}

#let counsel-block(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(right, block(width: 3.2in, {
    for l in need(meta, "counsel") { inl(l); linebreak() }
  }))
}

// ---------------------------------------------------------------------------
// Headings. Level 1 is a centered section (I., II., ...); level 2 a bold sub-heading (A., B., ...);
// level 3 bold italic. The numerals are typed in the markdown, so the text is exactly the author's.
// ---------------------------------------------------------------------------

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  if it.level == 1 {
    block(width: 100%, sticky: true, above: pitch * 0.5, below: pitch * 0.5,
      align(center, strong(upper(it.body))))
  } else if it.level == 2 {
    block(width: 100%, sticky: true, above: pitch * 0.5, below: pitch * 0.5,
      par(hanging-indent: 0.5in, strong(it.body)))
  } else {
    block(width: 100%, sticky: true, above: pitch * 0.5, below: pitch * 0.5,
      par(hanging-indent: 0.5in, strong(emph(it.body))))
  }
}

// ---------------------------------------------------------------------------
// Table of contents (Rule 56.2(c)(2)) and table of authorities (Rule 56.2(c)(2)).
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.16em)])

#let toa-groups = (
  ("case", "Cases:"),
  ("constitution", "Constitutional Provisions:"),
  ("statute", "Statutes:"),
  ("regulation", "Regulations:"),
  ("rule", "Rules:"),
  ("other", "Other Authorities:"),
)

#let sort-key(a) = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite))))
  .replace(regex("[^a-z0-9 ]"), "")

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("cit-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 1em } else { 1.4em }, below: 0.2em, sticky: true, {
        set par(first-line-indent: 0pt)
        strong(title)
        if first { h(1fr); strong(underline[Page(s)]) }
      })
      first = false
      for (key, a) in members {
        // Distinct printed page labels, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        block(breakable: false, above: 0.7em, below: 0pt, width: 100%, par(hanging-indent: 0.35in, first-line-indent: 0pt, leading: single-leading, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [,]
            linebreak()
          }
          inl(a.cite)
          h(0.8em)
          dot-leader
          h(0.3em)
          page-text
        }))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Word-count certificate (Chambers 2(B)(2)): states the number of words in the brief, counted from the
// body by the same rules as the word processor (headings, footnotes and quotations counted; caption,
// tables, certificates and counsel blocks not counted).
// ---------------------------------------------------------------------------

#let certificate-of-compliance(meta, words) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper[Certificate of Compliance]))
  v(pitch)
  par(first-line-indent: para-indent, leading: body-leading, [
    This brief has been prepared using a proportionally spaced typeface (#font-family, #str(type-size.pt())-point).
    In accordance with the Standard Chambers Procedures of this Court, the undersigned certifies that
    this brief contains #group-digits(words) words, excluding the parts of the brief exempted by
    Chambers Procedures 2(B)(1)(c). The certified word count is based on the word count of the
    markdown source from which this brief was typeset, counted as a word processor counts words.
  ])
  signature-block(meta)
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let cit-motion-brief(meta, md) = {
  let authorities = meta.at("authorities", default: (:))
  let words = count-words(md)
  if words > word-limit {
    panic("cit-motion-brief: the body has " + str(words) + " words; Chambers Procedures 2(B)(1)(a) limit is " + str(word-limit))
  }

  set document(title: need(meta, "brief_title") + ", Ct. No. " + need(meta, "court_no"))
  set page(paper: "us-letter", margin: margins, numbering: "1", footer: context align(center, counter(page).display()))
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size)     // CIT-TYPE-001 covers footnotes too
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(left: para-indent, right: para-indent, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
    it.body
  }))
  show regex("\\S*\\)\\(\\S*"): it => box(it)
  show regex("[§¶] \\S+"): it => box(it)
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- front matter: motion cover and motion; memorandum cover; contents (lower-case roman) ----
  // Rule 81(d) numbers every page from 1; the cover counts as page 1.
  cover-page(meta, need(meta, "brief_title"))
  v(pitch)
  block(width: 100%, blk(need(meta, "motion")))
  signature-block(meta)
  pagebreak()

  cover-page(meta, need(meta, "memo_title"))
  v(pitch)
  counsel-block(meta)
  v(pitch)
  align(center, [Dated: #need(meta, "date")])
  pagebreak()

  // ---- contents ----
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  show outline.entry: it => link(it.element.location(), block(above: 0.35em, below: 0pt, par(
    hanging-indent: 0.5in * (it.element.level - 1) + 0.5in, first-line-indent: 0pt, leading: single-leading, {
      h(0.5in * (it.element.level - 1))
      it.element.body
      h(0.8em)
      dot-leader
      box(width: 2.6em, align(right, it.page()))
    })))
  outline(title: none, depth: 3)
  pagebreak()

  toa-section(authorities)
  pagebreak()

  // ---- body: the memorandum from the Rule 56.2 statement on; the signature and certificate follow ----
  set par(leading: body-leading, spacing: 0pt, first-line-indent: (amount: para-indent, all: true), justify: false)
  cmarker.render(md, raw-typst: false, smart-punctuation: true, h1-level: 1)

  signature-block(meta)
  pagebreak()

  certificate-of-compliance(meta, words)
}
