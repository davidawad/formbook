// California Superior Court (calsuperct): notice of motion and motion, with the memorandum of points and
// authorities, in one document on pleading paper.
//
// Rule-driven and content-agnostic. The governing rules are Cal. Rules of Court 2.100-2.119 and 3.1110-3.1113 (see
// ../README.md and ../../rules.md for the rule numbers, URLs and the date each was verified). No case-specific text,
// no coordinates measured off a filed brief, no forced line breaks. Every case word comes from the sample's
// frontmatter or its markdown body.
//
// Body contract: the markdown body is the notice of motion first, then a line
// `# MEMORANDUM OF POINTS AND AUTHORITIES`, then the memorandum. The template prints that title itself.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/pleading-paper.typ": line-numbers as shared-line-numbers, pleading-rules as shared-pleading-rules
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters: each traces to a rule or is a named layout choice.
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // CRC 2.105: essentially equivalent to Times New Roman
#let type-size = 12pt              // CRC 2.104: not smaller than 12 points
#let page-w = 8.5in                // CRC 2.103: 8 1/2 by 11 inches
#let page-h = 11in
#let lines-per-page = 28           // numbered lines per page (pleading convention, tier 2; CRC 2.108(4): at least
                                   // three per vertical inch)
#let top-margin = 1in              // line 1 starts 1 inch from the top (CRC 2.111(1))
#let left-margin = 1.5in           // CRC 2.107: at least 1 inch; room for the line numbers and the rules
#let right-margin = 0.5in          // CRC 2.107: at least 1/2 inch
#let para-indent = 0.5in           // first-line indent of a paragraph
#let heading-tab = 0.5in           // a heading's label in a box of this width; each level a further step in
#let clerk-lines = 7               // CRC 2.111(2): lines 1-7 right of center are the clerk's; CRC 2.111(3): the court
                                   // title on line 8 or below
#let caption-col = 50%             // CRC 2.111(4): the case title left of the center of the page
#let caption-inset = 0.12in        // the party column's text stands off its right rule
#let caption-right = 0.2in         // the right column stands off the party column's rule
#let hearing-label = 0.75in        // the hearing details: the label column
#let space-indent = 0.25em         // a caption line's leading spaces: an indent of this much per space
#let quote-inset = 0.5in           // block quotations, both sides (CRC 2.108(3): may be single-spaced)
#let sig-col = 3.1in               // the signature column ("Dated:" at the margin, the rest from here)
#let sig-name = 0.3in              // the signer's name and role stand this far into the signature column
#let sig-rule = 2.7in              // the signature line after "By:"
#let toc-col = 0.5in               // the page column of the table of contents
#let toa-col = 0.75in              // the page column of the table of authorities
#let toa-indent = 0.5in            // an authority's first line; its later lines hang a further toa-indent
#let passim-threshold = 7          // an authority cited on this many pages or more: "passim" (convention)
#let memo-page-limit = 15          // CRC 3.1113(d): an opening memorandum may not exceed 15 pages
#let footer-size = 10pt            // CRC 2.110(c): the footer title at least 10 points
#let number-size = 12pt            // the page number (CRC 2.109)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is set here (Word's exact
// line spacing; docx/calsuperct.lua sets the same twips).
#let pitch = 24pt                  // CRC 2.108(1): double spacing; the numbered lines (body, headings, tables)
#let pitch-single = 12pt           // CRC 2.108(3): single-spaced lines (attorney block, caption, signature, block
                                   // quotations, footnotes), two to a numbered line
