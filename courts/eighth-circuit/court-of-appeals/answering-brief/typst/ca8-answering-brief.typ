// U.S. Court of Appeals for the Eighth Circuit: appellee's (answering) brief.
//
// Rule-driven and content-agnostic. Sources, rule numbers and the date each was verified are in
// ../README.md. No case-specific text, no coordinates measured off any filed brief, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same file (schema: ../README.md, "Markdown contract").
//
// Structure follows the Eighth Circuit's own form, as the rules require it (FRAP 28(b), 32(a)):
// cover, summary of the case and statement on oral argument (Rule 28A(i)(1)), corporate disclosure
// statement (FRAP 26.1(d)(2): before the table of contents), table of contents, table of authorities,
// the body, signature block, certificate of compliance (FRAP 32(g)(1); Local Rule 28A(h)(2)),
// certificate of service.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")          // FRAP 32(a)(5)(A): proportionally spaced, serif. Vendored in /fonts.
#let type-size = 14pt                      // FRAP 32(a)(5)(A): 14-point or larger, everywhere (footnotes too).
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; LaTeX \pdfeachlineheight).
#let pitch-double = 28pt                   // FRAP 32(a)(4): double-spaced, 2 x the 14 pt type, the filed exemplar's pitch
#let pitch-single = 17pt                   // FRAP 32(a)(4): headings, quotations, footnotes, TOC/TOA, cover, signature single-spaced
#let single-leading = 0pt                  // the line boxes carry the spacing: no leading between them
#let toc-page-col = 36pt                   // TOC: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 56pt                   // TOA: page lists such as 1, 4, 6, 8 (a longer list widens its own row's column)
#let page-margin = 1in                     // FRAP 32(a)(4): at least one inch on all four sides.
#let para-indent = 0.5in
#let toc-depth = 4
#let word-limit = 13000                    // FRAP 32(a)(7)(B)(i): principal brief, appellee's included (FRAP 28(b)).

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

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

#let need(meta, key) = {
  if key not in meta { panic("ca8-answering-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ca8-answering-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Put an invisible `tag` right after the first word of `c`, keeping any emphasis around it.
/// Returns (content, placed). Why not simply put the tag in front: when a citation begins at the
/// start of a line, typst files a tag that sits before the first word under the PREVIOUS line, which
/// may be on the previous page, so the table of authorities would cite the wrong page.
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

/// Word count of markdown source, whitespace-delimited like a word processor.
/// Markup characters are removed first; links keep their text.
#let count-words(md) = {
  let s = md
  s = s.replace(regex("<!--[\\s\\S]*?-->"), " ")
  s = s.replace(regex("(?m)^\\[\\^[^\\]]+\\]:"), " ")      // footnote definition labels
  s = s.replace(regex("\\[\\^[^\\]]+\\]"), "")             // footnote references
  // (typst's string replacement has no $1: a function returns the captured text)
  let keep(m) = m.captures.at(0)
  s = s.replace(regex("\\[([^\\]]*)\\]\\([^)]*\\)"), keep)  // links keep their text
  s = s.replace(regex("(?m)^#{1,6}[ \t]+"), "")
  s = s.replace(regex("(?m)^>[ \t]?"), "")
  s = s.replace(regex("(?m)^[ \t]*([-*+]|[0-9]+[.)])[ \t]+"), "")   // list markers are not words
  s = s.replace(regex("\\\\(.)"), keep)                    // backslash escapes
  s = s.replace(regex("[*]"), "")
  s = s.replace(regex("(^|[\\s(\\[\u{201C}\"])_"), keep)
  s = s.replace(regex("_([\\s.,;:)\\]\u{201D}\"!?]|$)"), keep)
  s.split(regex("\\s+")).filter(w => w != "").len()
}

// ---------------------------------------------------------------------------
// Headings: numbering scheme and styles
// ---------------------------------------------------------------------------

/// True when the level-1 section that contains `loc` is the Argument.
#let in-argument(loc) = {
  let tops = query(selector(heading.where(level: 1)).before(loc, inclusive: true))
  tops.len() > 0 and lower(plain(tops.last().body)).trim() == "argument"
}

