// U.S. District Court, District of Utah: motion with its supporting memorandum (one document).
//
// Rules: DUCivR 7-1(a)(1) (the motion and memorandum are one document: an initial separate section states the relief
// sought and its grounds, then the facts, authority and argument), 10-1(1) (letter paper, 1 1/2 in top margin, 1 in
// others), 10-1(3) (12 point minimum, footnotes included; no face named), 10-1(4) (double spacing except block quotes
// and footnotes), 10-1(5) (pages numbered consecutively), 10-1(6) (counsel block above the caption; caption table
// with parties, title, case number, judge), 10-1(8) (signature); Fed. R. Civ. P. 12(b). See ../README.md and
// ../../rules.md. Content-agnostic: every case-specific word comes from the sample's frontmatter and body, never from
// this file. No coordinates measured off the exemplar, no forced line breaks.
//
// Layout: the counsel block, caption and the motion (DUCivR 7-1(a)(1)(A)) from page 1, then the tables of contents
// and authorities, then the memorandum (DUCivR 7-1(a)(1)(B)) from its `# MEMORANDUM OF LAW` heading.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // DUCivR 10-1(3) names no face; Times New Roman (docs/FONTS.md), vendored in fonts/
#let type-size = 12pt                   // DUCivR 10-1(3): minimum 12 point, footnotes included
#let margins = (top: 1.5in, bottom: 1in, x: 1in) // DUCivR 10-1(1): top at least 1 1/2 in, the others at least 1 in
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                // first-line indent of body paragraphs; list labels start here
#let label-box = 0.5in                  // a list label or heading label in a box: its text starts half an inch after it
#let caption-left = 3.75in              // the party column of the caption, closed by a rule on its right and below
#let caption-pad = 0.15in               // the party column's text to its rule, and the rule to the right column
#let designation-indent = 1.25in        // "Plaintiff," / "Defendants." under the party names
#let sig-left = 3.25in                  // the signature column starts 3.25 in from the margin
#let toc-col = 0.5in                    // contents: the page column the rows wrap before
#let toa-col = 1in                      // authorities: the page column ("9, 10, 11" fits)
#let toa-hang = 0.5in                   // an authority's later lines hang this far in
#let passim-threshold = 7               // an authority cited on this many pages or more: "passim"
#let toa-above = 6pt                    // above each authority (a group title has a blank single line above it)
#let lead-slack = 4pt                   // a row keeps its last word before the leader only with this much to spare: LibreOffice wants about 4 pt free after the
                                        // leader's three spaces (docs/EVAL-LOOP.md, federal-circuit fan-out), so typst asks for it too

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/utd-motion-brief.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-body = 24pt                  // DUCivR 10-1(4): double spacing, two 12 pt lines (body, lists, headings)
#let pitch-single = 13.8pt              // single spacing (counsel, court title, caption, tables, signature, page number, footnotes): Word's 1.15 x 12 pt
#let gap = 24pt                         // a blank double line: between the cover's parts, under a table's title, before the signature
#let note-gap = 6pt                     // after each footnote (Word: Footnote Text's space after)
#let note-clearance = 7.8pt             // the text to the footnote rule: with note-gap, the 13.8 pt single line of Word's separator

// Table of authorities: groups in order, with the heading each prints under.
#let toa-groups = (
  ("case", "Cases"),
  ("statute", "Statutes"),
  ("rule", "Rules"),
  ("other", "Other Authorities"),
)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("utd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("utd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Inline markdown.
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// Single-spaced lines, one paragraph each; "" is a blank single line. `above`: space above the first line.
#let line-stack(items, above: 0pt, left: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  let g = above
  for i in items {
    if i == "" { g += pitch-single } else {
      block(width: 100%, above: g, below: 0pt, pad(left: left, if type(i) == str { inl(i) } else { i }))
      g = 0pt
    }
  }
}

/// Printed label of a heading: level 2 "I.", 3 "A.", 4 "1."; level 1 none. The counters restart under each level 1.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 2 { numbering("I.", k) } else if lv == 3 { numbering("A.", k) } else if lv == 4 { numbering("1.", k) } else { "" }
}

