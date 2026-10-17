// Memorandum in support of a motion to dismiss for the U.S. District Court for the District of Rhode Island (rid).
// Rules: Fed. R. Civ. P. 7(b)(1) (grounds stated with particularity), 12(b)(6); D.R.I. LR Cv 5(a)(1)-(5) (form of
// papers: 8 1/2 x 11, caption with judge's initials after docketing, title, double spacing, at least 12-point type,
// footnotes at least 10-point, page numbers bottom center, signature block); LR Cv 7(a)(2)(A)-(B) (motion states
// grounds and argument; a memorandum is an attachment to the motion, not a separate docket entry); LR Cv 7(c)
// (statement on oral argument and evidentiary hearing).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
// See ../README.md.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; LR Cv 5(a)(3) sets no typeface, only the size
#let type-size = 12pt                   // LR Cv 5(a)(3): at least 12-point font
#let footnote-size = 10pt               // LR Cv 5(a)(3): footnotes at least 10-point, may be single-spaced
#let page-w = 8.5in                     // LR Cv 5(a): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // convention (no D.R.I. margin rule); page number sits in the bottom margin
#let text-width = page-w - 2 * margin
#let pitch = 27.6pt                     // double spacing: the baseline pitch of both filed exemplars at 12 pt (measured, README.md)
#let body-leading = 1.645em             // Liberation Serif sets a 0.655em line, so 1.645em of leading gives the 27.6 pt pitch above
#let single-leading = 0.5em             // caption, counsel, signature and footnotes: single-spaced (13.8 pt at 12 pt)
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let quote-indent = 0.5in               // block quotations are indented on both sides
#let caption-left = 3.4in               // width of the party column of the caption
#let sig-left = 2.9in                   // width of the left column of the signature block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("rid-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, links, footnote references, smart punctuation) for one run of text.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Roman numerals for heading level 1 (I to XX is enough for a memorandum).
#let roman(n) = (
  "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X",
  "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX",
).at(n - 1)

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// The caption: the party names on the left (closed by a rule on the right and below) and the civil action
/// number on the right, with the judge's initials (LR Cv 5(a)(1)).
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  let number = if "case_number" in meta and meta.case_number != "" {
    "C.A. No. " + meta.case_number
  } else {
    "C.A. No. ______________"
  }
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 0.12in, bottom: 0.12in), line-stack(rows)),
    block(inset: (left: 0.1in), {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [#number]
      if "jury_demand" in meta and meta.jury_demand {
        v(pitch)
        text(weight: "bold", "JURY TRIAL DEMANDED")
      }
    }),
  )
}

#let cover(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  align(center, text(weight: "bold", stack(dir: ttb, spacing: single-leading,
    "UNITED STATES DISTRICT COURT",
    "FOR THE DISTRICT OF RHODE ISLAND",
  )))
  v(pitch)
  caption(meta)
  v(pitch)
  align(center, text(weight: "bold", inl(meta.brief_title)))
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body: headings (auto-numbered at levels 1 and 2), paragraphs, block quotations, footnotes
// ---------------------------------------------------------------------------

/// Level 1: centered bold capitals with a roman numeral (I., II., ...). Level 2: bold, "A.", "B.", ... at the
/// left. Level 3: bold, at the left, exactly as written (a level-3 heading that numbers itself keeps its number).
/// Sticky: a heading never ends a page.
#let heading-block(level, n1, n2, text-md) = block(width: text-width, above: 0pt, below: body-leading, sticky: true, {
  set par(leading: single-leading, spacing: 0pt)
  if level == 1 {
    align(center, text(weight: "bold", [#roman(n1). #upper(text-md)]))
  } else if level == 2 {
    text(weight: "bold", [#("ABCDEFGHIJKLMNOPQRSTUVWXYZ".at(n2 - 1)). #inl(text-md)])
  } else {
    text(weight: "bold", inl(text-md))
  }
})

/// Footnote definitions in the body (`[^key]: text`) are collected first. Each paragraph is rendered with the
/// definitions of the keys it refers to, so cmarker resolves every reference to a typst footnote.
#let collect-footnotes(chunks) = {
  let defs = (:)
  for t in chunks {
    if t.starts-with("[^") {
      let m = t.match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*"))
      if m != none { defs.insert(m.captures.at(0), t.slice(m.end)) }
    }
  }
  defs
}

#let footnote-source(t, defs) = {
  let keys = t.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0)).dedup()
  let out = t
  for k in keys {
    if k in defs { out += "\n\n[^" + k + "]: " + defs.at(k) }
  }
  out
}

