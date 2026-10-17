// U.S. District Court, District of Connecticut (ctd): complaint.
//
// Rule-driven and content-agnostic. Requirement IDs (CTD-...) refer to ../README.md, which quotes the
// rule text (D. Conn. Local Rule 10; Fed. R. Civ. P. 8, 10; the Electronic Filing Policies and Procedures).
// No case-specific text, no coordinates measured off the exemplar, no forced line breaks. The markdown
// body is rendered by cmarker; the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"     // CTD-FORM-003: the rules name no font (see README); Times New Roman substitute per docs/FONTS.md, vendored in fonts/
#let type-size = 12pt                // CTD-FORM-002: 12-point text (L.R. 7(a)(5) for memoranda; Rule 10 is silent for pleadings)
#let line-pitch = 27.6pt             // CTD-FORM-001: double spacing = 2 x 13.8 pt, the single line of 12 pt Times in Word (the exemplar measures 27.6 pt)
#let body-leading = 1.645em          // gap between lines; with Liberation Serif's line box (0.655 em) it gives line-pitch (measured, README)
#let single-leading = 0.5em          // caption, counsel and signature blocks: single spaced
#let para-indent = 0.5in             // first-line indent of numbered paragraphs
#let para-number-gap = 0.35in        // gap between the paragraph number and its text
#let margin = 1in                    // CTD-FORM-004: at least one inch on every side (L.R. 10)
#let text-width = 8.5in - 2 * margin
#let caption-left = 3.3in            // width of the party column of the caption
#let caption-indent = 1.5in          // designations ("Plaintiffs,", "Defendant.") sit under the names

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ctd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ctd-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A block of single-spaced lines (caption, counsel, signature).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if type(i) == str { inl(i) } else { i }))
}

/// Round a block up to whole numbered lines, so whatever follows it stays on the pitch.
/// Typst's `leading` sits between lines only, so a block's own height is n lines plus n - 1 gaps;
/// the rounding puts the gap after the last line back in. Used for headings (short, not split).
#let on-grid(c, sticky: false) = context {
  let h = measure(width: text-width, c).height
  block(width: 100%, height: calc.ceil(h / line-pitch) * line-pitch, above: 0pt, below: 0pt, sticky: sticky, c)
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (CTD-FIRST-001..003)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let court = need(meta, "court")
  align(center, strong(upper(court.map(l => [#l]).join(linebreak()))))
  v(line-pitch)
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.2in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
      // Each party: its names, then its designation indented under them; "v." between the parties.
      let rows = ()
      for (k, p) in need(meta, "caption").parties.enumerate() {
        if k > 0 { rows.push("v.") }
        rows += p.names
        rows.push(pad(left: caption-indent, inl(p.designation)))
      }
      line-stack(rows)
    }),
    block(inset: (left: 0.1in), {
      line-stack(("Case No. " + need(meta, "case_number"), "Date: " + need(meta, "date")))
      v(line-pitch * 0.5)
      text(weight: "bold", inl(need(meta, "brief_title")))
      if "jury_demand" in meta and meta.jury_demand {
        v(line-pitch * 0.5)
        text(weight: "bold", "DEMAND FOR JURY TRIAL")
      }
    }),
  )
  v(line-pitch)
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lettered lists (FRCP 10(b))
// ---------------------------------------------------------------------------

/// Headings: level 1 is a centered bold section; level 2 a centered bold sub-heading; level 3 bold italic.
/// A heading is kept with the paragraph after it (sticky), so it never ends a page.
#let heading-block(level, c) = on-grid(sticky: true, {
  set par(leading: body-leading, first-line-indent: 0pt)
  if level == 1 { align(center, strong(upper(c))) }
  else if level == 2 { align(center, strong(c)) }
  else { strong(emph(c)) }
})

/// Numbered paragraphs and lettered lists. Each blank-line-separated chunk of markdown that is neither a
/// heading nor a list is one numbered paragraph (FRCP 10(b)), unless it starts with the marker
/// `[unnumbered]`, which the template strips (the wherefore clause and the jury demand are unnumbered).
/// Each chunk ends with v(body-leading), so n lines take exactly n line-pitches and the text stays on the grid.
/// Numbering is a plain counter in this function, not a `show par` rule: a show rule that re-wraps
/// paragraph content recurses without end in typst 0.15.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let lv = t.match(regex("^#+")).end
      heading-block(lv, inl(t.slice(lv).trim()))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lists may break across pages. Items are spaced by body-leading; the trailing v() closes the list on the grid.
      block(width: 100%, {
        set par(leading: body-leading, first-line-indent: 0pt)
        set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
        set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
        inl(t)
        v(body-leading)
      })
    } else {
      let unnumbered = t.starts-with("[unnumbered]")
      let text-body = if unnumbered { t.slice("[unnumbered]".len()).trim() } else { t }
      if not unnumbered { n += 1 }
      // A paragraph breaks across pages like any text; the heading in front of it stays with its first line.
      block(width: 100%, {
        set par(leading: body-leading, first-line-indent: 0pt)
        if unnumbered {
          h(para-indent)
          inl(text-body)
        } else {
          h(para-indent)
          [#(n).]
          h(para-number-gap)
          inl(text-body)
        }
        v(body-leading)
      })
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (CTD-SIG-001: EFPP XI.B and L.R. 10)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (2.6in, 1fr), column-gutter: 0.2in, [Dated: #need(meta, "date")], {
      [Respectfully submitted,]
      v(line-pitch)
      line-stack(("/s/ " + sig.signer,))
      linebreak()
      let name-line = if "bar" in sig { sig.signer + ", Fed. Bar No. " + sig.bar } else { sig.signer }
      line-stack((name-line,) + sig.at("lines", default: ()))
    })
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let ctd-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court", "caption", "brief_title", "date", "signature") {
    let _ = need(meta, k)
  }

  set page(
    paper: "us-letter",
    margin: margin,
    // CTD-FORM-005: page numbers in the bottom margin of each page after page 1.
    footer: context {
      if counter(page).get().first() > 1 {
        align(center, text(size: type-size, counter(page).display()))
      }
    },
  )
  set document(title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"), author: need(meta, "signature").signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false)
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  caption(meta)

  if "lead_in" in meta {
    block(width: 100%, {
      set par(leading: body-leading, first-line-indent: 0pt)
      h(para-indent)
      inl(meta.lead_in)
      v(body-leading)
    })
  }

  allegations(body)

  signature-block(meta)
}
