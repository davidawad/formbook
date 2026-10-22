// Memorandum of law in support of a motion for the U.S. District Court for the Central District of Illinois (ilcd).
// Rules: Civil LR 5.1 (format: letter paper, one-inch margins, numbered pages, double spacing, 12- or 14-point body,
// footnotes 10-point or larger), 7.1(B)(1) (memorandum identifies the rule under which the motion is filed),
// 7.1(B)(4) (double-spaced, 15 pages or 7,000 words; certificate of compliance), 40.1(E)(1) (division in the caption),
// 5.11(A) (s/name signatures), 11.1 (telephone number and typed name); Fed. R. Civ. P. 12(b). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LR 5.1(B)(2) asks for a plain roman style and names no face; Times New Roman, with Liberation Serif its vendored metric-compatible substitute (docs/FONTS.md)
#let type-size = 12pt                   // LR 5.1(B)(2): body text 12-point or 14-point
#let footnote-size = 10pt               // LR 5.1(B)(2): footnote text no smaller than 10-point
#let page-margin = 1in                  // LR 5.1(A)
#let para-indent = 0.5in                // first-line indent of body text
#let heading-hang = 0.5in               // a level 2 heading's later lines hang this far in (after its typed "I." label)
#let caption-left = 3.2in               // party column of the caption, closed by a rule on its right and below
#let caption-pad = 0.15in               // the party column's text to its rule, and the rule to the case number
#let designation-indent = 1.25in        // "Plaintiff," and "v." sit under the party names
#let counsel-indent = 3.25in            // counsel block and signature block start at the right half of the page
#let toc-col = 0.5in                    // contents: the page column the rows wrap before
#let toa-col = 0.75in                   // authorities: the page column ("6, 7, 8, 9" fits)
#let toa-hang = 0.5in                   // an authority's second line hangs this far in
#let passim-threshold = 7               // an authority cited on this many pages or more: "passim"

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/ilcd-motion-brief.lua sets the same twips).
#let pitch-body = 24pt                  // LR 5.1(B)(1), 7.1(B)(4): double spacing, a 24 pt pitch at 12 pt (body, headings, certificate)
#let pitch-single = 13.8pt              // single spacing (court title, caption, title, counsel, tables, quotations, signature, page number): Word's single line, 1.15 x 12 pt
#let pitch-note = 11.5pt                // a footnote line: 1.15 x the footnote size
#let gap = 24pt                         // one blank double-spaced line: around the caption and title, before a table's rows and the signature
#let note-gap = 6pt                     // after each footnote (Word: Footnote Text's space after)
#let note-clearance = 7.8pt             // the text to the footnote rule: with note-gap, the 13.8 pt single line of Word's separator

// Table of authorities: groups in order, with the heading each prints under.
#let toa-groups = (
  ("case", "Cases"),
  ("constitution", "Constitutional Provisions"),
  ("statute", "Statutes"),
  ("regulation", "Regulations"),
  ("rule", "Rules"),
  ("other", "Other Authorities"),
)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilcd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced lines, one paragraph each; an empty string is a blank single line. `above`: space above the first.
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

/// Words in the memorandum body, counted from the markdown: link targets, footnote markers and the footnote
/// labels are not words; headings, footnote text and quotations are (LR 7.1(B)(4)(d)). The cover, tables and
/// signature block are generated outside the body and are not counted. An approximation: a draft for the
/// filer's word processor count, which the certificate may rely on (LR 7.1(B)(4)(c)).
#let word-count(md) = {
  let s = md.replace(regex("\\((toa|https?):[^)]*\\)"), "")
  s = s.replace(regex("\\[\\^[^\\]]*\\]:?"), "")
  s.replace(regex("\\s+"), " ").split(" ").filter(w => w.match(regex("[A-Za-z0-9]")) != none).len()
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper, counsel
// ---------------------------------------------------------------------------

