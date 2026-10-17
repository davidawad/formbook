// Adversary complaint for the U.S. Bankruptcy Court, S.D. Mississippi (mssb). Doc type: adversary-complaint.
// Rules: Fed. R. Bankr. P. 7001, 7008(a) (consent statement; jurisdiction allegation), 7010 (Fed. R. Civ. P. 10
// applies: numbered paragraphs, 10(b)), 9004(b) (caption); Miss. Bankr. L.R. 5005-1(a)(2)(G) (8 1/2 x 11, no
// smaller than 12 point, double-spaced), 5005-1(a)(2)(H)(i) (counsel identification), 5005-1(a)(2)(I) (titles),
// 7008-1 (consent statement). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // 5005-1(a)(2)(G): no smaller than 12 point; footer and captions included
#let pitch = 24pt                       // 5005-1(a)(2)(G): double-spaced; one line of text is one pitch
#let page-w = 8.5in                     // 5005-1(a)(2)(G): 8 1/2 by 11 inches
#let page-h = 11in
#let margin = 1in                       // the rules set no margin; one inch is the usual minimum (README.md)
#let text-width = page-w - 2 * margin
#let body-leading = 1.345em             // double spacing: 0.655em line box + 1.345em leading = 2.0em = 24 pt at 12 pt (measured in ../README.md)
#let single-leading = 0.495em            // single spacing for caption, counsel block, tables and signature
#let para-indent = 0.5in                // first-line indent of numbered paragraphs and unnumbered lead-ins
#let caption-left = 3.6in               // width of the party column of the caption
#let signature-indent = 3.25in          // the signature block sits in the right half of the page

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mssb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with &, *et al.*, footnote-free text).
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
  assert("caption" in meta, message: "mssb-adversary-complaint: frontmatter needs caption (debtor, case_number, chapter, parties, adversary_number)")
  let c = meta.caption
  assert("case_number" in c and "chapter" in c and "adversary_number" in c and "debtor" in c, message: "mssb-adversary-complaint: caption needs debtor, case_number, chapter and adversary_number (FRBP 9004(b)(3); 7008(a) requires the bankruptcy case reference)")
  assert(c.parties.len() == 2, message: "mssb-adversary-complaint: caption.parties needs exactly two entries (plaintiff, defendants)")
  assert("title" in meta and meta.title.len() > 0, message: "mssb-adversary-complaint: frontmatter needs title (FRBP 9004(b)(4); 5005-1(a)(2)(I))")
  assert("consent" in meta and meta.consent.len() > 0, message: "mssb-adversary-complaint: frontmatter needs consent (FRBP 7008(a); Miss. Bankr. L.R. 7008-1)")
  let s = meta.signature
  let lines = s.counsel
  assert(lines.any(l => l.contains("@")), message: "mssb-adversary-complaint: counsel needs an e-mail address (Miss. Bankr. L.R. 5005-1(a)(2)(H)(i))")
  assert(lines.any(l => l.contains("MSB") or l.contains("Bar")), message: "mssb-adversary-complaint: counsel needs a Mississippi Bar number (Miss. Bankr. L.R. 5005-1(a)(2)(H)(i))")
  assert(lines.any(l => l.contains("Telephone") or l.contains("Phone")), message: "mssb-adversary-complaint: counsel needs a telephone number (Miss. Bankr. L.R. 5005-1(a)(2)(H)(i))")
  assert(lines.any(l => l.contains("Pass") or l.contains("Street") or l.contains("Avenue") or l.contains("Drive") or l.contains("Suite") or l.contains("Road") or l.contains("Boulevard") or l.contains("Place") or l.contains("Capitol") or l.contains("Broadway")), message: "mssb-adversary-complaint: counsel needs a street address (Miss. Bankr. L.R. 5005-1(a)(2)(H)(i))")
}

// ---------------------------------------------------------------------------
// Cover: court name, caption (FRBP 9004(b)), title of the paper (5005-1(a)(2)(I))
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
  align(center, text(weight: "bold", upper(meta.title)))
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
  pad(left: signature-indent, {
    [Respectfully submitted,]
    v(pitch * 0.5)
    line-stack(("/s/ " + s.signer, s.signer, s.role) + s.counsel)
  })
})

/// Body chunks (blank-line separated markdown):
///  - `#`, `##`, `###`: headings (centered caps, centered bold, bold italic left), kept with the next chunk;
///  - `- item`: lettered sub-items (a), (b), ...; a sub-list may break across pages;
///  - `| row |`: a table, single-spaced, not numbered;
///  - `WHEREFORE` / `COMES NOW`: unnumbered lead-in paragraphs;
///  - anything else: a numbered paragraph (Fed. R. Civ. P. 10(b)).
/// Footnote definitions (`[^n]: ...`) are passed to each chunk that renders, so typst numbers them in order.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let defs = chunks.filter(c => c.trim().starts-with("[^")).join("\n\n")
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("[^") { continue }
    let piece = none
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
      continue
    } else if t.starts-with("- ") {
      let items = t.split("\n").filter(l => l.trim().starts-with("- "))
      piece = {
        set par(leading: body-leading, first-line-indent: 0pt)
        for (i, l) in items.enumerate() {
          on-grid(grid(
            columns: (1in, 1fr),
            pad(left: 0.5in, numbering("(a)", i + 1)),
            cmarker.render(l.trim().slice(2), raw-typst: false, smart-punctuation: true),
          ))
        }
      }
    } else if t.starts-with("|") {
      // Not on-grid: the table is indented and measured at its real width (see the motion template).
      piece = block(width: text-width, below: pitch * 0.5, pad(left: 1in, {
        set par(leading: single-leading, spacing: 0pt)
        set table(stroke: none, inset: (x: 0.12in, y: 2pt))
        cmarker.render(t, raw-typst: false, smart-punctuation: true)
      }))
    } else if t.starts-with("WHEREFORE") or t.starts-with("COMES NOW") {
      piece = on-grid({
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent)
        cmarker.render(t + "\n\n" + defs, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else {
      para-counter.step()
      piece = on-grid({
        set par(leading: body-leading, first-line-indent: 0pt)
        context {
          h(para-indent)
          para-counter.display("1.")
          h(0.3in)
          cmarker.render(t + "\n\n" + defs, raw-typst: false, smart-punctuation: true, h1-level: 1)
        }
      })
    }
    if has-pending {
      block(breakable: false, width: text-width, { pending; piece })
    } else {
      piece
    }
    pending = []
    has-pending = false
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let mssb-adversary-complaint(meta, body) = {
  check-meta(meta)
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered caps section; level 2 a centered bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => heading-block(align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => heading-block(text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)
  v(pitch)

  if "lead_in" in meta and meta.lead_in != none {
    on-grid({
      set par(leading: body-leading, first-line-indent: 0pt)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  // Consent statement (FRBP 7008(a); Miss. Bankr. L.R. 7008-1): an unnumbered paragraph after the lead-in.
  on-grid({
    set par(leading: body-leading, first-line-indent: 0pt)
    h(para-indent)
    inl(meta.consent)
  })

  // Body: numbered paragraphs; lettered sub-items; headings unnumbered.
  allegations(body, para-counter)

  signature-block(meta)
}
