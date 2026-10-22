// U.S. District Court, District of Connecticut (ctd): memorandum of law in support of a motion
// (Rule 12(b) motion to dismiss, or any other motion with a memorandum).
//
// Rule-driven and content-agnostic. Requirement IDs (CTD-...) refer to ../README.md and ../../rules.md, which quote
// the rule text (D. Conn. Local Rules 5(c), 7(a), 7(d), 10; Fed. R. Civ. P. 7(b), 10, 12(b); the Electronic Filing
// Policies and Procedures). No case-specific text, no coordinates measured off the exemplar, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the same file (schema:
// ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // CTD-FORM-006: the rules name no font (see README); Times New Roman, the house face (vendored, docs/FONTS.md)
#let type-size = 12pt                // CTD-FORM-102: text "in at least 12 point font" (L. Civ. R. 7(a)(5))
#let note-size = 10pt                // CTD-FORM-102: footnotes "in at least 10 point font" (L. Civ. R. 7(a)(5))
#let margin = 1in                    // CTD-FORM-002/003: at least one inch left and right (L. Civ. R. 10); 1 in top and bottom
#let text-width = 8.5in - 2 * margin
#let para-indent = 0.5in             // first-line indent of body paragraphs
#let heading-tab = 0.5in             // a heading's label box; each deeper level half an inch further in
#let list-left = 0.5in               // a list item's label starts half an inch in ...
#let list-label = 0.4in              // ... in a box this wide; the text hangs after it
#let quote-indent = 0.5in            // a block quotation is indented this much on both sides
#let caption-left = 3.3in            // width of the party column of the caption
#let caption-rule-pad = 10pt         // the party column's text to its right rule
#let caption-gutter = 0.2in          // the party column's rule to the right column ...
#let caption-pad = 0.1in             // ... and the right column's text stands off the gutter by this much
#let designation-indent = 1.5in      // designations ("Plaintiffs,", "Defendant.") sit under the names
#let sig-left = 2.8in                // the signature column's left edge ("Dated:" at the margin; CTD-ELEC-005: right half)
#let page-col = 1in                  // contents and authorities: the page column the rows wrap before (room for a list of pages)
#let toa-hang = 0.35in               // an authority's second line hangs this far in
#let passim-threshold = 7            // authority cited on this many pages or more: "passim"

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/motion-brief.lua and docx/reference.xml set the
// same twips).
#let pitch-body = 27.6pt             // CTD-FORM-101: memoranda "double-spaced" (L. Civ. R. 7(a)(5)), twice the 13.8 pt single line of 12 pt Times
#let pitch-single = 13.8pt           // single-spaced (L. Civ. R. 7(a)(5) exempts headings and block quotes): court title,
                                     // caption, headings, quotations, table rows, signature blocks, page number
#let pitch-note = 11.5pt             // footnotes single-spaced (L. Civ. R. 7(a)(5)): the single line of 10 pt Times
#let blank = 27.6pt                  // one blank body line: court title to caption, text to signature, signature to certification
#let single-gap = 13.8pt             // one blank single line: above a heading, a quotation, a table row or group; inside the caption
#let note-gap = 4pt                  // between two footnotes (docx: Footnote Text 80 twips after)
#let note-clearance = 12pt           // the body text to the footnote rule
// CTD-FORM-005 (L. Civ. R. 10: page numbers in the bottom margin): the number in a single-spaced line box whose foot is
// 0.5 in above the bottom edge (docx: footer distance 720 twips): 72 - 36 - 13.8 = 22.2 pt below the text.
#let footer-descent = 22.2pt

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

#let need(meta, key) = {
  if key not in meta { panic("ctd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ctd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced lines, one paragraph each; an empty item is a blank single line. `above`: the space before the
/// first line. An item is a string (markdown) or content.
#let line-stack(items, above: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let g = above
  for i in items {
    if i == "" { g += pitch-single } else {
      block(width: 100%, above: g, below: 0pt, if type(i) == str { unloose(inl(i)) } else { i })
      g = 0pt
    }
  }
}

/// A centred bold title in a single line, kept with what follows.
#let title-line(s, above: 0pt) = block(width: 100%, above: above, below: 0pt, sticky: true, {
  set text(..edges(pitch-single))
  align(center, par(first-line-indent: 0pt, strong(upper(s))))
})

// ---------------------------------------------------------------------------
// Headings: numbering and styles (CTD-CONT-104)
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 2 "A.", 3 "1.", 4 "a.". Level 1 is unnumbered.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 2 { numbering("A.", k) }
  else if lv == 3 { numbering("1.", k) }
  else if lv == 4 { numbering("a.", k) }
  else { "" }
}

