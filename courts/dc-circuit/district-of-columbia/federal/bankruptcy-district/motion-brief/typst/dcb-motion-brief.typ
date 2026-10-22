// Motion with memorandum for the United States Bankruptcy Court for the District of Columbia (dcb).
// Rules: Fed. R. Bankr. P. 9013 (written motion; grounds stated with particularity; relief requested),
// 9004(a) (legible) and 9004(b) (caption: court, title, case and adversary number, designation of the paper),
// Local Bankruptcy Rule 9013-1(b) (grounds, relief, optional memorandum), 9013-1(c) (notice of the motion,
// objection deadline and hearing, conforming substantially to Official Form B 420A), 9013-1(d) (response
// deadlines), 9013-1(f) (certificate of service with date, manner and recipients), LBR 5005-1(c) (attorney
// identifiers on the first page). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no D.C. Bankruptcy rule sets a face; vendored in fonts/ (README.md, gap 2)
#let type-size = 12pt                   // no D.C. Bankruptcy rule sets a size; 12 pt matches the exemplar's body (README.md, gap 2)
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let quote-indent = 0.5in               // block quotations indented from both margins; level-3 headings step in as far
#let margin = 1in                       // 1-inch margins on all sides (the exemplar; LBR 5005-1(b) for pro se papers)
#let caption-left = 3.3in               // width of the party column of the caption
#let caption-mid = 0.35in               // width of the ")" column
#let box-inset = 10pt                   // the notice box: its text stands this far inside the rule
#let sig-left = 2.8in                   // signature grid: the "Date" column, a gutter, the signature column
#let sig-gutter = 0.2in
#let cert-col = 2.8in                   // the certificate's signature column, at the right margin

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // double spacing: the exemplar's body lines are 27.6 pt apart (measured, README.md)

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

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// Single lines, the first with space above it.
#let line-group(above, items) = for (i, l) in items.enumerate() { line-block(above: if i == 0 { above } else { 0pt }, md(l)) }

// ---------------------------------------------------------------------------
// Cover: counsel block (upper left, LBR 5005-1(c)), court name, caption, title, notice
// ---------------------------------------------------------------------------

#let counsel-block(c) = {
  assert(c.email.contains("@"), message: "dcb-motion-brief: counsel.email is required (LBR 5005-1(c))")
  assert(c.represents.len() > 0, message: "dcb-motion-brief: counsel.represents is required (LBR 5005-1(c))")
  line-group(0pt, (c.name, c.firm, ..c.address, c.phone, c.email, ..c.represents))
}

#let court-title(meta) = for (i, l) in meta.court.enumerate() {
  line-block(above: if i == 0 { pitch-double } else { 0pt }, below: if i == meta.court.len() - 1 { pitch-single } else { 0pt },
    align(center, text(weight: "bold", l)))
}

/// The caption: parties on the left, a column of ")" marks, and the case numbers on the right (FRBP 9004(b)), one
/// grid row per line.
#let caption(meta) = {
  let c = meta.caption
  let left = c.debtor.names + (c.debtor.designation, "") + c.plaintiff.names + (c.plaintiff.designation, "vs.") + ("Adversary No. " + c.adversary_number,) + ("",) + c.defendant.names + (c.defendant.designation,)
  let right = range(left.len()).map(i => {
    if i == 0 { "In re:" } else if i == 1 { "Case No. " + c.case_number } else if i == 2 { "(Chapter " + c.chapter + ")" } else { "" }
  })
  block(below: pitch-single, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    grid(
      columns: (caption-left, caption-mid, 1fr),
      ..range(left.len()).map(i => (md(left.at(i)), align(center, ")"), md(right.at(i)))).flatten(),
    )
  })
}

/// Notice of motion, objection deadline and hearing (LBR 9013-1(c), (d)). A blank field prints a fill-in line.
#let notice-box(meta) = {
  let n = meta.notice
  let fill(s) = if s == "" { "________________" } else { s }
  block(width: 100%, stroke: 0.6pt, inset: box-inset, breakable: false, above: pitch-single, below: pitch-single, {
    line-block(align(center, text(weight: "bold", "NOTICE OF MOTION, OBJECTION DEADLINE, AND HEARING")))
    line-block(above: pitch-single)[Any response to this motion must be filed with the Court and served on the movant’s counsel no later than #emph[#fill(n.response_deadline)]. If no response is timely filed, the Court may grant the relief requested without a hearing. A hearing on this motion is set for #emph[#fill(n.hearing)].]
  })
}

#let cover(meta) = {
  counsel-block(meta.counsel)
  court-title(meta)
  caption(meta)
  line-block(align(center, text(weight: "bold", meta.title)))
  notice-box(meta)
}

// ---------------------------------------------------------------------------
// Body: paragraphs, headings, block quotations, signature, certificate of service
// ---------------------------------------------------------------------------

/// Body text: each blank-line-separated chunk is a heading, a block quotation (">", single-spaced, indented from
/// both margins, a single line above and below) or a paragraph (double-spaced, first-line indented).
#let body(text-md) = {
  for c in text-md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(">") {
      line-block(above: pitch-single, below: pitch-single, pad(x: quote-indent, md(t.slice(1).trim())))
    } else {
      block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), md(t)))
    }
  }
}

/// The signature block: "Date" at the left; "Respectfully submitted,", the firm and the signer's lines at the right.
#let signature-block(s) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
  columns: (sig-left, 1fr),
  column-gutter: sig-gutter,
  line-block[Date: #s.date],
  {
    line-group(0pt, ("Respectfully submitted,", s.firm))
    line-group(pitch-single, ("/s/ " + s.signer, s.signer, ..s.address, "Phone: " + s.phone, "Email: " + s.email, ..s.role))
  },
))

/// Certificate of service (LBR 9013-1(f)): date, manner, and the recipients who are not served through CM/ECF. On
/// one page.
#let certificate-of-service(s, sig) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  line-block(below: pitch-single, align(center, text(weight: "bold", "CERTIFICATE OF SERVICE")))
  block(width: 100%, above: 0pt, below: pitch-single, par(first-line-indent: (amount: para-indent, all: true))[
    I HEREBY CERTIFY that on #s.date, a copy of the foregoing was served through #s.method, on the following:
  ])
  for r in s.recipients { line-group(pitch-single, (r.name, ..r.lines)) }
  block(width: 100%, above: pitch-double, below: 0pt, grid(columns: (1fr, cert-col), [],
    line-group(0pt, ("/s/ " + sig.signer, sig.signer, ..sig.address, "Phone: " + sig.phone, "Email: " + sig.email))))
})

#let dcb-motion-brief(meta, body-md) = {
  // The page number: centered in a single-spaced line box, at the same place on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // Headings: single-spaced, a single line above and below, kept with the text after them; level 1 centered bold,
  // level 2 bold, level 3 bold italic, a step in.
  show heading: it => block(sticky: true, width: 100%, above: pitch-single, below: pitch-single, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    if it.level == 1 { align(center, text(weight: "bold", it.body)) } else if it.level == 2 {
      text(weight: "bold", it.body)
    } else { pad(left: quote-indent, text(weight: "bold", style: "italic", it.body)) }
  })
  cover(meta)
  body(body-md)
  signature-block(meta.signature)
  certificate-of-service(meta.service, meta.signature)
}
