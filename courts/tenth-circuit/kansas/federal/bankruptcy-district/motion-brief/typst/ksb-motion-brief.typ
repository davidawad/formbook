// U.S. Bankruptcy Court, District of Kansas: memorandum in support of a motion (FRBP 9013; LBR 9013.1,
// 9013.3, 7012.1). The memorandum is the brief; the motion it supports is a separate filing.
//
// Rule-driven and content-agnostic. Requirement IDs (KSB-...) refer to ../README.md, which quotes
// the rule text (Fed. R. Bankr. P. 7010, 9004, 9011, 9013; D. Kan. LBR 9004.1, 9013.1, 9013.3, 7012.1).
// No case-specific text, no coordinates measured off the exemplar, no forced line breaks. The
// markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the same
// file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")    // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 16pt                    // KSB-FORM-002: 12 pt or larger, and an average of no more than 12 characters per inch (LBR 9004.1(a)(1)). Measured in Liberation Serif on the sample text (typst 0.15.0, 2026-10-17): 12.8 cpi at 14 pt, 11.9 at 15 pt, 11.2 at 16 pt; 16 pt keeps a margin under 12.
#let line-pitch = 2 * type-size           // KSB-FORM-003: double-spaced where practicable (LBR 9004.1(a)(1)): two type sizes per line.
#let body-leading = line-pitch - 1.107 * type-size  // gap between body lines; 1.107 em is Liberation Serif's line box (hhea ascender 0.891em to descender 0.216em), so the pitch is line-pitch.
#let single-leading = 0.448em            // counsel block, caption, headings, tables and authorities.
#let page-margin = 1in                   // style choice: 1 inch on all sides (no margin figure in the rules).
#let para-indent = 0.5in                 // first-line indent of body paragraphs.
#let heading-tab = 0.5in                 // hanging label width for numbered sub-headings.
#let sig-left = 3.2in                    // signature block: the right half of the page.
#let caption-left = 3.6in                // caption: width of the party column.
#let passim-threshold = 7                // authority cited on this many pages or more: "passim".

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ksb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ksb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

// ---------------------------------------------------------------------------
// Headings: numbering and styles (LBR 9013.1(a))
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
#let label-indent(level) = (level - 2) * heading-tab

// ---------------------------------------------------------------------------
// Tables of contents and authorities (LBR 9004.1(a)(2); exemplar convention)
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.25em)])

/// One table-of-contents row from a heading element; wrapped lines hang under the title.
#let toc-entry(hd) = {
  let nums = counter(heading).at(hd.location()).slice(0, hd.level)
  let lab = heading-num(..nums)
  let ind = if hd.level == 1 { 0pt } else { label-indent(hd.level) }
  let pg = numbering(hd.location().page-numbering(), ..counter(page).at(hd.location()))
  // The page number sits in its own column so a wrapped title can never push it onto a new line.
  link(hd.location(), block(width: 100%, above: 0.45em, below: 0pt, grid(
    columns: (1fr, auto), column-gutter: 0.4em,
    hang(ind + heading-tab, {
      h(ind)
      if lab != "" { box(width: heading-tab, lab) }
      if hd.level == 1 { upper(hd.body) } else { hd.body }
      h(0.2em)
      dot-leader
    }),
    align(right + bottom, box(width: 2em, align(right, pg))),
  )))
}

#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, block(above: 0.3em, below: 0pt, strong[Page]))
  context {
    for hd in query(heading.where(outlined: true)) {
      if hd.level <= 4 { toc-entry(hd) }
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
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  align(right, block(above: 0.3em, below: 0pt, strong[Page(s)]))
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("ksb-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 1em } else { 1.4em }, below: 0.2em, sticky: true, {
        set par(first-line-indent: 0pt, leading: single-leading)
        strong(title)
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
        block(breakable: false, above: 0.6em, below: 0pt, width: 100%, hang(0.35in, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [, ]
          }
          inl(a.cite)
          h(0.8em)
          dot-leader
          h(0.3em)
          page-text
        }))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover and caption (FRBP 7010 by analogy; FRBP 9004(b): court, title, case number, designation)
// ---------------------------------------------------------------------------

/// Counsel block, upper left, single-spaced, with the party represented under it.
#let counsel-block(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  for l in need(meta, "counsel") { inl(l); linebreak() }
  v(line-pitch * 0.5)
  emph(inl(need(meta, "counsel_role")))
}