#let gap = pitch-single            // a blank single line between the groups of the caption's right column
// A group of single lines starts this far below a numbered line's top, so every other single line stands level with
// a line number.
#let single-drop = 0.8 * (pitch - pitch-single)
#let caption-foot = 6pt            // the party column's last line box to its bottom rule
#let caption-clear = pitch-single  // the caption's foot to the body: at least this, then the next numbered line
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 48 pt: holds the footer
#let footer-gap = 2pt              // the last numbered line to the page number
#let footer-rule-gap = 4pt         // the page number to the footer rule (docx: an underlined tab in a 4 pt line)
#let note-gap = 6pt                // between two footnotes
#let note-clearance = 12pt         // the body text to the footnote rule

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let need(meta, key) = {
  if key not in meta { panic("calsuperct-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("calsuperct-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline markdown (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let as-list(v) = if v == none { () } else if type(v) == array { v } else { (v,) }

/// Single-spaced lines, one paragraph per item. An empty item is a blank single line; an item's leading spaces are
/// an indent of `space-indent` each (so a caption's "Petitioner," and "v." stand where the filer put them).
#let line-stack(items, above: 0pt, weight: "regular") = block(width: 100%, above: above, below: 0pt, {
  // no widow or orphan rule: a column that runs over a page end breaks at the last line that fits (docx: the same)
  set text(..edges(pitch-single), weight: weight, costs: (widow: 0%, orphan: 0%))
  set par(first-line-indent: 0pt)
  for it in as-list(items) {
    let s = str(it)
    let m = s.match(regex("^( *)(.*)$"))
    let n = m.captures.at(0).len()
    if m.captures.at(1).trim() == "" {
      block(height: pitch-single)
    } else {
      block(pad(left: n * space-indent, inl(m.captures.at(1))))
    }
  }
})

/// The space to the top of the first numbered line at least `clear` below this point.
#let to-grid(clear) = context {
  let y = here().position().y
  let k = calc.ceil((y + clear - top-margin) / pitch - 0.001)
  block(width: 100%, height: top-margin + k * pitch - y)
}

// ---------------------------------------------------------------------------
// Pleading paper (CRC 2.108): numbers 1 to 28 down the left margin on the body's line boxes, a double rule left of
// the text and a single rule right of it; the footer (CRC 2.109, 2.110): the page number, below it a printed line,
// below that the paper's title. Pages are numbered in Arabic from the first (CRC 2.109).
// ---------------------------------------------------------------------------

#let line-numbers() = shared-line-numbers(left-margin, top-margin, pitch, lines-per-page, type-size, ..edges(pitch))

#let pleading-rules() = shared-pleading-rules(page-w, page-h, left-margin, right-margin)

#let footer-block(title) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + footer-gap,
  block(width: page-w - left-margin - right-margin, {
    set par(first-line-indent: 0pt)
    set text(size: number-size, ..edges(pitch-single))
    align(center, context counter(page).display("1"))
    block(above: footer-rule-gap, below: 0pt, width: 100%, stroke: (top: 0.5pt),
      align(center, text(size: footer-size, upper(inl(title)))))
  }),
)

// ---------------------------------------------------------------------------
// First page (CRC 2.111, 3.1110(b)): attorney block from line 1, court title on line 8 or below, caption
// ---------------------------------------------------------------------------

/// CRC 2.111(1)-(2): the attorney block from line 1, left of center, one line per item (an item that does not fit
/// left of center stops the build: split it into two items); the court title on line 8, or on the first numbered
/// line below a longer block.
#let attorney-block(meta) = {
  let items = as-list(need(meta, "attorney"))
  layout(size => {
    for it in items {
      let w = measure(text(size: type-size, inl(str(it)))).width
      if w > size.width * caption-col {
        panic("calsuperct-motion-brief: the attorney line `" + str(it) + "` does not fit left of center (CRC 2.111(1)-(2)); split it")
      }
    }
  })
  let n = calc.max(clerk-lines, calc.ceil((single-drop + items.len() * pitch-single) / pitch))
  block(width: 100%, height: n * pitch, above: 0pt, below: 0pt, inset: (top: single-drop), line-stack(items))
}

/// CRC 2.111(3): the title of the court, centered, bold, one numbered line each.
#let court-title(meta) = {
  for l in as-list(need(meta, "court")) {
    block(width: 100%, align(center, text(weight: "bold", inl(str(l)))))
  }
}