/// The body: chunks separated by blank lines. A heading (#...), a block quotation (>...), a list, or a paragraph.
/// Paragraphs are not numbered (a memorandum is not a pleading); each has a first-line indent.
#let body-content(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let defs = collect-footnotes(chunks)
  let pieces = ()
  let n1 = 0
  let n2 = 0
  for t in chunks {
    if t.starts-with("[^") {
      // a footnote definition: rendered as a footnote where it is referenced
    } else if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      let text-md = t.slice(level).trim()
      if level == 1 {
        n1 += 1
        n2 = 0
      } else if level == 2 {
        n2 += 1
      }
      pieces.push(heading-block(level, n1, n2, text-md))
    } else if t.starts-with(">") {
      let quoted = t.split(regex("\\r?\\n")).map(l => l.trim().trim(">", at: start).trim()).join(" ")
      pieces.push(block(width: text-width, above: 0pt, below: body-leading, inset: (left: quote-indent, right: quote-indent), {
        set par(leading: body-leading)
        inl(footnote-source(quoted, defs))
      }))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pieces.push(block(width: text-width, above: 0pt, below: body-leading, {
        set par(leading: body-leading)
        set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in)
        set list(indent: 0.5in, body-indent: 0.4in)
        inl(footnote-source(t, defs))
      }))
    } else {
      pieces.push(block(width: text-width, above: 0pt, below: body-leading, {
        set par(leading: body-leading)
        h(para-indent)
        inl(footnote-source(t, defs))
      }))
    }
  }
  pieces.join()
}

/// The oral argument statement (LR Cv 7(c)): "requested" with the estimated time, or "not requested".
#let oral-argument(meta) = {
  let oa = meta.oral_argument
  let statement = if oa.requested {
    "Oral argument and evidentiary hearing are requested" + if "minutes" in oa and oa.minutes != none { "; the estimated time is " + str(oa.minutes) + " minutes." } else { "." }
  } else {
    "Oral argument and evidentiary hearing are not requested."
  }
  block(width: text-width, above: 0pt, below: body-leading, breakable: false, {
    set par(leading: body-leading)
    h(para-indent)
    text(weight: "bold", "Statement on oral argument. ")
    statement
  })
}

/// The signature block (LR Cv 5(a)(5)): optional lead line ("Respectfully submitted,"), the party line, the
/// signers with bar numbers, then the firm's address, telephone, and email. Kept on one page.
#let signature(meta) = block(width: text-width, breakable: false, above: pitch, {
  let sig = meta.signature
  grid(
    columns: (sig-left, 1fr),
    column-gutter: 0.2in,
    if "date" in meta { [Dated: #meta.date] } else { [] },
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      if "lead" in sig { line-stack((sig.lead,)) ; v(pitch * 0.5) }
      line-stack(sig.party)
      v(pitch * 0.5)
      let rows = ()
      for s in sig.signers {
        rows.push("/s/ " + s.name)
        rows.push(if "bar" in s and s.bar != "" { s.name + " " + s.bar } else { s.name })
        rows.push("")
      }
      if rows.len() > 0 { line-stack(rows.slice(0, rows.len() - 1)) }
      v(pitch * 0.5)
      line-stack(sig.firm)
    },
  )
})

/// The certificate of service (LR Cv 5(a)(5) signature; the text comes from the sample's frontmatter).
#let certificate(meta) = if "certificate_of_service" in meta {
  let cos = meta.certificate_of_service
  let signer = meta.signature.signers.at(0)
  block(width: text-width, above: pitch, breakable: false, {
    align(center, block(above: 0pt, below: body-leading, sticky: true, text(weight: "bold", "CERTIFICATE OF SERVICE")))
    block(width: text-width, above: 0pt, below: body-leading, {
      set par(leading: body-leading)
      h(para-indent)
      inl(cos.text)
    })
    grid(
      columns: (sig-left, 1fr),
      column-gutter: 0.2in,
      [],
      {
        set par(leading: single-leading, spacing: 0pt, justify: false)
        line-stack(("/s/ " + signer.name, signer.name + " " + signer.at("bar", default: "")))
      },
    )
  })
}

#let rid-motion-brief(meta, body) = {
  set page(paper: "us-letter", margin: margin, numbering: "1")
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  show footnote.entry: it => {
    set par(leading: single-leading)
    set text(size: footnote-size)
    it
  }

  // The caption, the title, and the signature are required (LR Cv 5(a)(1), (2), (5); Fed. R. Civ. P. 10(a) as
  // applied to motions by Rule 7(b)(2)). Missing fields fail the build.
  assert("caption" in meta and "parties" in meta.caption, message: "rid-motion-brief: the sample needs caption.parties")
  assert("brief_title" in meta, message: "rid-motion-brief: the sample needs brief_title")
  assert("signature" in meta, message: "rid-motion-brief: the sample needs a signature block (LR Cv 5(a)(5))")
  assert("oral_argument" in meta, message: "rid-motion-brief: the sample needs oral_argument (LR Cv 7(c))")

  cover(meta)
  body-content(body)
  oral-argument(meta)
  signature(meta)
  certificate(meta)
}
