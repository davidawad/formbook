// Adversary complaint for the United States Bankruptcy Court for the District of Columbia (dcb).
// Rules: Fed. R. Bankr. P. 7010 (Fed. R. Civ. P. 10 applies; the caption substantially conforms to Official Form 416),
// 9004(a) (legible) and 9004(b) (caption: court, title, case and adversary number, designation of the paper),
// 7008(a) (reference to the name, number and chapter of the case; whether the pleader consents to final orders),
// Local Bankruptcy Rule 7012-1 (consent statement in the initial substantive filing), LBR 5005-1(c)
// (attorney identifiers on the first page), Fed. R. Civ. P. 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no D.C. Bankruptcy rule sets a face; vendored in fonts/ (README.md, gap 2)
#let type-size = 12pt                   // no D.C. Bankruptcy rule sets a size; 12 pt matches the exemplar's body (README.md, gap 2)
#let para-indent = 0.5in                // first-line indent of body paragraphs; the paragraph number's box after it
#let margin = 1in                       // 1-inch margins on all sides (the exemplar; LBR 5005-1(b) for pro se papers)
#let caption-left = 3.3in               // width of the party column of the caption
#let caption-mid = 0.35in               // width of the ")" column
#let sig-left = 2.8in                   // signature grid: the "Dated" column, a gutter, the signature column
#let sig-gutter = 0.2in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // double spacing: the exemplar's body lines are 27.6 pt apart (measured, README.md)

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

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

// ---------------------------------------------------------------------------
// Cover: counsel block (upper left, LBR 5005-1(c)), court name, caption, title of the paper
// ---------------------------------------------------------------------------

#let counsel-block(c) = {
  assert(c.email.contains("@"), message: "dcb-adversary-complaint: counsel.email is required (LBR 5005-1(c))")
  assert(c.represents.len() > 0, message: "dcb-adversary-complaint: counsel.represents is required (LBR 5005-1(c))")
  for l in (c.name, c.bar, c.firm, ..c.address, c.phone, c.email, ..c.represents) { line-block(md(l)) }
}

#let court-title(meta) = {
  for (i, l) in meta.court.enumerate() {
    line-block(above: if i == 0 { pitch-double } else { 0pt }, below: if i == meta.court.len() - 1 { pitch-single } else { 0pt },
      align(center, text(weight: "bold", l)))
  }
}

/// The caption: parties on the left, a column of ")" marks, and the case numbers on the right, one grid row per
/// line. The right column holds "In re:", the case number and the chapter at the debtor's lines; the adversary
/// number at the plaintiff's first line (FRBP 9004(b)).
#let caption(meta) = {
  let c = meta.caption
  let left = c.debtor.names + (c.debtor.designation, "") + c.plaintiff.names + (c.plaintiff.designation, "v.", "") + c.defendant.names + (c.defendant.designation,)
  let plaintiff-first = c.debtor.names.len() + 2
  let adv = if c.adversary_number == "" { "____________" } else { c.adversary_number }
  let right = range(left.len()).map(i => {
    if i == 0 { "In re:" } else if i == 1 { "Case No. " + c.case_number } else if i == 2 { "(Chapter " + c.chapter + ")" } else if i == plaintiff-first { "Adv. Case No. " + adv } else { "" }
  })
  block(above: pitch-single, below: pitch-double, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    grid(
      columns: (caption-left, caption-mid, 1fr),
      ..range(left.len()).map(i => (md(left.at(i)), align(center, ")"), md(right.at(i)))).flatten(),
    )
  })
}

#let cover(meta) = {
  counsel-block(meta.counsel)
  court-title(meta)
  caption(meta)
  line-block(below: pitch-double, align(center, text(weight: "bold", meta.title)))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, statement on final orders, signature
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch, first-line indented; a numbered one (Fed. R. Civ. P. 10(b)) has its number
/// in a box of the paragraph indent after the indent.
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), if num == none { content } else {
    [#box(width: para-indent, [#num.])#content]
  }))

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
  heading(level: 1, outlined: false)[Statement on Final Orders and Judgments]
  body-par(none)[This adversary proceeding arises in the chapter #meta.caption.chapter case of #emph[In re #debtor], Case No. #meta.caption.case_number. #stmt]
}

/// Body paragraphs: each blank-line-separated chunk is a paragraph. Chunks after the first heading are numbered
/// (Fed. R. Civ. P. 10(b)); a chunk before the first heading (the lead-in) and a WHEREFORE paragraph are not.
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let first-h = chunks.position(c => c.trim().starts-with("#"))
  let n = 0
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if (first-h == none or i > first-h) and not t.starts-with("WHEREFORE") {
      n += 1
      body-par(n, md(t))
    } else {
      body-par(none, md(t))
    }
  }
}

/// The signature block: "Dated" at the left; "Respectfully submitted," and the signer's lines at the right.
#let signature-block(s) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
  columns: (sig-left, 1fr),
  column-gutter: sig-gutter,
  line-block[Dated: #s.date],
  {
    line-block[Respectfully submitted,]
    let lines = ("By: /s/ " + s.signer, s.signer, ..if "bar" in s { (s.bar,) } else { () }, ..s.address,
      "Phone: " + s.phone, ..if "fax" in s { ("Facsimile: " + s.fax,) } else { () }, "Email: " + s.email, ..s.role)
    for (i, l) in lines.enumerate() { line-block(above: if i == 0 { pitch-single } else { 0pt }, md(l)) }
  },
))

#let dcb-adversary-complaint(meta, body) = {
  // The page number: centered in a single-spaced line box, at the same place on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // Headings: one centered line at the body pitch, level 1 bold; kept with the text after them.
  show heading: it => block(sticky: true, width: 100%, above: 0pt, below: 0pt, {
    set par(first-line-indent: 0pt)
    set text(size: type-size)
    align(center, text(weight: if it.level == 1 { "bold" } else { "regular" }, it.body))
  })
  cover(meta)
  allegations(body)
  // The statement on final orders stays with the signature block, so a signature never stands alone on a page.
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    final-orders(meta)
    signature-block(meta.signature)
  })
}

