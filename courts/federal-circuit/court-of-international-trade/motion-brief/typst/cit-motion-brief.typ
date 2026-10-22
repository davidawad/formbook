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
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the two
// explicit spacings. The docx engine (../docx/) sets the same pitches, spaces, indents and columns.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman; Liberation Serif is its metric twin
#let type-size = 12pt                    // CIT-TYPE-001: Rule 81(f), 12 point or larger, footnotes included
#let pitch = 24pt                        // CIT-SPACE-001: Rule 81(f), double spaced: 24 pt line pitch at 12 pt
#let pitch-single = 14pt                 // caption, headings, quotations, footnotes, tables, counsel lines: single spaced
#let margin-x = 1in                      // CIT-PAPER-002: typed matter 6 1/2 in wide and at most 9 1/2 in tall
#let margin-y = 1in
#let margins = (top: margin-y, bottom: margin-y, x: margin-x)
#let para-indent = 0.5in                 // first-line indent of body paragraphs; list labels in a box this wide
#let caption-left = 3.4in                // width of the party column of the caption
#let caption-paren = 0.3in               // width of the column of ")" marks
#let caption-desig = 1.2in               // indent of a party's designation in the party column
#let caption-right = 0.2in               // indent of the court number in the right column
#let counsel-left = 3.3in                // the counsel block on the memorandum cover starts here
#let sig-left = 2.8in                    // signature block: the date column; the counsel column takes the rest
#let gap = 12pt                          // the half-line spaces: party to title, "Respectfully submitted," to /s/
#let space-section = (above: 24pt, below: 12pt)   // level-1 headings (centered capitals)
#let space-sub = (above: 12pt, below: 12pt)       // lower headings
#let space-quote = 14pt                  // above, below and between the paragraphs of a block quotation
#let note-gap = 7pt                      // between footnotes
#let note-clearance = 12.6pt             // between the body and the footnote rule
#let toc-page-col = 36pt                 // the contents' page column
#let toc-indent = 0.5in                  // each heading level below the first indents the contents row this much
#let toc-above = (7pt, 4.9pt)            // above a contents row of a level-1 and of a lower heading
#let toa-page-col = 56pt                 // the authorities' page column (wider when the page list is)
#let toa-hang = 0.35in                   // wrapped lines of an authority hang this much
#let toa-above = 9.8pt                   // above an authority
#let toa-group = (first: 14pt, next: 19.6pt, below: 2.8pt)   // above and below a group title ("Cases:")
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
#let inl(s) = cmarker.render(s.trim(), raw-typst: false, smart-punctuation: true)

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


/// One single-spaced line (a paragraph of its own, no indent).
#let line1(body) = par(first-line-indent: 0pt, hanging-indent: 0pt, body)

// ---------------------------------------------------------------------------
// Caption (Rule 10(a)): every party on a side, a designation, a ")" mark on each line, the court
// number on the right. A side may name the word that joins it to the next side (default "v.").
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let sides = need(meta, "caption")
  let rows = ()
  for (i, side) in sides.enumerate() {
    for n in side.names { rows.push(line1(inl(n))) }
    rows.push(pad(left: caption-desig, line1(inl(side.designation))))
    if i < sides.len() - 1 { rows.push(align(center, line1(inl(side.at("between", default: "v."))))) }
  }
  let right = pad(left: caption-right, {
    line1[Ct. No. #need(meta, "court_no")]
    if "before" in meta { line1[Before: #meta.before] }
  })
  let cells = ()
  for (k, r) in rows.enumerate() {
    cells.push(r)
    cells.push(line1[)])
    if k == 0 { cells.push(grid.cell(rowspan: rows.len(), align(top, right))) }
  }
  grid(columns: (caption-left, caption-paren, 1fr), row-gutter: 0pt, ..cells)
}

// ---------------------------------------------------------------------------
// Signature block (Rule 11(a): signer's address, e-mail and telephone are in the lines)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: pitch, below: 0pt, {
    set text(..edges(pitch-single))
    grid(columns: (sig-left, 1fr), column-gutter: 0pt,
      line1[Dated: #need(meta, "date")],
      {
        line1[Respectfully submitted,]
        block(above: gap, below: 0pt, line1[/s/ #sig.signer])
        for l in sig.lines { line1(inl(l)) }
      })
  })
}

// ---------------------------------------------------------------------------
// Covers: the motion's cover, then the memorandum's cover (same caption, different title)
// ---------------------------------------------------------------------------

#let cover-page(meta, title) = {
  set text(..edges(pitch-single))
  for l in need(meta, "court") { align(center, line1(strong(upper(l)))) }
  v(pitch)
  caption(meta)
  v(pitch)
  align(center, line1(strong(upper(inl(need(meta, "party"))))))
  block(above: gap, below: 0pt, width: 100%, { set align(center); line1(strong(upper(inl(title)))) })
}

#let counsel-block(meta) = {
  set text(..edges(pitch-single))
  pad(left: counsel-left, for l in need(meta, "counsel") { line1(inl(l)) })
}