/// CRC 2.111(4)-(7), 3.1110(b), 3.1112(c): the case title left of center (the column ruled at its right and foot),
/// and to its right, a numbered line apart: the case number, the title of each paper combined (bold), the details,
/// the hearing (date, time, department, judge), the date the action was filed and the papers filed with it.
#let caption(meta) = {
  let cap = need(meta, "caption")
  let groups = ()
  if "case_number" in cap { groups.push(line-stack(cap.case_number)) }
  groups.push(line-stack(need(cap, "title"), weight: "bold"))
  if "details" in cap { groups.push(line-stack(cap.details)) }
  // the hearing (CRC 3.1110(b)(1)) and the date the action was filed (CRC 3.1110(b)(3)), one group
  let rows = ()
  if "hearing" in meta {
    for (k, lab) in (("date", "Date:"), ("time", "Time:"), ("dept", "Dept.:"), ("judge", "Judge:")) {
      if k in meta.hearing { rows.push((lab, meta.hearing.at(k))) }
    }
  }
  if rows.len() > 0 or "action_filed" in cap {
    groups.push(block(width: 100%, {
      set text(..edges(pitch-single))
      for (lab, v) in rows {
        block(width: 100%, par(first-line-indent: 0pt, hanging-indent: hearing-label,
          { box(width: hearing-label, lab); inl(str(v)) }))
      }
      if "action_filed" in cap { line-stack("Action Filed: " + cap.action_filed) }
    }))
  }
  // CRC 3.1110(b)(2): the papers filed with it
  if "concurrent" in cap { groups.push(line-stack("[" + cap.concurrent + "]")) }
  block(width: 100%, above: pitch, below: 0pt, grid(
    columns: (caption-col, 1fr),
    // The column may run over a page end: its space above and below are blocks (an inset would repeat on each page).
    grid.cell(stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset), {
      block(height: single-drop)
      line-stack(cap.at("left", default: ()))
      block(height: caption-foot)
    }),
    grid.cell(inset: (left: caption-right), {
      block(height: single-drop)
      for (k, g) in groups.enumerate() { block(width: 100%, above: if k == 0 { 0pt } else { gap }, below: 0pt, g) }
    }),
  ))
}

// ---------------------------------------------------------------------------
// Signature block: "Dated:" at the margin, the rest in the signature column; never split across pages
// ---------------------------------------------------------------------------

#let sig-row(lead, body, above: 0pt, indent: 0pt) = block(width: 100%, above: above, below: 0pt,
  par(first-line-indent: 0pt, hanging-indent: sig-col + indent, { box(width: sig-col + indent, lead); body }))

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, above: pitch, below: 0pt, breakable: false, inset: (top: single-drop), {
    set text(..edges(pitch-single))
    let lines = as-list(sig.at("lines", default: ()))
    let dated = if "dated" in sig [Dated: #inl(sig.dated)] else []
    for (k, l) in lines.enumerate() { sig-row(if k == 0 { dated } else { [] }, inl(str(l))) }
    if lines.len() == 0 { sig-row(dated, []) }
    sig-row([], box(width: sig-rule, [By: #box(width: 1fr, line(length: 100%, stroke: 0.5pt))]), above: pitch)
    sig-row([], strong(upper(inl(need(sig, "signer")))), indent: sig-name)
    if "role" in sig { sig-row([], inl(sig.role), indent: sig-name) }
  })
}

/// Blocks whose last one stays whole with the signature block after it.
#let with-signature(pieces, sig) = {
  for p in pieces.slice(0, calc.max(0, pieces.len() - 1)) { p }
  block(width: 100%, breakable: false, { if pieces.len() > 0 { pieces.last() }; sig })
}

// ---------------------------------------------------------------------------
// The body: each blank-line-separated chunk of markdown is a heading, a block quotation or a paragraph. Footnote
// definitions are kept apart from the chunks: each chunk is rendered alone, with the definitions of the notes it
// refers to.
// ---------------------------------------------------------------------------

/// A heading's label typed by the author ("A.", "1.", "a.", "IV."), and the rest of its text.
#let split-label(t) = {
  let m = t.match(regex("^([A-Za-z]{1,4}|\\d{1,3})\\.[ \\t]+"))
  if m == none { (none, t) } else { (m.captures.at(0) + ".", t.slice(m.end)) }
}

