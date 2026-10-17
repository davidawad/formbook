// U.S. District Court, Middle District of North Carolina: brief in support of a motion (a memorandum of
// law), with a table of contents, a table of authorities, a certificate of word count and a certificate
// of service.
//
// Rule-driven and content-agnostic. Requirement IDs (NCMD-...) refer to ../README.md, which quotes the
// rule text (M.D.N.C. Local Civil Rules, effective June 1, 2026: LR 7.1, 7.2, 7.3). No case-specific text,
// no coordinates measured off the exemplar, no forced line breaks. The markdown body is rendered by cmarker;
// the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // NCMD-FORM-002: proportional font; the rule names no face, so the default applies: Times New Roman substitute (docs/FONTS.md "No face named")
#let type-size = 13pt                    // NCMD-FORM-002: proportional font "no smaller than 13 point" (LR 7.1(a)); footnotes included
#let pitch = 23pt                        // NCMD-FORM-003: one double-spaced line; 27 x 23 pt = 621 pt, inside the 630 pt text height (see README.md)
#let body-leading = pitch - 1.15em      // the text runs in a 1.15em line box (top-edge 0.9em, bottom-edge -0.25em) (14.95 pt at 13 pt); the gap makes the 23 pt pitch
#let single-leading = 0.3em              // caption, counsel and signature blocks, table of contents and authorities, footnotes
#let top-margin = 1.25in                 // NCMD-FORM-004: top margin "not less than one and one-quarter inches" (LR 7.1(a))
#let bottom-margin = 1in                 // NCMD-FORM-004: bottom, left and right margins "not less than one inch" (LR 7.1(a))
#let side-margin = 1in
#let page-number-gap = 0.4in             // NCMD-FORM-005: page numbered at the bottom (LR 7.1(a))
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let passim-threshold = 7                // authority cited on this many pages or more: "passim"
#let word-limit = "6,250"                // LR 7.3(d)(1): briefs prepared on a computer, words (not counted by the template; see README.md)

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

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

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
#let label-indent(level) = (level - 2) * heading-tab

// ---------------------------------------------------------------------------
// Tables of contents and authorities
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
        panic("ncmd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
// Cover: court title, caption, title of the paper (LR 7.1; no hearing: LR 7.3(c)(1))
// ---------------------------------------------------------------------------

#let caption-table(meta) = {
  let sides = need(meta, "caption")
  table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.75pt, bottom: 0.75pt) } else { none },
    pad(right: 1.2em, bottom: 1em, {
      set par(first-line-indent: 0pt, leading: single-leading, justify: false)
      for (i, side) in sides.enumerate() {
        for n in side.names { inl(n); parbreak() }
        pad(left: 1.8in, inl(side.designation))
        if i < sides.len() - 1 { v(pitch * 0.5); align(center)[v.]; v(pitch * 0.5) }
      }
    }),
    pad(left: 1.2em, top: 0.3em, {
      set par(first-line-indent: 0pt, leading: single-leading, justify: false)
      need(meta, "case_number")
      v(pitch * 0.5)
      // Not upper-cased here: the title's rule citations ("12(b)(1)") must keep their case.
      strong(inl(need(meta, "brief_title")))
    }),
  )
}

#let cover(meta) = page(numbering: none, footer: none, margin: (top: top-margin, bottom: bottom-margin, x: side-margin), {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(
    need(meta, "court").map(l => [#l]).join(linebreak())
  )))
  v(pitch)
  caption-table(meta)
})

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

#let signature-block(meta) = {
  let sigs = need(meta, "signatures")
  for s in sigs { check-signer(s) }
  block(breakable: false, above: pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [Dated: #need(meta, "date")], {
      [Respectfully submitted,]
      v(pitch)
      for s in sigs {
        if "firm" in s { [#s.firm]; linebreak() }
        [/s/ #s.signer]
        linebreak()
        inl(s.signer)
        linebreak()
        if "bar_number" in s { inl(s.bar_number); linebreak() }
        for l in s.address { inl(l); linebreak() }
        inl(s.phone)
        linebreak()
        inl(s.email)
        linebreak()
        emph(inl(s.role))
        v(pitch * 0.5)
      }
    })
  })
}

#let certificates(meta) = {
  let sigs = need(meta, "signatures")
  let sig = sigs.first()
  block(breakable: false, above: pitch, width: 100%, {
    set par(first-line-indent: 0pt, leading: body-leading, justify: false)
    align(center, strong(upper[Certificate of Word Count]))
    v(pitch * 0.5)
    par(first-line-indent: para-indent, [I hereby certify that this brief complies with Local Rule 7.3(d)(1) in that it does not exceed #word-limit words in length, including the body of the brief, headings, and footnotes.])
    par(first-line-indent: para-indent, [This the #need(meta, "certificate_date").])
    v(pitch * 0.5)
    grid(columns: (1fr, 3.2in), [], {
      set par(leading: single-leading)
      [/s/ #sig.signer]
      linebreak()
      inl(sig.signer)
    })
  })
  block(breakable: false, above: pitch, width: 100%, {
    set par(first-line-indent: 0pt, leading: body-leading, justify: false)
    align(center, strong(upper[Certificate of Service]))
    v(pitch * 0.5)
    par(first-line-indent: para-indent, [I certify that, on #need(meta, "service_date"), a copy of the foregoing document was filed with the Clerk of the Court using the CM/ECF System, which will send notification of the filing to the parties and counsel of record who are registered with that system.])
    v(pitch * 0.5)
    grid(columns: (1fr, 3.2in), [], {
      set par(leading: single-leading)
      [/s/ #sig.signer]
      linebreak()
      inl(sig.signer)
    })
  })
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let running-footer = context {
  let loc = here()
  align(center, text(size: type-size, numbering(loc.page-numbering(), ..counter(page).get())))
}

#let ncmd-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court", "caption", "brief_title", "date", "certificate_date", "service_date", "signatures") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(paper: "us-letter")   // LR 7.1(a): letter size, single-sided
  set document(
    title: need(meta, "brief_title") + ", Civil Action No. " + need(meta, "case_number"),
    author: need(meta, "signatures").first().signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    // A 1.15em line box (a word-processor single line); Liberation Serif's ascender-descender box is only 0.909em,
    // so single-spaced lines with no gap would touch.
    top-edge: 0.9em, bottom-edge: -0.25em,
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
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

  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    if it.level == 1 {
      block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
        align(center, strong(upper(it.body))))
    } else {
      let ind = label-indent(it.level)
      block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
        hang(ind + heading-tab, {
          h(ind)
          box(width: heading-tab, lab)
          strong(it.body)
        }))
    }
  }

  cover(meta)
  page(numbering: "i", footer: running-footer, margin: (top: top-margin, bottom: bottom-margin, x: side-margin), {
    counter(page).update(1)
    toc-section()
    pagebreak()
    toa-section(authorities)
  })
  page(numbering: "1", footer: running-footer, margin: (top: top-margin, bottom: bottom-margin, x: side-margin), {
    counter(page).update(1)
    // The last section (the conclusion) is kept with the signature block, so a sign-off never stands alone.
    let parts = md.split("\n## ")
    if parts.len() > 1 {
      cmarker.render(parts.slice(0, -1).join("\n## "), raw-typst: false, smart-punctuation: true)
      block(breakable: false, width: 100%, {
        cmarker.render("## " + parts.last(), raw-typst: false, smart-punctuation: true)
        signature-block(meta)
      })
    } else {
      cmarker.render(md, raw-typst: false, smart-punctuation: true)
      signature-block(meta)
    }
    certificates(meta)
  })
}
