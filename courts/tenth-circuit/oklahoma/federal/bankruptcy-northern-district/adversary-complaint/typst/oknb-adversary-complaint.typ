// Adversary complaint for the U.S. Bankruptcy Court, N.D. Oklahoma (oknb).
// Rules: Fed. R. Bankr. P. 7001 (adversary proceeding begins with a complaint), 7008(a) (jurisdiction
// allegation; core or non-core statement; consent to final orders), 7010 with Fed. R. Civ. P. 10(a)-(c)
// (caption, numbered paragraphs, separate counts), 9004 (legibility, caption); Local Rules 9004-1
// (8 1/2 x 11, 12-point minimum including footnotes, margins of at least one inch, one side, double
// spaced), 9004-2 (caption), 9011-1 and 9004-1(C) (signature block), 7010-1 (defers to 9004-1, 9004-2).
// See ../README.md for the rule text and dates.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // LBR 9004-1(A): no less than 12-point (footnotes included)
#let page-w = 8.5in                     // LBR 9004-1(A): 8 1/2 by 11 inches
#let page-h = 11in
#let margin = 1in                       // LBR 9004-1(A): margins of no less than one inch
#let text-width = page-w - 2 * margin
#let body-leading = 1.345em             // double spacing: Liberation Serif's line box is 0.655em, so 1.345em leading makes a 2.0em pitch (LBR 9004-1(A)); measured in README.md
#let single-leading = 0.495em            // single spacing for caption, signature block, quotations and footnotes
#let pitch = 2em                       // one double-spaced line: a heading or title block is this tall, because Liberation Serif's line box (0.655em) is shorter than its glyphs
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.6in               // width of the party column of the caption (LBR 9004-2(A) caption)
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "NORTHERN DISTRICT OF OKLAHOMA")  // LBR 9004-2(A): name of the court

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("oknb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown (headings, lists, paragraphs).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line per item: the stack keeps single spacing between items.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Caption (LBR 9004-2(A)): court name, title of the case, case number, chapter, adversary number
// ---------------------------------------------------------------------------

#let court-title() = {
  set par(leading: single-leading, spacing: 0pt)
  align(center, stack(dir: ttb, spacing: single-leading,
    text(weight: "bold", court-name.at(0)),
    text(weight: "bold", court-name.at(1)),
  ))
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    let rows = ()
    if "in_re" in meta.caption {
      rows.push("In re:")
      rows.push(..meta.caption.in_re.names)
      rows.push(meta.caption.in_re.designation)
      rows.push("")
    }
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    line-stack((
      "Case No. " + meta.case_number,
      "Chapter " + meta.chapter,
      "Adv. No. " + meta.adversary_number,
    ))
  }),
)

#let title-block(meta) = {
  v(body-leading)
  block(width: text-width, height: pitch, align(center, text(weight: "bold", meta.title)))
  v(body-leading * 0.5)
}

// ---------------------------------------------------------------------------
// Generated sections (rule-driven text; only frontmatter values are filled in)
// ---------------------------------------------------------------------------

/// Jurisdiction and venue as numbered paragraphs (FRBP 7008(a): the allegation of jurisdiction names
/// the case, its number, its chapter and the district where it is pending, and states whether the
/// proceeding is core or non-core and whether the pleader consents to final orders by the bankruptcy judge).
#let jurisdiction-md(meta) = {
  let j = meta.jurisdiction
  let c = meta.core
  let p1 = "This adversary proceeding relates to the chapter " + meta.chapter + " bankruptcy case of " + j.case_name + ", Case No. " + meta.case_number + ", which was commenced by the filing of a voluntary petition on " + j.petition_date + " and is pending in the United States Bankruptcy Court for the Northern District of Oklahoma."
  let p2 = "The Court has jurisdiction under 28 U.S.C. §§ 1334(b) and 157(a) and (b)(1)."
  let p3 = if c.is_core {
    "This is a core proceeding under 28 U.S.C. § 157(b)(2)" + c.subsection + "."
  } else {
    "This is a non-core proceeding under 28 U.S.C. § 157(c)(1)."
  }
  let p3b = if c.consent {
    "Plaintiff does consent to the entry of final orders or judgment by the Bankruptcy Court."
  } else {
    "Plaintiff does not consent to the entry of final orders or judgment by the Bankruptcy Court."
  }
  let p4 = "Venue is proper in this district under 28 U.S.C. §§ 1408 and 1409(a)."
  "# Jurisdiction and Venue\n\n" + (p1, p2, p3 + " " + p3b, p4).join("\n\n")
}

