// Brief in support of a motion to dismiss for the U.S. District Court for the Eastern District of Arkansas (ared).
// Rules: E.D. Ark. Local Rule 7.2(a), (e) (a motion to dismiss is a separate pleading with a separate brief);
// Local Rule 5.5(a) (type not less than elite, double space, letter size, one side) and 5.5(c)(1) (signature
// block); Fed. R. Civ. P. 7(b), 11(a), 12(b)(6). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/word-compat.typ": word-compat

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // vendored in fonts/; no rule names a font (LR 5.5(a) sets only a minimum)
#let type-size = 12pt                   // LR 5.5(a): type not less than elite (12 cpi); 12 pt is the working equivalent
#let table-size = 11pt                  // tables only; the exemplar's chart is set smaller than body text (convention)
#let pitch = 24pt                       // LR 5.5(a): double space
#let page-w = 8.5in                     // LR 5.5(a): letter size
#let page-h = 11in
#let margin = 1in                       // no margin rule in LR 5.5; 1 inch on every side, as in the exemplar
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // EB Garamond's line box is 0.65em, so 1.35em gives a 24 pt baseline pitch at 12 pt
#let single-leading = 0.5em             // single spacing for the caption, headings, block quotations, tables, signature
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let quote-indent = 1in                 // block quotation: indented both sides, single-spaced (convention)
#let caption-left = 3.2in               // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ared-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics for case names and signals, for example).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Fill whole double-spaced lines: the block is rounded up to a multiple of `pitch`, so whatever follows
/// it stays on the same line grid.
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// Like on-grid, but the block is not fixed in height, so a long paragraph can break across pages. The
/// padding after it (weak, so it vanishes at the top of a page) brings the next line onto the grid.
#let on-grid-flow(c, weak: true) = context {
  let h = measure(width: text-width, c).height
  c
  v(calc.ceil(h / pitch) * pitch - h, weak: weak)
}

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number, centered, in the bottom margin.
#let footer-block() = {
  set text(size: 11pt)
  align(center, context counter(page).display())
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (no separate cover page)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  on-grid(align(center, "IN THE UNITED STATES DISTRICT COURT"))
  on-grid(align(center, "FOR THE EASTERN DISTRICT OF ARKANSAS"))
  if "division" in meta and meta.division != none {
    on-grid(align(center, upper(meta.division)))
  }
}

#let caption(meta) = on-grid(grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    // Each party: its names, then its designation; "v." between the parties.
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    line-stack(("Case No. " + meta.case_number,))
  }),
))

#let cover(meta) = {
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch * 0.5)
  on-grid(align(center, text(weight: "bold", inl(meta.brief_title))))
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: text-width, on-grid(grid(
  columns: (2.6in, 1fr),
  column-gutter: 0.2in,
  if "date" in meta and meta.date != none [Dated: #meta.date] else [],
  {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    v(pitch * 0.5)
    line-stack(meta.signature.firm)
    v(pitch * 0.5)
    line-stack(("/s/ " + meta.signature.signer,) + meta.signature.lines)
  },
)))

/// Brief body. Unlike a complaint, the paragraphs of a brief are not numbered. Each blank-line-separated
/// chunk of markdown is one of:
///   `# TEXT` ... heading level 1: numbered I., II., ... (a leading <!--unnumbered--> makes it unnumbered, e.g. CONCLUSION)
/// Brief body. Unlike a complaint, the paragraphs of a brief are not numbered. Each blank-line-separated
/// chunk of markdown is one of:
///   `# TEXT` ... heading level 1: numbered I., II., ... (a leading <!--unnumbered--> makes it unnumbered, e.g. CONCLUSION)
///   `## TEXT` ... heading level 2: lettered A., B., ...
///   `### TEXT` ... heading level 3: numbered 1., 2., ...
///   `| ... |` ... a pipe table: single-spaced, not indented
///   `> TEXT` ... a block quotation: single-spaced, indented both sides
///   `1. ...` ... a list (numbered (1), (2), ...)
///   anything else ... a body paragraph, double-spaced, first-line indent.
/// A heading is a sticky block: it stays on the page with the first line of the chunk after it.
/// Paragraphs break across pages like any text. The heading counters are plain variables in this
/// loop; numbers are not typed by the author. The value of each iteration is the chunk's content.
#let brief-body(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let h1 = 0
  let h2 = 0
  let h3 = 0
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      let title = t.slice(level).trim()
      let unnumbered = title.starts-with("<!--unnumbered-->")
      if unnumbered { title = title.slice("<!--unnumbered-->".len()).trim() }
      let heading = if level == 1 {
        if not unnumbered { h1 += 1; h2 = 0; h3 = 0 }
        on-grid(align(center, text(weight: "bold", if unnumbered {
          upper(inl(title))
        } else {
          [#numbering("I.", h1)#h(0.5in)#upper(inl(title))]
        })))
      } else if level == 2 {
        h2 += 1
        h3 = 0
        on-grid(grid(columns: (0.5in, 1fr), text(weight: "bold", numbering("A.", h2)), text(weight: "bold", inl(title))))
      } else {
        h3 += 1
        on-grid(grid(columns: (0.5in, 1fr), numbering("1.", h3), text(weight: "bold", style: "italic", inl(title))))
      }
      block(sticky: true, width: text-width, heading)
    } else if t.starts-with("|") {
      on-grid({
        set text(size: table-size)
        set par(leading: single-leading, spacing: 0pt, justify: false)
        cmarker.render(t, raw-typst: false, smart-punctuation: true)
      })
    } else if t.starts-with(">") {
      let quoted = t.split("\n").map(l => l.trim().replace(regex("^>\\s?"), "")).join(" ")
      on-grid({
        set par(leading: single-leading, spacing: 0pt, justify: true)
        pad(left: quote-indent, right: quote-indent, inl(quoted))
      })
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      // Items are spaced by body-leading, so each item fills whole double-spaced lines.
      {
        set par(leading: body-leading)
        set enum(numbering: "(1)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true)
        v(body-leading)
      }
    } else {
      let para = on-grid-flow({
        set par(leading: body-leading)
        h(para-indent)
        inl(t)
      }, weak: i != chunks.len() - 1)
      // The last paragraph stays with the signature block, so a signature never stands alone on a page.
      if i == chunks.len() - 1 { block(sticky: true, width: text-width, para) } else { para }
    }
  }
}

#let ared-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: margin, bottom: margin, left: margin, right: margin),
    footer: footer-block(),
    footer-descent: 0.35in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  // Word paragraph composition (lib/typst/word-compat.typ); the INPUT's `word:` map sets justify/shrink.
  show: word-compat.with(meta.at("word", default: (:)))

  cover(meta)

  brief-body(body)

  signature-block(meta)
}
