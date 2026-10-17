// Adversary complaint for the United States Bankruptcy Court, District of Nebraska (nebraskab).
// Rules: Fed. R. Bankr. P. 7001 (adversary proceeding), 7008 (pleading: jurisdiction, core/non-core,
// consent to final orders), 7010 (caption substantially conforms to Official Form 416), 9004(a)-(b)
// (legible; caption: court, title, case and adversary numbers, designation), 9011(a) (signer's address
// and telephone number); Fed. R. Civ. P. 10(b) (numbered paragraphs, as applied by 7010). Local Rules
// (2026 text): LR 1015-1(B) (captions of jointly administered cases), LR 9011-1 (signatures). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no Nebraska font rule; standard serif, vendored in fonts/
#let type-size = 13pt                   // legible (FRBP 9004(a)); 13 pt in EB Garamond reads like 12 pt Times (README.md)
#let body-leading = 1.35em              // double spacing: EB Garamond's line box is 0.65em, so 1.35em gives a 26 pt baseline pitch at 13 pt
#let single-leading = 0.45em            // single spacing for caption, signature, footnotes
#let margin = 1in                       // no Nebraska margin rule; 1 inch on every side (conventional)
#let text-width = 8.5in - 2 * margin
#let para-indent = 0.5in                // first-line indent of numbered allegations
#let number-gap = 0.3in                 // space between the paragraph number and its text
#let caption-left = 3.4in               // width of the party column of the caption
#let footnote-size = 11pt               // footnotes: not body text; no rule sets a size

// Court name (Official Form 416 caption, FRBP 9004(b)(1)). Constant for this court; not case-specific.
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "DISTRICT OF NEBRASKA")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nebraskab-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown rendered as inline content (names, lines, the title): italics and smart quotes, no paragraphs.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A markdown chunk rendered as body text. h1-level 1 keeps the heading levels the sample uses.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Footnote definitions `[^key]: text`, collected from the body (one per line).
#let footnote-defs(body) = {
  let defs = (:)
  for line in body.split("\n") {
    let m = line.match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1)) }
  }
  defs
}

/// Keep "§" with the number after it (no line may end on "§").
#let nbsp-sections(s) = s.replace("§ ", "§\u{a0}").replace(" §", "\u{a0}§")

// Single-spaced lines, one block per item (no forced line breaks: each item is its own block).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: court name, caption, title (Official Form 416; FRBP 9004(b))
// ---------------------------------------------------------------------------

#let caption(meta) = {
  stack(dir: ttb, spacing: single-leading, ..court-name.map(line => align(center, text(weight: "bold", line))))
  v(body-leading)
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    {
      // "In re:" block, then the parties separated by "v.". The rule closes the debtor block.
      line-stack(("In re:",) + meta.in_re)
      v(single-leading * 2)
      line(length: 100%, stroke: 0.6pt)
      v(single-leading * 2)
      for (k, p) in meta.parties.enumerate() {
        if k > 0 {
          v(single-leading * 2)
          pad(left: 0.5in, [v.])
          v(single-leading * 2)
        }
        line-stack(p.names)
        v(single-leading)
        pad(left: 1in, inl(p.designation))
      }
    },
    {
      v(single-leading * 3)
      line-stack((meta.chapter,) + meta.case_lines)
      v(body-leading)
      line-stack((meta.adversary_line,))
    },
  )
  v(body-leading)
  align(center, text(weight: "bold", inl(nbsp-sections(upper(meta.title)))))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: headings, numbered allegations, lettered prayer items
// ---------------------------------------------------------------------------

/// A heading is a sticky block: it never ends a page, and it keeps the paragraph after it.
#let heading-block(level, text-md) = {
  v(body-leading * 0.5)
  block(width: text-width, sticky: true, above: 0pt, below: body-leading, {
    if level == 1 {
      align(center, text(weight: "bold", inl(upper(text-md))))
    } else {
      align(center, text(weight: "bold", inl(text-md)))
    }
  })
}

/// Lettered items (a), (b), ... for the prayer: a hanging indent at the paragraph indent.
#let lettered(items) = {
  let letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p")
  for (k, it) in items.enumerate() {
    block(width: text-width, above: 0pt, below: body-leading, {
      set par(leading: body-leading, first-line-indent: 0pt)
      grid(
        columns: (para-indent + 0.4in, 1fr),
        [#h(para-indent) (#letters.at(k))],
        md(it),
      )
    })
  }
}

/// Body text. Each blank-line-separated chunk is one block. Numbering: allegations are numbered from
/// the first heading to the prayer; the intro paragraph and the prayer are unnumbered (Fed. R. Civ. P. 10(b)).
#let body-chunks(body, notes) = {
  let para-counter = counter("allegation")
  let numbering-on = false
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("[^") {
      // footnote definitions are attached to the chunk that cites them (see below)
      continue
    }
    if t.starts-with("#") {
      let m = t.match(regex("^(#+)[ \t]+(.*)$"))
      let level = m.captures.at(0).len()
      let title = m.captures.at(1)
      if level == 1 and upper(title) == "PRAYER FOR RELIEF" {
        numbering-on = false
      } else if not numbering-on and level == 1 {
        numbering-on = true
      }
      heading-block(level, title)
    } else if t.starts-with(regex("^[-*+][ \t]")) {
      let items = t.split("\n").filter(l => l.trim().starts-with(regex("^[-*+][ \t]"))).map(l => l.trim().slice(2))
      lettered(items)
    } else {
      // cite-and-define: the footnote definitions this chunk uses are rendered with it
      let extra = ""
      for m in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
        let key = m.captures.at(0)
        extra += "\n\n[^" + key + "]: " + notes.at(key)
      }
      let content = md(nbsp-sections(t + extra))
      if numbering-on {
        para-counter.step()
        block(width: text-width, above: 0pt, below: body-leading, {
          set par(leading: body-leading, first-line-indent: 0pt)
          context [#h(para-indent)#(para-counter.display()).#h(number-gap)#content]
        })
      } else {
        block(width: text-width, above: 0pt, below: body-leading, {
          set par(leading: body-leading, first-line-indent: 0pt)
          h(para-indent)
          content
        })
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature (FRBP 9011(a): signer's address and telephone number; LR 9011-1: /s/ signature)
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: text-width, breakable: false, above: body-leading, {
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    [Dated: #meta.date],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Respectfully submitted,]
      v(single-leading * 2)
      for (k, b) in meta.signature.enumerate() {
        if k > 0 { v(single-leading * 2) }
        line-stack(b)
      }
    },
  )
})

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let nebraskab-complaint(meta, body) = {
  // FRBP 7008(a): the complaint must state whether the pleader does or does not consent to final orders.
  assert(body.find("consent to the entry of final orders") != none, message: "nebraskab-adversary-complaint: the complaint must state consent to the entry of final orders (FRBP 7008(a))")
  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: 11pt, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set block(spacing: 0pt)

  caption(meta)

  show footnote.entry: set text(size: footnote-size)

  body-chunks(body, footnote-defs(body))

  signature-block(meta)
}
