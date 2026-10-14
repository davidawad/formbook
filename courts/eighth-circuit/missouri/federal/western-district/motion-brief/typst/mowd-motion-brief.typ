// Suggestions in support of a motion to dismiss for the U.S. District Court for the Western District of Missouri (mowd).
// Rules: W.D. Mo. L.R. 7.0(a) (written motions are supported by suggestions), 7.0(d) (supporting suggestions may not
// exceed 15 pages, exhibits, signature blocks, certificates and statements of fact do not count; suggestions over 10
// pages need a table of contents and a table of authorities, which do not count), 7.0(e) (request for oral argument
// marked on the first page); Fed. R. Civ. P. 12(b); Fed. R. Civ. P. 5(b) (service). See ../README.md.
// The local rules set no typeface, margin or spacing rule for this court; the choices below are conventions.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/ (the only serif face vendored here)
#let type-size = 13pt                   // EB Garamond at 13 pt has about the x-height of Times New Roman at 12-14 pt (the Mannon exemplar)
#let body-leading = 1.35em              // double spacing: EB Garamond's line box is 0.65em, so 1.35em leading gives about 2 lines of pitch
#let single-leading = 0.5em             // caption, block quotations, tables of contents and authorities: single spaced
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let margin = 1in                       // all four margins
#let caption-left = 3.25in              // width of the party column of the caption
#let text-width = 8.5in - 2 * margin
#let passim-at = 7                      // an authority cited on this many pages or more prints "passim" (the ca9 template's rule)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mowd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in *italic*, bold, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Heading numbers: the template numbers the sections I., A., 1., a. A heading that already starts with its own
/// number keeps it (an excerpt of a filing keeps the filing's numbers). A heading whose text starts with
/// "Introduction" or "Certificate of Service" is unnumbered.
#let own-number = regex("^([IVXLC]+|[A-H]|[0-9]+|[a-h])\\.\\s+")
#let unnumbered-heading = regex("^(Introduction|Certificate of Service)\\b")

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  stack(dir: ttb, spacing: single-leading,
    align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")),
    align(center, text(weight: "bold", "FOR THE WESTERN DISTRICT OF MISSOURI")),
  )
  if "division" in meta and meta.division != none {
    v(single-leading)
    align(center, text(weight: "bold", upper(meta.division)))
  }
  v(body-leading * 1.5)
}

#let caption(meta) = {
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    {
      // Each party: its names, then its designation; the separator ("v." or "vs.") between the parties.
      let rows = ()
      let between = if "between" in meta.caption { meta.caption.between } else { "v." }
      for (k, p) in meta.caption.parties.enumerate() {
        if k > 0 { rows.push(between) }
        rows += p.names + (p.designation,)
      }
      line-stack(rows)
    },
    {
      set par(leading: single-leading, spacing: 0pt)
      [Case No. #meta.case_number]
    },
  )
  v(body-leading * 1.5)
  align(center, text(weight: "bold", inl(meta.title)))
  v(body-leading * 1.5)
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Headings, table of contents, table of authorities
// ---------------------------------------------------------------------------

/// Heading state: the counters for levels 1 to 4 (I., A., 1., a.), kept in one array and passed by value.
/// A heading renders as a block, kept with the paragraph after it, and carries a metadata label for the TOC.
#let heading-block(level, label, text-md, numbered) = {
  let body = inl(text-md)
  if numbered {
    block(width: text-width, above: body-leading, below: body-leading, sticky: true, {
      pad(left: (level - 1) * 0.5in, grid(
        columns: (0.5in, 1fr),
        text(weight: "bold", label),
        text(weight: "bold", body),
      ))
      [#metadata((level: level, label: label, text: text-md)) <toc-entry>]
    })
  } else {
    block(width: text-width, above: body-leading, below: body-leading, sticky: true, {
      align(center, text(weight: "bold", upper(text-md)))
      [#metadata((level: 1, label: "", text: text-md)) <toc-entry>]
    })
  }
}

/// One row of the table of contents: indent, label, title, dot leader, page number.
#let toc-row(level, label, text-md, pg) = {
  let body = inl(text-md)
  block(width: text-width, above: single-leading, below: 0pt, {
    pad(left: (level - 1) * 0.5in, grid(
      columns: (0.5in, 1fr, 0.4in),
      column-gutter: 0.1in,
      label, body, align(right, [#pg]),
    ))
  })
}

#let toc-page() = {
  align(center, text(weight: "bold", "TABLE OF CONTENTS"))
  v(body-leading)
  context {
    for e in query(<toc-entry>) {
      let pg = counter(page).at(e.location()).first()
      toc-row(e.value.level, e.value.label, e.value.text, pg)
    }
  }
}

#let kind-titles = (
  case: "Cases",
  constitution: "Constitutional Provisions",
  statute: "Statutes",
  regulation: "Regulations",
  rule: "Rules",
  other: "Other Authorities",
)