/// Printed label of a numbered heading, e.g. "I.", "A.", "1.", "a.".
/// Argument: I. / A. / 1. / a.   Elsewhere: A. / 1. / a. / (1)
#let heading-label(h) = {
  let loc = h.location()
  let c = counter(heading).at(loc)
  let n = c.at(h.level - 1, default: 1)
  if in-argument(loc) {
    if h.level == 2 { numbering("I.", n) }
    else if h.level == 3 { numbering("A.", n) }
    else if h.level == 4 { numbering("1.", n) }
    else if h.level == 5 { numbering("a.", n) }
    else { panic("ca8-answering-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("ca8-answering-brief: headings deeper than level 5 are not supported") }
  }
}

#let heading-tab = 0.5in

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// Left edge of a heading's label. Labels sit half an inch in from the margin; each further
/// level steps in half an inch more. In the Argument the level-2 point heading is centered, so
/// its sub-headings start at the first step.
#let label-indent(h) = {
  let first = if in-argument(h.location()) { 3 } else { 2 }
  (h.level - first + 1) * heading-tab
}

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size, ..edges(pitch-single))   // typst's built-in heading sizes are not used; every heading is body size
  if it.level == 1 {
    // Section headings: bold, capitals, centered (FRAP 28(a)(7), (8)).
    block(width: 100%, sticky: true, above: 21pt, below: 15.4pt,
      align(center, strong(upper(it.body))))
  } else if it.numbering == none {
    // Unnumbered sub-headings: bold, left.
    block(width: 100%, sticky: true, above: 16.8pt, below: 12.6pt, strong(it.body))
  } else if in-argument(it.location()) and it.level == 2 {
    // Point headings: bold, centered, with the roman numeral.
    block(width: 100%, sticky: true, above: 16.8pt, below: 14pt,
      align(center, strong(heading-label(it) + [ ] + it.body)))
  } else {
    // Sub-headings: label in a fixed box, text hangs under the text, bold (italic below level 3).
    let ind = label-indent(it)
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: 15.4pt, below: 12.6pt, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, if it.level >= 4 { strong(emph(lab)) } else { strong(lab) })
      if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
    }))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

/// One table-of-contents row, built from a heading element. The label sits where the
/// heading's own label sits in the body, and wrapped lines hang under the title text.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none and hd.level >= 2
  let ind = if numbered { label-indent(hd) } else if hd.level >= 2 { (hd.level - 2) * heading-tab } else { 0pt }
  // The Argument's centered point heading has no body indent in the table; its label starts at the margin.
  if numbered and in-argument(hd.location()) and hd.level == 2 { ind = 0pt }
  let lab = if numbered { heading-label(hd) } else { none }
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  // The page number has its own column (listing-row), so a title that fills its last line can never push the number
  // onto a line of its own; the leader runs from the end of the title to the number.
  listing-row(hd.location(), {
    h(ind)
    if numbered { box(width: heading-tab, lab) }
    title
  }, it.page(), toc-page-col, ind + heading-tab, if hd.level == 1 { 8.4pt } else { 4.9pt })
}

/// Table of contents: every outlined heading, front matter included (the filed exemplar lists them).
#let toc-section() = {
  heading(level: 1, numbering: none)[Table of Contents]
  show outline.entry: toc-entry
  outline(title: none, target: selector(heading.where(outlined: true)), depth: toc-depth, indent: 0pt)
}

#let toa-groups = (
  ("case", "Cases"),
  ("constitution", "Constitutional Provisions"),
  ("statute", "Statutes"),
  ("regulation", "Regulations"),
  ("rule", "Rules"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite))))
    .replace(regex("[^a-z0-9 ]"), "")

/// Table of authorities (FRAP 28(a)(3): alphabetical, cases first), built from the `toa:` links in the body.
#let toa-section(authorities) = {
  heading(level: 1, numbering: none)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("ca8-answering-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: 15.4pt, below: 2.8pt, sticky: true, {
        set par(first-line-indent: 0pt)
        strong(title)
      })
      for (key, a) in members {
        // Distinct printed page labels, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        let page-text = pages.join(", ")
        listing-row(none, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [,]
            linebreak()
          }
          inl(a.cite)
        }, page-text, calc.max(toa-page-col, measure(page-text).width), 0.35in, 9.8pt)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (FRAP 32(a)(2)(A)-(F))
// ---------------------------------------------------------------------------

#let double-rule = {
  line(length: 100%, stroke: 1.6pt)
  v(2.5pt)
  line(length: 100%, stroke: 0.5pt)
}
#let short-rule = align(center, line(length: 2in, stroke: 0.7pt))