/// Left edge of a heading's label: level 2 at the margin, each deeper level half an inch in.
#let label-indent(level) = calc.max(level - 2, 0) * heading-tab

// ---------------------------------------------------------------------------
// Tables of contents and authorities (CTD-CONT-103)
// ---------------------------------------------------------------------------

#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

/// A table's title, then its column label at the right.
#let table-head(title, col) = {
  title-line(title)
  block(width: 100%, above: single-gap, below: 0pt, sticky: true, {
    set text(..edges(pitch-single))
    align(right, par(first-line-indent: 0pt, strong(col)))
  })
}

#let toc-section() = {
  table-head[Table of Contents][Page]
  context {
    set text(..edges(pitch-single))
    for hd in query(heading.where(outlined: true)) {
      if hd.level > 4 { continue }
      let body = if hd.level == 1 { upper(hd.body) } else {
        let lab = heading-num(..counter(heading).at(hd.location()).slice(0, hd.level))
        [#h(label-indent(hd.level))#box(width: heading-tab, lab)#hd.body]
      }
      listing-row(hd.location(), body, page-label(hd.location()), page-col, label-indent(hd.level) + heading-tab,
        single-gap)
    }
  }
}

#let toa-groups = (
  ("case", "Cases"),
  ("statute", "Statutes"),
  ("rule", "Federal Rules"),
  ("regulation", "Regulations"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(a.at("name", default: a.at("cite", default: "")))

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  table-head[Table of Authorities][Page(s)]
  context {
    set text(..edges(pitch-single))
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("ctd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(width: 100%, above: single-gap, below: 0pt, sticky: true, par(first-line-indent: 0pt, strong(title)))
      for (key, a) in members {
        // Distinct printed page labels, in document order (the page a citation starts on).
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let label = page-label(h.location())
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        let name = if "name" in a { [#if kind == "case" { emph(unloose(inl(a.name))) } else { unloose(inl(a.name)) }, ] }
        listing-row(none, [#name#unloose(inl(a.cite))], page-text, page-col, toa-hang, single-gap)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (CTD-CAP-001..004)
// ---------------------------------------------------------------------------

/// The party column (ruled right and bottom) at left; the case number, the date (L. Civ. R. 10) and the title at right.
#let caption(meta) = {
  let rows = ()
  for (i, side) in need(meta, "caption").enumerate() {
    if i > 0 { rows += ("", "v.", "") }   // "v." between the parties, a blank single line either side
    rows += side.names
    rows.push(pad(left: designation-indent, unloose(inl(side.designation))))
  }
  let right = ("Case No. " + need(meta, "case_number"), "", "Date: " + need(meta, "date"), "",
    strong(upper(unloose(inl(need(meta, "brief_title"))))))
  block(width: 100%, above: blank, below: 0pt, breakable: false, grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt),
      inset: (right: caption-rule-pad, bottom: pitch-single), line-stack(rows)),
    pad(left: caption-pad, line-stack(right)),
  ))
}

/// CTD-CONT-102 (L. Civ. R. 7(a)(1), (2)): whether oral argument is requested, in the lower margin of the first page,
/// when the sample says (`oral_argument`); in the cover's footer.
#let oral-argument-legend(meta) = {
  if "oral_argument" in meta and meta.oral_argument != none {
    text(..edges(pitch-single), weight: "bold", upper("Oral argument " + meta.oral_argument))
  }
}

#let cover(meta) = {
  line-stack(need(meta, "court").map(l => align(center, strong(upper(l)))))
  caption(meta)
}

// ---------------------------------------------------------------------------
// Signature block and certification (CTD-ELEC-003..005: EFPP XI; L. Civ. R. 10; CTD-CERT-101: L. Civ. R. 5(c))
// ---------------------------------------------------------------------------

/// "Dated:" at the margin and "Respectfully submitted," in the signature column on one line; for each signer a blank
/// body line, "BY: /s/" and the signer, the name with the federal bar number, and the signer's lines. One block.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let signers = (sig,) + sig.at("others", default: ())
  block(width: 100%, above: blank, below: 0pt, breakable: false, {
    grid(columns: (sig-left, 1fr), line-stack(("Dated: " + need(meta, "date"),)), line-stack(("Respectfully submitted,",)))
    for s in signers {
      let name-line = if "bar" in s { s.signer + ", Fed. Bar No. " + s.bar } else { s.signer }
      block(width: 100%, above: blank, below: 0pt,
        pad(left: sig-left, line-stack(("BY: /s/ " + s.signer, name-line) + s.at("lines", default: ()))))
    }
  })
}

/// The certification of service: its title, its text on the body pitch, then "/s/" and the signer's lines in the
/// signature column; one block.
#let certification-block(meta) = {
  let c = meta.at("certification", default: none)
  if c != none {
    block(width: 100%, above: blank, below: 0pt, breakable: false, {
      title-line[Certification of Service]
      block(width: 100%, above: single-gap, below: 0pt, par(unloose(inl(c.text))))
      block(width: 100%, above: blank, below: 0pt,
        pad(left: sig-left, line-stack(("/s/ " + c.signer, c.signer) + c.at("lines", default: ()))))
    })
  }
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let running-footer = context {
  align(center, text(..edges(pitch-single), numbering(here().page-numbering(), ..counter(page).get())))
}

#let ctd-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court", "caption", "brief_title", "date", "signature") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margin, footer-descent: footer-descent)
  set document(
    title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number; list labels in a box.
  show: xengine.with(pitch: pitch-body, list-indent: list-label)
  // A doubled sign stays whole and with its number ("§§ 42-110a"): typst would break between the signs.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // The numbering function is what steps the heading counter; the labels are drawn by the show rule below.
  set heading(numbering: heading-num)
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: note-gap, clearance: note-clearance, indent: 0pt)
  show footnote.entry: it => {
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  // Lists: "1)" labels half an inch in (the label box is xengine's list-indent).
  set enum(numbering: "1)")
  show enum: it => pad(left: list-left, it)
  show list: it => pad(left: list-left, it)
  // Block quotations single-spaced and indented on both sides (L. Civ. R. 7(a)(5) exempts block quotes), a blank
  // single line above.
  show quote.where(block: true): it => block(width: 100%, above: single-gap, below: 0pt,
    pad(left: quote-indent, right: quote-indent, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      it.body
    }))

  // Authority links: a link whose target is `toa:KEY` is recorded on the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#metadata(it.dest.slice(4))<toa-hit>#it.body]
    } else {
      it
    }
  }

  // Headings single-spaced (L. Civ. R. 7(a)(5) exempts headings), a blank single line above, kept with the block
  // after them: level 1 centred bold capitals; deeper levels bold, the label in a box half an inch wide (each level
  // half an inch further in), the title hanging after it.
  show heading: it => {
    set text(size: type-size, ..edges(pitch-single))
    let body = if it.level == 1 { align(center, par(first-line-indent: 0pt, strong(upper(it.body)))) } else {
      let lab = context numbering(it.numbering, ..counter(heading).at(it.location()).slice(0, it.level))
      pad(left: label-indent(it.level), par(first-line-indent: 0pt, hanging-indent: heading-tab,
        strong[#box(width: heading-tab, lab)#it.body]))
    }
    block(width: 100%, above: single-gap, below: 0pt, sticky: true, body)
  }

  // ---- cover (no page number; the oral-argument legend, if any, in its lower margin) ----
  page(numbering: none, footer: oral-argument-legend(meta), cover(meta))

  // ---- contents and authorities, numbered i, ii, ... (excluded from the page limit, L. Civ. R. 7(a)(5)) ----
  set page(numbering: "i", footer: running-footer)
  counter(page).update(1)
  toc-section()
  pagebreak()
  toa-section(authorities)

  // ---- body, numbered from 1 ----
  set page(numbering: "1", footer: running-footer)
  counter(page).update(1)
  // The last section (from the last level 1 heading, the conclusion) is kept with the signature block, so a sign-off
  // never stands alone. Footnote definitions (chunks starting "[^") go to both halves: cmarker resolves a note only
  // inside the markdown it renders.
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n"))
  let defs = chunks.filter(c => c.trim().starts-with("[^")).join("\n\n", default: "")
  let text-md = chunks.filter(c => not c.trim().starts-with("[^")).join("\n\n")
  let parts = ("\n" + text-md).split("\n# ")
  if parts.len() > 1 {
    cmarker.render(parts.slice(0, -1).join("\n# ") + "\n\n" + defs, raw-typst: false, smart-punctuation: true)
    block(breakable: false, width: 100%, above: 0pt, below: 0pt, {
      cmarker.render("# " + parts.last() + "\n\n" + defs, raw-typst: false, smart-punctuation: true)
      signature-block(meta)
    })
  } else {
    cmarker.render(md, raw-typst: false, smart-punctuation: true)
    signature-block(meta)
  }
  certification-block(meta)
}