#let court-title(meta) = line-stack((
  align(center, strong[UNITED STATES DISTRICT COURT]),
  align(center, strong[CENTRAL DISTRICT OF ILLINOIS]),
  // LR 40.1(E)(1): the caption must identify the division in which the case is pending.
  align(center, strong(upper(meta.division))),
))

/// Caption: the party column (names, designations, "v.", a blank single line between the entries) closed by a rule
/// on its right and below, as filed; the case number at the right, on the column's first line.
#let caption(meta) = {
  let left = ()
  let parties = meta.caption.parties
  for (k, p) in parties.enumerate() {
    if k > 0 { left += ("", pad(left: designation-indent, [v.]), "") }
    for n in p.names { left.push(inl(n)) }
    left += ("", pad(left: designation-indent, inl(p.designation)))
  }
  block(width: 100%, above: gap, below: 0pt, breakable: false, grid(
    columns: (caption-left, 1fr),
    stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) } else { none },
    pad(right: caption-pad, bottom: pitch-single, line-stack(left)),
    pad(left: caption-pad, line-stack(([Case No. #meta.case_number],))),
  ))
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  block(width: 100%, above: gap, below: 0pt,
    line-stack((align(center, strong(upper(inl(meta.brief_title)))),)))
  // The counsel block of the cover, in the right half of the page (LR 11.1 is met in the signature block); a blank
  // single line between the groups.
  let lines = ()
  for (i, g) in meta.counsel.enumerate() {
    if i > 0 { lines.push("") }
    lines += g.names + g.lines
  }
  line-stack(lines, above: 2 * gap, left: counsel-indent)
}

// ---------------------------------------------------------------------------
// Tables: contents (generated from headings) and authorities (generated from the links in the body)
// ---------------------------------------------------------------------------

#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

/// A table's title on the body pitch, a blank double line, then the column label at the right.
#let table-head(title, col) = {
  block(width: 100%, above: 0pt, below: gap, sticky: true, align(center, strong(title)))
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set text(..edges(pitch-single))
    align(right, strong(col))
  })
}