// ---------------------------------------------------------------------------
// Headings. Level 1 is a centered section (I., II., ...); lower levels bold, flush left, wrapped lines hanging
// half an inch. The numerals are typed in the markdown, so the text is exactly the author's. Typst's built-in
// heading sizes are not used: every heading is the body size, single spaced.
// ---------------------------------------------------------------------------

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  set text(size: type-size, ..edges(pitch-single))
  if it.level == 1 {
    block(width: 100%, sticky: true, ..space-section, align(center, strong(upper(it.body))))
  } else {
    block(width: 100%, sticky: true, ..space-sub, par(hanging-indent: para-indent, strong(it.body)))
  }
}

// ---------------------------------------------------------------------------
// Table of contents (Rule 56.2(c)(2)) and table of authorities (Rule 56.2(c)(2)): rows as in Word, the text
// wrapping before a page column, a dot leader from three spaces after the text to the page (listing-row).
// ---------------------------------------------------------------------------

#let toc-entry(it) = {
  let hd = it.element
  let ind = toc-indent * (hd.level - 1)
  listing-row(hd.location(), { h(ind); hd.body }, it.page(), toc-page-col, ind,
    if hd.level == 1 { toc-above.at(0) } else { toc-above.at(1) })
}

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
      block(above: if first { toa-group.first } else { toa-group.next }, below: toa-group.below, sticky: true, {
        set par(first-line-indent: 0pt)
        strong(title)
        if first { h(1fr); strong(underline[Page(s)]) }
      })
      first = false
      for (key, a) in members {
        // Distinct printed page labels, in page order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        listing-row(none, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [,]
            linebreak()
          }
          inl(a.cite)
        }, page-text, calc.max(toa-page-col, measure(page-text).width), toa-hang, toa-above)
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
  { set text(..edges(pitch-single)); align(center, line1(strong(upper[Certificate of Compliance]))) }
  block(above: pitch, below: 0pt, par[
    This brief has been prepared using a proportionally spaced typeface (#font-family.first(), #str(type-size.pt())-point).
    In accordance with the Standard Chambers Procedures of this Court, the undersigned certifies that
    this brief contains #group-digits(words) words, excluding the parts of the brief exempted by
    Chambers Procedures 2(B)(1)(c). The count includes headings, footnotes and quotations.
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
  // Rule 81(d) numbers every page from 1; the cover counts as page 1. The number sits in a single-spaced line box.
  set page(paper: "us-letter", margin: margins, numbering: "1", footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, no kerning, ligatures or hyphenation, line boxes of the body pitch,
  // footnote marks at 58 %; lists below (the label in a half-inch box, as xengine sets them).
  show: xengine.with(pitch: pitch, list-indent: none)
  // A doubled section sign stays with its number too ("§§ 1500"), as the docx filter binds it.
  show regex("[§¶]{2} \\S+"): it => box(it)
  // Loose lists (items apart by a blank line) carry a paragraph break at the end of each item, which may not stand
  // inside the item's paragraph (lib/typst/xengine.typ): the items are set as xengine sets them, without it.
  let tight(b) = if b.func() == [].func() { b.children.filter(c => c.func() != parbreak).join() } else { b }
  let item(lab, body) = block(above: 0pt, below: 0pt,
    par(hanging-indent: para-indent, first-line-indent: 0pt, { box(width: para-indent, lab); tight(body) }))
  show enum: it => {
    let n = if it.start == auto { 1 } else { it.start }
    for i in it.children {
      if i.has("number") and i.number != none { n = i.number }
      item(numbering(it.numbering, n), i.body)
      n += 1
    }
  }
  show list: it => for i in it.children { item([•], i.body) }
  set heading(numbering: none)
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    // CIT-TYPE-001 covers footnotes too: 12 pt, single spaced; the marker, a space, the note
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: space-quote, below: space-quote,
    pad(left: para-indent, right: para-indent, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt, spacing: space-quote)
      it.body
    }))
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- motion cover and motion ----
  cover-page(meta, need(meta, "brief_title"))
  // The motion's last paragraph (the WHEREFORE paragraph) stays on the page with the signature block,
  // so a signature is never alone on a page (keep-together, not a forced break).
  let motion-paras = need(meta, "motion").trim(at: end).split("\n\n")
  block(above: pitch, below: 0pt, width: 100%, {
    if motion-paras.len() > 1 { blk(motion-paras.slice(0, -1).join("\n\n")) }
    block(above: 0pt, below: 0pt, width: 100%, breakable: false, {
      blk(motion-paras.last())
      signature-block(meta)
    })
  })
  pagebreak()

  // ---- memorandum cover ----
  cover-page(meta, need(meta, "memo_title"))
  v(pitch)
  counsel-block(meta)
  v(pitch)
  { set text(..edges(pitch-single)); align(center, line1[Dated: #need(meta, "date")]) }
  pagebreak()

  // ---- contents and authorities ----
  {
    set text(..edges(pitch-single))
    heading(level: 1, numbering: none, outlined: false)[Table of Contents]
    show outline.entry: toc-entry
    outline(title: none, depth: 3, indent: 0pt)
    pagebreak()
    toa-section(authorities)
  }
  pagebreak()

  // ---- body: the memorandum from the Rule 56.2 statement on; the signature and certificate follow ----
  blk(md)
  signature-block(meta)
  pagebreak()

  certificate-of-compliance(meta, words)
}