#let label-indent(level) = (level - 1) * heading-tab

/// Headings on the numbered lines, bold, kept with the text: level 1 centered capitals; deeper levels with the
/// author's label in a box at the level's indent, the lines after the first hanging after it.
#let heading-block(level, t) = block(width: 100%, sticky: true, {
  set text(weight: "bold")
  set par(first-line-indent: 0pt)
  if level == 1 {
    align(center, upper(inl(t)))
  } else {
    let (lab, rest) = split-label(t)
    let ind = label-indent(level)
    let body = if level >= 4 { emph(inl(rest)) } else { inl(rest) }
    if lab == none {
      par(hanging-indent: ind, { h(ind); body })
    } else {
      par(hanging-indent: ind + heading-tab, { h(ind); box(width: heading-tab, lab); body })
    }
  }
})

/// A footnote whose note does not fit on the page of its mark: typst keeps the line with the mark and sets the note
/// on the next page; Word and LibreOffice move the line on with its note. Each paragraph that anchors a note starts
/// with this guard; when a note of the paragraph lands a page after its mark (`note-check`, below), the guard places
/// an empty float at the foot of the page that ends the text half a line into the mark's line, so the line moves on
/// with its note as in Word. The float records where it stood, and the paragraph keeps it while it stands (the layout
/// then settles). Only a mark on the page where its paragraph starts is moved.
#let note-pars = counter("calsuperct-note-par")
#let note-guard() = {
  note-pars.step()
  context {
    let k = note-pars.get().first()
    [#metadata(k)<fn-par>]
    let pushes = query(<fn-push>).filter(p => p.value.par == k and p.value.page == here().page())
    if pushes.len() > 0 {
      let p = pushes.first().value
      // the top of the footnotes that stay on the page (or the foot of the text), less the space above them
      let tops = query(<fn-body>).filter(e => e.location().page() == p.page).map(e => e.location().position().y)
      let area = if tops.len() == 0 { page-h - bottom-margin } else { calc.min(..tops) - note-clearance }
      let f = area - (p.top + pitch / 2)
      if f > 0pt { place(bottom, float: true, clearance: 0pt, block(width: 0pt, height: f, [#metadata(p)<fn-float>])) }
    }
  }
}

/// After a footnote mark: flags the paragraph when the note is set a page after the mark (or a float of the
/// paragraph stands), with the top of the mark's line (the body lines are on the numbered lines).
#let note-check() = context {
  let n = counter(footnote).get().first()
  let pars = query(selector(<fn-par>).before(here()))
  if pars.len() > 0 {
    let k = pars.last().value
    let fl = query(<fn-float>).filter(f => f.value.par == k)
    if fl.len() > 0 {
      [#metadata(fl.first().value)<fn-push>]
    } else {
      let es = query(<fn-body>).filter(e => e.value == n)
      if es.len() > 0 and es.first().location().page() > here().page() {
        let top = top-margin + calc.floor((here().position().y - top-margin) / pitch) * pitch
        [#metadata((par: k, page: here().page(), top: top))<fn-push>]
      }
    }
  }
}

/// A body paragraph, its first line indented. One that anchors a footnote may leave a single line on a page (no
/// widow or orphan rule), so that the line with the mark moves on with its note (docx: Body Text Note).
#let body-par(note: false, c) = {
  if note {
    set text(costs: (widow: 0%, orphan: 0%))
    note-guard()
    par(first-line-indent: (amount: para-indent, all: true), c)
  } else {
    block(width: 100%, par(first-line-indent: (amount: para-indent, all: true), c))
  }
}

/// A block quotation (CRC 2.108(3): may be single-spaced), quote-inset in on both sides, its first line on the next
/// numbered line (single-drop into it, as every group of single lines, so every other line stands level with a
/// number); the text after it starts on the first numbered line at least a blank single line below its last line
/// (docx: the filter counts the quotation's lines).
#let block-quote(c) = context {
  let q = block(width: 100%, inset: (left: quote-inset, right: quote-inset), {
    set text(..edges(pitch-single), costs: (widow: 0%, orphan: 0%))
    set par(first-line-indent: 0pt)
    c
  })
  let n = calc.round(measure(q, width: page-w - left-margin - right-margin).height / pitch-single)
  let end = single-drop + n * pitch-single
  let below = calc.ceil((end + pitch-single / 2) / pitch - 0.001) * pitch - end
  block(width: 100%, above: single-drop, below: below, q)
}

#let body-pieces(body, notes) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
    .filter(c => not c.starts-with(regex("^\\[\\^[^\\]]+\\]:")))
  chunks.map(t => {
    let defs = ""
    for r in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
      let id = r.captures.at(0)
      defs += "\n\n[^" + id + "]: " + notes.at(id, default: "")
    }
    let h = t.match(regex("^(#+)[ \\t]+(.*)$"))
    if h != none {
      heading-block(h.captures.at(0).len(), h.captures.at(1).trim())
    } else if t.starts-with(">") {
      let q = t.replace(regex("(?m)^>[ \\t]?"), "")
      block-quote(render(q + defs))
    } else {
      body-par(note: defs != "", render(t + defs))
    }
  })
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities (CRC 3.1113(f)), each on its own page, rows on the numbered lines
// ---------------------------------------------------------------------------

#let table-title(t) = block(width: 100%, below: pitch, sticky: true, align(center, strong(t)))

/// The headings of the memorandum, with the lines for the table of authorities and the memorandum's title.
#let toc-section(memo-headings) = {
  table-title[TABLE OF CONTENTS]
  context {
    let at(lbl) = str(counter(page).at(query(lbl).first().location()).first())
    listing-row(none, [TABLE OF AUTHORITIES], at(<toa-first>), toc-col, heading-tab, 0pt)
    listing-row(none, [MEMORANDUM OF POINTS AND AUTHORITIES], at(<memo-first>), toc-col, heading-tab, 0pt)
    for (k, (level, t)) in memo-headings.enumerate() {
      let loc = query(label("memo-h-" + str(k))).first().location()
      let pg = str(counter(page).at(loc).first())
      if level == 1 {
        listing-row(none, upper(inl(t)), pg, toc-col, heading-tab, 0pt)
      } else {
        let (lab, rest) = split-label(t)
        let ind = label-indent(level)
        listing-row(none, {
          h(ind)
          if lab != none { box(width: heading-tab, lab) }
          inl(rest)
        }, pg, toc-col, ind + if lab != none { heading-tab } else { 0pt }, 0pt)
      }
    }
  }
}

#let toa-groups = (
  ("case", "Cases"), ("constitution", "Constitutional Provisions"), ("statute", "Statutes"),
  ("regulation", "Regulations"), ("rule", "Rules"), ("other", "Other Authorities"),
)

