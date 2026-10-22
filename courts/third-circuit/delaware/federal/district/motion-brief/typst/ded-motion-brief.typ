// Opening brief in support of a motion to dismiss (memorandum of points and authorities) for the United
// States District Court for the District of Delaware (ded). Rules: D. Del. LR 7.1.3(a)(1) (cover: court,
// caption, civil action number, nature of the paper, date, party, counsel's name, Delaware bar number,
// address and telephone), 7.1.3(a)(2) and 5.1.1(a) (at least 12 point type for all printed matter, double
// spacing "typical word processing" (not exactly 24 point), at least 1 inch margins, consecutive page
// numbers, date and descriptive title, Delaware counsel under the signature line), 7.1.3(a)(4) (20 pages,
// exclusive of the contents and the citations) and 7.1.3(b)(1) (table of contents, table of citations,
// nature and stage, summary of argument, statement of facts, argument, conclusion, in that order).
// See ../README.md for the rule text, the verification date and the open choices.
// Content-agnostic: every case-specific word comes from the sample's frontmatter or markdown, never from
// this file. Authorities are linked in the markdown as [text](toa:KEY); the table of citations and its
// page numbers are built from those links.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // vendored; not a rule requirement: the rule is about size
#let type-size = 12pt                   // LR 5.1.1(a), 7.1.3(a)(2): at least 12 point for all printed matter
#let margin = 1in                       // LR 5.1.1(a): margins not less than 1 inch
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let label-box = 0.5in                  // a heading's label ("I.", "A.") in a box this wide, the title after it;
                                        // a level-3 label starts this far in (docx: a hanging indent and a tab)
#let cap-left = 3.4in                   // the caption's party column, ruled at its right and foot ...
#let cap-rule = 0.75pt                  // ... with a rule this thick ...
#let cap-pad = 8.65pt                  // ... its text this far from the rule, its last line this far above it (docx 173) ...
#let cap-right = 0.45in                 // ... and the case column's text this far right of it (0.3 in gutter + 0.15 in)
#let counsel-gutter = 0.3in             // the cover's two counsel columns, of equal width, this far apart
#let sig-col = 3.2in                    // the signature column (3.3 in wide); "Dated:" sits left of its first line
#let toc-col = 0.5in                    // the contents' page column
#let toa-col = 1in                      // the citations' page column ("4, 5, 6")
#let toa-hang = 0.35in                  // a citation's lines after the first hang this far
#let passim-threshold = 7               // an authority on this many pages or more is printed as "passim"

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/ded-motion-brief.lua and docx/reference.xml
// set the same twips: 20 x pt).
#let pitch-body = 27.6pt                // LR 5.1.1(a): double spacing "according to typical word processing software":
                                        // 2 x 1.15 x 12 pt, the exemplar's pitch (docx 552)
#let pitch-single = 13.8pt              // cover, headings that wrap, contents, citations, signature, footnotes (docx 276)
#let cover-gap = 27.6pt                 // a blank double line between the cover's blocks
#let head-space = 13.8pt                // above and below a level-2 or level-3 heading (a single line)
#let toc-gap = 13.8pt                   // above a contents row
#let toa-gap = 6.9pt                    // above a citation row
#let group-above = 13.8pt               // above a citation group's title ("Cases")
#let sig-above = 27.6pt                 // the last paragraph to the signature block
#let note-after = 7pt                   // below every footnote, the last too (docx: Footnote Text's space after, 140 twips, which
                                        // LibreOffice counts on the last note of a page as well)
#let note-clearance = 3.5pt             // the last text line to the separator; with the separator's 7 pt box, the
                                        // 10.5 pt LibreOffice keeps between the text and the first note
#let note-rule = 7pt                    // the separator rule at the top of a box this tall, above the first note
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

#let need(meta, key) = {
  if key not in meta { panic("ded-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ded-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Inline markdown (italics, citations).
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// Footnote definitions "[^n]: text" keyed by label; each reference "[^n]" becomes a typst footnote.
#let footnote-defs(body) = {
  let d = (:)
  for m in body.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.+)$")) { d.insert(m.captures.at(0), m.captures.at(1)) }
  d
}

/// Inline markdown for one text segment; a space at either edge is kept (a footnote sits between two segments).
#let seg(s) = {
  let lead = if s.starts-with(" ") { [ ] } else { [] }
  let trail = if s.ends-with(" ") { [ ] } else { [] }
  lead + inl(s) + trail
}

/// Inline markdown with footnote references turned into typst footnotes.
#let rich(t, defs) = {
  let out = []
  let pos = 0
  for m in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
    out += seg(t.slice(pos, m.start))
    out += footnote(inl(defs.at(m.captures.at(0))))
    pos = m.end
  }
  out + seg(t.slice(pos))
}

