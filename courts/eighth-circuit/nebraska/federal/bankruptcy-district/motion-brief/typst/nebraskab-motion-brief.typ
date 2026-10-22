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
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "TeX Gyre Bonum"           // no Nebraska font rule; the exemplar is set in Bookman Old Style (data/exemplar-fonts.json), TeX Gyre Bonum its vendored metric kin
#let type-size = 12pt                   // legible (FRBP 9004(a)); no rule sets a size; 12 pt, the exemplar's body size
#let footnote-size = 11pt               // footnotes: not body text; no rule sets a size
#let margin = 1in                       // no Nebraska margin rule; 1 inch on every side (conventional)
#let para-indent = 0.5in                // first-line indent of body paragraphs; the box of a subsection letter
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-gutter = 0.25in            // between the party column and the case-number column
#let sig-left = 3in                     // the signature column starts 3 in from the margin (3.5 in wide)
#let caption-indent = 0.5in             // "v." in the party column
#let designation-indent = 1in           // "Plaintiff," / "Defendants." in the party column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 14.4pt              // a single line: 1.2 x the type size (Bonum's tall face needs more than Times' 1.15)
#let pitch-double = 2 * pitch-single    // double spacing (the folder's choice; no rule sets one): 28.8 pt
#let pitch-note = 13.2pt                // a single line of an 11 pt footnote (1.2 x)

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

/// Footnote definitions `[^key]: text`, collected from the body (one per line).
#let footnote-defs(body) = {
  let defs = (:)
  for line in body.split("\n") {
    let m = line.match(regex("^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$"))
    if m != none { defs.insert(m.captures.at(0), m.captures.at(1)) }
  }
  defs
}

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

/// An empty single-spaced line.
#let blank-line = block(width: 100%, height: pitch-single, above: 0pt, below: 0pt)

/// A column of the caption: each entry a line block ("" a blank line, (text, indent) an indented one).
#let column(entries) = for e in entries {
  if type(e) == array { line-block(indent: e.at(1), inl(e.at(0))) }
  else if e == "" { blank-line }
  else { line-block(inl(e)) }
}

// ---------------------------------------------------------------------------
// Caption and title (FRBP 9004(b); Official Form 416 layout, title in the right column)
// ---------------------------------------------------------------------------

/// Two rows of three columns (party column, gutter, case column). Row 1: the "In re:" block and the case lines, the
/// rule under its party column. Row 2: the parties with "v." between them and the intervenors after them; the
/// adversary line, a blank double line, and the title in bold capitals.
#let caption(meta) = {
  let left-a = ("In re:",) + meta.in_re + ("",)
  let right-a = ("",) + meta.case_lines
  let left-b = ("",)
  for (k, p) in meta.parties.enumerate() {
    if k > 0 { left-b += ("", ("v.", caption-indent), "") }
    left-b += p.names + ("", (p.designation, designation-indent))
  }
  for p in meta.at("intervenors", default: ()) {
    left-b += ("", "") + p.names + ("", (p.designation, designation-indent))
  }
  block(width: 100%, above: pitch-double, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    grid.cell(stroke: (bottom: 0.5pt), column(left-a)), blank-line, column(right-a),
    column(left-b), blank-line,
    {
      column(("", meta.adversary_line, "", ""))
      line-block(text(weight: "bold", inl(upper(meta.title))))
    },
  ))
}

#let cover(meta) = {
  for l in court-name { line-block(align(center, text(weight: "bold", l))) }
  caption(meta)
  blank-line   // a single blank line between the caption and the text
}

// ---------------------------------------------------------------------------
// Body: sections (roman), subsections (letters), paragraphs
// ---------------------------------------------------------------------------

/// A heading line at the body pitch, bold, kept with the text after it.
#let heading-line(body) = block(width: 100%, sticky: true, above: 0pt, below: 0pt, {
  set par(first-line-indent: 0pt)
  text(weight: "bold", body)
})

/// A body paragraph at the double pitch, first-line indented.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), content))

/// Body text. Each blank-line-separated chunk is one block. Sections (level 2) are numbered I., II., ...;
/// subsections (level 3) A., B., ... restart under each section; level 1 is unnumbered (CERTIFICATE OF
/// SERVICE is generated, not in the body). Paragraphs are not numbered (a brief's numbering is typed by
/// the author, as in the exemplar's responses 1 to 8, which the sample types). `tail` (the signature block) follows
/// the last chunk; a last paragraph and the tail form one unbreakable block, so the signature never stands alone.
#let body-chunks(body, notes, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "" and not c.trim().starts-with("[^"))
  let sec-n = 0
  let sub-n = 0
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      let m = t.match(regex("^(#+)[ \t]+(.*)$"))
      let level = m.captures.at(0).len()
      let title = m.captures.at(1)
      if level == 2 {
        sec-n += 1
        sub-n = 0
        heading-line(align(center, [#numbering("I.", sec-n) #inl(upper(title))]))
      } else if level == 3 {
        sub-n += 1
        heading-line(par(hanging-indent: para-indent, [#box(width: para-indent, numbering("A.", sub-n))#inl(title)]))
      } else {
        heading-line(align(center, inl(upper(title))))
      }
    } else {
      // cite-and-define: a footnote definition used by this chunk is rendered with it
      let extra = ""
      for m in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
        let key = m.captures.at(0)
        extra += "\n\n[^" + key + "]: " + notes.at(key)
      }
      if last {
        block(width: 100%, breakable: false, above: 0pt, below: 0pt, { body-par(md(t + extra)); tail })
      } else {
        body-par(md(t + extra))
      }
    }
    if last and t.starts-with("#") { tail }
  }
}

// ---------------------------------------------------------------------------
// Signature and certificate of service
// ---------------------------------------------------------------------------

/// The signature block in the right column: the party line, a blank line, the signer's lines. One unbreakable
/// block, `above` below the text.
#let signature-grid(above, lines) = block(width: 100%, breakable: false, above: above, below: 0pt, grid(
  columns: (sig-left, 1fr),
  [],
  column(lines),
))

/// CM/ECF certificate (LR 5005-1(C): a certificate states how service on non-CM/ECF participants was made;
/// the sample's filing is served on CM/ECF participants only). Kept on its own page.
#let certificate(meta) = {
  pagebreak()
  block(width: 100%, above: 0pt, below: pitch-double, heading-line(align(center, "CERTIFICATE OF SERVICE")))
  body-par[I hereby certify that on #inl(meta.certificate.date), I electronically filed the foregoing document with the Clerk of the Court using the #box[CM/ECF] system which sent notification of said filing to all #box[CM/ECF] participants.]
  signature-grid(2 * pitch-double, ("/s/ " + meta.certificate.signer, "", meta.certificate.signer))
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let nebraskab-motion-brief(meta, body) = {
  // The page number: centered in a single-spaced line box, at the same place on every page (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced), footnote marks at 58 %, a section sign kept with its number.
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // "§§ 547" stays whole: the shared rule binds the last sign to the number, and a line could otherwise end
  // between the two signs (Word never breaks there).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes: 11 pt, single spaced; the footnote area costs what LibreOffice gives it, so a note moves to the
  // next page in both engines alike.
  set footnote.entry(gap: 7pt, clearance: 9pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: footnote-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt, spacing: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    // a note is never split across pages (Word keeps its lines together)
    block(breakable: false, [#super(num)#h(0.25em)#note.body])
  }

  cover(meta)
  body-chunks(body, footnote-defs(body), signature-grid(pitch-double, (meta.signature.party, "") + meta.signature.lines))
  certificate(meta)
}
