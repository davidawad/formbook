// San Diego County Superior Court (calsuperct-sandiego): motion (notice and memorandum of points and authorities) on
// pleading paper.
//
// Rule-driven and content-agnostic. The governing rules are Cal. Rules of Court 2.100-2.119, 3.1110 and 3.1113 and
// the San Diego Superior Court Local Rules, Division II (see ../README.md for the rule numbers, URLs and the date each
// was verified). No case-specific text, no coordinates measured off the filed exemplar, no forced line breaks. The
// markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the same file.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/pleading-paper.typ": line-numbers as shared-line-numbers, pleading-rules as shared-pleading-rules
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters: the only numbers in this file. Each one traces to a rule or is a named style choice.
// ---------------------------------------------------------------------------

// CRC 2.105: "essentially equivalent to Courier, Times New Roman, or Arial". No face is named, so
// the house face applies: Times New Roman (Liberation Serif, its metric twin, as the fallback).
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 12pt              // CRC 2.104: a font size not smaller than 12 points (footnotes included).
#let lines-per-page = 28           // numbered lines per page (pleading convention, tier 2; CRC 2.108 sets no count).
#let page-w = 8.5in
#let page-h = 11in
#let top-margin = 1in              // line 1 starts 1 inch from the top (CRC 2.111(1)).
#let left-margin = 1.5in           // text starts here; CRC 2.107 requires at least 1 inch.
#let right-margin = 0.5in          // CRC 2.107 requires at least 1/2 inch.
#let clerk-lines = 7               // lines 1-7 keep the right of center clear (CRC 2.111(2)).
#let para-indent = 0.5in
#let fee-width = 2.3in             // the fee-exemption label's column, top right (SD Local Rule 2.1.2(H)).
#let caption-left = 3.6in          // the party column of the caption.
#let caption-inset = 9pt           // the party column's text stands off its right rule
#let caption-foot = 9pt            // and its last line off its bottom rule
#let caption-rule = 0.75pt         // the party column's rules
#let caption-right = 0.2in         // the case column stands off the party column's rule
#let space-indent = 3pt            // a leading space in a caption line indents it by a quarter em (12 pt)
#let signature-left = 3.1in        // the signature column
#let signer-indent = 0.3in         // the signer's name and role, in from the signature column
#let signature-rule = 2.7in        // the signature line after "By:"
#let footer-size = 10pt            // CRC 2.110: the footer title in at least 10-point type.
#let memo-page-limit = 10          // CRC 3.1113(f): over 10 pages, a TOC and a TOA are required.
#let toc-indent = 0.5in            // each heading level below the top one, in the table of contents
#let toc-col = 0.5in               // the page column of the table of contents
#let toa-hang = 0.25in             // a citation stands under its case name, this far in
#let toa-col = 0.75in              // the page column of the table of authorities

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is set here (Word's exact
// line spacing; docx/calsuperct-sandiego-motion-brief.lua sets the same twips).
#let pitch = 24pt                  // double spacing (CRC 2.108(1)); the numbered lines (body, headings, tables).
#let pitch-single = 12pt           // single spacing (attorney block, caption, signature): two lines to a numbered line.
#let pitch-note = pitch           // footnotes on the numbered lines (CRC 2.108(3) allows single spacing, does not require
                                   // it): stacked from the foot of line 28, every note line is level with a line number, so
                                   // the PDF text reads the same lines in every engine (single lines there would stand
                                   // 2.4 pt off a number and read with it or apart by a hair)
#let note-gap = 0pt                // between two footnotes: none, so every note stays on the numbered lines
#let note-clearance = 14.5pt       // the body text to the footnote rule: the 14.5 pt LibreOffice keeps above a note
#let gap = pitch-single            // a single line between the groups of the caption and the signature
// A group of single lines starts this far below a numbered line's top, so every second single line stands level
// with a line number and the others halfway between two: the PDF text reads the same lines in every engine.
#let single-drop = 0.8 * (pitch - pitch-single)
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 48 pt: holds the footer
#let footer-gap = 4pt              // the footer's rule this far below the last numbered line
#let footer-rule-gap = 2pt         // the page number's line box this far below the rule

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// A loose markdown paragraph's trailing paragraph break dropped (a chunk rendered alone ends in one).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Render an inline markdown string (italics, links, footnote references) as inline content.
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

#let need(meta, key) = {
  if key not in meta { panic("calsuperct-sandiego-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("calsuperct-sandiego-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced lines, one paragraph per item, with `above` before the first. An empty item is an empty line;
/// leading spaces in an item indent it by a quarter em each, so the caption's "Plaintiff," and "v." sit where the
/// filer put them.
#let line-stack(items, above: 0pt, weight: "regular", align-to: left) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single), weight: weight)
  set par(first-line-indent: 0pt)
  for it in items {
    let m = it.match(regex("^( *)(.*)$"))
    let n = m.captures.at(0).len()
    let t = m.captures.at(1)
    if t == "" { block(height: pitch-single) } else {
      block(width: 100%, inset: (left: n * space-indent), align(align-to, inl(t)))
    }
  }
})

// ---------------------------------------------------------------------------
// Pleading paper: 28 numbered lines, two vertical rules, footer below the page number
// ---------------------------------------------------------------------------

#let line-numbers() = shared-line-numbers(left-margin, top-margin, pitch, lines-per-page, type-size, ..edges(pitch))

#let pleading-rules() = shared-pleading-rules(page-w, page-h, left-margin, right-margin)

/// Footer (CRC 2.109, 2.110): a printed line, the page number (in the numbering of the page it sits on), then the
/// title of the paper in at least 10-point type, in the bottom margin below the last numbered line.
#let footer-block(title) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + footer-gap,
  block(width: page-w - left-margin - right-margin, {
    line(length: 100%, stroke: 0.5pt)
    block(above: footer-rule-gap, below: 0pt, {
      set text(..edges(pitch-single))
      align(center, context numbering(here().page-numbering(), ..counter(page).get()))
    })
    block(above: 0pt, below: 0pt, {
      set text(size: footer-size, ..edges(pitch-single))
      align(center, title)
    })
  }),
)

