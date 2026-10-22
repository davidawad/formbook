// Complaint for the U.S. District Court for the Western District of Missouri (mowd).
// Rules: Fed. R. Civ. P. 8(a) and 10 (caption, numbered paragraphs), 5.2 (privacy redaction, by the author);
// W.D. Mo. L.R. 3.1 (civil cover sheet) and 3.2 (divisional venue), 7.1 (certificate of interest): separate filings.
// The local rules set no typeface, margin or spacing rule for this court; the choices below are conventions
// and are recorded in ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // vendored in fonts/; no face in the local rules, the exemplar's face
#let type-size = 12pt                   // no size in the local rules; the Johnson exemplar's Times New Roman 12 pt
#let para-indent = 0.5in                // first-line indent; the paragraph number's box after it
#let item-indent = 0.5in                // lettered items: the letter half an inch in, the text a box after it
#let quote-indent = 0.5in               // block quotations: indented from both margins
#let margin = 1in                       // all four margins (no rule in the local rules; the exemplars use 1 inch)
#let caption-left = 3.25in              // width of the party column of the caption
#let caption-gutter = 0.25in
#let sig-left = 2.6in                   // signature grid: the "Dated" column, a gutter, the signature column
#let sig-gutter = 0.2in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size; caption, quotations, signature
#let pitch-double = 2 * pitch-single    // double spacing (the exemplar's)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mowd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  line-block(align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")))
  line-block(align(center, text(weight: "bold", "FOR THE WESTERN DISTRICT OF MISSOURI")))
  if "division" in meta and meta.division != none {
    line-block(align(center, text(weight: "bold", upper(meta.division))))
  }
}

#let caption(meta) = block(above: pitch-double, below: pitch-double, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  {
    // Each party: its names, then its designation; "v." between the parties.
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block("v.") }
      for n in p.names { line-block(inl(n)) }
      line-block(inl(p.designation))
    }
  },
  {
    line-block[Case No. #meta.case_number]
    line-block(above: pitch-single, text(weight: "bold", inl(meta.title)))
    if "jury_demand" in meta and meta.jury_demand {
      line-block(above: pitch-single, text(weight: "bold", "JURY TRIAL DEMANDED"))
    }
  },
))

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Signature block: date at the left, "Respectfully submitted" and the signer at the right; one block per firm, a
/// single line apart. It never breaks across a page.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  let sig = meta.signature
  grid(
    columns: (sig-left, 1fr),
    column-gutter: sig-gutter,
    line-block[Dated: #sig.date],
    {
      line-block[Respectfully submitted,]
      line-block(above: pitch-single, text(weight: "bold", inl(sig.signer)))
      for (k, firm) in sig.blocks.enumerate() {
        for (i, l) in firm.enumerate() { line-block(above: if k > 0 and i == 0 { pitch-single } else { 0pt }, inl(l)) }
      }
    },
  )
})

/// A body paragraph at the double pitch: unnumbered (first-line indent) or numbered (Fed. R. Civ. P. 10(b): the
/// number in a box of the paragraph indent after the first-line indent, the text after it). `keep`: kept on the
/// page of the block after it (the last paragraph stays with the signature block).
#let body-par(num, content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep, if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: para-indent, [#num.])#content])
})

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither
/// a heading, a list, a quotation nor the WHEREFORE lead-in is one numbered paragraph.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let num = 0
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(">") {
      // Block quotation: indented from both margins and single spaced (the class definition in the sample).
      block(width: 100%, above: 0pt, below: pitch-single, pad(x: quote-indent, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        md(t.replace(regex("(?m)^>[ \\t]?"), ""))
      }))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list: lettered A., B., ... by the template, the letter half an inch in.
      pad(left: item-indent, md(t))
    } else if t.starts-with("WHEREFORE") {
      // The prayer's lead-in is an unnumbered paragraph (the exemplar's "WHEREFORE" line); see README.md.
      body-par(none, md(t), keep: last)
    } else {
      num += 1
      body-par(num, md(t), keep: last)
    }
  }
}

#let mowd-complaint(meta, body) = {
  // Page numbers centered, arabic, on every page; the number in a single-spaced line box, so it sits at the same
  // place on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double spaced); lists as a label box (item-indent) with the text hanging.
  show: xengine.with(pitch: pitch-double, list-indent: item-indent)
  // A web address breaks only after "?", "=", "&", a hyphen or a slash that no digit (nor a second slash) follows:
  // each part is a box, so the PDF text keeps the author's characters. Without this typst breaks a URL at any
  // character, which Word does not (the docx filter sets the same break points; ca8 briefs).
  show regex("(https?://|www\\.)\\S+"): it => {
    let parts = ("",)
    let cs = it.text.clusters()
    for (i, c) in cs.enumerate() {
      parts.last() += c
      let next = cs.at(i + 1, default: "")
      let prev = cs.at(i - 1, default: "")
      if c in ("?", "=", "&") or (c in ("/", "-") and next != "/" and not (c == "/" and prev == "/")
        and next.match(regex("^[0-9]$")) == none) { parts.push("") }
    }
    parts.filter(p => p != "").map(p => box(p)).join()
  }

  // Headings at the body size and pitch, bold: level 1 centered capitals; level 2 centered; level 3 at the margin.
  // No space of their own (the double pitch sets them off); sticky, so a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      align(center, text(weight: "bold", it.body))
    } else { text(weight: "bold", it.body) }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
  }
  // Lists: lettered A., B., ... (the markdown numbers are not printed).
  set enum(numbering: "A.")

  court-title(meta)
  caption(meta)
  allegations(body)
  signature-block(meta)
}
