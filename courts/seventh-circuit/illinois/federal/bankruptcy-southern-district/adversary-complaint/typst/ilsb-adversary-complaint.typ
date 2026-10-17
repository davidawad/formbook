// U.S. Bankruptcy Court, Southern District of Illinois: adversary complaint (Fed. R. Bankr. P. 7001 and
// 7010, which apply Fed. R. Civ. P. 10 with a Form 416 caption; S.D. Ill. L.R. 5005-1, 5005-2, 9011).
//
// Rule-driven and content-agnostic. Requirement IDs (ILSB-...) refer to ../README.md, which quotes the
// rule text. No case-specific text, no coordinates measured off the exemplar, no forced line breaks.
// The body is markdown rendered by cmarker; the caption, counsel and signature data come from the YAML
// frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a named style choice; see ../README.md)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"        // No S.D. Ill. rule names a typeface (ILSB-FORM-002 gap); Times New Roman substitute per docs/FONTS.md. Vendored in /fonts.
#let type-size = 12pt                   // Style choice: the exemplar is Times 12 pt. No S.D. Ill. type-size rule.
#let pitch = 24pt                       // Double spacing for the body (convention, not a rule; see ../README.md).
#let body-leading = 1.345em             // Gives a 24 pt baseline pitch at 12 pt in Liberation Serif (line box 0.655 em).
#let single-leading = 0.5em             // Caption, counsel, signature, block quotations, footer.
#let page-w = 8.5in                     // ILSB-FORM-001 (L.R. 5005-2): 8 1/2 by 11 inch paper.
#let page-h = 11in
#let page-margin = 1in
#let para-indent = 0.5in                // First-line indent of numbered paragraphs.
#let number-gap = 0.3in                 // Space between the paragraph number and its text.
#let caption-left = 3.6in               // Width of the party column of the caption.
#let footer-size = 10pt                 // Page number only; not body text.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilsb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names, *et al.*), as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item, with the single-spaced gap between items.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Caption (Form 416 as S.D. Ill. uses it: court, debtor and chapter, parties, adversary number)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  let lines = ("IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE SOUTHERN DISTRICT OF ILLINOIS")
  if "division" in meta and meta.division != none { lines.push(upper(meta.division)) }
  align(center, stack(dir: ttb, spacing: single-leading, ..lines.map(l => text(weight: "bold", l))))
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  // Left: the debtor (In re), then the parties to the adversary proceeding, "v." between the sides.
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
    let rows = ("In re:",) + meta.debtors + (meta.debtor_designation,)
    rows.push("")
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  // Right: the bankruptcy case number and chapter (L.R. 5005-1(B)(2)), then the adversary number.
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt)
    stack(
      dir: ttb,
      spacing: single-leading,
      [Case No. #meta.bankruptcy_case_no],
      [Chapter #meta.chapter],
      v(pitch * 0.5),
      if meta.adversary_no != none and meta.adversary_no != "" {
        [Adversary No. #meta.adversary_no]
      } else {
        [Adversary No. #("_" * 10)]
      },
    )
  }),
)

// ---------------------------------------------------------------------------
// Signature and attorney block (L.R. 9011(A); FRBP 9011 and Electronic Filing Rules, Rule 5)
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch, {
  grid(
    columns: (2.8in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      set par(leading: single-leading, spacing: 0pt)
      [Respectfully submitted,]
      v(pitch * 0.5)
      line-stack(meta.signature.party)
      v(pitch * 0.5)
      line-stack(("/s/ " + meta.signature.signer, meta.signature.signer + ",", meta.signature.signer_title))
    },
  )
  v(pitch)
  line-stack(meta.signature.attorney)
})

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, prayers and lists
// ---------------------------------------------------------------------------

