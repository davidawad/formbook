// U.S. Court of Appeals for the Eighth Circuit: reply brief (FRAP 28(c), 32).
//
// Rule-driven and content-agnostic. Rule IDs (CA8-...) refer to ../README.md.
// No case-specific text, no coordinates measured off the filed exemplar, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the
// YAML frontmatter of the same file (markdown contract: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // CA8-FORM-004: serif, proportional. Times New Roman, the
                                           // standard face (David, 2026-10-17; fb-595.54.9), though the audited exemplar is
                                           // set in Georgia (data/exemplar-fonts.json, template_face). Pinned install, docs/FONTS.md.
#let font-name = "Times New Roman, 14-point"   // printed in the certificate of compliance: the face set above
#let type-size = 14pt                      // CA8-FORM-004: 14-point or larger, everywhere.
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; LaTeX \pdfeachlineheight).
#let pitch-double = 28pt                   // CA8-FORM-003: double-spaced, 2 x the 14 pt type
#let pitch-single = 17pt                   // headings, quotations, footnotes, TOC/TOA, cover, signature, certificates: single-spaced
#let single-leading = 0pt                  // the line boxes carry the spacing: no leading between them
#let toc-page-col = 36pt                   // TOC: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 56pt                   // TOA: page lists such as 1, 4, 6, 8 (a longer list widens its own row's column)
#let page-margin = 1in                     // CA8-FORM-002
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let toc-depth = 4
#let passim-threshold = 7                  // an authority cited on this many pages or more: "passim"
#let word-limit = 6500                     // CA8-LIMIT-001: half of the 13,000-word principal limit

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
  if key not in meta { panic("ca8-reply-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ca8-reply-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Put an invisible `tag` right after the first word of `c`, keeping any emphasis around it.
/// (Typst files a tag placed before a line's first word under the previous line, which may be on
/// the previous page, so the tag goes after the first word instead.)
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
// Headings: numbering scheme and styles (CA8-CONT-010)
// Section (level 1): bold capitals, centered. Then A. / 1. / a. / (1), one step in per level.
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading, e.g. "A.", "1.", "a.".
#let heading-label(h) = {
  let n = counter(heading).at(h.location()).at(h.level - 1, default: 1)
  if h.level == 2 { numbering("A.", n) }
  else if h.level == 3 { numbering("1.", n) }
  else if h.level == 4 { numbering("a.", n) }
  else if h.level == 5 { numbering("(1)", n) }
  else { panic("ca8-reply-brief: headings deeper than level 5 are not supported") }
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size, ..edges(pitch-single))
  if it.level == 1 {
    block(width: 100%, sticky: true, above: 21pt, below: 15.4pt,
      align(center, strong(upper(it.body))))
  } else if it.numbering == none {
    block(width: 100%, sticky: true, above: 16.8pt, below: 12.6pt, strong(it.body))
  } else {
    let ind = (it.level - 2) * heading-tab
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: 15.4pt, below: 12.6pt, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, strong(lab))
      if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
    }))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities (CA8-CONT-001, -002)
// ---------------------------------------------------------------------------

/// One table-of-contents row, built from a heading element. Wrapped lines hang under the title.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none and hd.level >= 2
  let ind = if hd.level >= 2 { (hd.level - 2) * heading-tab } else { 0pt }
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

#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, block(above: 4.2pt, below: 0pt, strong(underline[Page])))
  show outline.entry: toc-entry
  outline(title: none, target: selector(heading.where(outlined: true)), depth: toc-depth, indent: 0pt)
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
        panic("ca8-reply-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 14pt } else { 19.6pt }, below: 2.8pt, sticky: true, {
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
        listing-row(none, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [,]
            linebreak()
          }
          inl(a.cite)
        }, page-text, calc.max(toa-page-col, measure(page-text).width), 0.35in, 7pt)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (FRAP 32(a)(2)(A)-(F); CA8-COVER-001 to -004)
// ---------------------------------------------------------------------------

#let double-rule = {
  line(length: 100%, stroke: 1.6pt)
  v(2.5pt)
  line(length: 100%, stroke: 0.5pt)
}

/// Set in the right half of the text block, left-aligned: it starts at mid-page whatever its width (a `pad(left: 50%)`
/// is half the padded content's own width, so its left edge moved with the longest line). `share`: where it starts.
#let right-half(body, share: 50%) = block(width: 100%, inset: (left: share), align(left, body))

#let cover-body(meta, gap) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 4.9pt, justify: false)
  set align(center)
  strong[No. #need(meta, "case_number")]
  v(gap)
  strong[IN THE UNITED STATES COURT OF APPEALS\ FOR THE EIGHTH CIRCUIT]
  v(gap * 1.5)
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    for name in side.names { inl(name); parbreak() }
    right-half(inl(side.designation))
    if i < sides.len() - 1 { v(gap * 0.6); [v.]; v(gap * 0.6) }
  }
  v(gap * 1.5)
  inl(need(meta, "proceeding"))
  if "district_court_case" in meta {
    parbreak()
    [D.C. No. #meta.district_court_case]
  }
  v(gap * 1.5)
  strong(upper(inl(need(meta, "brief_title"))))
  v(gap * 1.5)
  // Counsel (FRAP 32(a)(2)(F): name, office address, telephone number; each `lines` holds the phone).
  right-half(share: 25%, {
    set par(hanging-indent: 0pt, spacing: 7pt)
    for g in need(meta, "counsel") {
      block(breakable: false, {
        for n in g.names { n; linebreak() }
        for l in g.lines { h(7pt); inl(l); linebreak() }
      })
      v(gap * 0.5)
    }
  })
  if "date" in meta {
    v(gap)
    meta.date
  }
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("ca8-reply-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Signature block and certificates (FRAP 32(g); CA8-CERT-001 to -003)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 19.6pt, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    right-half({
      [Respectfully submitted,]
      v(16.8pt)
      [/s/ #sig.signer]
      linebreak()
      sig.signer
      for l in sig.at("lines", default: ()) { linebreak(); inl(l) }
      for a in sig.at("also", default: ()) {
        v(11.2pt)
        a.name
        for l in a.at("lines", default: ()) { linebreak(); inl(l) }
      }
    })
    if "date" in meta { v(11.2pt); meta.date }
    if "note" in sig {
      v(11.2pt)
      set par(leading: single-leading, first-line-indent: 0pt)
      text(size: type-size, inl(sig.note))
    }
  })
}

