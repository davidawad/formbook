// Complaint for the U.S. District Court for the Southern District of Alabama (alsd).
// Rules: S.D. Ala. Gen. L.R. 5(a) (8 1/2 x 11 paper, double spacing, margins of at least 1 inch, plain roman
// font of 12 point or larger, counsel's name, address and telephone under the signature line), Civ. L.R. 10(a)
// (numbered paragraphs, one set of circumstances each), Fed. R. Civ. P. 10(a) and (b). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Gen. L.R. 5(a)(2): plain roman font; Times New Roman substitute per docs/FONTS.md
#let type-size = 12pt                   // Gen. L.R. 5(a)(2): 12 point or larger, footer included
#let margin = 1in                       // Gen. L.R. 5(a)(1): at least 1 inch on all four sides
#let para-indent = 0.5in                // first-line indent of numbered paragraphs; the number's box after it
#let item-indent = 0.5in                // lettered items: the label stands half an inch in
#let item-label = 0.4in                 // the label's box; the item text hangs after it
#let quote-indent = 0.5in               // block quotations, indented on both sides
#let caption-party-w = 3.2in            // width of the party column of the caption
#let caption-paren-w = 0.3in            // the column of ")" marks
#let signature-indent = 3.0in           // signature block sits in the right half of the page

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // Gen. L.R. 5(a)(1): double-spaced text (twice the type size)
#let pitch-single = 13.8pt              // headings, caption, quotations, counsel and signature lines: 1.15 x the type size

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("alsd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in *italics*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  for l in ("IN THE UNITED STATES DISTRICT COURT", "FOR THE SOUTHERN DISTRICT OF ALABAMA", upper(meta.division)) {
    line-block(align(center, text(weight: "bold", l)))
  }
}

/// Party column, a column of ")" marks, and the case number on the middle line (the S.D. Ala. form); one row per
/// line.
#let caption(meta) = {
  let rows = ()
  let n = meta.caption.parties.len()
  for (k, p) in meta.caption.parties.enumerate() {
    for name in p.names { rows.push(name) }
    rows.push(p.designation)
    if k < n - 1 {
      rows.push("")
      rows.push("v.")
      rows.push("")
    }
  }
  let mid = calc.floor(rows.len() / 2)
  let cells = rows.enumerate().map(((i, r)) => (
    line-block(inl(r)),
    line-block[)],
    line-block(if i == mid [Civil Action No. #meta.case_number] else []),
  )).flatten()
  block(above: pitch-double, below: 0pt, grid(columns: (caption-party-w, caption-paren-w, 1fr), ..cells))
}

#let cover(meta) = {
  court-title(meta)
  caption(meta)
  line-block(above: pitch-double, align(center, text(weight: "bold", inl(meta.brief_title))))
  if "jury_demand" in meta and meta.jury_demand {
    line-block(above: pitch-single, align(center, text(weight: "bold", "JURY TRIAL DEMANDED")))
  }
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Signature block (Gen. L.R. 5(a)(3)): signature line, then name, address and telephone of each attorney; it
/// never breaks across a page.
#let signature-block(meta) = block(breakable: false, width: 100%, above: pitch-double, below: 0pt, {
  line-block[Dated: #meta.date]
  line-block(above: pitch-double, indent: signature-indent)[Respectfully submitted,]
  for (k, lines) in meta.signature.blocks.enumerate() {
    for (j, l) in lines.enumerate() {
      line-block(above: if j == 0 { if k == 0 { pitch-double } else { pitch-single } } else { 0pt },
        indent: signature-indent, inl(l))
    }
  }
})

/// A body paragraph at the double pitch: numbered (the number in a box after the first-line indent), or not.
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt, if num == none {
  par(first-line-indent: 0pt, content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: para-indent, [#num.])#content])
})

/// Numbered paragraphs (Civ. L.R. 10(a); Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown
/// that is neither a heading, a list, a quotation, a bracketed record cite nor a WHEREFORE clause is one numbered
/// paragraph. Numbering is applied per chunk (not with a `show par` rule, which recurses without end).
#let allegations(body) = {
  let n = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lettered (a), (b) ...; the label half an inch in, the text hanging after it.
      pad(left: item-indent, md(t))
    } else if t.starts-with(">") {
      // A quotation of contract text: single-spaced (Gen. L.R. 5(a)(1)), indented on both sides, a single line
      // off the text above and below.
      let q = t.split("\n").map(l => l.trim().trim(">", at: start).trim()).join("\n")
      block(width: 100%, above: pitch-single, below: pitch-single, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        pad(left: quote-indent, right: quote-indent, md(q))
      })
    } else if t.starts-with(regex("^(\\[|WHEREFORE)")) {
      // Not numbered: a bracketed record cite ("[Indemnity Agreement, ¶ 3].") or a prayer lead-in.
      body-par(none, md(t))
    } else {
      n += 1
      body-par(n, md(t))
    }
  }
}

#let alsd-complaint(meta, body) = {
  // Page numbers centered, arabic, at the type size (Gen. L.R. 5(a)(2)), in a single-spaced line box.
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (Gen. L.R. 5(a)(1): double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: item-label)
  // A doubled sign stays with its number ("§§ 157"), as the Word filter binds it (xengine binds one sign).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  set enum(numbering: "(a)")

  // Headings at the type size and the body pitch: level 1 a centered section in capitals, level 2 a centered
  // bold sub-heading, level 3 bold italic at the left; no space of their own. Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      align(center, text(weight: "bold", it.body))
    } else { text(weight: "bold", style: "italic", it.body) }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
  }

  cover(meta)
  if "lead_in" in meta {
    block(above: pitch-single, below: 0pt, par(first-line-indent: (amount: para-indent, all: true), inl(meta.lead_in)))
  }
  allegations(body)
  signature-block(meta)
}