/// The contents: level 1 headings at the margin, deeper levels half an inch in per level, each title's later lines
/// half an inch further in; a blank single line above each row.
#let toc() = {
  table-head[TABLE OF CONTENTS][Page]
  context {
    set text(..edges(pitch-single))
    for hd in query(heading) {
      if hd.level > 3 { continue }
      let ind = (hd.level - 1) * heading-hang
      let t = if hd.level == 1 { upper(hd.body) } else { hd.body }
      listing-row(hd.location(), [#h(ind)#t], page-label(hd.location()), toc-col, ind + heading-hang, pitch-single)
    }
  }
}

/// The authorities the body cites (its `toa:` links), by group, sorted by name; the pages each is cited on.
#let toa(meta) = {
  table-head[TABLE OF AUTHORITIES][Page(s)]
  context {
    set text(..edges(pitch-single))
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in meta.authorities {
        panic("ilcd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:`")
      }
    }
    for (kind, title) in toa-groups {
      let keys = meta.authorities.keys().filter(k => meta.authorities.at(k).kind == kind and hits.any(h => h.value == k))
      keys = keys.sorted(key: k => lower(meta.authorities.at(k).name))
      if keys.len() == 0 { continue }
      block(width: 100%, above: pitch-single, below: 0pt, sticky: true, par(first-line-indent: 0pt, strong(title)))
      for k in keys {
        let a = meta.authorities.at(k)
        let pages = ()
        for h in hits.filter(h => h.value == k) {
          let l = page-label(h.location())
          if l not in pages { pages.push(l) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        let name = if kind == "case" { emph(a.name) } else { a.name }
        let cite = if a.cite != "" { [, #a.cite] } else { [] }
        listing-row(none, [#name#cite], page-text, toa-col, toa-hang, pitch-single)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature and certificate
// ---------------------------------------------------------------------------

/// "Dated" at the left; "Respectfully submitted," and the firm at the right; "/s/ name" and the signer's
/// name, address, telephone and email typed below (LR 5.11(A)(2), LR 11.1); a blank single line between the parts.
#let signature-block(meta) = block(breakable: false, width: 100%, above: gap, below: 0pt,
  grid(
    columns: (counsel-indent, 1fr),
    line-stack(("Dated: " + meta.date,)),
    line-stack(("Respectfully submitted,", "") + meta.signature.firm + ("", "/s/ " + meta.signature.signer)
      + meta.signature.lines),
  ),
)

/// Certificate of compliance with the type-volume limitation (LR 7.1(B)(4)(c)), on a page of its own. The count is
/// the template's count of the body (see word-count); the filer must confirm it with the word processor.
#let certificate(meta, words) = {
  pagebreak()
  heading(level: 1)[Certificate of Compliance]
  block(width: 100%, above: 0pt, below: 0pt, par[I certify pursuant to Civil Local Rule 7.1(B)(4)(c) that this memorandum complies with the type-volume limitation. This memorandum contains #words words, including headings, footnotes, and quotations, and excluding the cover page, tables, and signature block.])
  block(breakable: false, width: 100%, above: gap, below: 0pt,
    line-stack(("/s/ " + meta.signature.signer,) + meta.signature.lines.slice(0, 1), left: counsel-indent))
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let ilcd-motion-brief(meta, body) = {
  assert("division" in meta, message: "ilcd-motion-brief: LR 40.1(E)(1) requires the division in the caption (frontmatter: division)")
  let words = word-count(body)

  // LR 5.1(A): letter paper, one-inch margins, the page number centered in the bottom margin (Word's footer).
  let running-footer = context align(center,
    text(..edges(pitch-single), numbering(here().page-numbering(), ..counter(page).get())))
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%)
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 1, 3(a)"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Footnotes: 10 pt (LR 5.1(B)(2)), single-spaced; the mark, a space, the note (Word's footnote layout); a note is
  // not split over pages (Word keeps Footnote Text's lines together: the line that anchors it moves on instead).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: footnote-size, ..edges(pitch-note))
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

  // Headings on the body pitch, as the author types them (labels "I.", "A." included), kept with the text after
  // them: level 1 centered bold capitals; level 2 bold, its later lines hanging half an inch; level 3 the same half
  // an inch in; level 4 bold italic an inch in.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, strong(upper(it.body))) }
      else if it.level <= 3 { pad(left: (it.level - 2) * heading-hang, par(hanging-indent: heading-hang, strong(it.body))) }
      else { pad(left: 2 * heading-hang, strong(emph(it.body))) }
    block(width: 100%, above: 0pt, below: 0pt, sticky: true, b)
  }

  // Quotations: single-spaced, indented half an inch on both sides, a single line above and below.
  show quote.where(block: true): it => block(width: 100%, above: pitch-single, below: pitch-single, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(x: para-indent, it.body)
  })

  // Cover: no page number (the cover is the first page of the document).
  page(numbering: none, footer: none, cover(meta))

  // Front matter: contents and authorities, numbered in roman numerals.
  set page(numbering: "i", footer: running-footer)
  counter(page).update(1)
  toc()
  pagebreak()
  toa(meta)

  // Body: arabic numbers from 1; the cited pages in the tables are these numbers.
  pagebreak()
  set page(numbering: "1", footer: running-footer)
  counter(page).update(1)

  // Footnote definitions may follow the last heading in the markdown, but a footnote reference is only resolved
  // in the same render call: the definitions are moved ahead of the split and rendered with the body.
  let lines = body.split("\n")
  let footnote-defs = lines.filter(l => l.starts-with("[^")).join("\n")
  let text-body = lines.filter(l => not l.starts-with("[^")).join("\n")
  // The last section (from the last level 1 heading: the conclusion) is kept with the signature block, so the
  // sign-off never stands alone.
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

  if "type_volume" in meta and meta.type_volume {
    certificate(meta, words)
  }
}
