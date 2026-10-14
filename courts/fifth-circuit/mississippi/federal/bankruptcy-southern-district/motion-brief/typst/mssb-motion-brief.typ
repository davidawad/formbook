// Motion with memorandum (memorandum brief in support) for the U.S. Bankruptcy Court, S.D. Mississippi (mssb).
// Doc type: motion-brief. Rules: Fed. R. Bankr. P. 9013 (motions), 9004(b) (caption; 9004-1(b) docket reference),
// 9011 and Miss. Bankr. L.R. 9011-1(a) (signature); Miss. Bankr. L.R. 9013-1(a) (rules and statutes relied on),
// 9013-1(b) (service); 5005-1(a)(2)(G) (8 1/2 x 11, no smaller than 12 point, double-spaced; quotations and
// footnotes may be single-spaced), 5005-1(a)(2)(H)(i) (counsel identification), 5005-1(a)(2)(I) (titles in the
// caption), 5005-1(a)(2)(D)(i) (a proposed order is a separate attachment; see ../README.md). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/; the only serif family vendored (README.md, known gaps)
#let type-size = 12pt                   // 5005-1(a)(2)(G): no smaller than 12 point; footer and captions included
#let pitch = 24pt                       // 5005-1(a)(2)(G): double-spaced; one line of text is one pitch
#let page-w = 8.5in                     // 5005-1(a)(2)(G): 8 1/2 by 11 inches
#let page-h = 11in
#let margin = 1in                       // the rules set no margin; one inch is the usual minimum (README.md)
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // double spacing: 0.65em line box + 1.35em leading = 2.0em = 24 pt at 12 pt (measured in ../README.md)
#let single-leading = 0.5em             // single spacing for the caption, counsel block, quotations, footnotes and signature
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.6in               // width of the party column of the caption
#let signature-indent = 3.25in          // the signature block sits in the right half of the page

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mssb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, footnote-free text).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A block of single-spaced lines (caption names, counsel block, signature lines).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Fill whole double-spaced rows. Typst puts leading between lines, not after the last one, so a
/// paragraph's box is one leading short; rounding every block up to a multiple of `pitch` restores the gap
/// before the next block (the cand template does the same; see ../README.md).
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// A heading: whole rows, kept with the text after it, never left at the foot of a page.
#let heading-block(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, sticky: true, c)
}

// ---------------------------------------------------------------------------
// Rule checks: the frontmatter must carry what the rules require, or the build stops here.
// ---------------------------------------------------------------------------

#let check-meta(meta) = {
  assert("caption" in meta, message: "mssb-motion-brief: frontmatter needs caption (debtor, case_number, chapter, parties, adversary_number)")
  let c = meta.caption
  assert("case_number" in c and "chapter" in c and "adversary_number" in c and "debtor" in c, message: "mssb-motion-brief: caption needs debtor, case_number, chapter and adversary_number (FRBP 9004(b)(3))")
  assert(c.parties.len() == 2, message: "mssb-motion-brief: caption.parties needs exactly two entries (plaintiff, defendant)")
  assert("title" in meta and meta.title.len() > 0, message: "mssb-motion-brief: frontmatter needs title: every content of the paper goes in the caption (5005-1(a)(2)(I); FRBP 9004(b)(4))")
  assert("related_docket" in meta and meta.related_docket.len() > 0, message: "mssb-motion-brief: frontmatter needs related_docket: a paper that relates to a filed document states its docket number, (Dkt. # ___) (Miss. Bankr. L.R. 9004-1(b))")
  let s = meta.signature
  let lines = s.counsel
  assert(lines.any(l => l.contains("@")), message: "mssb-motion-brief: counsel needs an e-mail address (Miss. Bankr. L.R. 5005-1(a)(2)(H)(i))")
  assert(lines.any(l => l.contains("MS Bar") or l.contains("MSB") or l.contains("Bar #")), message: "mssb-motion-brief: counsel needs a Mississippi Bar number (Miss. Bankr. L.R. 5005-1(a)(2)(H)(i))")
  assert(lines.any(l => l.contains("Telephone") or l.contains("Phone")), message: "mssb-motion-brief: counsel needs a telephone number (Miss. Bankr. L.R. 5005-1(a)(2)(H)(i))")
  assert(lines.any(l => l.match(regex("^\\d+ ")) != none), message: "mssb-motion-brief: counsel needs a street address (Miss. Bankr. L.R. 5005-1(a)(2)(H)(i))")
}

// ---------------------------------------------------------------------------
// Cover: court name, caption (FRBP 9004(b)), title of the paper (5005-1(a)(2)(I)), docket reference (9004-1(b))
// ---------------------------------------------------------------------------

