// Brief in support of a motion, for the U.S. District Court for the District of Nebraska (ned).
// Rules: NECivR 7.1(a)(1)(A) (a supporting brief, separate from the motion; no facts unless supported);
// NECivR 7.1(d)(1)(A) (13,000-word limit, caption and headings included) and 7.1(d)(3) (certificate of compliance:
// the word count and the name and version of the software used); NECivR 11.1(a)(1)(A) (signature format);
// NECivR 10.1(a)(3) (caption shows the paper's description). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // no D. Neb. font rule; EB Garamond is the only vendored serif (README.md)
#let type-size = 12pt
#let pitch = 24pt                       // double-spaced baseline pitch (the body grid, a convention)
#let page-w = 8.5in                     // NECivR 10.1(b)(1): 8 1/2 by 11 inch paper (paper filings)
#let page-h = 11in
#let margin = 1in
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // double spacing: 0.65em line box + 1.35em leading = 2em = 24 pt at 12 pt
#let single-leading = 0.55em            // single spacing: caption, block quotes, signature, certificates: 1.2em = 14.4 pt
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.25in              // width of the party column of the caption
#let footer-size = 10pt
#let word-limit = 13000                 // NECivR 7.1(d)(1)(A): a supporting brief may not exceed 13,000 words

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ned-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italic, case names, etc.).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Single-spaced lines: one item per line, each item may wrap.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items)
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Footer on every page after the first: the paper's title, the page number, the case number.
#let footer-block(title, case-number) = context {
  if counter(page).get().first() > 1 {
    set text(size: footer-size)
    align(center, counter(page).display())
    v(3pt)
    grid(columns: (1fr, auto), upper(title), [Case No. #case-number])
  }
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper, lead-in
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  align(center, text(weight: "bold", "IN THE UNITED STATES DISTRICT COURT"))
  v(single-leading)
  align(center, text(weight: "bold", "FOR THE DISTRICT OF NEBRASKA"))
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt, top: 4pt), {
    // Each party: its names, then its designation, indented; "v." between the parties.
    let items = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { items.push(md("v.")) }
      for n in p.names { items.push(md(n)) }
      items.push(pad(left: 1.5in, md(p.designation)))
    }
    line-stack(items)
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt)
    [Case No. #meta.case_number]
    v(pitch * 0.5)
    text(weight: "bold", md(meta.brief_title))
  }),
)

#let cover(meta) = {
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body, signature and certificates
// ---------------------------------------------------------------------------

/// A heading as its own sticky block. `gap` is the space below it: single spacing when another heading follows,
/// otherwise one double-spaced line before the text it introduces. Level 1 is a centered section (bold caps);
/// levels 2 and 3 are left-aligned sub-headings that may run over several lines (hanging indent).
#let heading-block(t, gap) = {
  set par(leading: single-leading)
  let lvl = t.match(regex("^#+")).text.len()
  let txt = t.replace(regex("^#+[ \\t]*"), "")
  if lvl == 1 {
    block(width: text-width, above: pitch, below: gap, sticky: true, align(center, text(weight: "bold", md(upper(txt)))))
  } else if lvl == 2 {
    block(width: text-width, above: pitch, below: gap, sticky: true, par(hanging-indent: 0.5in, text(weight: "bold", md(txt))))
  } else {
    block(width: text-width, above: 0pt, below: gap, sticky: true, par(hanging-indent: 0.5in, text(weight: "bold", style: "italic", md(txt))))
  }
}

/// Signature block in NECivR 11.1(a)(1)(A) order: "s/ name", bar number, attorney for, firm and contact lines.
#let signature-block(meta) = {
  let sig = meta.signature
  let lines = ("s/ " + sig.signer, "Bar Number: " + sig.bar_number, "Attorney for " + sig.attorney_for) + sig.firm
  block(width: text-width, breakable: false, pad(left: 3.25in, line-stack(lines.map(md))))
}

