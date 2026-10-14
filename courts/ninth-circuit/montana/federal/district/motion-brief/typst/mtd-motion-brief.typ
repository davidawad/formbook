// U.S. District Court, District of Montana: brief in support of a motion (memorandum).
//
// Rule-driven and content-agnostic. Rule IDs (MT-...) refer to ../README.md, which quotes the rule
// text: D. Mont. L.R. 1.5 (form of documents), 7.1(d) (briefs: length, table of contents and
// authorities, certificate of compliance). No case-specific text, no coordinates measured off the
// exemplar, no forced line breaks. The markdown body is rendered by cmarker; the metadata comes from
// the YAML frontmatter of the same file (schema: ../README.md).
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"        // MT-FORM-002: a proportionally spaced serif; the only face vendored in fonts/
#let type-size = 14pt                   // MT-FORM-002: typewritten in 14-point font (L.R. 1.5(a)(2))
#let line-pitch = 32pt                  // MT-FORM-003: double-spaced (L.R. 1.5(a)(2)); 2 x 16 pt at 14 pt type, see README.md
#let body-leading = 1.64em              // gap between lines of body text: EB Garamond's line box is 0.65 em, so 1.64 em gives a 32 pt baseline pitch at 14 pt (measured, README.md)
#let single-leading = 0.6em             // counsel block, caption, signature, footnotes, tables of contents and authorities: single-spaced
// The vertical gap between two blocks or paragraphs: the pitch minus EB Garamond's 0.65 em line box.
#let gap = line-pitch - 0.65em
#let margins = (top: 1in, bottom: 1in, left: 1in, right: 1in)   // MT-FORM-001 (L.R. 1.5(a)(1)): one-inch margins
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let heading-tab = 0.5in
#let footer-size = 14pt                 // page number at the foot of every page (MT-FORM-004, L.R. 1.5(a)(3))
#let caption-cols = (1.3fr, 1fr)        // style choice: the party column is wider, so the long list of plaintiffs wraps less and the cover fits on page 1
#let passim-threshold = 7               // an authority cited on this many pages or more prints "passim"
#let word-limit = 6500                  // MT-LEN-001 (L.R. 7.1(d)(2)(A)): briefs in support of a motion
#let toc-threshold = 4000               // MT-LEN-002 (L.R. 7.1(d)(2)(C)): a brief of this many words or more needs a TOC and TOA; the template always prints both

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mtd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, italic role lines, etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("mtd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// Thousands separators for a printed word count: 6496 -> "6,496".
#let commas(n) = {
  let out = ""
  let k = 0
  for ch in str(n).clusters().rev() {
    if k > 0 and calc.rem(k, 3) == 0 { out = "," + out }
    out = ch + out
    k += 1
  }
  out
}

/// Words in the brief, for the certificate of compliance: whitespace-separated tokens of the markdown
/// body that contain a letter or a digit. Footnote labels and the `(toa:KEY)` targets are not words.
/// An approximation of a word processor's count; a `word_count` in the frontmatter overrides it.
#let count-words(md) = {
  let plain = md.replace(regex("\\[\\^[^\\]]*\\]"), " ").replace(regex("\\(toa:[^)]*\\)"), " ")
  plain.split(regex("\\s+")).filter(w => w.find(regex("[A-Za-z0-9]")) != none).len()
}

// ---------------------------------------------------------------------------
// Headings: numbering and styles (the numbers are the template's, not the author's)
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
#let label-indent(level) = (level - 2) * heading-tab

// ---------------------------------------------------------------------------
// Tables of contents and authorities (L.R. 7.1(d)(2)(C); MT-CONT-001)
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
  ("constitution", "Constitutional Provisions"),
  ("statute", "Statutes"),
  ("rule", "Rules"),
  ("regulation", "Regulations"),
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
        panic("mtd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
          set par(leading: single-leading)
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
// Cover: counsel (upper left), court title, caption, title of the paper (Appendix C, Form A)
// ---------------------------------------------------------------------------

/// One counsel group: its lines, single-spaced.
#let counsel-group(lines) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  for l in lines { inl(l); linebreak() }
}

/// Counsel groups, in two columns (as the exemplar sets them) when there are two or more groups.
#let counsel-block(meta) = {
  let groups = need(meta, "counsel")
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0.3in,
    stack(dir: ttb, spacing: line-pitch * 0.5, ..groups.slice(0, 1).map(counsel-group)),
    stack(dir: ttb, spacing: line-pitch * 0.5, ..groups.slice(1).map(counsel-group)),
  )
  v(line-pitch * 0.5)
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  emph(inl(need(meta, "counsel_role")))
}

#let court-title(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  // One centred line each: the court, the district, the division (Appendix C, Form A).
  align(center, strong(stack(dir: ttb, spacing: single-leading,
    [IN THE UNITED STATES DISTRICT COURT],
    [FOR THE DISTRICT OF MONTANA],
    upper(need(meta, "division")),
  )))
}

