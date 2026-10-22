// U.S. District Court, Eastern District of New York: memorandum of law in support of a motion
// (Fed. R. Civ. P. 12(b) motion with memorandum, Local Civil Rule 7.1(a)(2), (b), (c)).
//
// Rule-driven and content-agnostic. Requirement IDs (NYED-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter
// of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // No EDNY rule names a face (NYED-FORM-002); Times New Roman, the house standard. Vendored in /fonts.
#let type-size = 12pt                    // NYED-FORM-002: LCR 7.1(b)(1), 12-point type or larger.
#let footnote-size = 10pt                // NYED-FORM-002: LCR 7.1(b)(1), 10-point type allowed in footnotes.
#let margins = (top: 1in, bottom: 1in, x: 1in)  // NYED-FORM-004: LCR 7.1(b)(2), at least one inch on all sides.
#let text-width = 8.5in - 2in
#let para-indent = 0.5in                 // First-line indent of body paragraphs (convention).
#let heading-tab = 0.5in                 // Width of a heading label (I., A., 1., a.) and the hang that follows it.
#let caption-left = 3.4in                // The party column of the caption.
#let caption-pad = 9pt                   // The party column's text this far inside its rules (top and bottom).
#let caption-gap = 0.2in                 // The case column this far right of the party column.
#let against-indent = 1.2in              // "-against-" between the parties.
#let designation-indent = 1.9in          // "Plaintiffs," / "Defendants." under the names.
#let signature-w = 3.2in                 // The signature column at the right.
#let rule = 0.75pt                       // The caption's rules.
#let toc-col = 0.5in                     // Contents: the page column the rows wrap before.
#let toa-col = 0.75in                    // Authorities: the page column (room for a list of pages).
#let toa-hang = 0.35in                   // An authority's second line hangs this far in.
#let passim-threshold = 7                // Authority cited on this many pages or more: "passim" (convention).

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                 // NYED-FORM-003: LCR 7.1(b)(3), double-spaced body text.
#let pitch-single = 13.8pt               // Single spacing, 1.15 x the size: court, caption, cover, headings (LCR
                                         // 7.1(b)(3) excepts headings), contents and authorities, signature.
#let pitch-note = 11.5pt                 // Footnotes (LCR 7.1(b)(3) excepts them): single lines at 10 pt.
#let row-above = 12pt                    // Contents and authorities: the space above each row.
#let note-gap = 4pt                      // Between two footnotes (docx: Footnote Text 80 twips after).
#let note-clearance = 12pt               // The body text to the footnote rule.

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Inline markdown (italics, links, footnote marks) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("nyed-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nyed-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it. An empty line
/// keeps its height.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if type(body) == str { inl(body) } else { body }
})

/// A centred bold title in capitals, single-spaced, kept with what follows.
#let title-line(body, above: 0pt, below: 0pt) = block(width: 100%, above: above, below: below, sticky: true, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  align(center, strong(upper(body)))
})

// ---------------------------------------------------------------------------
// Cover: court name, caption (Fed. R. Civ. P. 10(a)), title, counsel
// ---------------------------------------------------------------------------

/// The caption, a double line below the court's name: the party column between a rule above and below, the case
/// column (case number, legend) at its right, its first line level with the party column's (Word gives a row's
/// cells one top margin). Never split.
#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let left = {
    for (i, side) in sides.enumerate() {
      if i > 0 {
        line-block("")
        line-block(pad(left: against-indent, [-against-]))
        line-block("")
      }
      for n in side.names { line-block(n) }
      line-block(pad(left: designation-indent, inl(side.designation)))
    }
  }
  let right = {
    line-block[Case No. #need(meta, "case_number")]
    if "legend" in meta { line-block(above: pitch-single, strong(upper(inl(meta.legend)))) }
  }
  block(width: 100%, above: pitch-double, below: 0pt, breakable: false, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, inset: (top: caption-pad, bottom: caption-pad), stroke: (top: rule, bottom: rule), left),
    pad(left: caption-gap, top: caption-pad, right),
  ))
}