#let caption-block(meta) = {
  let debtor = need(meta, "debtor")
  let sides = need(meta, "caption")
  let adv = meta.at("adversary_number", default: "Adv. No. " + "_" * 10)
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    text(weight: "regular", "In re:")
    linebreak()
    v(line-pitch * 0.25)
    for n in debtor.names { inl(n); linebreak() }
    pad(left: 2in, inl(debtor.designation))
    v(line-pitch * 0.25)
    for (i, side) in sides.enumerate() {
      for n in side.names { inl(n); linebreak() }
      pad(left: 2in, inl(side.designation))
      if i < sides.len() - 1 { v(line-pitch * 0.25); align(center)[v.]; v(line-pitch * 0.25) }
    }
    v(line-pitch * 0.25)
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    v(line-pitch * 1.5)
    inl(need(meta, "bankruptcy_case"))
    linebreak()
    inl(need(meta, "chapter"))
    v(line-pitch * 2.5)
    adv
  }
  table(
    columns: (caption-left, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt) } else { none },
    pad(right: 1.2em, bottom: 0.5em, left),
    pad(left: 1.2em, right),
  )
}

#let cover(meta) = {
  counsel-block(meta)
  v(line-pitch * 0.5)
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(
    need(meta, "court").map(l => [#l]).join(linebreak())
  )))
  v(line-pitch * 0.5)
  caption-block(meta)
  v(line-pitch * 0.5)
  align(center, strong(upper(inl(need(meta, "title")))))
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service (LBR 9013.3(a); FRBP 9011(a))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, sig-left), [Dated: #need(meta, "date")], {
      for l in sig.at("preamble", default: ()) { inl(l); linebreak() }
      v(line-pitch * 0.5)
      [/s/ #sig.signer]
      linebreak()
      inl(sig.signer)
      if "bar" in sig { [, ] ; inl(sig.bar) }
      linebreak()
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
      v(line-pitch * 0.5)
      emph(inl(sig.at("role", default: "")))
    })
  })
}

/// Certificate of service. The wording is the local rule's example (LBR 9013.3(a)(1)) for service
/// through the CM/ECF system; the metadata names the document and the signer.
#let certificate-of-service(meta) = {
  let svc = need(meta, "service")
  let sig = need(meta, "signature")
  pagebreak()
  heading(level: 1, numbering: none, outlined: false)[Certificate of Service]
  set par(first-line-indent: para-indent, leading: body-leading)
  [I hereby certify that on #need(meta, "date"), I electronically filed the foregoing #upper(inl(svc.document)) with the Clerk of the Court using the CM/ECF system, which will send notice of electronic filing to all counsel of record.]
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, sig-left), [], {
      [/s/ #sig.signer]
      linebreak()
      inl(svc.signer)
      linebreak()
      emph(inl(sig.at("role", default: "")))
    })
  })
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let ksb-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "debtor", "bankruptcy_case", "chapter", "caption", "title", "counsel", "counsel_role", "date", "signature") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // LBR 9013.1(a)(1)-(4): the memorandum must state the nature of the matter, the facts, the question
  // presented and the argument. A missing section is a build failure, not a silent omission.
  for frag in ("NATURE", "FACT", "QUESTION", "ARGUMENT") {
    if md.find(regex("(?m)^# [^\n]*" + frag)) == none { panic("ksb-motion-brief: no `# ...` section heading containing `" + frag + "` (LBR 9013.1(a))") }
  }

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",                  // LBR 9004.1(a)(1): 8-1/2 x 11 inch paper.
    margin: page-margin,
    numbering: "1",                      // LBR 9004.1(a)(2): numbered from the first page, the cover included.
    number-align: center,
  )
  set document(
    title: need(meta, "title"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: 0.891em, bottom-edge: -0.216em,  // Liberation Serif's hhea ascender and descender: a 1.107em line box
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: heading-num)
  set table(stroke: none, inset: (x: 6pt, y: 3pt))
  show table: set par(leading: single-leading, first-line-indent: 0pt)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Authority links: a link whose target is `toa:KEY` is recorded with the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      let key = it.dest.slice(4)
      [#it.body#metadata(key)<toa-hit>]
    } else {
      it
    }
  }

  // Headings: level 1 is a centered section in capitals; deeper levels hang their label.
  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    if it.level == 1 {
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        text(size: type-size, align(center, strong(upper(it.body)))))
    } else {
      let ind = label-indent(it.level)
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        text(size: type-size, hang(ind + heading-tab, {
          h(ind)
          box(width: heading-tab, lab)
          strong(it.body)
        })))
    }
  }

  // The cover is page 1; the footer is a page number only.
  cover(meta)
  pagebreak()
  toc-section()
  pagebreak()
  toa-section(authorities)
  pagebreak()
  cmarker.render(md, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
  certificate-of-service(meta)
}
