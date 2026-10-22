// U.S. District Court, Middle District of North Carolina: brief in support of a motion (a memorandum of
// law), with a table of contents, a table of authorities, a certificate of word count and a certificate
// of service.
//
// Rule-driven and content-agnostic. Requirement IDs (NCMD-...) refer to ../README.md, which quotes the
// rule text (M.D.N.C. Local Civil Rules, effective June 1, 2026: LR 7.1, 7.2, 7.3). No case-specific text,
// no coordinates measured off the exemplar, no forced line breaks. The markdown body is rendered by cmarker;
// the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

// NCMD-FORM-002: a proportional font (LR 7.1(a) names no face): Times New Roman, the house face (vendored, docs/FONTS.md)
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 13pt                    // NCMD-FORM-002: proportional font "no smaller than 13 point" (LR 7.1(a)); footnotes included
#let top-margin = 1.25in                 // NCMD-FORM-004: top margin "not less than one and one-quarter inches" (LR 7.1(a))
#let bottom-margin = 1in                 // NCMD-FORM-004: bottom, left and right margins "not less than one inch" (LR 7.1(a))
#let side-margin = 1in
#let para-indent = 0.5in                 // first-line indent of every body paragraph
#let heading-tab = 0.5in                 // a heading's label box; each deeper level half an inch further in
#let caption-pad = 0.2in                 // the party column's text to its rule, and the rule to the case block
#let designation-indent = 1.8in          // "Plaintiffs," / "Defendants." under the names
#let text-width = 8.5in - 2 * side-margin
#let sig-col = 3.2in                     // the signature column at the right of the page
#let page-col = 0.5in                    // contents and authorities: the page column the rows wrap before
#let toa-hang = 0.35in                   // an authority's second line hangs this far in
#let passim-threshold = 7                // authority cited on this many pages or more: "passim"
#let word-limit = "6,250"                // LR 7.3(d)(1): briefs prepared on a computer, words (not counted by the template; see README.md)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/ncmd-motion-brief.lua sets the same twips).
#let pitch-body = 23pt                   // NCMD-FORM-003: 27 x 23 pt = 621 pt, inside the 630 pt text height (LR 7.1(a))
#let pitch-single = 15pt                 // single-spaced: court name, caption, table rows, signature blocks, footnotes, page number
#let blank = 23pt                        // one blank body line: court name to caption, a table's title to its rows,
                                         // the conclusion to the signature block, between the certificates
#let row-above = 15pt                    // contents and authorities: a blank single line above each row
#let caption-below = 15pt                // the party column's last line to its bottom rule (one single line)
#let note-gap = 4pt                      // between two footnotes (docx: Footnote Text 80 twips after)
#let note-clearance = 12pt               // the body text to the footnote rule
// NCMD-FORM-005 (LR 7.1(a): numbered at the bottom): the number in a single-spaced line box whose foot is 0.4 in above
// the bottom edge (docx: footer distance 576 twips): 72 - 28.8 - 15 = 28.2 pt below the text.
#let footer-descent = 28.2pt

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ncmd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ncmd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Single-spaced lines, one paragraph each; an empty item is a blank single line. `above`: space above the first.
#let line-stack(items, above: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let gap = above
  for i in items {
    if i == "" { gap += pitch-single } else {
      block(width: 100%, above: gap, below: 0pt, i)
      gap = 0pt
    }
  }
}

/// A centred bold title on the body pitch.
#let title-line(s, above: 0pt, below: 0pt) = block(width: 100%, above: above, below: below, sticky: true,
  align(center, par(first-line-indent: 0pt, strong(s))))

// ---------------------------------------------------------------------------
// Headings: numbering and styles
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 2 "I.", 3 "A.", 4 "1.", 5 "a.". Level 1 is unnumbered.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 2 { numbering("I.", k) }
  else if lv == 3 { numbering("A.", k) }
  else if lv == 4 { numbering("1.", k) }
  else if lv == 5 { numbering("a.", k) }
  else { "" }
}