#let toa-page(registry) = {
  align(center, text(weight: "bold", "TABLE OF AUTHORITIES"))
  v(body-leading)
  context {
    let hits = query(<toa-hit>)
    for kind in kind-titles.keys() {
      let keys = registry.keys().filter(k => registry.at(k).kind == kind)
      if keys.len() == 0 { continue }
      // Cases are alphabetized by name; the other kinds keep the order they are sorted by in the registry.
      let keyed = keys.map(k => {
        let a = registry.at(k)
        (key: k, sort: if "sort" in a { a.sort } else if "name" in a { a.name } else { a.cite }, a: a)
      })
      keyed = keyed.sorted(key: x => lower(x.sort))
      text(weight: "bold", kind-titles.at(kind))
      v(single-leading)
      for x in keyed {
        let pages = hits.filter(h => h.value == x.key).map(h => counter(page).at(h.location()).first())
        pages = pages.dedup().sorted()
        let pg = if pages.len() >= passim-at { "passim" } else { pages.map(str).join(", ") }
        let md = if "name" in x.a { if kind == "case" { "*" + x.a.name + "*, " + x.a.cite } else { x.a.name + ", " + x.a.cite } } else { x.a.cite }
        block(width: text-width, above: single-leading, below: 0pt, {
          grid(
            columns: (1fr, 0.6in),
            column-gutter: 0.1in,
            inl(md), align(right, [#pg]),
          )
        })
      }
      v(body-leading)
    }
  }
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Signature block: one block at the right half of the page (W.D. Mo. signature under the body).
#let signature-block(meta) = block(width: text-width, breakable: false, {
  let sig = meta.signature
  grid(columns: (1fr, 3.4in), [], {
    set par(leading: single-leading, spacing: 0pt)
    [Respectfully submitted,]
    v(body-leading)
    text(weight: "bold", sig.signer)
    v(single-leading)
    line-stack(sig.lines)
  })
})

/// The certificate of service: the wording is the template's, the date and recipients come from the sample.
#let service-block(meta) = {
  let svc = meta.service
  block(width: text-width, above: 0pt, below: 0pt, {
    heading-block(1, "", "Certificate of Service", false)
    set par(leading: body-leading)
    h(para-indent)
    [I hereby certify that on #svc.date, I caused a copy of the foregoing document to be sent to all counsel of record via this Court’s CM/ECF system and via electronic mail to #svc.recipients.]
    v(body-leading)
    grid(columns: (1fr, 3.4in), [], {
      set par(leading: single-leading, spacing: 0pt)
      text(weight: "bold", svc.signer)
    })
  })
}

/// The body: headings (numbered by the template, see own-number), block quotations, lists, paragraphs.
/// Each chunk is a block, so chunks stack with one line of leading after them. A heading is kept with the chunk after it.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Counters for the template's numbering: level 1 I., level 2 A., level 3 1., level 4 a.
  let n = (0, 0, 0, 0)
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let m = t.match(regex("^(#+)\\s+(.*)$"))
      let level = m.captures.at(0).len()
      let text-md = m.captures.at(1).trim()
      let label = ""
      let numbered = text-md.match(unnumbered-heading) == none
      if text-md.match(own-number) != none {
        // Keeps the filing's own number; the template's counters are not advanced for it.
        label = text-md.match(own-number).text.trim()
        text-md = text-md.slice(text-md.match(own-number).end)
      } else if numbered {
        n.at(level - 1) += 1
        for j in range(level, 4) { n.at(j) = 0 }
        let k = n.at(level - 1)
        label = if level == 1 { numbering("I.", k) } else if level == 2 { numbering("A.", k) } else if level == 3 { numbering("1.", k) } else { numbering("a.", k) }
      }
      pending += heading-block(level, label, text-md, numbered)
      has-pending = true
    } else if t.starts-with(">") {
      // Block quotation: indented, single spaced (FRAP-style; the W.D. Mo. rules set no form for quotations).
      let piece = block(width: text-width, inset: (left: 0.5in, right: 0.5in), above: 0pt, below: 0pt, {
        set par(leading: single-leading, spacing: 0pt)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
      if has-pending { block(breakable: false, width: text-width, { pending; piece }) } else { piece }
      pending = []
      has-pending = false
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list; items are double spaced. Its numbers are the markdown's own.
      let items = block(width: text-width, above: 0pt, below: 0pt, {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
      if has-pending { block(breakable: false, width: text-width, { pending; items }) } else { items }
      pending = []
      has-pending = false
    } else {
      // Body paragraph: first line indented, double spaced. Its own block, so the lines keep their pitch.
      let piece = block(width: text-width, above: 0pt, below: 0pt, {
        set par(leading: body-leading)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
      if has-pending { block(breakable: false, width: text-width, { pending; piece }) } else { piece }
      pending = []
      has-pending = false
    }
  }
  if has-pending { block(breakable: false, width: text-width, pending) }
}

#let mowd-motion-brief(meta, body) = {
  let registry = if "authorities" in meta { meta.authorities } else { (:) }

  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Links to authorities: `[text](toa:key)` is recorded with its page for the table of authorities.
  // A key that is not in the registry stops the build.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      let key = it.dest.slice(4)
      if key not in registry { panic("mowd-motion-brief: authority key not in the registry: " + key) }
      [#it.body#metadata(key)<toa-hit>]
    } else {
      it
    }
  }

  // Front matter: the cover (no number), the contents and the authorities (roman), then the body (arabic from 1).
  set page(paper: "us-letter", margin: margin, numbering: none,
    footer: none)
  cover(meta)
  pagebreak()

  set page(numbering: "i", footer: context align(center, text(size: type-size, counter(page).display())))
  counter(page).update(1)
  toc-page()
  pagebreak()
  toa-page(registry)
  pagebreak()

  set page(numbering: "1", footer: context align(center, text(size: type-size, counter(page).display())))
  counter(page).update(1)
  body-chunks(body)

  v(body-leading)
  signature-block(meta)
  pagebreak()
  service-block(meta)
}