/// The cover (no page number): the court's name, the caption, two double lines below it the title; counsel at the
/// foot of the page (docx: a frame at the bottom margin).
#let cover(meta) = page(numbering: none, footer: none, {
  for l in need(meta, "court") { line-block(align(center, strong(upper(inl(l))))) }
  caption-table(meta)
  title-line(above: 2 * pitch-double, inl(need(meta, "brief_title")))
  if "counsel" in meta {
    place(bottom, block(width: 100%, for l in meta.counsel { line-block(l) }))
  }
})

// ---------------------------------------------------------------------------
// Headings: level 1 centered bold capitals; levels 2 to 4 bold with a label box (I., A., 1., a.)
// ---------------------------------------------------------------------------

/// Numbered-label parse: "## I.  TITLE" gives (2, "I.", "TITLE"); a heading with no two-space gap has no label.
#let parse-heading(t) = {
  let m = t.match(regex("^(#+)\\s+(\\S+\\.)\\s{2,}(.+)$"))
  if m != none { (m.captures.at(0).len(), m.captures.at(1), m.captures.at(2)) }
  else {
    let p = t.match(regex("^(#+)\\s+(.+)$"))
    if p == none { panic("nyed-motion-brief: malformed heading: " + t) }
    (p.captures.at(0).len(), "", p.captures.at(1))
  }
}

/// Left edge of a heading's label: level 2 at the margin, each deeper level half an inch in.
#let label-indent(level) = calc.max(level - 2, 0) * heading-tab

/// A heading, single-spaced (LCR 7.1(b)(3)), a single line above and below, sticky; it records itself for the table
/// of contents (<toc-entry>).
#let heading-block(level, label, text) = block(width: 100%, above: pitch-single, below: pitch-single, sticky: true, {
  set std.text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  [#metadata((level: level, label: label, text: text))<toc-entry>]
  if level == 1 { align(center, strong(upper(inl(text)))) } else {
    pad(left: label-indent(level), par(hanging-indent: heading-tab,
      strong[#box(width: heading-tab, inl(label))#inl(text)]))
  }
})

// ---------------------------------------------------------------------------
// Tables of contents and authorities (LCR 7.1(c): excluded from the word count)
// ---------------------------------------------------------------------------

#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

/// A table's title, a double line below it the column label at the right.
#let table-head(title, col) = {
  title-line(title, below: pitch-double)
  line-block(align(right, strong(col)))
}

#let toc-section() = {
  table-head[Table of Contents][Page]
  context {
    set text(..edges(pitch-single))
    for e in query(<toc-entry>) {
      let hd = e.value
      if hd.level > 4 { continue }
      let body = if hd.level == 1 { upper(inl(hd.text)) } else {
        [#h(label-indent(hd.level))#box(width: heading-tab, inl(hd.label))#inl(hd.text)]
      }
      listing-row(e.location(), body, page-label(e.location()), toc-col, label-indent(hd.level) + heading-tab,
        row-above)
    }
  }
}

#let toa-groups = (
  ("case", "Cases"),
  ("statute", "Statutes"),
  ("rule", "Federal Rules of Civil Procedure"),
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
        panic("nyed-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(width: 100%, above: pitch-double, below: 0pt, sticky: true, par(first-line-indent: 0pt, strong(title)))
      for (key, a) in members {
        // Distinct printed page labels, in document order (the page a citation starts on).
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let label = page-label(h.location())
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        let name = if "name" in a { [#if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }, ] }
        listing-row(none, [#name#inl(a.cite)], page-text, toa-col, toa-hang, row-above)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Body: paragraphs with their footnotes
// ---------------------------------------------------------------------------

/// Inline content of a paragraph with its footnote references ("[^id]") turned into footnotes. Each piece is rendered
/// on its own, which trims its spaces: a space at either end of a piece is set again.
#let with-notes(t, defs) = {
  let piece(s) = {
    if s.starts-with(regex("\\s")) [ ]
    inl(s)
    if s.ends-with(regex("\\s")) [ ]
  }
  let out = []
  let pos = 0
  for m in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
    let id = m.captures.at(0)
    if id not in defs { panic("nyed-motion-brief: footnote [^" + id + "] has no definition") }
    out += piece(t.slice(pos, m.start))
    out += footnote(inl(defs.at(id)))
    pos = m.end
  }
  out + piece(t.slice(pos))
}

/// A body paragraph at the double pitch with the first-line indent; `keep`: kept whole on the page of the block after
/// it (the last paragraph stays with the signature block).
#let body-par(content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep, breakable: not keep,
  par(first-line-indent: (amount: para-indent, all: true), content))

// ---------------------------------------------------------------------------
// Word count (LCR 7.1(c)): counts the body markdown, footnotes included, and nothing else
// ---------------------------------------------------------------------------

/// Words of the markdown body: link targets, footnote marks and markdown symbols are removed; a token
/// counts if it has a letter or digit. The word-processor count is the one that governs the filed
/// certificate; this is the template's own count, stated so the attorney can compare.
#let count-words(md) = {
  let t = md.replace(regex("\\]\\(toa:[^)]*\\)"), "]")
  t = t.replace(regex("\\[\\^[^\\]]+\\]:?"), " ")
  t = t.replace(regex("[#*_>]"), " ")
  t.split(regex("\\s+")).filter(w => w.find(regex("[A-Za-z0-9]")) != none).len()
}

// ---------------------------------------------------------------------------
// Signature, certificates
// ---------------------------------------------------------------------------

/// A double line below the text: "Dated:" at the left, the signature column at the right; single-spaced, never
/// broken across a page.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
    columns: (1fr, signature-w),
    line-block[Dated: #inl(need(meta, "date"))],
    {
      line-block[Respectfully submitted,]
      line-block(above: pitch-double)[By: /s/ #inl(sig.signer)]
      line-block(sig.signer)
      for l in sig.at("lines", default: ()) { line-block(l) }
    },
  ))
}

/// The certificate of compliance (LCR 7.1(c)), a double line below the signature block: its title and its text on the
/// body pitch, kept on one page.
#let word-certificate(words) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  title-line[Certificate of Compliance]
  body-par[I certify that this memorandum of law complies with the word-count limit of Local Civil Rule 7.1(c). Excluding the caption, table of contents, table of authorities, signature block, and certificates, it contains #words words, as counted by the template. The count must be confirmed against the word-processing program used to prepare the filed document.]
})

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

// The page number centered at the foot, in a single line box, where Word's footer sets it.
#let running-footer = context align(center,
  text(..edges(pitch-single), numbering(here().page-numbering(), ..counter(page).get())))