/// The body, one blank-line-separated chunk at a time.
///  - `#` / `##` / `###` headings: centered bold capitals / centered bold / bold. Not numbered.
///  - a chunk beginning WHEREFORE starts the prayer for relief: it is not numbered, and the items after
///    it are written `A. ...`, `B. ...` and rendered lettered with a hanging indent, unnumbered.
///  - a chunk beginning `- ` is a bulleted list (not numbered, not part of the prayer).
///  - a chunk beginning `>` is a block quotation: single-spaced and indented.
///  - every other chunk is a numbered paragraph (Fed. R. Civ. P. 10(b)). The author writes no number:
///    a chunk beginning "1. " is a numbered paragraph's text, not a list, so the number is the template's.
/// Numbering is applied per chunk, not with a show rule (a show rule that re-wraps paragraph content
/// recurses without end in typst 0.15). Headings are `sticky`, so one never ends a page.
#let body-flow(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Footnote definitions are rendered with the paragraph that cites them (see ilsb-motion-brief.typ).
  let defs = (:)
  for c in chunks {
    let key = c.trim().match(regex("^\\[\\^([^\\]]+)\\]:"))
    if key != none { defs.insert(key.captures.at(0), c.trim()) }
  }
  let md(t) = {
    let tail = ""
    for (key, d) in defs {
      if t.contains("[^" + key + "]") { tail += "\n\n" + d }
    }
    cmarker.render(t + tail, raw-typst: false, smart-punctuation: true, h1-level: 1)
  }
  chunks = chunks.filter(c => not c.trim().starts-with("[^"))
  let para-counter = counter("ilsb-paragraph")
  let in-prayer = false
  for c in chunks {
    let t = c.trim()
    let prayer-item = t.match(regex("^([A-Z])\\.[ \\t]+([\\s\\S]*)"))
    if t.starts-with("#") {
      in-prayer = false
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if in-prayer and prayer-item != none {
      block(width: 100%, below: body-leading, {
        set par(leading: body-leading)
        grid(
          columns: (para-indent + 0.3in, 1fr),
          [#h(para-indent)#(prayer-item.captures.at(0)).],
          cmarker.render(prayer-item.captures.at(1), raw-typst: false, smart-punctuation: true, h1-level: 1),
        )
      })
    } else if t.starts-with(regex("^[-*+][ \\t]")) {
      // A bulleted list: items are spaced by body-leading, so each fills whole lines; the trailing v() closes it.
      {
        set par(leading: body-leading)
        set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
    } else if t.starts-with(">") {
      pad(left: 0.5in, right: 0.5in, {
        set par(leading: single-leading)
        v(pitch * 0.5)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(pitch * 0.5)
      })
    } else if t.starts-with("WHEREFORE") {
      in-prayer = true
      block(width: 100%, below: body-leading, sticky: true, {
        set par(leading: body-leading)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else {
      para-counter.step()
      block(width: 100%, below: body-leading, context {
        set par(leading: body-leading)
        h(para-indent)
        [#(para-counter.display()).]
        h(number-gap)
        md(t)
      })
    }
  }
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let ilsb-adversary-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context {
      let p = counter(page).get().first()
      let n = counter(page).final().first()
      set text(size: footer-size)
      align(center, [Page #p of #n])
    },
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  show heading.where(level: 1): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5, sticky: true,
    text(size: type-size, weight: "bold", it.body))

  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
  align(center, text(weight: "bold", upper(meta.title)))
  v(pitch)

  if "lead_in" in meta and meta.lead_in != none {
    block(width: 100%, below: body-leading, {
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  body-flow(body)

  signature-block(meta)

  if "exhibits" in meta and meta.exhibits != none and meta.exhibits.len() > 0 {
    // Summary of Exhibits: the last page of the filing (Admin. Guide, adversary complaint; Electronic
    // Filing Rules, Rule 6). Its certificate of service is required when exhibits are served.
    pagebreak()
    align(center, text(weight: "bold", "SUMMARY OF EXHIBITS"))
    v(pitch)
    for ex in meta.exhibits {
      block(width: 100%, above: pitch * 0.5, below: 0pt, {
        set par(leading: single-leading)
        grid(columns: (1.2in, 1fr), column-gutter: 0.2in, text(weight: "bold", ex.label), inl(ex.description))
      })
    }
    if "exhibits_service" in meta and meta.exhibits_service != none {
      v(pitch)
      align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
      v(pitch * 0.5)
      block(width: 100%, {
        set par(leading: body-leading)
        h(para-indent)
        inl(meta.exhibits_service)
      })
    }
  }
}