/// Counsel blocks in two columns, the name of each group in capitals, its address and contact lines
/// below (FRAP 32(a)(2)(F): name, office address and telephone number). A group's own `phone`
/// follows its lines; a top-level `phone` (used when no group has one) follows the last group's lines.
#let counsel-block(meta) = {
  let groups = need(meta, "counsel")
  let has-group-phone = groups.any(g => "phone" in g)
  let cells = ()
  for (gi, g) in groups.enumerate() {
    let lines = g.at("lines", default: ())
    if "phone" in g { lines = lines + (g.phone,) }
    else if gi == groups.len() - 1 and not has-group-phone { lines = lines + (need(meta, "phone"),) }
    cells.push(block(breakable: false, {
      set par(first-line-indent: 0pt, leading: single-leading, spacing: 4.9pt, justify: false)
      // (not small capitals: Word and LaTeX synthesize those differently, so the lines could not agree across engines)
      for n in g.names { n; linebreak() }
      for l in lines { emph(inl(l)); linebreak() }
    }))
  }
  grid(columns: (1fr, 1fr), column-gutter: 16.8pt, row-gutter: 16.8pt, ..cells)
}

#let cover-body(meta, gap) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 4.9pt, justify: false)
  set align(center)
  v(gap * 0.6)
  [No. #need(meta, "case_number")]
  v(gap)
  strong[IN THE UNITED STATES COURT OF APPEALS\ FOR THE EIGHTH CIRCUIT]
  v(gap)
  double-rule
  v(gap)
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    for name in side.names { inl(name); parbreak() }
    emph(inl(side.designation))
    if i < sides.len() - 1 { v(gap * 0.3); [v.]; v(gap * 0.3) }
  }
  v(gap)
  double-rule
  v(gap)
  inl(need(meta, "proceeding"))
  if "district_court_case" in meta or "judge" in meta {
    parbreak()
    [#if "district_court_case" in meta [#inl(meta.district_court_case)]#if "district_court_case" in meta and "judge" in meta [, ]#if "judge" in meta [#inl(meta.judge)]]
  }
  v(gap)
  double-rule
  v(gap)
  strong(inl(need(meta, "brief_title")))
  v(gap)
  double-rule
  v(gap)
  counsel-block(meta)
  v(gap)
  double-rule
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("ca8-answering-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Signature, certificates
// ---------------------------------------------------------------------------

/// Signature block after the Conclusion: date on the left, "Respectfully submitted," on the right,
/// as in the filed exemplar (FRAP 32(d)).
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 19.6pt, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 1fr), column-gutter: 14pt,
      [#if "date" in meta [Dated: #meta.date]],
      [
        Respectfully submitted,
        #v(16.8pt)
        #emph[/s/ #sig.signer]
        #linebreak()
        #upper(sig.signer)
        #for l in sig.at("lines", default: ()) { linebreak(); emph(inl(l)) }
      ])
  })
}