#let is-def(t) = t.match(regex("^\\[\\^[^\\]]+\\]:")) != none

/// A single-pitch line (one paragraph; it wraps on single lines).
#let sline(content, above: 0pt, align-to: left, indent: 0pt) = block(width: 100%, above: above, below: 0pt,
  pad(left: indent, align(align-to, par(first-line-indent: 0pt, content))))

/// Single-pitch lines, one paragraph each; an empty item is a blank single line (leading blank lines as v(): the
/// space above the first block of a cell would be dropped, docx keeps an empty paragraph).
#let lines(items) = {
  let gap = 0pt
  let first = true
  for i in items {
    if i == "" { gap += pitch-single } else {
      if first and gap > 0pt { v(gap); gap = 0pt }
      sline(if type(i) == str { inl(i) } else { i }, above: gap)
      gap = 0pt
      first = false
    }
  }
}

/// The printed label of a numbered heading: level 2 "I.", level 3 "A."; level 1 is unnumbered.
#let heading-label(level, nums) = if level == 2 { numbering("I.", nums.at(0)) } else if level == 3 {
  numbering("A.", nums.at(1)) } else { "" }

/// Headings, kept with the block after them. Level 1: centred bold capitals on the body pitch, no space of its own
/// (also the titles of the contents and the citations); levels 2 and 3: bold single lines a single line above and
/// below, the label in `label-box` (level 3 a box further in), the title hanging after it.
#let heading-block(level, title, label: "") = {
  if level <= 1 {
    block(width: 100%, above: 0pt, below: 0pt, sticky: true, align(center, par(first-line-indent: 0pt,
      text(weight: "bold", upper(title)))))
  } else {
    let ind = (level - 2) * label-box
    block(width: 100%, above: head-space, below: head-space, sticky: true, {
      set text(..edges(pitch-single))
      par(first-line-indent: 0pt, hanging-indent: ind + label-box,
        text(weight: "bold", [#h(ind)#box(width: label-box, label)#title]))
    })
  }
}

// ---------------------------------------------------------------------------
// Cover: court, caption, title, counsel, date (LR 7.1.3(a)(1))
// ---------------------------------------------------------------------------

/// The caption: the parties at the left ("v." between them), ruled at the right and the foot; the civil action
/// number at the right (docx: a one-row table, the left cell bordered).
#let caption(meta) = {
  let left-col = {
    for (k, p) in need(meta, "caption").enumerate() {
      if k > 0 { sline([v.]) }
      lines(p.names)
      sline(inl(p.designation))
    }
  }
  // grid cell strokes and insets: the rule runs the height of the row, with the space below it under both columns
  // (LibreOffice takes a cell's bottom margin for the whole row)
  block(width: 100%, above: cover-gap, below: 0pt, breakable: false, grid(
    columns: (cap-left, 1fr),
    stroke: (x, y) => if x == 0 { (right: cap-rule, bottom: cap-rule) },
    inset: (x, y) => if x == 0 { (right: cap-pad, bottom: cap-pad) } else { (left: cap-right, bottom: cap-pad) },
    left-col, lines(("", [C.A. No. #need(meta, "case_number")])),
  ))
}

#let cover(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  sline(align-to: center, text(weight: "bold")[IN THE UNITED STATES DISTRICT COURT])
  sline(align-to: center, text(weight: "bold")[FOR THE DISTRICT OF DELAWARE])
  caption(meta)
  sline(above: cover-gap, align-to: center, text(weight: "bold", upper(inl(need(meta, "brief_title")))))
  // LR 7.1.3(a)(1): the counsel block for the filing party sits on the cover; "OF COUNSEL:" at the left
  block(width: 100%, above: cover-gap, below: 0pt, breakable: false, grid(
    columns: (1fr, 1fr), column-gutter: counsel-gutter,
    if "of_counsel" in meta { lines(("OF COUNSEL:", "") + meta.of_counsel) },
    lines(need(meta, "counsel")),
  ))
  sline(above: cover-gap, [Dated: #inl(need(meta, "date"))])
}

// ---------------------------------------------------------------------------
// Signature block (Delaware counsel under the signature line: LR 5.1.1(a)): single lines in the signature
// column, "Dated:" left of the first; kept whole
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let rows = sig.firm + ("", "/s/ " + sig.signer) + sig.lines
  block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
    set text(..edges(pitch-single))
    let gap = 0pt
    let first = true
    for r in rows {
      if r == "" { gap += pitch-single } else {
        block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
          [#box(width: sig-col, if first [Dated: #inl(need(meta, "date"))])#inl(r)]))
        gap = 0pt
        first = false
      }
    }
  })
}

// ---------------------------------------------------------------------------
// Contents and table of citations (LR 7.1.3(b)(1)(A)-(B))
// ---------------------------------------------------------------------------

#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

/// The column heading over the page numbers ("Page", "Page(s)"), a bold single line set right.
#let column-head(s) = sline(align-to: right, above: 0pt, text(weight: "bold", s))

/// The contents: every body heading, single lines, a level-2 label at the margin and a level-3 label a box in, the
/// title after it; the page in its own column with a dot leader to it (listing-row).
#let toc-section() = {
  heading-block(1, [Table of Contents])
  set text(..edges(pitch-single))
  column-head[Page]
  context {
    for m in query(<ded-toc>) {
      let lv = m.value.level
      let ind = if lv <= 1 { 0pt } else { (lv - 2) * label-box }
      let hang = if lv <= 1 { 0pt } else { ind + label-box }
      let body = if lv <= 1 { inl(m.value.title) } else { [#h(ind)#box(width: label-box, m.value.label)#inl(m.value.title)] }
      listing-row(none, body, page-label(m.location()), toc-col, hang, toc-gap)
    }
  }
}

#let toa-groups = (("case", "Cases"), ("statute", "Statutes"), ("rule", "Rules"), ("other", "Other Authorities"))

#let sort-key(a) = lower(a.at("name", default: "") + " " + a.at("cite", default: ""))

/// The table of citations, built from the `toa:` links found in the body (LR 7.1.3(b)(1)(B)): by kind, sorted, each
/// authority with the distinct pages it is cited on ("passim" at `passim-threshold` pages or more).
#let toa-section(authorities) = {
  pagebreak(weak: true)
  heading-block(1, [Table of Citations])
  set text(..edges(pitch-single))
  column-head[Page(s)]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("ded-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(width: 100%, above: group-above, below: 0pt, sticky: true, par(first-line-indent: 0pt,
        text(weight: "bold", title)))
      for (key, a) in members {
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let label = page-label(h.location())
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        let entry = if "name" in a { (if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }) + [ ] } else { [] }
        listing-row(none, entry + inl(a.cite), page-text, toa-col, toa-hang, toa-gap)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// The memorandum: paragraphs (first line indented), headings (numbered I., A.), footnotes
// ---------------------------------------------------------------------------

#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt, par(content))

#let memorandum(meta, md) = {
  let defs = footnote-defs(md)
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "" and not is-def(c))
  let nums = (0, 0)
  for (i, t) in chunks.enumerate() {
    let h = t.match(regex("^(#{1,3})[ \\t]+(.*)$"))
    if h != none {
      let lv = h.captures.at(0).len()
      if lv == 2 { nums = (nums.at(0) + 1, 0) } else if lv == 3 { nums = (nums.at(0), nums.at(1) + 1) }
      let label = heading-label(lv, nums)
      [#metadata((level: lv, label: label, title: h.captures.at(1)))<ded-toc>]
      heading-block(lv, inl(h.captures.at(1)), label: label)
    } else if i + 1 == chunks.len() {
      // the last paragraph is kept on one page with the signature block
      block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
        body-par(rich(t, defs))
        signature-block(meta)
      })
    } else {
      body-par(rich(t, defs))
    }
  }
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ded-motion-brief(meta, md) = {
  for k in ("case_number", "caption", "brief_title", "counsel", "date", "signature") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  set document(title: need(meta, "brief_title") + ", C.A. No. " + need(meta, "case_number"), author: need(meta, "signature").signer)
  let footer = context align(center, text(..edges(pitch-single), counter(page).display()))
  set page(paper: "us-letter", margin: margin, footer-descent: footer-descent)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number; a footnote's line moves on with the
  // line before it, as Word does (footnote-widows: false).
  show: xengine.with(pitch: pitch-body, list-indent: none, footnote-widows: false)
  // A doubled sign stays with its number ("¶¶ 19-20"; xengine binds a single sign; docx: a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at the type size (LR 5.1.1(a)), single-spaced (docx: Footnote Text in 13.8 pt boxes, 7 pt after).
  set footnote.entry(gap: 0pt, clearance: note-clearance, indent: 0pt,
    separator: box(height: note-rule, line(length: 30%, stroke: 0.5pt)))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    block(width: 100%, above: 0pt, below: 0pt, par[#super(num)#h(0.25em)#unloose(note.body)])
    v(note-after)
  }
  // Authority links: a link whose target is `toa:KEY` is recorded with the page it starts on; its text stays plain.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") { [#metadata(it.dest.slice(4))<toa-hit>#it.body] } else { it }
  }

  // The cover: no page number (DEF-COVER-001).
  page(numbering: none, footer: none, cover(meta))
  // The contents and the citations: lower roman from i.
  page(numbering: "i", footer: footer, {
    counter(page).update(1)
    toc-section()
    toa-section(authorities)
  })
  // The memorandum: arabic from 1.
  page(numbering: "1", footer: footer, {
    counter(page).update(1)
    memorandum(meta, md)
  })
}