// California style: the case name, then the year and the report ("Name (2001) 90 Cal.App.4th 810").
#let sort-key(a) = lower(a.at("sort", default: a.at("name", default: a.at("cite", default: ""))))

/// The authorities cited by a `toa:KEY` link, by kind, sorted, with the pages they are cited on; a key with no
/// entry under `authorities:` stops the build.
#let toa-section(authorities) = {
  table-title[TABLE OF AUTHORITIES]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("calsuperct-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(width: 100%, above: if first { 0pt } else { pitch }, sticky: true, strong(title))
      first = false
      for (key, a) in members {
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let pg = str(counter(page).at(h.location()).first())
          if pg not in pages { pages.push(pg) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        listing-row(none, {
          h(toa-indent)
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [ ]
          }
          inl(a.cite)
        }, page-text, toa-col, 2 * toa-indent, 0pt)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

/// Split the body into the notice (before the memorandum heading) and the memorandum.
#let split-body(body) = {
  let parts = body.split(regex("(?m)^# MEMORANDUM OF POINTS AND AUTHORITIES[ \t]*\r?\n"))
  if parts.len() != 2 {
    panic("calsuperct-motion-brief: the body needs exactly one line `# MEMORANDUM OF POINTS AND AUTHORITIES`")
  }
  (parts.at(0), parts.at(1))
}

#let calsuperct-motion-brief(meta, body) = {
  for k in ("footer_title", "attorney", "court", "caption", "signature") { let _ = need(meta, k) }
  let notes = (:)
  for m in body.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$")) {
    notes.insert(m.captures.at(0), m.captures.at(1))
  }
  let (notice, memo) = split-body(body)
  let authorities = meta.at("authorities", default: (:))

  set page(
    width: page-w,
    height: page-h,
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(need(meta, "footer_title")),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  show: xengine.with(pitch: pitch, list-indent: none)
  set block(above: 0pt, below: 0pt)
  // A doubled sign stays with its number too (xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  // Footnotes (CRC 2.108(3): may be single-spaced) at the type size, the mark, a space, the text (docx: Footnote
  // Text).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#metadata(counter(footnote).at(note.location()).first())<fn-body>#super(num) #note.body]
  }
  show footnote: it => it + note-check()

  // Authority links: a link whose target is `toa:KEY` is its text, recorded with the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#it.body#metadata(it.dest.slice(4))<toa-hit>]
    } else {
      it
    }
  }

  // The memorandum's headings (for the table of contents), each marked where it stands.
  let memo-headings = memo.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim())
    .map(c => c.match(regex("^(#+)[ \\t]+(.*)$"))).filter(m => m != none)
    .map(m => (m.captures.at(0).len(), m.captures.at(1).trim()))
  let memo-pieces = body-pieces(memo, notes)
  let k = 0
  let marked = ()
  for (i, p) in memo-pieces.enumerate() {
    let c = memo.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
      .filter(c => not c.starts-with(regex("^\\[\\^[^\\]]+\\]:"))).at(i)
    if c.starts-with(regex("#+[ \\t]")) {
      marked.push([#metadata(none)#label("memo-h-" + str(k))#p])
      k += 1
    } else {
      marked.push(p)
    }
  }

  // Page 1: attorney block, court title, caption; the notice starts on the first numbered line below the caption.
  attorney-block(meta)
  court-title(meta)
  caption(meta)
  to-grid(caption-clear)
  with-signature(body-pieces(notice, notes), signature-block(meta))

  // The tables, each on its own page (CRC 3.1113(f)).
  pagebreak()
  toc-section(memo-headings)
  pagebreak()
  [#metadata(none) <toa-first>]
  toa-section(authorities)

  // The memorandum (CRC 3.1113): its title, the body, the signature block.
  pagebreak()
  [#metadata(none) <memo-first>]
  block(width: 100%, below: pitch, sticky: true, align(center, strong[MEMORANDUM OF POINTS AND AUTHORITIES]))
  with-signature(marked, signature-block(meta))
  [#metadata(none) <memo-last>]

  // CRC 3.1113(d): the memorandum may not exceed the page limit. The count runs from the memorandum's first page to
  // the page of its signature block; the caption page, the notice and the tables are excluded.
  context {
    let first = query(<memo-first>).first().location().page()
    let last = query(<memo-last>).first().location().page()
    if last - first + 1 > memo-page-limit {
      panic("calsuperct-motion-brief: the memorandum is " + str(last - first + 1) + " pages; CRC 3.1113(d) allows " +
        str(memo-page-limit))
    }
  }
}
