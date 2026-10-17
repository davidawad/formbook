// Adversary complaint for the United States Bankruptcy Court for the District of Columbia (dcb).
// Rules: Fed. R. Bankr. P. 7010 (Fed. R. Civ. P. 10 applies; the caption substantially conforms to Official Form 416),
// 9004(a) (legible) and 9004(b) (caption: court, title, case and adversary number, designation of the paper),
// 7008(a) (reference to the name, number and chapter of the case; whether the pleader consents to final orders),
// Local Bankruptcy Rule 7012-1 (consent statement in the initial substantive filing), LBR 5005-1(c)
// (attorney identifiers on the first page), Fed. R. Civ. P. 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no D.C. Bankruptcy rule sets a face; vendored in fonts/ (README.md, gap 2)
#let type-size = 12pt                   // no D.C. Bankruptcy rule sets a size; 12 pt matches the exemplar's body (README.md, gap 2)
#let pitch = 27.6pt                     // double spacing: the exemplar's body lines are 27.6 pt apart (measured, README.md)
#let body-leading = 1.65em              // gives a 27.6 pt baseline pitch at 12 pt in EB Garamond (measured, README.md)
#let single-leading = 0.45em            // counsel, caption, signature and recipients
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let margin = 1in                       // 1-inch margins on all sides (the exemplar; LBR 5005-1(b) for pro se papers)
#let text-width = 8.5in - 2 * margin
#let caption-left = 3.3in               // width of the party column of the caption
#let caption-mid = 0.35in               // width of the ")" column

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("dcb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline and block markdown (case names, the sample's emphasis).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line per item.
#let lines-stack(items) = {
  set par(leading: single-leading, spacing: 0pt)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => [#i]))
}

// ---------------------------------------------------------------------------
// Cover: counsel block (upper left, LBR 5005-1(c)), court name, caption, title of the paper
// ---------------------------------------------------------------------------

#let counsel-block(c) = {
  assert(c.email.contains("@"), message: "dcb-adversary-complaint: counsel.email is required (LBR 5005-1(c))")
  assert(c.represents.len() > 0, message: "dcb-adversary-complaint: counsel.represents is required (LBR 5005-1(c))")
  lines-stack((c.name, c.bar, c.firm, ..c.address, c.phone, c.email, ..c.represents))
}

#let court-title(meta) = {
  stack(dir: ttb, spacing: single-leading, ..meta.court.map(l => align(center, text(weight: "bold", l))))
}

/// The caption: parties on the left, a column of ")" marks, and the case numbers on the right.
/// The right column holds "In re:", the case number and the chapter at the debtor's lines; the
/// adversary number at the plaintiff's first line (FRBP 9004(b)).
#let caption(meta) = {
  let c = meta.caption
  let left = c.debtor.names + (c.debtor.designation, "") + c.plaintiff.names + (c.plaintiff.designation, "v.", "") + c.defendant.names + (c.defendant.designation,)
  let plaintiff-first = c.debtor.names.len() + 2
  let adv = if c.adversary_number == "" { "____________" } else { c.adversary_number }
  let right = range(left.len()).map(i => {
    if i == 0 { "In re:" } else if i == 1 { "Case No. " + c.case_number } else if i == 2 { "(Chapter " + c.chapter + ")" } else if i == plaintiff-first { "Adv. Case No. " + adv } else { "" }
  })
  set text(size: type-size)
  set par(leading: single-leading, spacing: 0pt)
  grid(
    columns: (caption-left, caption-mid, 1fr),
    row-gutter: single-leading,
    ..range(left.len()).map(i => (left.at(i), align(center, ")"), right.at(i))).flatten(),
  )
}

#let cover(meta) = {
  counsel-block(meta.counsel)
  v(pitch)
  court-title(meta)
  v(pitch * 0.5)
  caption(meta)
  v(pitch)
  align(center, text(weight: "bold", meta.title))
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, statement on final orders, signature
// ---------------------------------------------------------------------------

/// Fill whole lines: the block is rounded up to a multiple of `pitch`, so the paragraph after it starts on the
/// next line of the grid. Without it, consecutive paragraphs overprint: leading applies inside a paragraph only.
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// A level-1 heading: one centered bold line.
#let heading-line(c) = block(width: text-width, height: pitch, above: 0pt, below: 0pt, sticky: true, align(center, text(weight: "bold", c)))

/// Statement on final orders and judgments (FRBP 7008(a); LBR 7012-1). The reference to the name, number and
/// chapter of the case is taken from the caption.
#let final-orders(meta) = {
  let f = meta.final_orders
  let stmt = if f.consent == "consents" {
    "Plaintiff consents to the entry of final orders and judgments by the bankruptcy judge."
  } else if f.consent == "does-not-consent" {
    "Plaintiff does not consent to the entry of final orders and judgments by the bankruptcy judge."
  } else {
    panic("dcb-adversary-complaint: final_orders.consent must be \"consents\" or \"does-not-consent\"")
  }
  let debtor = meta.caption.debtor.names.join(" ")
  block(width: text-width, above: pitch, below: 0pt, breakable: false, {
    heading-line[Statement on Final Orders and Judgments]
    par(leading: body-leading, first-line-indent: para-indent)[
      This adversary proceeding arises in the chapter #meta.caption.chapter case of #emph[In re #debtor], Case No. #meta.caption.case_number. #stmt
    ]
  })
}

/// Body paragraphs: each blank-line-separated chunk is a paragraph. Chunks after the first heading are numbered
/// (Fed. R. Civ. P. 10(b)); a chunk before the first heading (the lead-in) and a WHEREFORE paragraph are not.
/// A heading is kept in one unbreakable block with the chunk after it.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let first-h = chunks.position(c => c.trim().starts-with("#"))
  let pending = []
  let has-pending = false
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    if t.starts-with("#") {
      pending += md(t)
      has-pending = true
    } else {
      let numbered = (first-h == none or i > first-h) and not t.starts-with("WHEREFORE")
      let piece = on-grid({
        set par(leading: body-leading, first-line-indent: 0pt)
        if numbered {
          para-counter.step()
          context [#h(para-indent)#(para-counter.display()).#h(0.3in)#md(t)]
        } else {
          [#h(para-indent)#md(t)]
        }
      })
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

#let signature-block(s) = block(breakable: false, above: pitch, grid(
  columns: (2.8in, 1fr),
  column-gutter: 0.2in,
  [Dated: #s.date],
  {
    lines-stack(("Respectfully submitted,",))
    v(pitch * 0.5)
    lines-stack(("By: /s/ " + s.signer, s.signer, ..if "bar" in s { (s.bar,) } else { () }, ..s.address, "Phone: " + s.phone, ..if "fax" in s { ("Facsimile: " + s.fax,) } else { () }, "Email: " + s.email, ..s.role))
  },
))

#let dcb-adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")
  set page(
    paper: "us-letter",
    margin: (top: margin, bottom: margin, left: margin, right: margin),
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  show heading.where(level: 1): it => heading-line(it.body)
  show heading.where(level: 2): it => block(width: text-width, height: pitch, above: 0pt, below: 0pt, sticky: true, align(center, it.body))
  cover(meta)
  allegations(body, para-counter)
  final-orders(meta)
  signature-block(meta.signature)
}