/// Signature under each certificate: "/s/ Name", the name, and the signer's role (`signature.role`,
/// default "Counsel for Appellant"), set flush left from the middle of the line like the signature block.
#let cert-sig(meta) = block(breakable: false, above: 19.6pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  let sig = need(meta, "signature")
  right-half({
    [/s/ #sig.signer]
    linebreak()
    sig.signer
    linebreak()
    sig.at("role", default: "Counsel for Appellant")
  })
})

/// Certificate of Compliance, Form 6 wording (FRAP 32(g)(1)-(2); CA8-CERT-001). The word count is
/// computed from the markdown: the body through the conclusion, footnotes included, the tables,
/// the signature block and the certificates excluded.
#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none)[Certificate of Compliance]
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
  [I certify that this brief complies with the type-volume limitation of Fed.~R.~App.~P. 32(a)(7)(B) because it contains #group-digits(words) words, excluding the parts of the brief exempted by Fed.~R.~App.~P. 32(f). The brief complies with the typeface requirements of Fed.~R.~App.~P. 32(a)(5) and the type-style requirements of Fed.~R.~App.~P. 32(a)(6) because it has been prepared in a proportionally spaced typeface (#font-name.split(", ").map(box).join(", ")).]
  parbreak()
  [Pursuant to Circuit~Rule~28A(h), I also certify that the electronic files of this brief have been submitted to the Clerk through the Court's CM/ECF system and have been scanned for viruses and are virus-free.]
  cert-sig(meta)
}

/// Certificate of Service (FRAP 25; Circuit~Rule~25A(a)). Printed only when `service.certificate` is true.
#let certificate-of-service(meta) = {
  heading(level: 1, numbering: none)[Certificate of Service]
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 14pt, justify: false)
  [Pursuant to Fed.~R.~App.~P. 25 and Circuit~Rule~25A(a), I hereby certify that on #meta.at("date", default: "__________"), I filed a copy of the #plain(inl(need(meta, "brief_title"))) with the Clerk of the Court through the Court's CM/ECF system, which will serve electronic copies on all registered counsel.]
  cert-sig(meta)
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ca8-reply-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "brief_title", "counsel", "signature") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))

  // ---- length (CA8-LIMIT-001) ----
  let words = count-words(md)
  if words > word-limit {
    panic("ca8-reply-brief: the reply brief has " + str(words) + " words; FRAP 32(a)(7)(B)(ii) allows " + str(word-limit))
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
  // pilcrow kept with its number, no break inside "1692f(1)".
  // footnote-widows: false: a paragraph whose last line carries a footnote moves on with its second-to-last line, as
  // LaTeX and Word set it (lib/typst/xengine.typ, fb-595.54.9)
  show: xengine.with(pitch: pitch-double, list-indent: para-indent, footnote-widows: false)
  // No widows or orphans, as LaTeX (\widowpenalty 10000) and Word's widow control forbid them; typst's default only
  // charges for one, and a long footnote could make it take a widow the other engines refuse.
  set text(costs: (widow: 10000%, orphan: 10000%))
  // Footnote marks are the digits scaled to 58 %, as Word and LaTeX set them, never a face's own superior figures.
  set super(typographic: false)
  set heading(numbering: none)
  // Footnotes: 8.5 pt from the text to the separator and 7 pt from it to each note, 15.5 pt in all.
  set footnote.entry(
    gap: 7pt, clearance: 8.5pt, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))   // typst's default is 0.85em; FRAP 32(a)(5) allows nothing under 14 pt
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 7pt)
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

  // ---- cover ----
  { set text(..edges(pitch-single)); cover(meta) }

  // ---- front matter (lowercase roman) ----
  set page(numbering: "i")
  counter(page).update(1)
  {
    set text(..edges(pitch-single))
    toc-section()
    pagebreak()
    toa-section(authorities)
  }

  // ---- body (arabic from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  {
    set heading(numbering: "1")
    // The signature block never stands alone: the brief's last paragraph is kept with it.
    // Footnote definitions are collected at the end of the markdown; they are handed to both
    // renders so a reference in either part still resolves, and the paragraph is found above them.
    let text-md = md.trim(at: end)
    let def-at = text-md.match(regex("(?m)^\\[\\^[^\\]]+\\]:"))
    let defs = if def-at == none { "" } else { text-md.slice(def-at.start) }
    let main-md = if def-at == none { text-md } else { text-md.slice(0, def-at.start).trim(at: end) }
    let breaks = main-md.matches(regex("\n[ \t]*\n"))
    let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
    let tail = main-md.slice(cut)
    let keep = tail.len() > 0 and not tail.starts-with("#")
    let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
    if keep {
      render(main-md.slice(0, cut) + "\n\n" + defs)
      block(breakable: false, { render(tail + "\n\n" + defs); signature-block(meta) })
    } else {
      render(text-md)
      signature-block(meta)
    }
  }

  // ---- certificates ----
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  if meta.at("service", default: (:)).at("certificate", default: false) {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
}
