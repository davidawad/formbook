// Motion or brief (motion with memorandum) for the United States Bankruptcy Court, District of Nebraska
// (nebraskab), in an adversary proceeding or a contested matter.
// Rules: Fed. R. Bankr. P. 9013 (a motion states its grounds with particularity and the relief requested);
// 9004(a)-(b) (legible; caption: court, title, case and adversary numbers, designation); 9011(a) (signer's
// address and telephone number); Local Rules (2026 text): LR 7007-1(A)-(G) (motions in adversary
// proceedings: basis and relief stated; a supporting brief filed contemporaneously when a substantial issue
// of law is raised; content of briefs; evidence index; no oral argument unless requested by motion),
// LR 9011-1(B) (/s/ signature), LR 1015-1(B) (jointly administered captions). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // no Nebraska font rule; standard serif, vendored in fonts/
#let type-size = 13pt                   // legible (FRBP 9004(a)); 13 pt in EB Garamond reads like 12 pt Times (README.md)
#let body-leading = 1.35em              // double spacing: 26 pt baseline pitch at 13 pt (EB Garamond's line box is 0.65em)
#let single-leading = 0.45em            // single spacing for caption, signature, footnotes
#let margin = 1in                       // no Nebraska margin rule; 1 inch on every side (conventional)
#let text-width = 8.5in - 2 * margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.4in               // width of the party column of the caption
#let footnote-size = 11pt               // footnotes: not body text; no rule sets a size

// Court name (FRBP 9004(b)(1)). Constant for this court; not case-specific.
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "DISTRICT OF NEBRASKA")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nebraskab-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown rendered as inline content (names, lines, the title): italics and smart quotes, no paragraphs.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// A markdown chunk rendered as body text. h1-level 1 keeps the heading levels the sample uses.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Keep "§" with the number after it (no line may end on "§").
#let nbsp-sections(s) = s.replace("§ ", "§\u{a0}").replace(" §", "\u{a0}§")

/// Footnote definitions `[^key]: text`, collected from the body (one per line).
#let footnote-defs(body) = {
  let defs = (:)
  for line in body.split("\n") {
    let m = line.match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1)) }
  }
  defs
}

/// Single-spaced lines, one block per item (no forced line breaks: each item is its own block).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Caption and title (FRBP 9004(b); Official Form 416 layout, title in the right column)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  stack(dir: ttb, spacing: single-leading, ..court-name.map(line => align(center, text(weight: "bold", line))))
  v(body-leading)
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    {
      // "In re:" block, a rule, then the parties with "v." between them; intervenors follow.
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
      for p in meta.at("intervenors", default: ()) {
        v(body-leading)
        line-stack(p.names)
        v(single-leading)
        pad(left: 1in, inl(p.designation))
      }
    },
    {
      v(single-leading * 3)
      line-stack(meta.case_lines)
      v(body-leading)
      line-stack((meta.adversary_line,))
      v(body-leading * 2)
      text(weight: "bold", inl(upper(meta.title)))
    },
  )
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: sections (roman), subsections (letters), paragraphs
// ---------------------------------------------------------------------------

/// Body text. Each blank-line-separated chunk is one block. Sections (level 2) are numbered I., II., ...;
/// subsections (level 3) A., B., ... restart under each section; level 1 is unnumbered (CERTIFICATE OF
/// SERVICE is generated, not in the body). Paragraphs are not numbered (a brief's numbering is typed by
/// the author, as in the exemplar's responses 1 to 8, which the sample types).
#let body-chunks(body, notes) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let sec-n = 0
  let sub-n = 0
  for c in chunks {
    let t = c.trim()
    if t.starts-with("[^") { continue }
    if t.starts-with("#") {
      let m = t.match(regex("^(#+)[ \t]+(.*)$"))
      let level = m.captures.at(0).len()
      let title = nbsp-sections(m.captures.at(1))
      v(body-leading * 0.5)
      if level == 2 {
        sec-n += 1
        sub-n = 0
        block(width: text-width, sticky: true, above: 0pt, below: body-leading,
          align(center, text(weight: "bold", [#numbering("I.", sec-n) #inl(upper(title))])))
      } else if level == 3 {
        sub-n += 1
        block(width: text-width, sticky: true, above: 0pt, below: body-leading,
          grid(columns: (0.5in, 1fr), text(weight: "bold", numbering("A.", sub-n)),
            text(weight: "bold", inl(title))))
      } else {
        block(width: text-width, sticky: true, above: 0pt, below: body-leading,
          align(center, text(weight: "bold", inl(upper(title)))))
      }
    } else {
      // cite-and-define: a footnote definition used by this chunk is rendered with it
      let extra = ""
      for m in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
        let key = m.captures.at(0)
        extra += "\n\n[^" + key + "]: " + notes.at(key)
      }
      block(width: text-width, above: 0pt, below: body-leading, {
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent)
        md(nbsp-sections(t + extra))
      })
    }
  }
}

// ---------------------------------------------------------------------------
// Signature and certificate of service
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: text-width, breakable: false, above: body-leading, {
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    [],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      inl(meta.signature.party)
      v(single-leading * 2)
      line-stack(meta.signature.lines)
    },
  )
})

/// CM/ECF certificate (LR 5005-1(C): a certificate states how service on non-CM/ECF participants was made;
/// the sample's filing is served on CM/ECF participants only). Kept on its own page.
#let certificate(meta) = {
  pagebreak()
  align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
  v(body-leading)
  block(width: text-width, {
    set par(leading: body-leading, first-line-indent: 0pt)
    h(para-indent)
    [I hereby certify that on #meta.certificate.date, I electronically filed the foregoing document with the Clerk of the Court using the CM/ECF system which sent notification of said filing to all CM/ECF participants.]
  })
  v(body-leading * 2)
  block(width: text-width, breakable: false, grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    [],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [/s/ #meta.certificate.signer]
      v(single-leading * 2)
      inl(meta.certificate.signer)
    },
  ))
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let nebraskab-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: 11pt, counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set block(spacing: 0pt)

  show footnote.entry: set text(size: footnote-size)

  caption(meta)

  body-chunks(body, footnote-defs(body))

  signature-block(meta)

  certificate(meta)
}
