// U.S. Bankruptcy Court, Northern District of Illinois: adversary complaint (Fed. R. Bankr. P. 7001, 7010).
//
// Rule-driven and content-agnostic. Requirement IDs (ILNB-...) refer to ../README.md, which quotes the rule
// text: Fed. R. Bankr. P. 7010 (caption and form of pleadings), 9004(b); Fed. R. Civ. P. 10 (as applied by 7010);
// N.D. Ill. Bankr. L.R. 5005-1(C), 5005-2, 7003-1 (effective Sept. 1, 2024). No case-specific text, no
// coordinates measured off the exemplar, no forced line breaks. The markdown body is rendered by cmarker; the
// metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"         // ILNB-FORM-002: a proportionally spaced font. Vendored in /fonts.
#let type-size = 13pt                    // ILNB-FORM-002: at least 12 point, footnotes included. 13 pt is a style choice (EB Garamond sets smaller than Times at the same point size); see ../README.md.
#let line-pitch = 24pt                   // ILNB-FORM-003: double spacing, a 24 pt baseline pitch.
#let body-leading = 0.54em               // extra space between body lines; tuned so the baseline pitch is line-pitch (measured: 24.0 pt at 13 pt).
#let single-leading = 0.2em              // caption, counsel, signature block, footnotes, quotations (ILNB-FORM-003 exception, README.md).
#let page-margin = 1in                   // ILNB-FORM-004: no margin less than one inch.
#let para-indent = 0.5in                 // first-line indent of text and numbered paragraphs.
#let number-gap = 0.4in                  // space between a paragraph number and its text.
#let caption-left = 3.4in                // width of the party column of the caption.
#let footer-size = 12pt                  // page numbers (ILNB-FORM-005)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Stop with a message when a required metadata field is missing.
#let need(meta, key) = {
  if key not in meta { panic("ilnb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilnb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Several single-spaced lines, one block per item. Items are markdown strings or content.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if type(i) == str { inl(i) } else { i }))
}

// ---------------------------------------------------------------------------
// Court heading and caption (ILNB-CAP-001..003)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  align(center, text(weight: "bold", line-stack((
    "IN THE UNITED STATES BANKRUPTCY COURT",
    "FOR THE NORTHERN DISTRICT OF ILLINOIS",
  ))))
  v(line-pitch * 0.5)
  align(center, text(weight: "bold", upper(need(meta, "division"))))
}

/// The caption: the party column (debtor, then the adversary parties) and the case column (chapter,
/// case number, adversary number, judge). Form 416 wording; the rule requires the case number, chapter,
/// judge and the division (ILNB-CAP-001..003).
#let caption(meta) = {
  let cap = need(meta, "caption")
  let party(p) = {
    let rows = p.names
    rows.push(pad(left: 1.4in, inl(p.designation)))
    line-stack(rows)
  }
  let left = {
    line-stack(("In re:",))
    v(single-leading)
    party(cap.in_re)
    if "adversary" in cap and cap.adversary != none {
      v(line-pitch * 0.5)
      for (k, p) in cap.adversary.parties.enumerate() {
        if k > 0 {
          v(line-pitch * 0.5)
          line-stack(("v.",))
          v(line-pitch * 0.5)
        }
        party(p)
      }
    }
  }
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.3in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 0.15in, bottom: 0.12in), left),
    block(inset: (top: 0pt), {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      let rows = ()
      if "chapter" in cap { rows.push(cap.chapter) }
      rows.push("Case No. " + cap.case_number)
      if "adversary" in cap and cap.adversary != none {
        rows.push("Adv. Pro. No. " + cap.adversary.number)
      }
      if "judge" in cap { rows.push(cap.judge) }
      stack(dir: ttb, spacing: line-pitch * 0.5, ..rows.map(r => inl(r)))
    }),
  )
}