// ---------------------------------------------------------------------------
// First page (CRC 2.111, 3.1110(b)): attorney block on line 1, court title on line 8, caption
// ---------------------------------------------------------------------------

/// Top of the first page: the attorney block, single spaced from line 1, left of center, on lines 1-7 at least
/// (CRC 2.111(1), (2)); more lines push the court title down to the next numbered line. When the filer is exempt
/// from fees (Gov. Code, § 6103), the label goes in the upper right-hand corner above the caption, clear of the
/// clerk's file-stamp area (SD Local Rule 2.1.2(H)).
#let first-page-top(meta) = {
  let att = need(meta, "attorney")
  let fee = meta.at("fee_exempt", default: ())
  let rows = calc.max(att.len(), fee.len())
  let n = calc.max(clerk-lines, calc.ceil((single-drop + rows * pitch-single) / pitch))
  if fee.len() > 0 {
    grid(columns: (1fr, fee-width), column-gutter: 0pt,
      block(height: n * pitch, inset: (top: single-drop), line-stack(att)),
      block(height: n * pitch, inset: (top: single-drop), line-stack(fee, align-to: right)))
  } else {
    block(height: n * pitch, inset: (top: single-drop), line-stack(att))
  }
}

/// Court title: centered, bold, one numbered line each, from line 8 (CRC 2.111(3)).
#let court-title(meta) = {
  for l in need(meta, "court") { block(align(center, text(weight: "bold", inl(l)))) }
}

/// Caption, a numbered line below the court title: parties on the left (ruled at its right and foot), the case
/// number, the nature of the paper, the details and the hearing block on the right (CRC 2.111(4)-(7), 3.1110(b)).
#let caption(meta) = {
  let cap = need(meta, "caption")
  block(above: pitch, grid(
    columns: (caption-left, 1fr),
    grid.cell(stroke: (right: caption-rule, bottom: caption-rule), inset: (top: single-drop, right: caption-inset, bottom: caption-foot + caption-rule),
      line-stack(need(cap, "left"))),
    // The case column ends as low as the party column: Word and LibreOffice give a row the foot of its tallest cell
    // with the party column's inset and rule below it.
    grid.cell(inset: (top: single-drop, left: caption-right, bottom: caption-foot + caption-rule), {
      let above = 0pt
      if "case_number" in cap { line-stack((cap.case_number,)); above = gap }
      // Limited civil cases carry the words "Limited Civil Case" in the caption (CRC 2.111(10)).
      if "limited_civil" in cap and cap.limited_civil { line-stack(("LIMITED CIVIL CASE",), above: above); above = gap }
      line-stack(need(cap, "title"), above: above, weight: "bold")
      if "details" in cap { line-stack(cap.details, above: gap) }
      // CRC 3.1110(b): the hearing date, time and place, the hearing judge, the date the action was filed and the
      // trial date (if set) on the first page. CRC 2.111(7): judge and department below the nature of the paper.
      let rows = ()
      if "hearing" in cap {
        for (key, label) in (("date", "Date:"), ("time", "Time:"), ("dept", "Dept.:"), ("judge", "Judge:")) {
          if key in cap.hearing { rows.push(label + " " + cap.hearing.at(key)) }
        }
      } else {
        if "dept" in cap { rows.push("Dept.: " + cap.dept) }
        if "judge" in cap { rows.push("Judge: " + cap.judge) }
      }
      if "action_filed" in cap { rows.push("Action filed: " + cap.action_filed) }
      if "trial_date" in cap { rows.push("Trial date: " + cap.trial_date) }
      if rows.len() > 0 { line-stack(rows, above: gap) }
      // CRC 2.111(9): on a limited civil paper, the amount-demanded statement (wording from the frontmatter).
      if "amount_demanded" in cap { line-stack((cap.amount_demanded,), above: gap) }
    }),
  ))
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities (CRC 3.1113(f)): a memorandum that exceeds 10 pages must include both. Built
// when the frontmatter has `authorities:`; citations in the body are links `[text](toa:key)` whose key names an
// entry there. Every row is on the numbered lines.
// ---------------------------------------------------------------------------