/// A certificate heading: centered bold caps, one double-spaced line above.
#let certificate-heading(title) = block(width: text-width, above: pitch, below: body-leading, sticky: true, align(center, text(weight: "bold", upper(title))))

/// Certificate of compliance, NECivR 7.1(d)(3): the word count, and the name and version of the software used.
/// The count is the filer's; the template checks the 13,000-word limit of NECivR 7.1(d)(1)(A).
#let compliance-certificate(meta) = {
  if "compliance" not in meta {
    panic("ned-motion-brief: NECivR 7.1(d)(3) requires a certificate of compliance; add a `compliance` block")
  }
  let words = meta.compliance.word_count
  let count = int(words.replace(",", ""))
  assert(count <= word-limit, message: "ned-motion-brief: NECivR 7.1(d)(1)(A) limits a supporting brief to 13,000 words; this one states " + words)
  certificate-heading("Certificate of Compliance")
  block(width: text-width, below: body-leading, {
    set par(leading: body-leading)
    h(para-indent)
    [I hereby certify that this Brief complies with NECivR 7.1(d)(1). It contains #words words, including the caption, headings, footnotes, and quotations, as calculated by the word-count function of #meta.compliance.software.]
  })
  let sig = meta.signature
  block(width: text-width, breakable: false, pad(left: 3.25in, line-stack(("s/ " + sig.signer, sig.signer + ", #" + sig.bar_number).map(md))))
}

/// Certificate of service: the filer's sentence, then each recipient's block. CM/ECF filing is the service
/// (no certificate is required for it under Fed. R. Civ. P. 5(d)(1)(B)); the exemplar files one anyway.
#let service-certificate(meta) = {
  if "service" in meta {
    let svc = meta.service
    certificate-heading("Certificate of Service")
    block(width: text-width, below: body-leading, {
      set par(leading: body-leading)
      h(para-indent)
      md(svc.text)
    })
    for r in svc.recipients {
      block(width: text-width, below: body-leading, pad(left: 0.5in, line-stack(r.map(md))))
    }
    let sig = meta.signature
    block(width: text-width, breakable: false, pad(left: 3.25in, line-stack(("s/ " + sig.signer, sig.signer + ", #" + sig.bar_number).map(md))))
  }
}

/// Body paragraphs are not numbered (a brief is not pleading under Fed. R. Civ. P. 10(b)). Each blank-line-separated
/// chunk is one paragraph (first-line indent), a heading, or a list (numbered 1., 2., ...). Each chunk is its own block,
/// so the next one starts on a new line.
#let body-chunks(chunks) = {
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let next = chunks.at(i + 1, default: "").trim()
    if t.starts-with("#") {
      let gap = if next.starts-with("#") { single-leading } else { single-leading + body-leading }
      heading-block(t, gap)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      block(width: text-width, below: body-leading, {
        set par(leading: body-leading)
        md(t)
      })
    } else if t.starts-with(">") {
      // Block quotes are handled by the `quote` show rule below.
      md(t)
    } else {
      block(width: text-width, below: body-leading, {
        set par(leading: body-leading)
        h(para-indent)
        md(t)
      })
    }
  }
}

#let ned-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-block(meta.footer_title, meta.case_number),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Block quotations are single-spaced and indented on both sides.
  show quote.where(block: true): it => block(width: text-width, inset: (left: 0.5in, right: 0.5in), below: body-leading, {
    set par(leading: single-leading, first-line-indent: 0pt)
    it.body
  })

  cover(meta)

  if "lead_in" in meta {
    block(width: text-width, below: body-leading, {
      set par(leading: body-leading)
      h(para-indent)
      md(meta.lead_in)
    })
  }

  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let last = chunks.len() - 1
  body-chunks(chunks.slice(0, last))
  // The last paragraph stays on the page with the signature: a signature never starts a page alone.
  block(width: text-width, breakable: false, {
    body-chunks(chunks.slice(last))
    signature-block(meta)
  })
  compliance-certificate(meta)
  service-certificate(meta)
}
