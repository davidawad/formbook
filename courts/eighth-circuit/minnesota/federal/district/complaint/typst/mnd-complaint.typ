// Complaint for the United States District Court for the District of Minnesota.
// Rules: Fed. R. Civ. P. 8(a) (short and plain statement; jurisdiction, claim, demand for relief),
// 10(a) (caption: court, title, file number, parties), 10(b) (numbered paragraphs), 38(b) (jury demand);
// D. Minn. LR 5.2(a) (double-spaced, pages numbered at the bottom). The case-initiating document carries
// no judge initials (LR 5.2(a) applies to documents filed after it). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // vendored in fonts/; the complaint has no type-size rule in the local rules
#let type-size = 13pt                   // D. Minn. LR 7.1(h)(1) sets 13 point for memoranda; used here too (open choice, see README.md)
#let page-w = 8.5in                     // LR 5.2(a) and Fed. R. Civ. P. 10: letter paper, numbered pages
#let page-h = 11in
#let margin = 1in
#let para-indent = 0.5in                // first-line indent; the paragraph number's box after it
#let item-indent = 0.5in                // prayer items: the letter half an inch in, the text a box after it
#let caption-left = 3.3in               // the party column of the caption
#let caption-gutter = 0.3in             // between the party column and the file-number column
#let caption-pad = 8pt                  // the party column's rules stand off the text
#let right-inset = 0.1in                // the file-number column stands off the gutter
#let vs-indent = 0.3in                  // "v." in the party column
#let designation-indent = 1.2in         // "Plaintiffs," / "Defendant." in the party column
#let sig-left = 2.6in                   // signature grid: the "Dated" column, a gutter, the signature column
#let sig-gutter = 0.2in
#let court-lines = ("UNITED STATES DISTRICT COURT", "DISTRICT OF MINNESOTA")  // the court's name, not the case's

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 14.95pt             // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // LR 5.2(a): double-spaced (29.9 pt, the exemplar's pitch)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mnd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for case names and party names).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

// ---------------------------------------------------------------------------
// Front page: court name, caption (party column; file number and title), then the body
// ---------------------------------------------------------------------------

#let court-title() = for l in court-lines { line-block(align(center, text(weight: "bold", l))) }

#let caption(meta) = block(above: pitch-double, below: pitch-double, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (top: 0.75pt, bottom: 0.75pt), inset: (top: caption-pad, bottom: caption-pad), {
    // Each party: its names, then its designation, indented; "v." between the parties.
    for (k, p) in meta.caption.enumerate() {
      if k > 0 { line-block(indent: vs-indent, "v.") }
      for n in p.names { line-block(inl(n)) }
      line-block(indent: designation-indent, inl(p.designation))
    }
  }),
  pad(left: right-inset, top: caption-pad, {
    // A complaint is filed before a case number is assigned: the file number is left blank for the clerk. It stands
    // level with the first party line, the title level with the third.
    let number = if meta.case_number == "" { "____________________" } else { meta.case_number }
    line-block[Civil No. #number]
    line-block(above: pitch-single, align(center, text(weight: "bold", upper(meta.brief_title))))
  }),
))

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)); headings; lettered prayer items; signature
// ---------------------------------------------------------------------------

/// Signature block: the date on the left, the firm and signer on the right (single-spaced); it never breaks across
/// a page. A "" line is a blank line.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, grid(
  columns: (sig-left, 1fr),
  column-gutter: sig-gutter,
  line-block[Dated: #meta.date],
  for l in meta.signature { line-block(if l == "" { "\u{00A0}" } else { inl(l) }) },
))

/// A body paragraph at the double pitch: unnumbered (first-line indent), numbered (Fed. R. Civ. P. 10(b): the
/// number in a box of the paragraph indent after the first-line indent, the text after it), or a lettered prayer
/// item (the letter half an inch in, the text hanging a box after it).
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt, if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: para-indent, [#num.])#content])
})
#let prayer-item(letter, content) = block(width: 100%, above: 0pt, below: 0pt, pad(left: item-indent,
  par(hanging-indent: item-indent, first-line-indent: 0pt, [#box(width: item-indent, letter)#content])))

/// The body, one chunk (blank-line separated) at a time. A heading or lettered item is set as itself;
/// every other chunk is a numbered allegation, except the lead-in, the jury demand and the prayer.
#let body-chunks(body) = {
  let numbered = false
  let n = 0
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t.starts-with("#") {
      // The jury demand and the prayer are not numbered; the counts and the parties are.
      let head = t.split("\n").first()
      if head.starts-with("# DEMAND") or head.starts-with("# PRAYER") {
        numbered = false
      } else if head.starts-with("# ") {
        numbered = true
      }
      md(t)
    } else if t.starts-with(regex("^[A-Z][.)][ \t]")) {
      // A lettered item of the prayer: hanging from the letter, not numbered.
      let m = t.match(regex("^([A-Z][.)])[ \t]+([\\s\\S]*)$"))
      prayer-item(m.captures.at(0), md(m.captures.at(1)))
    } else if numbered {
      n += 1
      body-par(n, md(t))
    } else {
      body-par(none, md(t))
    }
  }
}

#let mnd-complaint(meta, body) = {
  // Page numbers centred at the bottom (LR 5.2(a)), arabic, on every page; the number in a single-spaced line box,
  // so it sits at the same place on every page (Word's footer).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (LR 5.2(a): double-spaced).
  show: xengine.with(pitch: pitch-double, list-indent: item-indent)
  // A web address breaks only after "?", "=", "&", a hyphen or a slash that no digit (nor a second slash) follows:
  // each part is a box, so the PDF text keeps the author's characters. Without this typst breaks a URL at any
  // character, which Word does not (the docx filter sets the same break points; ca8 briefs).
  show regex("(https?://|www\\.)\\S+"): it => {
    let parts = ("",)
    let cs = it.text.clusters()
    for (i, c) in cs.enumerate() {
      parts.last() += c
      let next = cs.at(i + 1, default: "")
      let prev = cs.at(i - 1, default: "")
      if c in ("?", "=", "&") or (c in ("/", "-") and next != "/" and not (c == "/" and prev == "/")
        and next.match(regex("^[0-9]$")) == none) { parts.push("") }
    }
    parts.filter(p => p != "").map(p => box(p)).join()
  }

  // Headings: level 1 centred, bold, capitals as written (PARTIES, COUNT I: ...); level 2 centred and bold (the
  // statute under which a count is brought). At the body size and pitch, no space of their own (the double pitch
  // sets them off); sticky, so a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, align(center, text(weight: "bold", it.body)))
  }

  court-title()
  caption(meta)
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }
  body-chunks(body)
  signature-block(meta)
}