/// Put an invisible `tag` right after the first word of `c`, keeping any emphasis around it. A tag placed before
/// the first word of a line is filed under the previous line, which can be on the previous page, so the table of
/// authorities would cite the wrong page.
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

/// Printed page label of a location ("3", "ii").
#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

#let table-title(t) = block(sticky: true, align(center, strong(t)))

#let toc-section() = {
  table-title[TABLE OF CONTENTS]
  context {
    let hds = query(selector(heading).after(<memo-start>))
    if hds.len() == 0 { panic("calsuperct-sandiego-motion-brief: the memorandum has no headings for its table of contents") }
    let top = calc.min(..hds.map(h => h.level))
    for hd in hds {
      let ind = (hd.level - top) * toc-indent
      listing-row(hd.location(), { h(ind); hd.body }, page-label(hd.location()), toc-col, ind + toc-indent, 0pt)
    }
  }
}

#let toa-groups = (
  ("case", "CASES"),
  ("constitution", "CONSTITUTIONAL PROVISIONS"),
  ("statute", "STATUTES"),
  ("regulation", "REGULATIONS"),
  ("rule", "RULES"),
  ("other", "OTHER AUTHORITIES"),
)

#let sort-key(a) = lower(a.at("sort", default: a.at("name", default: a.cite)))

/// Each group a numbered line below the one before, its title kept with its first entry; an entry with a name is
/// the name on its own line and the citation under it, a dot leader and every page that cites it.
#let toa-section(authorities) = {
  table-title[TABLE OF AUTHORITIES]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("calsuperct-sandiego-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 0pt } else { pitch }, sticky: true, strong(title))
      first = false
      for (key, a) in members {
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let label = page-label(h.location())
          if label not in pages { pages.push(label) }
        }
        if "name" in a {
          block(sticky: true, par(hanging-indent: toa-hang, [#if kind == "case" { emph(inl(a.name)) } else { inl(a.name) },]))
          listing-row(none, { h(toa-hang); inl(a.cite) }, pages.join(", "), toa-col, toa-hang, 0pt)
        } else {
          listing-row(none, inl(a.cite), pages.join(", "), toa-col, toa-hang, 0pt)
        }
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (CRC 2.111(1); the signature under CCP 128.7 is the signer's own)
// ---------------------------------------------------------------------------

/// A numbered line below the text: the date at the left, the signature lines in the signature column, a numbered
/// line, "By:" and the signature line, the signer's name and role; never split across pages.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: pitch, inset: (top: single-drop), {
    if "dated" in sig { line-stack(("Dated: " + sig.dated,)) }
    pad(left: signature-left, {
      line-stack(sig.at("lines", default: ()))
      block(above: pitch, below: 0pt, {
        set text(..edges(pitch-single))
        [By: #box(width: signature-rule, line(length: 100%, stroke: 0.5pt))]
      })
      pad(left: signer-indent, {
        line-stack((upper(sig.signer),), weight: "bold")
        if "role" in sig { block(above: 0pt, below: 0pt, { set text(..edges(pitch-single)); inl(sig.role) }) }
      })
    })
  })
}

// ---------------------------------------------------------------------------
// The body: markdown chunks (the text between blank lines), without the footnote definitions; each chunk rendered
// alone with the definitions of the footnotes it refers to. A heading is on the numbered lines, kept with the chunk
// after it; every other chunk is a paragraph, its first line indented half an inch.
// ---------------------------------------------------------------------------

#let chunks-of(md) = {
  md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim())
    .filter(c => c != "" and not c.starts-with(regex("\\[\\^[^\\]]+\\]:")))
}

#let pieces-of(chunks, notes) = chunks.map(t => {
  let defs = ""
  for r in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
    let id = r.captures.at(0)
    defs += "\n\n[^" + id + "]: " + notes.at(id, default: "")
  }
  if t.starts-with("#") {
    block(sticky: true, cmarker.render(t + defs, raw-typst: false, smart-punctuation: true, h1-level: 1))
  } else {
    block(par(first-line-indent: (amount: para-indent, all: true), inl(t + defs)))
  }
})

