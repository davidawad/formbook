// United States District Court, Middle District of Florida: motion with legal memorandum (Local Rules 1.08, 3.01).
// Rule-driven and content-agnostic. No case-specific text, no coordinates measured off any filed brief, no forced
// line breaks. The body is markdown rendered by cmarker; the metadata is the YAML frontmatter of the same sample
// file (schema: ../README.md, "Markdown contract"). Rule IDs (FLMD-...) refer to ../rules.md.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // FLMD-FORM-004: Times New Roman, allowed by LR 1.08(b) at 14 point (the house face; docs/FONTS.md: Liberation Serif is its metric twin). The filed exemplar sets Book Antiqua, LR 1.08(a).
#let type-size = 14pt              // FLMD-FORM-003/004: Times New Roman main text at least 14-point (1.08(b)); quotations at least 13, footnotes 12: all text here is 14.
#let page-margin = 1in             // FLMD-FORM-002: 1 inch on all sides.
#let para-indent = 0.5in           // first-line indent of body paragraphs.
#let caption-w = 2.9in             // width of the party column of the caption; the case number column must hold "CASE NO.: 8:26-cv-02634-SDM-AEP" on one line.
#let caption-gutter = 0.25in       // between the party column and the case-number column.
#let designation-indent = 0.5in    // a party's designation ("Plaintiffs,") stands half an inch in.
#let case-number-drop = 0.5in      // the case number stands half an inch below the top of the caption.
#let item-indent = 0.5in           // lettered items: the label half an inch in,
#let item-label = 0.4in            // the text a label box after it.
#let quote-indent = 0.5in          // indented quotations: half an inch in from both margins.
#let sig-indent = 3in              // the signature block's left edge.

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 16.1pt                 // FLMD-FORM-003: single-spaced lines: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single       // FLMD-FORM-003: main text double-spaced (2.0; 32.2 pt)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flmd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (party names, case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Markdown chunk (heading, list or paragraph), with `#` as level 1.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// A body paragraph at the double pitch, with or without the first-line indent.
#let body-par(indent, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: if indent { para-indent } else { 0pt }, all: true), content))

// ---------------------------------------------------------------------------
// Caption and cover (FRCP 10(a): court, title, file number, Rule 7(a) designation)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  line-block(align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")))
  line-block(align(center, text(weight: "bold", "MIDDLE DISTRICT OF FLORIDA")))
  if "division" in meta and meta.division != none {
    line-block(align(center, text(weight: "bold", upper(meta.division))))
  }
}

/// Party column: names, then the designation (indented); "v." between the parties; a closing rule. The case
/// number column at the right.
#let caption(meta) = block(width: 100%, above: pitch-double, below: 0pt, grid(
  columns: (caption-w, 1fr),
  column-gutter: caption-gutter,
  {
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block(inl(meta.caption.at("versus", default: "v."))) }
      for n in p.names { line-block(inl(n)) }
      line-block(pad(left: designation-indent, inl(p.designation)))
    }
    line-block("_" * 29 + "/")   // fits the party column (29 underscores and the slash: 207 pt of 208.8)
  },
  pad(top: case-number-drop, line-block("CASE NO.: " + meta.case_number)),
))

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  block(width: 100%, above: pitch-double, below: pitch-single,
    line-block(align(center, text(weight: "bold", inl(meta.brief_title)))))
}

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, lists
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of markdown is one unit:
///   `#` heading            centered bold (levels 1 and 2); bold, left (level 3); bold italic (level 4)
///   `1.` list              items lettered (a), (b), ...
///   `>` quotation          indented, single-spaced
///   `~ text`               a paragraph with no first-line indent (certificate lines, signature lines)
///   any other text         a body paragraph with a first-line indent (not numbered: M.D. Fla. memoranda are not)
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") or t.starts-with(">") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      pad(left: item-indent, md(t))
    } else if t.starts-with("~ ") {
      body-par(false, inl(t.slice(2)))
    } else {
      body-par(true, md(t))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature (Fed. R. Civ. P. 11(a): signed by counsel of record) and certificates
// ---------------------------------------------------------------------------

/// One unbreakable block: "Respectfully submitted," never ends a page apart from the signature. The firm, each
/// counsel and the address single-spaced at the signature indent, a single line between the groups.
#let signature-block(meta) = block(width: 100%, above: pitch-single, below: 0pt, breakable: false, {
  line-block(pad(left: para-indent, [Respectfully submitted,]))
  pad(left: sig-indent, {
    let groups = (meta.signature.firm,) + meta.signature.counsel
    groups.push(meta.signature.address + (meta.signature.at("for", default: ""),))
    for g in groups {
      for (k, l) in g.enumerate() { line-block(above: if k == 0 { pitch-single } else { 0pt }, inl(l)) }
    }
  })
})

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let flmd-motion-brief(meta, body) = {
  // The certificate of service is written last in the sample; it is printed after the signature block.
  let parts = body.split("# CERTIFICATE OF SERVICE")
  let main = parts.at(0)
  let cert = if parts.len() > 1 { "# CERTIFICATE OF SERVICE" + parts.at(1) } else { none }

  set page(
    paper: "us-letter",
    margin: page-margin,
    footer-descent: 30%,
    footer: context {
      // FLMD-FORM-005: bottom center; no number is needed on page one. The number in a single-spaced line box,
      // so it sits where Word's footer sets it.
      let n = counter(page).get().first()
      if n > 1 { align(center, text(..edges(pitch-single), str(n))) }
    },
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (FLMD-FORM-003: double-spaced); lettered items as a label box with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: item-label)
  // A doubled section sign or pilcrow stays with its number too ("¶¶ 24-39"; xengine binds a single sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  set enum(numbering: "(a)")
  // FLMD-FORM-003: indented quotations single-spaced, half an inch in from both margins, a single line below.
  show quote.where(block: true): it => block(width: 100%, above: 0pt, below: pitch-single,
    pad(left: quote-indent, right: quote-indent, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      it.body
    }))

  // Headings at the body size and pitch, bold; levels 1 and 2 centered, 3 at the margin, 4 italic; no space of
  // their own (the double pitch sets them off). Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level <= 2 { align(center, text(weight: "bold", it.body)) } else if it.level == 3 {
      text(weight: "bold", it.body)
    } else { text(weight: "bold", style: "italic", it.body) }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
  }

  cover(meta)

  if "lead_in" in meta and meta.lead_in != none { body-par(true, inl(meta.lead_in)) }

  body-chunks(main)

  signature-block(meta)

  if cert != none {
    // Unbreakable: the certificate moves to the next page whole, rather than leaving its signature alone.
    block(width: 100%, above: pitch-double, below: 0pt, breakable: false, body-chunks(cert))
  }
}