#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for (i, side) in sides.enumerate() {
      for n in side.names { inl(n); linebreak() }
      v(line-pitch * 0.5)
      pad(left: 1.4in, inl(side.designation))
      if i < sides.len() - 1 {
        v(line-pitch * 0.5)
        [v.]
        v(line-pitch * 0.5)
      }
    }
  }
  let case-no = need(meta, "case_number")
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [Case No. #case-no]
    v(line-pitch * 1.5)
    strong(upper(inl(need(meta, "brief_title"))))
  }
  table(
    columns: caption-cols,
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1em, bottom: 1em, left),
    pad(left: 1.2em, top: 0.3em, right),
  )
}

#let cover(meta) = {
  counsel-block(meta)
  v(line-pitch * 0.5)
  court-title(meta)
  v(line-pitch * 0.5)
  caption-table(meta)
}

// ---------------------------------------------------------------------------
// Signature and certificates (L.R. 1.5(b), 7.1(d)(2)(E); FRCP 5(b))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.1in), [DATED: #need(meta, "date")], {
      for l in sig.at("preamble", default: ()) { inl(l); linebreak() }
      v(line-pitch)
      [/s/ #sig.signer]
      linebreak()
      inl(sig.signer)
      linebreak()
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

#let certificate-compliance(meta, words) = {
  heading(level: 1, numbering: none)[Certificate of Compliance]
  let sig = need(meta, "signature")
  block(breakable: false, {
    set par(first-line-indent: para-indent, leading: body-leading, justify: false)
    [Pursuant to Local Rule 7.1(d)(2)(E), I certify that this brief is printed with a proportionately spaced #font-family typeface of 14 points; is double-spaced except for footnotes and for quoted and indented material; and the word count is #commas(words) words, excluding caption, certificate of compliance, table of contents and authorities, exhibit index, and certificate of service.]
    grid(columns: (1fr, 3.1in), [], {
      set par(first-line-indent: 0pt, leading: single-leading, justify: false)
      v(line-pitch)
      [/s/ #sig.signer]
      linebreak()
      inl(sig.signer)
    })
  })
}

#let certificate-service(meta) = {
  heading(level: 1, numbering: none)[Certificate of Service]
  let sig = need(meta, "signature")
  block(breakable: false, {
    set par(first-line-indent: para-indent, leading: body-leading, justify: false)
    [I hereby certify that on this date, an accurate copy of the foregoing document was served electronically through the Court's CM/ECF system on registered counsel.]
    grid(columns: (1fr, 3.1in), [Dated: #need(meta, "date")], {
      set par(first-line-indent: 0pt, leading: single-leading, justify: false)
      [/s/ #sig.signer]
      linebreak()
      inl(sig.signer)
    })
  })
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let mtd-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "division", "counsel", "counsel_role", "caption", "brief_title", "signature", "date") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))
  let words = meta.at("word_count", default: count-words(md))
  // L.R. 7.1(d)(2)(A): a brief in support of a motion is limited to 6500 words.
  assert(words <= word-limit, message: "mtd-motion-brief: L.R. 7.1(d)(2)(A): " + str(words) + " words exceeds the " + str(word-limit) + "-word limit")

  // ---- document-wide settings ----
  set page(paper: "us-letter")
  set document(
    title: need(meta, "brief_title"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
  )
  set par(leading: body-leading, spacing: gap, first-line-indent: para-indent, justify: false)
  // The numbering function is what steps the heading counter; the labels are drawn by the show rule below.
  set heading(numbering: heading-num)
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

  // Headings: level 1 a centered section; level 2 and deeper a hanging numbered label. Kept with what follows.
  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    if it.level == 1 {
      block(width: 100%, above: gap, below: gap, sticky: true,
        align(center, strong(upper(it.body))))
    } else {
      let ind = label-indent(it.level)
      block(width: 100%, above: gap, below: gap, sticky: true,
        hang(ind + heading-tab, {
          h(ind)
          box(width: heading-tab, lab)
          strong(it.body)
        }))
    }
  }

  let footer-num = context align(center, text(size: footer-size, counter(page).display()))

  // Cover: page i (the counter starts at 1 and the front matter continues in roman numerals).
  page(numbering: "i", footer: footer-num, margin: margins, cover(meta))
  // Table of contents and table of authorities: pages ii and onward.
  page(numbering: "i", footer: footer-num, margin: margins, {
    toc-section()
    pagebreak()
    toa-section(authorities)
  })
  // The memorandum: arabic numbering from 1.
  page(numbering: "1", footer: footer-num, margin: margins, {
    counter(page).update(1)
    cmarker.render(md, raw-typst: false, smart-punctuation: true)
    signature-block(meta)
    pagebreak()
    certificate-compliance(meta, words)
    if meta.at("certificate_service", default: true) {
      v(line-pitch)
      certificate-service(meta)
    }
  })
}
