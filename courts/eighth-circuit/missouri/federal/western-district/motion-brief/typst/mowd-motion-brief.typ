// Suggestions in support of a motion to dismiss for the U.S. District Court for the Western District of Missouri (mowd).
// Rules: W.D. Mo. L.R. 7.0(a) (written motions are supported by suggestions), 7.0(d) (supporting suggestions may not
// exceed 15 pages, exhibits, signature blocks, certificates and statements of fact do not count; suggestions over 10
// pages need a table of contents and a table of authorities, which do not count), 7.0(e) (request for oral argument
// marked on the first page); Fed. R. Civ. P. 12(b); Fed. R. Civ. P. 5(b) (service). See ../README.md.
// The local rules set no typeface, margin or spacing rule for this court; the choices below are conventions.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // no face named by the rules: the house standard, as filed (the Mannon exemplar is Times New Roman)
#let type-size = 13pt                   // no size rule; between the 12 pt house standard and the exemplar's 14 pt
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let quote-indent = 0.5in               // block quotations: indented from both margins
#let margin = 1in                       // all four margins
#let caption-left = 3.25in              // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column (its right rule) and the case number
#let caption-inset = 10pt               // the party text stands off the caption's right rule
#let sig-left = 3.1in                   // the signature block starts here (the right half of the text width)
#let level-step = 0.5in                 // headings and contents: each level a half inch further in
#let label-w = 0.5in                    // the box of a heading's number ("I.", "A."); the title hangs after it
#let toc-page-col = 36pt                // contents: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 72pt                // authorities: the page lists ("1, 2, 5", "passim") keep the last inch
#let toa-hang = 0.25in                  // authorities: a wrapped citation hangs a quarter inch
#let passim-at = 7                      // an authority cited on this many pages or more prints "passim" (the ca9 template's rule)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips, 20 x pt).
#let pitch-single = 14.95pt             // a single line: 1.15 x the type size (Word's single line in this face), 299 twips
#let pitch-double = 2 * pitch-single    // double spacing (Word's double), 598 twips
#let gap = 12pt                         // between contents rows and between the groups of the signature block
#let footer-descent = 21.25pt           // the page number's line box ends 0.5 in above the page foot (Word's footer)

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
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// Heading numbers: the template numbers the sections I., A., 1., a. A heading that already starts with its own
/// number keeps it (an excerpt of a filing keeps the filing's numbers). A heading whose text starts with
/// "Introduction" or "Certificate of Service" is unnumbered.
#let own-number = regex("^([IVXLC]+|[A-H]|[0-9]+|[a-h])\\.\\s+")
#let unnumbered-heading = regex("^(Introduction|Certificate of Service)\\b")

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (a page of its own)
// ---------------------------------------------------------------------------

#let caption(meta) = block(above: pitch-double, below: pitch-double, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt), inset: (right: caption-inset), {
    // Each party: its names, then its designation a line below; the separator ("v." or "vs.") between the parties,
    // a line from either side.
    let between = if "between" in meta.caption { meta.caption.between } else { "v." }
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block(above: pitch-single, inl(between)) }
      for (i, n) in p.names.enumerate() { line-block(above: if k > 0 and i == 0 { pitch-single } else { 0pt }, inl(n)) }
      line-block(above: pitch-single, inl(p.designation))
    }
  }),
  line-block[Case No. #meta.case_number],
))

#let cover(meta) = {
  line-block(align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")))
  line-block(align(center, text(weight: "bold", "FOR THE WESTERN DISTRICT OF MISSOURI")))
  if "division" in meta and meta.division != none {
    line-block(align(center, text(weight: "bold", upper(meta.division))))
  }
  caption(meta)
  // The title of the paper, centered under the caption.
  line-block(align(center, text(weight: "bold", inl(meta.title))))
}

// ---------------------------------------------------------------------------
// Headings, table of contents, table of authorities
// ---------------------------------------------------------------------------

/// A heading, single-spaced and bold, a single line above it (the double-spaced line after it brings its own
/// space), kept with the text after it. Numbered: the number in a box at its level's indent, the title hanging after
/// it; unnumbered: centered capitals. It carries a metadata label for the contents.
#let heading-block(level, label, text-md, numbered) = block(width: 100%, above: pitch-single, below: 0pt,
  sticky: true, {
    set text(..edges(pitch-single))
    if numbered {
      let ind = (level - 1) * level-step
      set par(first-line-indent: 0pt, hanging-indent: ind + label-w)
      text(weight: "bold", { h(ind); box(width: label-w, label); inl(text-md) })
    } else {
      set par(first-line-indent: 0pt)
      align(center, text(weight: "bold", upper(text-md)))
    }
    [#metadata((level: if numbered { level } else { 1 }, label: label, text: text-md)) <toc-entry>]
  })