/// Jury demand, only when the frontmatter asks for it (FRBP 9015).
#let jury-md(meta) = if meta.jury_demand {
  "\n\n# Demand for Jury Trial\n\nPlaintiff demands a trial by jury on all claims so triable, as provided by Fed. R. Civ. P. 38 and 39, made applicable by Fed. R. Bankr. P. 9015."
} else { "" }

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Numbered paragraphs (Fed. R. Civ. P. 10(b), incorporated by FRBP 7010). Each blank-line-separated chunk
/// of markdown that is neither a heading nor a list is one numbered paragraph. Headings and lists are not
/// numbered. Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps
/// paragraph content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  // Footnote definitions (`[^key]: text`) are attached to the chunk that references them, because each
  // chunk is rendered separately. A definition-only chunk is skipped, so it takes no paragraph number.
  let defs = body.matches(regex("(?m)^\\[\\^[^\\]]+\\]:[^\\n]*")).map(m => m.text)
  let notes-for(t) = {
    let refs = t.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0))
    defs.filter(d => refs.any(r => d.starts-with("[^" + r + "]:"))).join("\n\n")
  }
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "" and not c.trim().starts-with("[^"))
  // Paragraphs and lists are plain flow content: double spacing comes from `leading`, the gap between
  // paragraphs from `spacing`, both set here for the whole body.
  set par(leading: body-leading, spacing: body-leading)
  // The prayer for relief is not numbered paragraphs (Fed. R. Civ. P. 10(b) numbers the claims).
  let numbered = true
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // A heading is a native typst heading (a block), not cmarker output, so it takes its own vertical space.
      let level = t.find(regex("^#+")).len()
      let title = t.slice(level).trim()
      numbered = not title.starts-with("Prayer")
      heading(level: level, title)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      md(t + "\n\n" + notes-for(t))
      parbreak()
    } else {
      // A numbered paragraph: the number is counted in the flow, so it follows the previous paragraph.
      if numbered {
        para-counter.step()
        [#h(para-indent)#context para-counter.display().#h(0.3in)#md(t + "\n\n" + notes-for(t))]
      } else {
        md(t + "\n\n" + notes-for(t))
      }
      parbreak()
    }
  }
}

/// Signature block (LBR 9004-1(C)): the signer's full name, state bar number, address, email, telephone,
/// and the party represented appear beneath the signature line.
#let signature-block(meta) = {
  let s = meta.signature
  assert("bar_number" in s, message: "oknb-adversary-complaint: signature.bar_number is required (LBR 9004-1(C))")
  assert("telephone" in s, message: "oknb-adversary-complaint: signature.telephone is required (LBR 9004-1(C))")
  assert("email" in s, message: "oknb-adversary-complaint: signature.email is required (LBR 9004-1(C))")
  block(width: text-width, breakable: false, above: body-leading, {
    grid(
      columns: (2.6in, 1fr),
      column-gutter: 0.2in,
      [Dated: #meta.date],
      {
        set par(leading: single-leading, spacing: 0pt, justify: false)
        [Respectfully submitted,]
        v(12pt)
        line-stack((s.firm,))
        v(12pt)
        line-stack((
          "By: /s/ " + s.signer,
          s.signer + " (" + s.bar_number + ")",
          ..s.address,
          "Telephone: " + s.telephone,
          "Email: " + s.email,
          "Attorneys for " + s.for,
        ))
      },
    )
  })
}

#let oknb-adversary-complaint(meta, body) = {
  assert("adversary_number" in meta, message: "oknb-adversary-complaint: adversary_number is required (LBR 9004-2(A))")
  assert("chapter" in meta, message: "oknb-adversary-complaint: chapter is required (LBR 9004-2(A))")
  assert("core" in meta, message: "oknb-adversary-complaint: core (is_core, subsection, consent) is required (FRBP 7008(a))")

  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
    footer-descent: 0.4in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set heading(numbering: none)

  // Headings: level 1 is a centered section; level 2 a centered bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => block(width: text-width, height: pitch, above: body-leading, below: 0pt, breakable: false,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, height: pitch, above: body-leading, below: 0pt, breakable: false,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: text-width, height: pitch, above: body-leading, below: 0pt, breakable: false,
    text(weight: "bold", style: "italic", it.body))

  // Footnotes: the same size as the text (LBR 9004-1(A) includes footnotes in the 12-point minimum).
  set footnote.entry(
    gap: 0.5em, clearance: 0.9em, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(left: para-indent, right: para-indent, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
    it.body
  }))

  // Cover: court title, caption, title of the paper (LBR 9004-2(A)).
  court-title()
  v(body-leading)
  assert("parties" in meta.caption, message: "oknb-adversary-complaint: caption.parties is required (LBR 9004-2(A))")
  caption(meta)
  title-block(meta)

  // Body: generated jurisdiction, then the sample's own sections, then the optional jury demand.
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(jurisdiction-md(meta) + "\n\n" + body + jury-md(meta), para-counter)

  signature-block(meta)
}