/// Pieces whose last one stays whole with `closing` after it.
#let with-closing(pieces, closing) = {
  if pieces.len() == 0 { closing; return }
  for p in pieces.slice(0, -1) { p }
  block(breakable: false, { pieces.last(); closing })
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let calsuperct-sandiego-motion-brief(meta, body) = {
  let authorities = meta.at("authorities", default: none)
  if body.match(regex("(?m)^#+[ \t]+[^\n]*\\]\\(toa:")) != none {
    panic("calsuperct-sandiego-motion-brief: citation links (toa:) are not allowed in headings; the table of contents would list them as authorities")
  }
  // Footnote text is kept apart from the chunks (each chunk is rendered alone with the definitions it refers to).
  let notes = (:)
  for m in body.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$")) { notes.insert(m.captures.at(0), m.captures.at(1)) }
  // A combined paper (notice of motion, then the memorandum) is split at the memorandum's heading; the tables go
  // between the two. Without that heading the whole body is the memorandum.
  let chunks = chunks-of(body)
  let memo-at = chunks.position(c => c.match(regex("(?i)^#+[ \t]+memorandum of points and authorities")) != none)
  let notice-chunks = if memo-at == none { () } else { chunks.slice(0, memo-at) }
  let memo-head = if memo-at == none { () } else { (chunks.at(memo-at),) }
  let memo-chunks = if memo-at == none { chunks } else { chunks.slice(memo-at + 1) }

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    footer: none,
    foreground: footer-block(need(meta, "footer_title")),
    // CRC 2.109: pages numbered consecutively at the bottom. With tables, the caption page, any notice and the
    // tables take lowercase roman numerals and the memorandum starts again at 1.
    numbering: if authorities == none { "1" } else { "i" },
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(first-line-indent: 0pt)
  show: xengine.with(pitch: pitch, list-indent: none)
  // A doubled sign stays with its number ("§§ 17200"): xengine binds one sign, so "§" "§ 17200" could part.
  show regex("[§¶]+ \\S+"): it => box(it)
  set block(above: 0pt, below: 0pt, width: 100%)

  // Headings on the numbered lines: levels 1 and 2 centered bold capitals; level 3 bold; levels 4 and 5 bold italic.
  show heading: it => {
    let b = if it.level <= 2 { upper(it.body) } else { it.body }
    let t = text(size: type-size, weight: "bold", style: if it.level >= 4 { "italic" } else { "normal" }, b)
    block(width: 100%, if it.level <= 2 { align(center, t) } else { t })
  }
  // Footnotes at 12 pt (CRC 2.104) in single lines (CRC 2.108(3)), the mark, a space, the text (docx: Footnote Text).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: type-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num) #note.body]
  }
  // A citation link (toa:KEY) is recorded with the page its first word is on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it }
  }

  first-page-top(meta)
  court-title(meta)
  caption(meta)

  let closing = {
    if "jury_demand" in meta {
      block(above: pitch, sticky: true, align(center, text(weight: "bold", upper(meta.jury_demand))))
    }
    signature-block(meta)
  }
  let memorandum(gap) = {
    if gap { v(pitch) }
    for p in pieces-of(memo-head, notes) { p }
    [#metadata(none)<memo-start>]
    with-closing(pieces-of(memo-chunks, notes), closing)
    [#metadata(none)<memo-end>]
  }

  // The notice (if any) a numbered line below the caption.
  if notice-chunks.len() > 0 {
    v(pitch)
    for p in pieces-of(notice-chunks, notes) { p }
  }
  if authorities == none {
    memorandum(notice-chunks.len() == 0)
    // CRC 3.1113(f): a memorandum over 10 pages needs a table of contents and a table of authorities.
    context {
      let n = locate(<memo-end>).page() - locate(<memo-start>).page() + 1
      if n > memo-page-limit {
        panic("calsuperct-sandiego-motion-brief: the memorandum runs " + str(n) + " pages; CRC 3.1113(f) requires a table of contents and a table of authorities over " + str(memo-page-limit) + " (add `authorities:` to the frontmatter)")
      }
    }
  } else {
    pagebreak()
    toc-section()
    pagebreak()
    toa-section(authorities)
    {
      set page(numbering: "1")
      counter(page).update(1)
      memorandum(false)
    }
  }
}