#let toc-page() = {
  line-block(below: gap, align(center, text(weight: "bold", "TABLE OF CONTENTS")))
  context {
    set text(..edges(pitch-single))
    for e in query(<toc-entry>) {
      let pg = counter(page).at(e.location()).first()
      let ind = (e.value.level - 1) * level-step
      let has-label = e.value.label != ""
      listing-row(e.location(), { h(ind); if has-label { box(width: label-w, e.value.label) }; inl(e.value.text) },
        str(pg), toc-page-col, ind + if has-label { label-w } else { 0pt }, gap)
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

/// The table of authorities: one group per kind (cases alphabetized by name, the others by their sort key or
/// citation), each authority cited in the body with the pages where it is cited.
#let toa-page(registry) = {
  line-block(below: gap, align(center, text(weight: "bold", "TABLE OF AUTHORITIES")))
  context {
    set text(..edges(pitch-single))
    let hits = query(<toa-hit>)
    for kind in kind-titles.keys() {
      let keys = registry.keys().filter(k => registry.at(k).kind == kind and hits.any(h => h.value == k))
      if keys.len() == 0 { continue }
      let keyed = keys.map(k => {
        let a = registry.at(k)
        (key: k, sort: if "sort" in a { a.sort } else if "name" in a { a.name } else { a.cite }, a: a)
      })
      keyed = keyed.sorted(key: x => (lower(x.sort), x.key))
      line-block(above: gap, text(weight: "bold", kind-titles.at(kind)))
      for x in keyed {
        let pages = hits.filter(h => h.value == x.key).map(h => counter(page).at(h.location()).first())
        pages = pages.dedup().sorted()
        let pg = if pages.len() >= passim-at { emph("passim") } else { pages.map(str).join(", ") }
        let src = if "name" in x.a { if kind == "case" { "*" + x.a.name + "*, " + x.a.cite } else { x.a.name + ", " + x.a.cite } } else { x.a.cite }
        listing-row(none, inl(src), pg, toa-page-col, toa-hang, gap)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Signature block: "Respectfully submitted,", the signer in bold and the lines under the name, in the right half of
/// the text width (W.D. Mo. signature under the body). It never breaks across a page.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt,
  pad(left: sig-left, {
    let sig = meta.signature
    line-block[Respectfully submitted,]
    line-block(above: gap, text(weight: "bold", inl(sig.signer)))
    for l in sig.lines { line-block(inl(l)) }
  }))

/// The certificate of service on a page of its own: the wording is the template's, the date and recipients come
/// from the sample.
#let service-block(meta) = {
  let svc = meta.service
  heading-block(1, "", "Certificate of Service", false)
  block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true),
    [I hereby certify that on #svc.date, I caused a copy of the foregoing document to be sent to all counsel of record via this Court’s CM/ECF system and via electronic mail to #inl(svc.recipients).]))
  block(width: 100%, breakable: false, above: pitch-single, below: 0pt,
    pad(left: sig-left, line-block(text(weight: "bold", inl(svc.signer)))))
}

/// The body: headings (numbered by the template, see own-number), block quotations, lists, paragraphs. A heading is
/// kept with the chunk after it (sticky); the last chunk stays whole with the signature block (`tail`).
#let body-chunks(body, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Counters for the template's numbering: level 1 I., level 2 A., level 3 1., level 4 a.
  let n = (0, 0, 0, 0)
  for (ci, c) in chunks.enumerate() {
    let t = c.trim()
    let piece = if t.starts-with("#") {
      let m = t.match(regex("^(#+)\\s+(.*)$"))
      let level = m.captures.at(0).len()
      if level > 4 { panic("mowd-motion-brief: heading level " + str(level) + " has no style") }
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
      heading-block(level, label, text-md, numbered)
    } else if t.starts-with(">") {
      // Block quotation: single spaced, indented from both margins, a single line above and below it.
      block(width: 100%, above: pitch-single, below: pitch-single, pad(x: quote-indent, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        md(t.replace(regex("(?m)^>[ \\t]?"), ""))
      }))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list, double spaced: the xengine list (the number or bullet in a half-inch box, the text hanging after it).
      block(width: 100%, above: 0pt, below: 0pt, md(t))
    } else {
      // A paragraph: first line indented, double spaced.
      block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), md(t)))
    }
    if ci == chunks.len() - 1 { block(width: 100%, breakable: false, above: 0pt, below: 0pt, { piece; tail }) } else { piece }
  }
}

#let mowd-motion-brief(meta, body) = {
  let registry = if "authorities" in meta { meta.authorities } else { (:) }

  set page(paper: "us-letter", margin: margin, numbering: none, footer: none)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double spacing).
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)

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
  cover(meta)

  // The page number: centered in a single-spaced line box (Word's footer).
  set page(numbering: "i", footer-descent: footer-descent,   // a new page, numbered from i
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  counter(page).update(1)
  toc-page()
  pagebreak()
  toa-page(registry)

  set page(numbering: "1")    // a new page, numbered from 1
  counter(page).update(1)
  body-chunks(body, signature-block(meta))
  pagebreak()
  service-block(meta)
}