/// The caption: each block of names on the left; the case facts and the designation on the right.
#let caption(meta) = {
  let c = meta.caption
  let row(left, right) = grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    line-stack(left),
    right,
  )
  row(c.debtor.names, line-stack(("CASE NO. " + c.case_number, c.chapter)))
  v(pitch * 0.5)
  for (k, p) in c.parties.enumerate() {
    if k > 0 {
      v(pitch * 0.5)
      row(("V.",), line-stack(("ADV. PROC. NO. " + c.adversary_number,)))
      v(pitch * 0.5)
    }
    row(p.names, align(right, line-stack((p.designation,))))
  }
}

#let cover(meta) = {
  let court = ("**IN THE UNITED STATES BANKRUPTCY COURT**", "**FOR THE SOUTHERN DISTRICT OF MISSISSIPPI**")
  if "division" in meta and meta.division != none {
    court.push("**" + upper(meta.division) + "**")
  }
  align(center, line-stack(court))
  v(pitch)
  caption(meta)
  v(pitch * 0.5)
  align(center, line-stack(("**" + upper(meta.title) + "**", "(Dkt. # " + meta.related_docket + ")")))
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: text-width, {
  let s = meta.signature
  set par(leading: single-leading, spacing: 0pt, justify: false)
  v(pitch)
  s.date
  v(pitch)
  let party = if "party" in s and s.party != none { (s.party,) } else { () }
  pad(left: signature-indent, line-stack(party + ("/s/ " + s.signer,) + s.counsel))
})

/// Body chunks (blank-line separated markdown), none numbered (a memorandum brief):
///  - `#`, `##`, `###`: headings: level 1 centered caps (I., II. ...), level 2 bold at the left (A., B. ...),
///    level 3 bold italic; each kept with the chunk after it;
///  - `> ...`: a quotation, single-spaced and indented; not on-grid, since its lines are measured at their real width;
///  - a chunk with hard line breaks (an address block): single-spaced;
///  - anything else: a body paragraph with a first-line indent, double-spaced.
/// The signature block follows the text and keeps the last paragraph with it (no signature alone on a page).
/// The certificate of service starts a new page after the signature, as in the filing.
/// Footnote definitions (`[^n]: ...`) are passed to each chunk that renders, so typst numbers them in order.
#let body-text(body, meta) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let defs = chunks.filter(c => c.trim().starts-with("[^")).join("\n\n")
  let out = []
  let held = []
  let has-held = false
  let pending = []
  let has-pending = false
  let signed = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("[^") { continue }
    if t.starts-with("# CERTIFICATE") {
      // The held paragraph (the last piece of text) goes on the same page as the signature block.
      if has-held {
        out += block(breakable: false, width: text-width, { held; signature-block(meta) })
      } else {
        out += signature-block(meta)
      }
      has-held = false
      held = []
      signed = true
      out += pagebreak(weak: true)
    }
    let piece = none
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
      continue
    } else if t.starts-with(">") {
      piece = block(width: text-width, below: pitch * 0.5, pad(left: 0.75in, right: 0.5in, {
        show quote.where(block: true): it => {
          set par(leading: single-leading, spacing: single-leading * 2, first-line-indent: 0pt)
          it.body
        }
        cmarker.render(t, raw-typst: false, smart-punctuation: true)
      }))
    } else if t.contains("\\\n") {
      // Single-spaced address blocks: one blank line of space after each, so two blocks do not run together.
      piece = block(width: text-width, below: pitch * 0.5, {
        set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
        cmarker.render(t + "\n\n" + defs, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else {
      piece = on-grid({
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent)
        cmarker.render(t + "\n\n" + defs, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    }
    let full = if has-pending { block(breakable: true, width: text-width, { pending; piece }) } else { piece }
    // Hold each piece back by one, so a signature can take the piece before it.
    if has-held { out += held }
    held = full
    has-held = true
    pending = []
    has-pending = false
  }
  if pending != [] { out += block(breakable: false, width: text-width, pending) }
  if has-held { out += held }
  if not signed { out += signature-block(meta) }
  out
}

#let mssb-motion-brief(meta, body) = {
  check-meta(meta)

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered caps section; level 2 is a bold heading at the left; level 3 bold italic.
  show heading.where(level: 1): it => heading-block(align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => heading-block(text(size: type-size, weight: "bold", style: "italic", it.body))

  // Footnotes are single-spaced at the type size (5005-1(a)(2)(G)).
  show footnote.entry: set par(leading: single-leading)
  show footnote.entry: set text(size: type-size)

  cover(meta)
  body-text(body, meta)
}
