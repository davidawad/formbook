// Complaint for the United States District Court for the District of Minnesota.
// Rules: Fed. R. Civ. P. 8(a) (short and plain statement; jurisdiction, claim, demand for relief),
// 10(a) (caption: court, title, file number, parties), 10(b) (numbered paragraphs), 38(b) (jury demand);
// D. Minn. LR 5.2(a) (double-spaced, pages numbered at the bottom). The case-initiating document carries
// no judge initials (LR 5.2(a) applies to documents filed after it). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // vendored in fonts/; the complaint has no type-size rule in the local rules
#let type-size = 13pt                   // D. Minn. LR 7.1(h)(1) sets 13 point for memoranda; used here too (open choice, see README.md)
#let page-w = 8.5in                     // LR 5.2(a) and Fed. R. Civ. P. 10: letter paper, numbered pages
#let page-h = 11in
#let margin = 1in
#let text-width = page-w - 2 * margin
#let body-leading = 1.65em              // double spacing (LR 5.2(a)): 0.65em natural line + 1.65em = 2.3em
#let single-leading = 0.5em             // headings and caption: 1.15em
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let court-lines = ("UNITED STATES DISTRICT COURT", "DISTRICT OF MINNESOTA")  // the court's name, not the case's

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mnd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for case names and party names).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item: each item is a paragraph, and the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Front page: court name, caption (party column; file number and title), then the body
// ---------------------------------------------------------------------------

#let court-title() = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  align(center, stack(dir: ttb, spacing: single-leading, ..court-lines.map(l => text(weight: "bold", l))))
}

#let caption(meta) = grid(
  columns: (3.3in, 1fr),
  column-gutter: 0.3in,
  block(width: 3.3in, stroke: (top: 0.75pt, bottom: 0.75pt), inset: (top: 8pt, bottom: 8pt), {
    // Each party: its names, then its designation, indented; "v." between the parties.
    let rows = ()
    for (k, p) in meta.caption.enumerate() {
      if k > 0 { rows.push(block(width: 100%, inset: (left: 0.3in), [v.])) }
      rows.push(line-stack(p.names))
      rows.push(block(width: 100%, inset: (left: 1.2in), inl(p.designation)))
    }
    set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
    stack(dir: ttb, spacing: single-leading, ..rows)
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
    // A complaint is filed before a case number is assigned: the file number is left blank for the clerk.
    let number = if meta.case_number == "" { "____________________" } else { meta.case_number }
    [Civil No. #number]
    v(body-leading)
    align(center, text(weight: "bold", upper(meta.brief_title)))
  }),
)

#let front-page(meta) = {
  court-title()
  v(body-leading)
  caption(meta)
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)); headings; lettered prayer items; signature
// ---------------------------------------------------------------------------

/// Signature block: the date on the left, the firm and signer on the right (single-spaced).
#let signature-block(meta) = block(width: 100%, breakable: false, {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    line-stack(meta.signature.map(l => if l == "" { "\u{00A0}" } else { l })),
  )
})

/// The body, one chunk (blank-line separated) at a time. A heading or lettered item is set as itself;
/// every other chunk is a numbered allegation, except the lead-in, the jury demand and the prayer.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let numbered = false
  let n = 0
  let out = ()
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // The jury demand and the prayer are not numbered; the counts and the parties are.
      let head = t.split("\n").first()
      if head.starts-with("# DEMAND") or head.starts-with("# PRAYER") {
        numbered = false
      } else if head.starts-with("# ") {
        numbered = true
      }
      out.push(cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
    } else if t.starts-with(regex("^[A-Z][.)][ \t]")) {
      // A lettered item of the prayer: hanging from the letter, not numbered.
      let m = t.match(regex("^([A-Z][.)])[ \t]+([\\s\\S]*)$"))
      out.push(pad(left: 0.5in, grid(
        columns: (0.4in, 1fr),
        column-gutter: 0.1in,
        [#m.captures.at(0)],
        block(width: 100%, {
          set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: true)
          cmarker.render(m.captures.at(1), raw-typst: false, smart-punctuation: true, h1-level: 1)
        }),
      )))
    } else if numbered {
      n += 1
      out.push({
        set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: true)
        [#h(para-indent)#n.#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
      })
    } else {
      out.push({
        set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: true)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    }
  }
  out.join()
}

#let mnd-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: margin, bottom: margin, left: margin, right: margin),
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: true)

  // Headings: level 1 centred, bold, capitals as written (PARTIES, COUNT I: ...); level 2 centred and bold
  // (the statute under which a count is brought). Both kept with the paragraph after them.
  show heading.where(level: 1): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 2): it => block(width: 100%, above: body-leading, below: body-leading, sticky: true,
    align(center, text(size: type-size, weight: "bold", it.body)))

  front-page(meta)
  if "lead_in" in meta {
    par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: true, inl(meta.lead_in))
  }
  body-chunks(body)
  v(body-leading)
  signature-block(meta)
}
