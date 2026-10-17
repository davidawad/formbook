// Motion to dismiss with incorporated memorandum for the U.S. District Court for the Southern District of
// Florida (flsd). Rules: S.D. Fla. L.R. 5.1(a) (paper, margins, spacing, type size, pagination, caption,
// signature block); L.R. 5.2 (certificate of service); L.R. 7.1(a)(1) (the motion incorporates its memorandum),
// 7.1(a)(3) (conferral certificate not required for a motion to dismiss for failure to state a claim),
// 7.1(c)(2) (20-page limit for a motion and its incorporated memorandum; the title page, signature page and
// certificate of service do not count). Fed. R. Civ. P. 7(b), 12(b)(6). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // no font rule in L.R. 5.1; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // L.R. 5.1(a)(4): fonts no smaller than 12 point, footnotes included
#let page-w = 8.5in                     // L.R. 5.1(a)(3): standard 8 1/2 x 11 inch paper
#let page-h = 11in
#let margin = 1in                       // L.R. 5.1(a)(4): 1 inch on top, bottom and each side
#let body-leading = 1.65em              // L.R. 5.1(a)(4): at least 1 1/2 spaces; the exemplar is double-spaced (27.6 pt pitch at 12 pt), see README.md
#let single-leading = 0.495em            // quotations of 50 words or more, footnotes, signature and caption blocks (13.8 pt pitch)
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let style-width = 3.25in               // L.R. 5.1(a)(5)(C): the style fills no more than the left side of the page

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flsd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, links, footnote references).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A block of single-spaced lines (caption style, signature and service blocks), one item per line.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Paginated consecutively at the bottom center of each page (L.R. 5.1(a)(4)).
#let footer-page-number() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Caption: court (L.R. 5.1(a)(5)(A)), docket line (B), style on the left (C), title (D)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  align(center, stack(dir: ttb, spacing: single-leading,
    text(weight: "bold", "UNITED STATES DISTRICT COURT"),
    text(weight: "bold", "SOUTHERN DISTRICT OF FLORIDA"),
    ..if "division" in meta { (text(weight: "bold", upper(meta.division)),) } else { () },
  ))
}

#let style-block(meta) = block(width: style-width, {
  // Each party: its names, then its designation; "v." between the parties; the "/" closes the style.
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  rows.push("/")
  line-stack(rows)
})

#let caption(meta) = {
  court-title(meta)
  v(body-leading * 2)
  // Docket line centered across the page (L.R. 5.1(a)(5)(B)): category, number, assigned judges.
  align(center, text("CIVIL CASE NO. " + meta.case_number))
  v(body-leading * 2)
  style-block(meta)
  v(body-leading * 2)
  align(center, text(weight: "bold", upper(meta.title)))
  v(body-leading * 2)
}

// ---------------------------------------------------------------------------
// Body: unnumbered paragraphs (a motion is not a pleading; Fed. R. Civ. P. 10(b) does not apply)
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of markdown is a heading, a list, or a paragraph. Numbering is not used.
/// Chunks are not wrapped in a `show par` rule (a show rule that re-wraps paragraph content recurses without
/// end in typst 0.15).
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // cmarker does not convert markdown footnotes: `[^key]: text` is a definition (collected here, not printed),
  // `[^key]` in a paragraph is a reference, rendered as a typst footnote.
  let notes = (:)
  for c in chunks {
    let m = c.trim().match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*"))
    if m != none { notes.insert(m.captures.at(0), c.trim().slice(m.end)) }
  }
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^\\[\\^[^\\]]+\\]:")) {
      // a footnote definition: printed at its reference
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      block(width: 100%, {
        set par(leading: body-leading, spacing: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else {
      let out = []
      let last = 0
      for r in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
        if r.start > last { out += inl(t.slice(last, r.start)) }
        out += footnote(inl(notes.at(r.captures.at(0))))
        last = r.end
      }
      if last < t.len() { out += inl(t.slice(last)) }
      par(leading: body-leading, first-line-indent: (amount: para-indent, all: true), out)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block, certificate of service (L.R. 5.2)
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: 100%, breakable: false, {
  [Dated: #meta.date]
  v(body-leading)
  pad(left: style-width + 0.25in, {
    [Respectfully submitted,]
    v(body-leading)
    // L.R. 5.1(a)(6): name, street address, telephone, e-mail and bar number of each counsel.
    line-stack(("By: s/ " + meta.signature.signer,) + meta.signature.lines)
  })
})

#let certificate-of-service(meta) = if "service" in meta {
  let s = meta.service
  block(width: 100%, breakable: false, {
    v(body-leading)
    block(width: 100%, sticky: true, above: body-leading, below: body-leading,
      align(center, text(weight: "bold", "CERTIFICATE OF SERVICE")))
    par(leading: body-leading, first-line-indent: (amount: para-indent, all: true),
      "I HEREBY CERTIFY that on this " + s.date + ", I electronically filed the foregoing document with the Clerk of the Court using CM/ECF. I also certify that the foregoing document is being served this day on all counsel of record in the manner specified, either via transmission of Notices of Electronic Filing generated by CM/ECF or in some other authorized manner for those counsel or parties who are not authorized to receive electronically Notices of Electronic Filing.")
    v(body-leading)
    pad(left: style-width + 0.25in, line-stack(("s/" + s.signer, s.signer)))
    v(body-leading)
    block(width: 100%, sticky: true, below: body-leading, text(weight: "bold", "SERVICE LIST"))
    line-stack(s.list)
  })
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let flsd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-page-number(),
    footer-descent: 0.3in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  // Footnotes are 12 point and single-spaced (L.R. 5.1(a)(4)).
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading, first-line-indent: 0pt)

  // Headings: level 1 centered bold capitals; level 2 bold, left (argument point, I., II.); level 3 bold, left,
  // indented (a., b.). The numbers are typed in the sample. A heading is sticky: it never ends a page.
  show heading.where(level: 1): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    text(weight: "bold", it.body))
  show heading.where(level: 3): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    pad(left: 0.5in, text(weight: "bold", it.body)))

  caption(meta)

  body-chunks(body)

  v(body-leading)
  signature-block(meta)

  certificate-of-service(meta)
}
