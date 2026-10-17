// U.S. District Court, District of Puerto Rico: complaint (Fed. R. Civ. P. 8 and 10; the form rules of
// D.P.R. Local Civil Rule 7 as quoted in ../README.md). Rule-driven and content-agnostic: every
// case-specific word comes from the sample's frontmatter, never from this file. The markdown body is
// rendered by cmarker; the metadata comes from the YAML frontmatter of the same sample file.
// Requirement IDs (PRD-...) in ../README.md say what each parameter below traces to.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")       // PRD-FORM-002: proportional font; Times New Roman substitute per docs/FONTS.md, vendored in /fonts (see ../README.md)
#let type-size = 12pt                  // PRD-FORM-002: 12 point or larger for a proportional font (L.Civ.R. 7)
#let line-pitch = 24pt                 // PRD-FORM-003: double spacing (L.Civ.R. 7); the baseline pitch of body text
#let body-leading = 1.345em            // gap between body lines at 12 pt in Liberation Serif: gives the 24 pt pitch (measured, README)
#let single-leading = 0.5em            // caption, counsel block, signature block: single-spaced (L.Civ.R. 7)
#let page-margin = 1in                 // PRD-FORM-004: margins are not stated in the rule text read; 1 inch as in the exemplar (README)
#let para-indent = 0.5in               // first-line indent of the lead-in
#let num-indent = 0.5in                // the numbered allegation's number sits at this indent
#let court-title = ("UNITED STATES DISTRICT COURT", "DISTRICT OF PUERTO RICO")  // PRD-CAP-001: the court's name, the same for every case
#let caption-left = 3.4in              // width of the party column of the caption
#let footer-size = 12pt                // PRD-FORM-005: page numbers at bottom centre, same size as the text
#let text-width = 8.5in - 2 * page-margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("prd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italic case names, § signs and the like).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("prd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Lines that each take one line of single-spaced text, with no paragraph space between them.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  for i in items {
    inl(i)
    linebreak()
  }
}

// ---------------------------------------------------------------------------
// Headings (PRD-CONT-001): centred capitals for sections, bold for sub-headings, bold italic below.
// ---------------------------------------------------------------------------

#let heading-block(it, body) = block(width: 100%, above: line-pitch, below: line-pitch * 0.5, sticky: true, {
  set text(size: type-size)   // a heading keeps the body size (the default heading size is larger)
  body
})

#let heading-rule(it) = {
  if it.level == 1 {
    heading-block(it, align(center, strong(upper(it.body))))
  } else if it.level == 2 {
    heading-block(it, strong(it.body))
  } else {
    heading-block(it, strong(emph(it.body)))
  }
}

// ---------------------------------------------------------------------------
// Caption (PRD-CAP-002): parties on the left with a rule on their right and bottom, the case number and the
// title of the paper on the right. No line numbers and no pleading rules: D.P.R. papers are not pleading paper.
// ---------------------------------------------------------------------------

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 12pt), {
    let sides = need(meta, "caption")
    set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
    for (i, side) in sides.enumerate() {
      for n in side.names {
        inl(n)
        linebreak()
      }
      pad(left: 1.4in, inl(side.designation))
      if i < sides.len() - 1 {
        v(line-pitch * 0.5)
        align(center, [v.])
        v(line-pitch * 0.5)
      }
    }
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
    [No. #need(meta, "case_number")]
    v(line-pitch * 0.5)
    strong(upper(need(meta, "brief_title")))
    if "jury_demand" in meta and meta.jury_demand {
      v(line-pitch * 0.5)
      strong[JURY TRIAL DEMANDED]
    }
  }),
)

#let cover(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  align(center, {
    for l in court-title { strong(l); linebreak() }
  })
  v(line-pitch)
  caption(meta)
  v(line-pitch)
}

// ---------------------------------------------------------------------------
// Body. Each blank-line-separated chunk of markdown that is neither a heading nor a list is one numbered
// allegation (Fed. R. Civ. P. 10(b)). Headings and lists are not numbered.
// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content
// recurses without end in typst 0.15.
// ---------------------------------------------------------------------------

// Paragraphs are plain content, not blocks: a fixed block around each one measured short and the next
// paragraph was drawn over its last line. The paragraph spacing equals the body leading, so the baseline
// pitch between paragraphs is the same as inside them.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true)
    } else if t.starts-with("WHEREFORE") {
      // The prayer's lead-in is not an allegation: it is indented text without a number.
      h(para-indent)
      cmarker.render(t, raw-typst: false, smart-punctuation: true)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list is not an allegation.
      cmarker.render(t, raw-typst: false, smart-punctuation: true)
    } else {
      para-counter.step()
      context [#h(num-indent)#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true)]
    }
    parbreak()
  }
}

// ---------------------------------------------------------------------------
// Signature block (PRD-SIG-001): the date, then each signing counsel group. A group with a `signer` gets
// the "By: s/" line; a group without one is counsel of record listed under the signature.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
    grid(columns: (1fr, 3.2in), [Dated: #need(meta, "date")], {
      [Respectfully submitted,]
      for g in sig.groups {
        v(line-pitch * 0.5)
        let lines = g.at("lines", default: ())
        if "signer" in g {
          lines = ("By: s/ " + g.signer, g.signer) + lines
        }
        line-stack(lines)
      }
    })
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let prd-complaint(meta, body) = {
  for k in ("case_number", "caption", "brief_title", "date", "signature") {
    let _ = need(meta, k)
  }

  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: footer-size, counter(page).display("-1-"))),
  )
  set document(title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"), author: "")
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false, fallback: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  show heading: heading-rule
  // Prayer items are lettered (A., B., ...); the markdown list numbers 1., 2., ... and the enum shows letters.
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  cover(meta)

  if "lead_in" in meta {
    block(width: 100%, {
      set par(leading: body-leading, first-line-indent: 0pt)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  let para-counter = counter("allegation")
  allegations(body, para-counter)

  signature-block(meta)
}
