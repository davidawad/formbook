// Complaint for the U.S. District Court for the Southern District of Mississippi (mssd).
// Rules: Fed. R. Civ. P. 8(a) and 10(a)-(b) (caption, numbered paragraphs); L.U.Civ.R. 11(a) (counsel's name, address,
// telephone, fax, e-mail and bar number on every signed paper); L.U.Civ.R. 38(a) (the jury demand is in the pleading).
// See ../README.md for the rule text, the choices and the gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a choice recorded in README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute per docs/FONTS.md (Times New Roman in the exemplar)
#let type-size = 12pt                   // 12 pt, the exemplar's size; no complaint rule sets one (L.U.Civ.R. 7(b)(5)(B), for memoranda, sets 12-point or larger)
#let margin = 1in                       // all four sides (the exemplar's margins; FRCP 10 sets none)
#let body-leading = 1.645em             // double spacing: calibrated to the exemplar's 27.6 pt line pitch (README.md); Liberation Serif's 0.655em line box + 1.645em = 2.3em = 27.6 pt at 12 pt
#let single-leading = 0.25em            // single spacing for the court title, caption, headings and signature block
#let para-indent = 0.5in                // first-line indent of numbered allegations

// The signature fields L.U.Civ.R. 11(a) requires. The template refuses to render without them.
#let required-signature-keys = ("signer", "bar_no", "firm", "address", "telephone", "fax", "email")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mssd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, smart quotes).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A heading (level 1: centered bold caps; level 2: centered bold). A heading stays with the paragraph after it.
#let heading-block(c) = block(width: 100%, above: 0pt, below: body-leading, sticky: true, text(size: type-size, c))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  for line in meta.court {
    align(center, text(weight: "bold", upper(line)))
    linebreak()
  }
}

#let caption(meta) = grid(
  columns: (3.6in, 1fr),
  column-gutter: 0.1in,
  {
    // Each party: its names, then its designation; "v." on its own line between the parties (the exemplar's layout).
    let blocks = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { blocks.push(line-stack(("v.",))) }
      blocks.push(line-stack(p.names + (p.designation,)))
    }
    stack(dir: ttb, spacing: single-leading * 2, ..blocks)
  },
  align(horizon, {
    set par(leading: single-leading, spacing: 0pt)
    [CIVIL ACTION NO.#linebreak()#meta.case_number]
  }),
)

#let cover(meta) = {
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, underline(text(weight: "bold", upper(meta.brief_title))))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let s = meta.signature
  for k in required-signature-keys {
    assert(k in s, message: "mssd-complaint: signature." + k + " is required (L.U.Civ.R. 11(a))")
  }
  block(width: 100%, breakable: false, {
    v(body-leading)
    pad(left: 3.0in, {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Respectfully submitted,]
      v(body-leading)
      [/s/ #s.signer]
      linebreak()
      [#upper(s.signer) (#s.bar_no)]
      linebreak()
      [#s.firm]
      linebreak()
      for a in s.address { [#a]; linebreak() }
      [Telephone: #s.telephone]
      linebreak()
      [Facsimile: #s.fax]
      linebreak()
      [Email: #s.email]
      linebreak()
      if "role" in s {
        v(single-leading * 2)
        [#upper(s.role)]
      }
    })
  })
}

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph (Fed. R. Civ. P. 10(b)). Headings and lists are rendered unnumbered.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Headings are sticky (see heading-block): a heading never ends a page, so each one is emitted in front of the chunk after it.
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages. Items are spaced by body-leading, so each item fills whole lines.
      block(width: 100%, below: body-leading, {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else {
      // Numbered paragraph (Fed. R. Civ. P. 10(b)). The number comes from a counter read in context.
      block(width: 100%, below: body-leading, {
        para-counter.step()
        set par(leading: body-leading)
        h(para-indent)
        context [#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
      })
    }
  }
}

#let mssd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section (caps); level 2 a centered bold sub-heading.
  show heading.where(level: 1): it => heading-block(align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(align(center, text(weight: "bold", it.body)))

  cover(meta)

  if "lead_in" in meta {
    block(width: 100%, below: body-leading, {
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  // Body: numbered allegations (Fed. R. Civ. P. 10(b)); markdown lists become a., b., c. ...
  set enum(numbering: "a.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter)

  signature-block(meta)
}