#let nyed-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court", "caption", "brief_title", "signature", "date") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(paper: "us-letter", margin: margins, footer-descent: 30%)
  set document(
    title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (LCR 7.1(b)(3): double spaced), footnote marks at 58 %.
  show: xengine.with(pitch: pitch-double)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: footnote-size, ..edges(pitch-note))
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

  cover(meta)

  // ---- contents and authorities, numbered i, ii, ... ----
  set page(numbering: "i", footer: running-footer)
  counter(page).update(1)
  toc-section()
  pagebreak()
  toa-section(authorities)

  // ---- body, numbered from 1 ----
  pagebreak()
  set page(numbering: "1", footer: running-footer)
  counter(page).update(1)
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  // Footnote definitions ("[^id]: text") are collected first and placed at their references.
  let defs = (:)
  let body-chunks = ()
  for t in chunks {
    let d = t.match(regex("^\\[\\^([^\\]]+)\\]:\\s*([\\s\\S]*)$"))
    if d != none { defs.insert(d.captures.at(0), d.captures.at(1)) } else { body-chunks.push(t) }
  }
  for (i, t) in body-chunks.enumerate() {
    if t.starts-with("#") {
      let (lvl, lab, txt) = parse-heading(t)
      heading-block(lvl, lab, txt)
    } else {
      // the last paragraph stays with the signature block
      body-par(with-notes(t, defs), keep: i == body-chunks.len() - 1)
    }
  }
  signature-block(meta)
  // LCR 7.1(c): 8,750 words for a memorandum supporting a motion, unless the court permits more
  // (then `word_limit` in the frontmatter states the court's limit, converted at 350 words per page).
  let words = count-words(md)
  let limit = meta.at("word_limit", default: 8750)
  if words > limit {
    panic("nyed-motion-brief: " + str(words) + " words exceeds the LCR 7.1(c) limit of " + str(limit))
  }
  word-certificate(words)
  if "service" in meta {
    pagebreak()
    title-line[Certificate of Service]
    block(width: 100%, above: pitch-single, below: 0pt, body-par(inl(meta.service)))
    signature-block(meta)
  }
}
