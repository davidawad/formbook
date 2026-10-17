// Adversary complaint for the United States Bankruptcy Court, S.D. Indiana (insb).
// Rules: Fed.R.Bankr.P. 7010 (Fed.R.Civ.P. 10 applies: the caption, and numbered paragraphs under Rule 10(b));
// Fed.R.Bankr.P. 7008 (the jurisdiction allegation names the case, its number and chapter, and the district and
// division; the pleader states whether it consents to final orders); Fed.R.Bankr.P. 9004(a) (clearly legible);
// S.D.Ind. B-5005-3 (papers no larger than 8-1/2 x 11). The S.D.Ind. Local Rules set no font, margin or line
// spacing: those are layout choices, marked as such in ../README.md.
// Content-agnostic: every case word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or is a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")      // layout choice: no S.D.Ind. font rule; Times New Roman substitute per docs/FONTS.md, vendored in fonts/
#let type-size = 12pt                 // layout choice: the Rule 9004(a) legibility floor is the only requirement
#let pitch = 27.6pt                   // layout choice: double spacing, matching the filed exemplar (27.6 pt baseline pitch, measured)
#let page-w = 8.5in                   // S.D.Ind. B-5005-3: no larger than 8-1/2 by 11 inches
#let page-h = 11in
#let margin = 1in                     // layout choice
#let text-width = page-w - 2 * margin
#let body-leading = 1.645em           // double spacing: 0.655 em line box + 1.645 em leading = 27.6 pt at 12 pt (measured, README.md)
#let single-leading = 0.5em           // single spacing for the caption, the counsel and the signature block
#let para-indent = 0.5in              // first-line indent of numbered allegations
#let caption-left = 3.4in             // width of the party column of each caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("insb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown: a chunk of body text, rendered double spaced.
#let body-md(t) = {
  set par(leading: body-leading, spacing: 0pt, justify: false)
  cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
}

/// Fill whole lines: the block is rounded up to a multiple of `pitch`, so every paragraph ends on the
/// line grid and the next one cannot be drawn over it (measured, not left to automatic block height).
#let on-grid(c, w: text-width) = context {
  let h = measure(width: w, c).height
  block(width: w, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// A heading: one or more lines, kept with the chunk after it so it never ends a page.
#let heading-block(c) = block(width: text-width, above: pitch * 0.5, below: pitch * 0.5, sticky: true, on-grid(c))

// ---------------------------------------------------------------------------
// Cover: court title, bankruptcy caption, adversary caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  align(center, text(weight: "bold", [UNITED STATES BANKRUPTCY COURT])) + linebreak()
  align(center, text(weight: "bold", [SOUTHERN DISTRICT OF INDIANA])) + linebreak()
  if "division" in meta and meta.division != none {
    align(center, text(weight: "bold", upper(meta.division) + " DIVISION"))
  }
}

/// The bankruptcy caption: the debtor in the left column, the case number and chapter on the right.
#let bankruptcy-caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    line-stack(("In re:", "") + meta.debtor.names + (meta.debtor.designation,))
  }),
  block(inset: (left: 0.1in), line-stack((
    "Case No. " + meta.case_number,
    "Chapter " + meta.chapter,
  ))),
)

/// The adversary caption: each party, then its designation; "v." between the parties.
#let adversary-caption(meta) = {
  let rows = ()
  for (k, p) in meta.adversary.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  let number = if meta.adversary.adv_number == "" { "Adv. Pro. No. ____________" } else { "Adv. Pro. No. " + meta.adversary.adv_number }
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.2in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), line-stack(rows)),
    block(inset: (left: 0.1in), line-stack((number,))),
  )
}

#let cover(meta) = {
  court-title(meta)
  v(pitch)
  bankruptcy-caption(meta)
  v(pitch * 0.5)
  adversary-caption(meta)
  v(pitch)
  align(center, text(weight: "bold", inl(meta.title)))
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: text-width, breakable: false, {
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      line-stack(meta.signature.firm)
      v(pitch * 0.5)
      line-stack(("By: /s/ " + meta.signature.signer, upper(meta.signature.signer)) + meta.signature.lines)
    },
  )
})

/// Body chunks, each separated by a blank line in the sample:
///   `#` heading                    centered (level 1) or bold (level 2); kept with the next chunk
///   `(a) ...` / `(1) ...`           labeled sub-item, shown as `a.` / `1.`, hanging indent, not numbered
///   `> ...`                         block quotation, single spaced, indented both sides, not numbered
///   `[...]`                         centered bracketed note, not numbered
///   `WHEREFORE ...`                 prayer paragraph, indented, not numbered
///   starts with a lowercase letter  continues the paragraph before it, not numbered
///   anything else                   numbered allegation (Fed.R.Civ.P. 10(b)); the count runs through the body
/// The count is a plain variable, not a counter: a counter display needs `context`, which block sizing
/// does not see. Numbering is per chunk, not a `show par` rule (that recurses without end in typst 0.15).
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    let labeled = t.match(regex("^\\(([a-z]+|[0-9]+)\\)[ \t]+"))
    let piece = if t.starts-with("#") {
      pending += body-md(t)
      has-pending = true
      none
    } else if t.starts-with(">") {
      let inner = t.split("\n").map(l => {
        let s = l.trim()
        if s.starts-with(">") { s = s.slice(1) }
        s.trim()
      }).join("\n")
      pad(left: 1in, right: 0.5in, on-grid(w: text-width - 1.5in, {
        set par(leading: single-leading, spacing: single-leading, justify: false)
        cmarker.render(inner, raw-typst: false, smart-punctuation: true)
      }))
    } else if t.starts-with("[") {
      on-grid({ set par(leading: body-leading); align(center, inl(t)) })
    } else if labeled != none {
      let label = labeled.captures.at(0) + "."
      let rest = t.slice(labeled.end)
      pad(left: para-indent, on-grid(w: text-width - para-indent, grid(
        columns: (0.6in, 1fr),
        [#label],
        body-md(rest),
      )))
    } else if t.starts-with("WHEREFORE") {
      on-grid({ set par(leading: body-leading); h(para-indent); inl(t) })
    } else if t.match(regex("^[a-z]")) != none {
      // Continues the paragraph before it (e.g. the total after a lettered list): not numbered, no indent.
      on-grid({ set par(leading: body-leading); inl(t) })
    } else {
      n += 1
      on-grid({ set par(leading: body-leading); h(para-indent); [#n.#h(0.3in)]; inl(t) })
    }
    // A heading is held until the chunk after it, so it never ends a page.
    if piece != none {
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

#let insb-adversary-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: none,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  show heading.where(level: 1): it => heading-block(align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-block(text(size: type-size, weight: "bold", it.body))

  cover(meta)

  if "lead_in" in meta and meta.lead_in != none {
    on-grid({ set par(leading: body-leading); h(para-indent); inl(meta.lead_in) })
  }

  allegations(body)

  v(pitch)
  signature-block(meta)
}
