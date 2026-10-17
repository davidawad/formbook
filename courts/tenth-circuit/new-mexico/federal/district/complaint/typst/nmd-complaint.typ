// Complaint for the United States District Court for the District of New Mexico (nmd).
// Rules: D.N.M.LR-Civ. 10.1 (paper, margins, double spacing, case number and assigned judges' initials on page 1),
// D.N.M.LR-Civ. 83.4(a) (signature block: name, firm, address, telephone, electronic address), Fed. R. Civ. P. 8(a)
// and 10(a)-(b) (caption, numbered paragraphs). See ../README.md for each rule's text and the interpretations.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // LR-Civ. 10.1: "at least 12 pitch", letter quality; 12 pt proportional (README.md)
#let pitch = 24pt                       // LR-Civ. 10.1: text double spaced; one double-spaced line = 24 pt at 12 pt
#let body-leading = 1.345em             // Liberation Serif's line box is 0.655em, so 1.345em + 0.655em = 2em = 24 pt at 12 pt
#let single-leading = 0.495em            // single spacing (caption, signature, lists of addresses): about 13.8 pt
#let margins = (top: 1.5in, bottom: 1in, left: 1in, right: 1in)   // LR-Civ. 10.1: top at least 1 1/2 in; others at least 1 in
#let text-width = 8.5in - 1in - 1in
#let para-indent = 0.5in                // first-line indent of numbered allegations
#let caption-left = 3.3in               // party column of the caption
#let caption-mark = 0.3in               // column of ")" marks between the parties and the case number

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Fail loudly when the sample leaves out a field the template needs (a missing field must not render as blank).
#let need(meta, key) = {
  assert(key in meta, message: "nmd-complaint: the sample's frontmatter must give '" + key + "'")
  meta.at(key)
}

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nmd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// First page: court title, caption, case number, title of the paper (LR-Civ. 10.1; Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  align(center, text(weight: "bold", need(meta, "court").map(l => upper(l)).join(linebreak())))
}

#let caption(meta) = {
  let rows = ()
  for (k, p) in need(meta, "caption").parties.enumerate() {
    if k > 0 { rows.push(pad(left: 1.2in, "v.")) }
    for n in p.names { rows.push(inl(n)) }
    rows.push(pad(left: 1.2in, inl(p.designation)))
  }
  let marks = rows.map(_ => ")")
  grid(
    columns: (caption-left + caption-mark, 1fr),
    block(width: caption-left + caption-mark, {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      grid(
        columns: (caption-left, caption-mark),
        row-gutter: single-leading,
        ..rows.zip(marks).flatten(),
      )
    }),
    block(inset: (left: 0.2in, top: 0pt), {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Case No. #need(meta, "case_number")]
    }),
  )
}

#let cover(meta) = {
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
  align(center, text(weight: "bold", need(meta, "brief_title")))
  v(pitch * 0.5)
}

// ---------------------------------------------------------------------------
// Body: numbered allegations (Fed. R. Civ. P. 10(b)), lead-in, headings, lists, prayer
// ---------------------------------------------------------------------------

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a list is one
/// numbered paragraph (Fed. R. Civ. P. 10(b)), unless the chunk starts with "^ ": that marker (removed here) makes
/// it an unnumbered paragraph, for the request for relief and the jury demand, which are not allegations.
/// Headings and lists are rendered unnumbered. Numbering is applied per chunk, not with a `show par` rule: a show
/// rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; only a heading in front of it is kept with its first line.
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading * 0.5)
      }
      if has-pending {
        block(breakable: false, width: text-width, { pending; items })
      } else {
        items
      }
      pending = []
      has-pending = false
    } else if t.starts-with("^ ") {
      // An unnumbered paragraph (the request for relief, the jury demand): same first-line indent, no number.
      let piece = {
        set par(leading: body-leading)
        h(para-indent)
        inl(t.slice(2))
      }
      if has-pending {
        block(breakable: false, width: text-width, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    } else {
      // A paragraph breaks across pages like any text; only a heading in front of it is kept with its first line.
      let piece = {
        para-counter.step()
        set par(leading: body-leading)
        context {
          let num = para-counter.display()
          h(para-indent) + [#num.] + h(0.3in) + cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        }
      }
      if has-pending {
        block(breakable: false, width: text-width, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

// ---------------------------------------------------------------------------
// Signature block (LR-Civ. 83.4(a): name, firm, address, telephone, electronic address; Fed. R. Civ. P. 11(a))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: pitch, width: text-width, grid(
    columns: (1fr, 3.2in),
    if "date" in meta { [Dated: #meta.date] } else { [] },
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      line-stack(sig.firm)
      v(pitch * 0.5)
      for (k, b) in sig.blocks.enumerate() {
        if k > 0 {
          v(pitch * 0.5)
          [and]
          v(pitch * 0.5)
        }
        line-stack(b)
      }
      v(pitch * 0.5)
      line-stack((sig.attorneys_for,))
    },
  ))
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let nmd-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court", "caption", "brief_title", "signature") {
    let _ = need(meta, k)
  }
  let para-counter = counter("allegation")

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",
    margin: margins,
    footer: context align(center, text(size: type-size, counter(page).display())),
    footer-descent: 0.45in,
  )
  set document(title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"))
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false, fallback: false)
  // Typst adds `leading` only between the lines of one paragraph; the gap between paragraphs is `spacing`.
  // Both must be body-leading, or consecutive paragraphs overlap (measured: 7.8 pt pitch without this).
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set enum(numbering: "a.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  // Headings: level 1 is a centered section; level 2 a centered sub-heading (a count's name); level 3 bold italic.
  show heading.where(level: 1): it => block(width: 100%, above: 12pt, below: 12pt, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: 0pt, below: 12pt, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 3): it => block(width: 100%, above: 12pt, below: 12pt, sticky: true,
    text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)
  // The lead-in is the unnumbered sentence before the first heading ("... and alleges as follows:" in other filings).
  if "lead_in" in meta {
    set par(leading: body-leading)
    h(para-indent)
    inl(meta.lead_in)
  }
  allegations(body, para-counter)
  signature-block(meta)
}
