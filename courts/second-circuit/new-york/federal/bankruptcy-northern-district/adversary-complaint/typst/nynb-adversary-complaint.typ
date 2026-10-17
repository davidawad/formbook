// Adversary complaint for the U.S. Bankruptcy Court, N.D.N.Y. (nynb).
// Rules: FRBP 7001 (adversary proceeding), 7003 (Fed. R. Civ. P. 3 applies), 7008(a) (Fed. R. Civ. P. 8 applies;
// jurisdiction must reference the bankruptcy case; statement of consent to final orders), 7010 (Fed. R. Civ. P. 10
// applies; caption substantially conforms to Official Form 416A), 9004(a)-(b) (legible; caption elements);
// LBR 9004-1(a) (form), (c) (caption), (d) (noncompliance). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")     // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; --ignore-system-fonts means no other substitute
#let type-size = 12pt                // LBR 9004-1(a)(1)(A): minimum 12-point, text and footnotes
#let pitch = 24pt                    // LBR 9004-1(a)(1)(B): double-spaced body (baseline pitch, measured)
#let page-w = 8.5in                  // LBR 9004-1(a)(2)(C): letter size
#let page-h = 11in
#let margin = 1in                    // LBR 9004-1(a)(2)(A): one-inch margin on all four sides
#let text-width = page-w - 2 * margin
#let body-leading = 1.345em          // 0.655em line box + 1.345em leading = 2.0em = 24 pt at 12 pt
#let single-leading = 0.5em          // 0.65em + 0.5em = 1.15em = 13.8 pt: caption, counsel, signature
#let para-indent = 0.5in             // first line of each numbered paragraph (FRCP 10(b))
#let caption-left = 3.4in            // width of the party column of the caption
#let caption-gutter = 0.25in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nynb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, section symbols, names with *et al.*).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced stack of lines (caption, counsel, signature).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Caption and cover (LBR 9004-1(c); FRBP 9004(b); FRBP 7010 / Official Form 416A)
// ---------------------------------------------------------------------------

#let counsel-block(meta) = if "counsel" in meta and meta.counsel != none {
  block(width: text-width, line-stack(meta.counsel))
  v(pitch)
}

#let court-title() = stack(dir: ttb, spacing: single-leading,
  align(center, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT")),
  align(center, text(weight: "bold", "NORTHERN DISTRICT OF NEW YORK")),
)

/// The bankruptcy caption: debtor on the left; case number and chapter on the right. Hearing
/// information, when the sample gives it, sits above the case number (LBR 9013-1(g)(1)).
#let bankruptcy-caption(meta) = {
  let debtor = (("In re:",) + meta.debtor.names + ("(" + meta.debtor.tin + ")",) + ("Debtor.",))
  grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt),
      line-stack(debtor)),
    block(inset: (left: 0.1in), line-stack(
      (if "hearing" in meta and meta.hearing != none {
        ("Hearing: " + meta.hearing.date, "Time: " + meta.hearing.time, "Location: " + meta.hearing.location)
      } else { () })
      + ("Case No. " + meta.case_number, "Chapter " + str(meta.chapter)))),
  )
}

/// The adversary caption: parties on the left; adversary number and the short title on the right
/// (LBR 9004-1(c): the adversary proceeding name and number; short title with the filing party).
#let adversary-caption(meta) = {
  let rows = ()
  for (k, p) in meta.adversary.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  grid(
    columns: (caption-left, 1fr),
    column-gutter: caption-gutter,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt),
      line-stack(rows)),
    block(inset: (left: 0.1in), line-stack(("Adv. Pro. No. " + meta.adversary.number,))),
  )
}

#let cover(meta) = {
  counsel-block(meta)
  court-title()
  v(pitch)
  bankruptcy-caption(meta)
  v(single-leading)
  adversary-caption(meta)
  v(pitch)
  align(center, text(weight: "bold", meta.title))
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (FRCP 10(b) via FRBP 7010), headings, prayer sub-items
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of markdown is one unit. A chunk starting with "#" is a heading (one
/// "#" centred, "##" flush left); a chunk starting with "(a)", "(b)", ... is an unnumbered sub-item; a chunk
/// starting with "%" is an unnumbered paragraph (a WHEREFORE clause); every other chunk is one numbered
/// paragraph. The first `preamble` chunks (frontmatter key, when given) are unnumbered; without it, the chunks
/// before the first heading are. Numbering is applied per chunk, not with a show rule.
#let body-content(body, preamble: none) = {
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = counter("nynb-para")
  let out = []
  // Paragraphs before the first heading are the unnumbered preamble; numbering starts at the first heading.
  let numbered = false
  // Typst puts leading between the lines of a paragraph, not after its last line, so every unit is followed by
  // one more leading: n lines then take n double-spaced pitches (24 pt each) and the next unit starts on the grid.
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    if preamble != none and i >= preamble { numbered = true }
    // A paragraph that leads into a lettered sub-item sticks to it (a lead-in is never left alone at a page foot).
    let leads-in = i + 1 < chunks.len() and chunks.at(i + 1).trim().starts-with(regex("^\\([a-z]\\)[ \\t]"))
    if t.starts-with("%") {
      out += block(width: text-width, breakable: true, sticky: leads-in, [#h(para-indent)#inl(t.slice(1).trim())])
      out += v(body-leading)
    } else if t.starts-with("#") {
      numbered = true
      let level = t.match(regex("^#+")).text.len()
      let words = t.slice(level).trim()
      out += v(pitch)
      if level == 1 {
        out += block(width: text-width, sticky: true, align(center, text(weight: "bold", inl(words))))
      } else {
        out += block(width: text-width, sticky: true, text(weight: "bold", inl(words)))
      }
      out += v(body-leading)
    } else if t.starts-with(regex("^\\([a-z]\\)[ \\t]")) {
      // Only the last prayer item is sticky: it stays with the signature block (no signature alone on a page).
      // The others may break across pages, as a prayer does in the filed exemplar.
      out += block(width: text-width, breakable: true, sticky: i + 1 == chunks.len(), inset: (left: 0.5in), inl(t))
      out += v(body-leading)
    } else if not numbered {
      out += block(width: text-width, breakable: true, [#h(para-indent)#inl(t)])
      out += v(body-leading)
    } else {
      out += block(width: text-width, breakable: true, sticky: leads-in, [
        #n.step()
        #h(para-indent)#context n.display().#h(0.25in)#inl(t)
      ])
      out += v(body-leading)
    }
  }
  out
}

// ---------------------------------------------------------------------------
// Signature block (FRBP 9011 signature; LBR 9011-1 and 9011-3 are author duties, not rendered)
// ---------------------------------------------------------------------------

#let signature(meta) = block(width: text-width, breakable: false, {
  v(pitch)
  grid(
    columns: (3in, 1fr),
    column-gutter: caption-gutter,
    [Dated: #meta.dated],
    line-stack(("Respectfully submitted,",) + meta.signature.firm + ("",
      "By: /s/ " + meta.signature.signer) + meta.signature.lines),
  )
})

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let nynb-adversary-complaint(meta, body) = {
  set document(title: meta.title)
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center + bottom,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us")
  cover(meta)
  body-content(body, preamble: meta.at("preamble", default: none))
  signature(meta)
}