/// Date line and signature line for a certificate, as in the filed exemplar.
#let form-sig-line(meta) = block(above: 22.4pt, breakable: false, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading)
  let sig = need(meta, "signature")
  grid(columns: (1fr, 1fr), column-gutter: 14pt,
    [Dated: #need(meta, "date")],
    [#emph[/s/ #sig.signer]\ #upper(sig.signer)])
})

/// Certificate of Compliance (FRAP 32(g)(1) requires the word count; Local Rule 28A(h)(2) requires the virus statement;
/// the wording follows the filed exemplar).
#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none)[Certificate of Compliance]
  set par(first-line-indent: para-indent)
  [This brief complies with the type-volume limitations imposed by Federal Rule of Appellate Procedure 32(a)(7)(B)(i) because it contains #group-digits(words) words, excluding the parts of the brief exempted by Rule 32(f). This brief complies with the typeface and typestyle requirements of Federal Rules of Appellate Procedure 32(a)(5) and 32(a)(6) because it has been prepared in a proportionally spaced typeface, #int(type-size / 1pt)-point #font-family.first(). This brief complies with the electronic-filing requirements of Local Rule 28A(h)(2) because it was #need(meta, "virus_check").]
  form-sig-line(meta)
}

/// Certificate of Service: electronic service through CM/ECF. FRAP 25(d)(1) requires proof of service only for
/// service other than through the court's electronic-filing system; this follows the filed exemplar.
#let certificate-of-service(meta) = {
  heading(level: 1, numbering: none)[Certificate of Service]
  set par(first-line-indent: para-indent)
  [I hereby certify that on #need(meta, "date"), the foregoing brief was filed with the Clerk of Court for the U.S. Court of Appeals for the Eighth Circuit through the CM/ECF system, which will send a notification of such filing to all counsel of record.]
  form-sig-line(meta)
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ca8-answering-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "brief_title", "counsel", "signature", "virus_check") { let _ = need(meta, k) }
  // FRAP 32(a)(2)(F): a telephone number, per counsel group or once for all.
  if not need(meta, "counsel").any(g => "phone" in g) { let _ = need(meta, "phone") }
  let authorities = meta.at("authorities", default: (:))

  // ---- the word count: the body only (FRAP 32(f) excludes the cover, disclosure, tables, summary, signature, certificates) ----
  let words = count-words(md)
  if words > word-limit {
    panic("ca8-answering-brief: the brief has " + str(words) + " words; FRAP 32(a)(7)(B)(i) allows " + str(word-limit))
  }

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  // The page number: centered in a single-spaced line box whatever the text around it (Word's footer, LaTeX's
  // plain page style), so it sits at the same place on every page.
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model (lib/typst/xengine.typ): first fit, no kerning or ligatures, no hyphenation, line
  // boxes of the body pitch, footnote marks at 58 %, lists with the number in a half-inch box, a section sign or
  // pilcrow kept with its number, no break inside "60(b)(5)".
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  // No widows or orphans, as LaTeX (\widowpenalty 10000) and Word's widow control forbid them; typst's default only
  // charges for one, and a long footnote could make it take a widow the other engines refuse.
  set text(costs: (widow: 10000%, orphan: 10000%))
  set heading(numbering: none)
  // Footnotes: 8.5 pt from the text to the separator and 7 pt from it to each note, 15.5 pt in all: the room
  // LibreOffice keeps above the notes of a Word document (the height of a line of the 14 pt face, ascent plus
  // descent), so the text above the notes ends where it ends in the docx render.
  set footnote.entry(
    gap: 7pt, clearance: 8.5pt, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))   // typst's default is 0.85em; FRAP 32(a)(5)(A) allows nothing under 14 pt
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 7pt)
    // marker, a thin space, then the note (typst's default runs them together)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    // a note is never split across pages (LaTeX and Word keep it whole: xengine.sty, the reference.docx)
    block(breakable: false, [#super(num)#h(0.25em)#note.body])
  }
  show quote.where(block: true): it => block(above: 14pt, below: 14pt, pad(left: para-indent, right: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 12.6pt)
    it.body
  }))
  // A URL breaks only after "?", "=", "&", a hyphen or a slash that no digit (nor a second slash) follows, never after
  // the "//" of its scheme: each part is
  // a box, so the PDF text keeps the author's characters. Without this typst breaks an overlong URL at any character,
  // which TeX and Word do not; the LaTeX and Word filters set the same break points (docs/EVAL-LOOP.md).
  show regex("https?://\\S+"): it => {
    let parts = ("",)
    let cs = it.text.clusters()
    for (i, c) in cs.enumerate() {
      parts.last() += c
      let next = cs.at(i + 1, default: "")
      let prev = cs.at(i - 1, default: "")
      if c in ("?", "=", "&") or (c in ("/", "-") and next != "/" and not (c == "/" and prev == "/")
        and next.match(regex("^[0-9]$")) == none) { parts.push("") }
    }
    parts.filter(p => p != "").map(p => box(p)).join()
  }
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- cover (FRAP 32(a)(2)) ----
  { set text(..edges(pitch-single)); cover(meta) }

  // ---- front matter (lowercase roman): summary, disclosure, contents, authorities ----
  set page(numbering: "i")
  counter(page).update(1)
  heading(level: 1, numbering: none)[Summary of the Case and Statement on Oral Argument]
  cmarker.render(need(meta, "summary"), raw-typst: false, smart-punctuation: true, h1-level: 1)
  if "disclosure" in meta {
    pagebreak(weak: true)
    heading(level: 1, numbering: none)[Corporate Disclosure Statement]
    cmarker.render(meta.disclosure, raw-typst: false, smart-punctuation: true, h1-level: 1)
  }
  pagebreak(weak: true)
  {
    set text(..edges(pitch-single))
    toc-section()
    pagebreak(weak: true)
    toa-section(authorities)
  }

  // ---- body (arabic from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  {
    set heading(numbering: "1")
    // The signature block never stands alone on a page: the brief's last paragraph is
    // kept together with it (unless that last block is a heading or a footnote definition).
    let text-md = md.trim(at: end)
    let breaks = text-md.matches(regex("\n[ \t]*\n"))
    let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
    let tail = text-md.slice(cut)
    let keep = tail.len() > 0 and not tail.starts-with("#") and not tail.starts-with("[^")
    let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
    if keep {
      render(text-md.slice(0, cut))
      block(breakable: false, { render(tail); signature-block(meta) })
    } else {
      render(text-md)
      signature-block(meta)
    }
  }

  // ---- certificates (each starts on its own page) ----
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  pagebreak(weak: true)
  certificate-of-service(meta)
}
