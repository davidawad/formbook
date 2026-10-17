// Motion with memorandum for the United States Bankruptcy Court for the District of Columbia (dcb).
// Rules: Fed. R. Bankr. P. 9013 (written motion; grounds stated with particularity; relief requested),
// 9004(a) (legible) and 9004(b) (caption: court, title, case and adversary number, designation of the paper),
// Local Bankruptcy Rule 9013-1(b) (grounds, relief, optional memorandum), 9013-1(c) (notice of the motion,
// objection deadline and hearing, conforming substantially to Official Form B 420A), 9013-1(d) (response
// deadlines), 9013-1(f) (certificate of service with date, manner and recipients), LBR 5005-1(c) (attorney
// identifiers on the first page). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no D.C. Bankruptcy rule sets a face; vendored in fonts/ (README.md, gap 2)
#let type-size = 12pt                   // no D.C. Bankruptcy rule sets a size; 12 pt matches the exemplar's body (README.md, gap 2)
#let pitch = 27.6pt                     // double spacing: the exemplar's body lines are 27.6 pt apart (measured, README.md)
#let body-leading = 1.65em              // gives a 27.6 pt baseline pitch at 12 pt in EB Garamond (measured, README.md)
#let single-leading = 0.45em            // counsel, caption, notice, block quotations, recipients and signature
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let margin = 1in                       // 1-inch margins on all sides (the exemplar; LBR 5005-1(b) for pro se papers)
#let text-width = 8.5in - 2 * margin
#let caption-left = 3.3in               // width of the party column of the caption
#let caption-mid = 0.35in               // width of the ")" column

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("dcb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline and block markdown (case names, the sample's emphasis).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line per item.
#let lines-stack(items) = {
  set par(leading: single-leading, spacing: single-leading)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => [#i]))
}

// ---------------------------------------------------------------------------
// Cover: counsel block (upper left, LBR 5005-1(c)), court name, caption, title, notice
// ---------------------------------------------------------------------------

#let counsel-block(c) = {
  assert(c.email.contains("@"), message: "dcb-motion-brief: counsel.email is required (LBR 5005-1(c))")
  assert(c.represents.len() > 0, message: "dcb-motion-brief: counsel.represents is required (LBR 5005-1(c))")
  lines-stack((c.name, c.firm, ..c.address, c.phone, c.email, ..c.represents))
}

#let court-title(meta) = {
  stack(dir: ttb, spacing: single-leading, ..meta.court.map(l => align(center, text(weight: "bold", l))))
}

/// The caption: parties on the left, a column of ")" marks, and the case numbers on the right (FRBP 9004(b)).
#let caption(meta) = {
  let c = meta.caption
  let left = c.debtor.names + (c.debtor.designation, "") + c.plaintiff.names + (c.plaintiff.designation, "vs.") + ("Adversary No. " + c.adversary_number,) + ("",) + c.defendant.names + (c.defendant.designation,)
  let right = range(left.len()).map(i => {
    if i == 0 { "In re:" } else if i == 1 { "Case No. " + c.case_number } else if i == 2 { "(Chapter " + c.chapter + ")" } else { "" }
  })
  set text(size: type-size)
  set par(leading: single-leading, spacing: 0pt)
  grid(
    columns: (caption-left, caption-mid, 1fr),
    row-gutter: single-leading,
    ..range(left.len()).map(i => (left.at(i), align(center, ")"), right.at(i))).flatten(),
  )
}

/// Notice of motion, objection deadline and hearing (LBR 9013-1(c), (d)). A blank field prints a fill-in line.
#let notice-box(meta) = {
  let n = meta.notice
  let fill(s) = if s == "" { "________________" } else { s }
  block(width: text-width, stroke: 0.6pt, inset: 10pt, breakable: false, {
    set par(leading: single-leading, spacing: single-leading)
    align(center, text(weight: "bold", "NOTICE OF MOTION, OBJECTION DEADLINE, AND HEARING"))
    v(single-leading)
    [Any response to this motion must be filed with the Court and served on the movant’s counsel no later than #emph[#fill(n.response_deadline)]. If no response is timely filed, the Court may grant the relief requested without a hearing. A hearing on this motion is set for #emph[#fill(n.hearing)].]
  })
}

#let cover(meta) = {
  counsel-block(meta.counsel)
  v(pitch)
  court-title(meta)
  v(pitch * 0.5)
  caption(meta)
  v(pitch * 0.5)
  align(center, text(weight: "bold", meta.title))
  v(pitch * 0.5)
  notice-box(meta)
  v(pitch * 0.5)
}

// ---------------------------------------------------------------------------
// Body: paragraphs, headings, block quotations, signature, certificate of service
// ---------------------------------------------------------------------------

/// Body text: each blank-line-separated chunk is a paragraph; a chunk beginning ">" is a block quotation.
/// Paragraph spacing equals the leading, so consecutive paragraphs keep the same pitch (no overprinting).
#let body(text-md) = {
  let chunks = text-md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(">") {
      block(width: text-width, inset: (left: 0.5in, right: 0.5in), {
        set par(leading: single-leading, spacing: single-leading)
        md(t)
      })
    } else {
      set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent)
      md(t)
    }
  }
}

/// Headings: level 1 centered bold; level 2 bold; level 3 bold italic. Each heading is kept with the text after it.
#let heading-style(it) = {
  set par(leading: single-leading, spacing: single-leading)
  if it.level == 1 {
    block(width: text-width, above: pitch * 0.5, below: pitch * 0.5, sticky: true, align(center, text(weight: "bold", it.body)))
  } else if it.level == 2 {
    block(width: text-width, above: pitch * 0.5, below: pitch * 0.5, sticky: true, text(weight: "bold", it.body))
  } else {
    block(width: text-width, above: pitch * 0.5, below: pitch * 0.5, sticky: true, pad(left: 0.5in, text(weight: "bold", style: "italic", it.body)))
  }
}

#let signature-block(s) = block(breakable: false, above: pitch, grid(
  columns: (2.8in, 1fr),
  column-gutter: 0.2in,
  [Date: #s.date],
  {
    lines-stack(("Respectfully submitted,", s.firm))
    v(pitch * 0.5)
    lines-stack(("/s/ " + s.signer, s.signer, ..s.address, "Phone: " + s.phone, "Email: " + s.email, ..s.role))
  },
))

/// Certificate of service (LBR 9013-1(f)): date, manner, and the recipients who are not served through CM/ECF.
#let certificate-of-service(s, sig) = block(breakable: false, above: pitch, {
  align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
  v(pitch * 0.5)
  par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent)[
    I HEREBY CERTIFY that on #s.date, a copy of the foregoing was served through #s.method, on the following:
  ]
  v(pitch * 0.5)
  for r in s.recipients {
    lines-stack((r.name, ..r.lines))
    v(pitch * 0.5)
  }
  v(pitch * 0.5)
  grid(columns: (1fr, 2.8in), [], lines-stack(("/s/ " + sig.signer, sig.signer, ..sig.address, "Phone: " + sig.phone, "Email: " + sig.email)))
})

#let dcb-motion-brief(meta, body-md) = {
  set page(
    paper: "us-letter",
    margin: (top: margin, bottom: margin, left: margin, right: margin),
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  show heading: it => heading-style(it)
  cover(meta)
  body(body-md)
  signature-block(meta.signature)
  certificate-of-service(meta.service, meta.signature)
}