/// Left edge of a heading's label: level 2 at the margin, each deeper level half an inch in.
#let label-indent(level) = calc.max(level - 2, 0) * heading-tab

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

/// A table's title (a page of its own), then the column label at the right.
#let table-head(title, col) = {
  title-line(upper(title), below: blank)
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
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
      let nums = counter(heading).at(hd.location()).slice(0, hd.level)
      let lab = heading-num(..nums)
      let ind = label-indent(hd.level)
      listing-row(hd.location(), [#h(ind)#box(width: heading-tab, lab)#hd.body], page-label(hd.location()),
        page-col, ind + heading-tab, row-above)
    }
  }
}

#let toa-groups = (
  ("case", "Cases"),
  ("statute", "Federal Statutes"),
  ("rule", "Federal Rules"),
  ("regulation", "Federal Regulations"),
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
        panic("ncmd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(width: 100%, above: row-above, below: 0pt, sticky: true, par(first-line-indent: 0pt, strong(title)))
      for (key, a) in members {
        // Distinct printed page labels, in document order (the page a citation starts on).
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let label = page-label(h.location())
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        let name = if "name" in a { [#if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }, ] }
        listing-row(none, [#name#inl(a.cite)], page-text, page-col, toa-hang, row-above)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (LR 7.1; no hearing: LR 7.3(c)(1))
// ---------------------------------------------------------------------------

/// The party column (closed by a right and a bottom rule) at left, the case number and the title at right; both
/// columns half the text width and starting on the same single line.
#let caption(meta) = {
  let left = ()
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    for n in side.names { left.push(inl(n)) }
    left.push(pad(left: designation-indent, inl(side.designation)))
    if i < sides.len() - 1 { left += ("", align(center)[v.], "") }
  }
  // Not upper-cased: the title's rule citations ("12(b)(1)") keep their case.
  let right = (inl(need(meta, "case_number")), "", strong(inl(need(meta, "brief_title"))))
  block(width: 100%, above: blank, below: 0pt, breakable: false, grid(
    columns: (50%, 50%),
    stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) } else { none },
    pad(right: caption-pad, bottom: caption-below, line-stack(left)),
    pad(left: caption-pad, line-stack(right)),
  ))
}

#let cover(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  for l in need(meta, "court") { block(width: 100%, above: 0pt, below: 0pt, align(center, strong(upper(l)))) }
  caption(meta)
}

// ---------------------------------------------------------------------------
// Signature blocks and certificates (LR 7.1(b), 7.3(d)(1))
// ---------------------------------------------------------------------------

/// LR 7.1(b): a signing attorney admitted to this Court states the state bar number. A signer without
/// one (for example, counsel appearing on a special basis) omits `bar_number`.
#let check-signer(sig) = {
  for k in ("signer", "address", "phone", "email", "role") {
    if k not in sig { panic("ncmd-motion-brief: signer block missing `" + k + "` (LR 7.1(b))") }
  }
}