#let cover(meta) = {
  court-title(meta)
  v(line-pitch)
  caption(meta)
  v(line-pitch)
  align(center, block(width: 100%, sticky: true, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    text(weight: "bold", upper(need(meta, "title")))
  }))
  v(line-pitch)
}

// ---------------------------------------------------------------------------
// Signature block (ILNB-SIG-001..002): the signing attorney's name, mailing address, email and telephone
// (LBR 5005-2(C)(6)). Single spaced, like the filed exemplars.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, sticky: true, grid(
    columns: (2.5in, 1fr),
    column-gutter: 0.2in,
    line-stack(("Dated: " + sig.date, sig.city)),
    {
      line-stack(("s/ " + sig.signer,))
      for (k, g) in sig.counsel.enumerate() {
        if k > 0 {
          v(line-pitch * 0.5)
          line-stack(([#"- and -"],))
        }
        v(line-pitch * 0.5)
        line-stack(g.names + g.lines)
      }
    },
  ))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (ILNB-BODY-001, Fed. R. Civ. P. 10(b) via Rule 7010)
// ---------------------------------------------------------------------------

/// Pull the footnote definitions out of the body: a definition is rendered with the paragraph that
/// refers to it, so the reference resolves inside one cmarker call.
#let footnote-key-re = regex("\\[\\^([^\\]]+)\\]")

/// Numbered paragraphs. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph. Headings and lists are not numbered. Numbering is applied per chunk,
/// not with a `show par` rule: a show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body) = {
  let para-n = 0
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let defs = chunks.filter(c => c.trim().starts-with("[^"))
  for c in chunks {
    let t = c.trim()
    if t.starts-with("[^") {
      // Footnote definitions are rendered with the paragraph that refers to them.
    } else if t.starts-with("#") {
      // A heading is sticky: it is never the last line of a page.
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list is not numbered; its items are spaced by body-leading. A list may break across pages.
      block(width: 100%, {
        set par(leading: body-leading, first-line-indent: 0pt)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
    } else {
      // Footnote definitions that this paragraph refers to, appended so the reference resolves in one render.
      let keys = t.matches(footnote-key-re).map(m => m.captures.at(0))
      let own = defs.filter(d => keys.any(k => d.trim().starts-with("[^" + k + "]:")))
      para-n += 1
      let body-md = t + "\n\n" + own.join("\n\n", default: "")
      // The indent and the number are inline content, so the first line starts indented. A block-first
      // paragraph does not take first-line-indent in typst 0.15, so the indent is an explicit space.
      block(width: 100%, above: 0pt, below: body-leading, {
        h(para-indent)
        [#str(para-n).#h(number-gap)]
        cmarker.render(body-md, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    }
  }
}

#let ilnb-adversary-complaint(meta, body) = {
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: footer-size, counter(page).display("1"))),
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Headings: level 1 centered bold capitals; level 2 bold; level 3 bold italic. Never the last line on a page.
  show heading.where(level: 1): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    align(center, text(size: type-size, strong(upper(it.body)))))
  show heading.where(level: 2): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    text(size: type-size, strong(it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
    text(size: type-size, strong(emph(it.body))))

  cover(meta)

  if "intro" in meta {
    block(width: 100%, {
      h(para-indent)
      inl(meta.intro)
    })
  }

  allegations(body)

  if "prayer" in meta {
    v(line-pitch * 0.5)
    block(width: 100%, sticky: true, { h(para-indent); inl(meta.prayer) })
    // Lettered items (a., b., ...). The last item is sticky so the signature block never stands alone on a page.
    let items = meta.prayer_items
    for (k, item) in items.enumerate() {
      let row = pad(left: para-indent, grid(columns: (0.4in, 1fr), numbering("a.", k + 1), inl(item)))
      if k == items.len() - 1 {
        block(width: 100%, sticky: true, row)
      } else {
        block(width: 100%, row)
      }
    }
  }

  v(line-pitch)
  signature-block(meta)
}