#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

// ---------------------------------------------------------------------------
// Cover: counsel (DUCivR 10-1(6)(A)), court title, caption (DUCivR 10-1(6)(B))
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let left = ()
  for (k, side) in need(meta, "caption").enumerate() {
    if k > 0 { left += ("", [v.], "") }
    left += side.names
    left += ("", pad(left: designation-indent, inl(side.designation)))
  }
  let right = ([Case No. #need(meta, "case_number")], "", strong(upper(inl(need(meta, "brief_title")))))
  if "judge" in meta { right += ("", [Judge #meta.judge]) }
  if "magistrate" in meta { right.push([Magistrate Judge #meta.magistrate]) }
  block(width: 100%, above: gap, below: 0pt, breakable: false, grid(
    columns: (caption-left, 1fr),
    stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) } else { none },
    pad(right: caption-pad, bottom: pitch-single, line-stack(left)),
    pad(left: caption-pad, line-stack(right)),
  ))
}

#let cover(meta) = {
  line-stack(need(meta, "counsel") + (emph(inl(need(meta, "counsel_role"))),))
  line-stack(need(meta, "court").map(l => align(center, strong(upper(l)))), above: gap)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities (DUCivR 10-1 leaves their form open; the exemplar has both)
// ---------------------------------------------------------------------------

/// A table's title on the body pitch, a blank double line, then the column label at the right.
#let table-head(title, col) = {
  block(width: 100%, above: 0pt, below: gap, sticky: true, align(center, strong(title)))
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set text(..edges(pitch-single))
    align(right, strong(col))
  })
}

/// The contents: level 1 headings at the margin in capitals; a level 2 heading's label at the margin, level 3 half
/// an inch in, the label in a half-inch box and the title's later lines under the title; a blank single line above
/// each row.
#let toc() = {
  table-head[TABLE OF CONTENTS][Page]
  context {
    set text(..edges(pitch-single))
    for hd in query(heading) {
      if hd.level > 3 { continue }
      let lab = heading-num(..counter(heading).at(hd.location()).slice(0, hd.level))
      let ind = if hd.level <= 2 { 0pt } else { (hd.level - 2) * label-box }
      let t = if hd.level == 1 { upper(hd.body) } else { [#box(width: label-box, lab)#hd.body] }
      listing-row(hd.location(), [#h(ind)#t#h(lead-slack)], page-label(hd.location()), toc-col,
        if hd.level == 1 { label-box } else { ind + label-box }, pitch-single)
    }
  }
}

/// The authorities the body cites (its `toa:` links), by group, sorted by name (or citation); the pages each is
/// cited on.
#let toa(authorities) = {
  table-head[TABLE OF AUTHORITIES][Page(s)]
  context {
    set text(..edges(pitch-single))
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("utd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let sort-key(a) = lower(a.at("name", default: a.at("cite", default: "")))
    for (kind, title) in toa-groups {
      let keys = authorities.keys().filter(k => authorities.at(k).kind == kind and hits.any(h => h.value == k))
      keys = keys.sorted(key: k => sort-key(authorities.at(k)))
      if keys.len() == 0 { continue }
      block(width: 100%, above: pitch-single, below: 0pt, sticky: true, par(first-line-indent: 0pt, strong(title)))
      for k in keys {
        let a = authorities.at(k)
        let pages = ()
        for h in hits.filter(h => h.value == k) {
          let l = page-label(h.location())
          if l not in pages { pages.push(l) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        let text = if "name" in a {
          [#if kind == "case" { emph(a.name) } else { a.name }, #a.cite]
        } else { a.cite }
        listing-row(none, [#text#h(lead-slack)], page-text, toa-col, toa-hang, toa-above)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (DUCivR 10-1(8)): the date at the left; the firm, "/s/", the signer and the lines at the right
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, width: 100%, above: gap, below: 0pt, grid(
    columns: (sig-left, 1fr),
    line-stack(("DATED: " + need(meta, "date"),)),
    line-stack(sig.at("firm", default: ()) + ("", "/s/ " + sig.signer, sig.signer) + sig.at("lines", default: ())),
  ))
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let utd-motion-brief(meta, md) = {
  for k in ("case_number", "court", "caption", "counsel", "counsel_role", "brief_title", "signature", "date") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // The body is split at the memorandum: everything before it is the motion (DUCivR 7-1(a)(1)(A)).
  let split-at = md.position(regex("(?m)^# MEMORANDUM OF LAW"))
  if split-at == none { panic("utd-motion-brief: the body needs a `# MEMORANDUM OF LAW` heading (DUCivR 7-1(a)(1)(B))") }
  let motion-md = md.slice(0, split-at)
  let memo-md = md.slice(split-at)

  set page(
    paper: "us-letter",                  // DUCivR 10-1(1): 8 1/2 x 11 inch
    margin: margins,
    numbering: "1",                      // DUCivR 10-1(5): pages numbered consecutively
    // centered at the foot, in a single-pitch line box that ends footer-distance above the page edge
    footer-descent: margins.bottom - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set document(title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"), author: need(meta, "signature").signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number; list labels in a half-inch box.
  show: xengine.with(pitch: pitch-body, list-indent: label-box)
  // A doubled sign stays with its number ("§§ 1331"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)
  // Lists: the label half an inch in (the paragraph indent), the text an inch in.
  show enum: it => pad(left: para-indent, it)
  show list: it => pad(left: para-indent, it)

  // Footnotes: 12 pt (DUCivR 10-1(3)), single-spaced (DUCivR 10-1(4)); the mark, a space, the note; a note is not
  // split over pages (Word keeps Footnote Text's lines together).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    block(breakable: false)[#super(num) #note.body]
  }

  // Authority links print as ordinary text; a link whose target is `toa:KEY` is recorded on the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") { [#metadata(it.dest.slice(4))<toa-hit>#it.body] }
    else { text(fill: black, it.body) }
  }

  // Headings on the body pitch, bold, kept with the text after them: level 1 centered capitals; level 2 its label
  // ("I.") at the margin in a half-inch box, its later lines under its text; level 3 ("A.") the same half an inch in;
  // level 4 ("1.") an inch in.
  set heading(numbering: heading-num)
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, strong(upper(it.body))) } else {
      let lab = heading-num(..counter(heading).at(it.location()).slice(0, it.level))
      pad(left: (it.level - 2) * label-box, par(hanging-indent: label-box, strong[#box(width: label-box, lab)#it.body]))
    }
    block(width: 100%, above: 0pt, below: 0pt, sticky: true, b)
  }

  cover(meta)
  // The motion: the relief sought and its grounds, a separate initial section (DUCivR 7-1(a)(1)(A)), a blank double
  // line under the caption.
  block(width: 100%, above: gap, below: 0pt, cmarker.render(motion-md, raw-typst: false, smart-punctuation: true))

  pagebreak()
  toc()
  pagebreak()
  toa(authorities)
  pagebreak()

  // Footnote definitions may follow the last heading in the markdown, but a footnote reference is only resolved
  // in the same render call: the definitions are moved ahead of the split and rendered with the body.
  let lines = memo-md.split("\n")
  let footnote-defs = lines.filter(l => l.starts-with("[^")).join("\n")
  let text-body = lines.filter(l => not l.starts-with("[^")).join("\n")
  // The last section (from the last level 1 heading: the conclusion) is kept with the signature block, so the
  // signature never stands alone.
  let parts = text-body.split("\n# ")
  if parts.len() > 1 {
    cmarker.render(parts.slice(0, -1).join("\n# ") + "\n\n" + footnote-defs, raw-typst: false, smart-punctuation: true)
    block(breakable: false, width: 100%, above: 0pt, below: 0pt, {
      cmarker.render("# " + parts.last(), raw-typst: false, smart-punctuation: true)
      signature-block(meta)
    })
  } else {
    cmarker.render(text-body + "\n\n" + footnote-defs, raw-typst: false, smart-punctuation: true)
    signature-block(meta)
  }
}