/// The date at the margin; in the signature column "Respectfully submitted,", a blank line, then each signer's lines,
/// a blank single line between two signers.
#let signature-block(meta) = {
  let sigs = need(meta, "signatures")
  for s in sigs { check-signer(s) }
  let right = ([Respectfully submitted,], "")
  for (i, s) in sigs.enumerate() {
    if i > 0 { right.push("") }
    if "firm" in s { right.push(inl(s.firm)) }
    right += ([/s/ #s.signer], inl(s.signer))
    if "bar_number" in s { right.push(inl(s.bar_number)) }
    for l in s.address { right.push(inl(l)) }
    right += (inl(s.phone), inl(s.email), emph(inl(s.role)))
  }
  block(width: 100%, above: blank, below: 0pt, breakable: false, grid(
    columns: (text-width - sig-col, sig-col),
    line-stack(([Dated: #need(meta, "date")],)),
    line-stack(right),
  ))
}

/// A certificate: its title, its text on the body pitch, the signer's /s/ and name in the signature column; kept on
/// one page.
#let certificate(title, paras, sig) = block(width: 100%, above: blank, below: 0pt, breakable: false, {
  title-line(upper(title))
  for p in paras { block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), p)) }
  block(width: 100%, above: pitch-single, below: 0pt, pad(left: text-width - sig-col, line-stack(([/s/ #sig.signer], inl(sig.signer)))))
})

#let certificates(meta) = {
  let sig = need(meta, "signatures").first()
  certificate([Certificate of Word Count], (
    [I hereby certify that this brief complies with Local Rule 7.3(d)(1) in that it does not exceed #word-limit words in length, including the body of the brief, headings, and footnotes.],
    [This the #need(meta, "certificate_date").],
  ), sig)
  certificate([Certificate of Service], (
    [I certify that, on #need(meta, "service_date"), a copy of the foregoing document was filed with the Clerk of the Court using the CM/ECF System, which will send notification of the filing to the parties and counsel of record who are registered with that system.],
  ), sig)
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let running-footer = context {
  align(center, text(..edges(pitch-single), numbering(here().page-numbering(), ..counter(page).get())))
}

#let ncmd-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court", "caption", "brief_title", "date", "certificate_date", "service_date", "signatures") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: (top: top-margin, bottom: bottom-margin, x: side-margin),
    footer-descent: footer-descent)   // LR 7.1(a): letter size, single-sided
  set document(
    title: need(meta, "brief_title") + ", Civil Action No. " + need(meta, "case_number"),
    author: need(meta, "signatures").first().signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body)
  // The numbering function is what steps the heading counter; the labels are drawn by the show rule below.
  set heading(numbering: heading-num)
  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt), gap: note-gap, clearance: note-clearance, indent: 0pt)
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // Authority links: a link whose target is `toa:KEY` is recorded on the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#metadata(it.dest.slice(4))<toa-hit>#it.body]
    } else {
      it
    }
  }

  // Headings on the body pitch, kept with the block after them: level 1 centred bold capitals; deeper levels bold,
  // the label in a box half an inch wide (each level half an inch further in), the title hanging after it.
  show heading: it => {
    set text(size: type-size)   // the type size, not typst's larger heading sizes
    let body = if it.level == 1 { align(center, par(first-line-indent: 0pt, strong(upper(it.body)))) } else {
      let ind = label-indent(it.level)
      let lab = context numbering(it.numbering, ..counter(heading).at(it.location()).slice(0, it.level))
      pad(left: ind, par(first-line-indent: 0pt, hanging-indent: heading-tab,
        strong[#box(width: heading-tab, lab)#it.body]))
    }
    block(width: 100%, above: 0pt, below: 0pt, sticky: true, body)
  }

  // ---- cover (no page number) ----
  page(numbering: none, footer: none, cover(meta))

  // ---- contents and authorities, numbered i, ii, ... ----
  set page(numbering: "i", footer: running-footer)
  counter(page).update(1)
  toc-section()
  pagebreak()
  toa-section(authorities)

  // ---- body, numbered from 1 ----
  set page(numbering: "1", footer: running-footer)
  counter(page).update(1)
  // The last section (the conclusion) is kept with the signature block, so a sign-off never stands alone.
  let parts = md.split("\n## ")
  if parts.len() > 1 {
    cmarker.render(parts.slice(0, -1).join("\n## "), raw-typst: false, smart-punctuation: true)
    block(breakable: false, width: 100%, above: 0pt, below: 0pt, {
      cmarker.render("## " + parts.last(), raw-typst: false, smart-punctuation: true)
      signature-block(meta)
    })
  } else {
    cmarker.render(md, raw-typst: false, smart-punctuation: true)
    signature-block(meta)
  }
  certificates(meta)
}
