// U.S. Bankruptcy Court, E.D. Oklahoma: complaint commencing an adversary proceeding.
//
// Rule-driven and content-agnostic. Governing rules are cited in ../README.md:
//   FRBP 7001 (adversary proceeding), FRBP 7010 (FRCP 10 applies; caption substantially conforms
//   to Official Form 416D), LBR 7001-1(A), LBR 9004-1 (paper, type size, margins, double spacing,
//   signature block), LBR 9004-2 (caption contents).
// No case-specific text, no coordinates measured off any filed complaint, no forced line breaks.
// The markdown body is rendered by cmarker, one chunk (a blank-line-separated block) at a time; the metadata comes
// from the YAML frontmatter of the same sample file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // LBR 9004-1(A) names no face; Times New Roman, the house standard and the exemplars' face (vendored metric twin)
#let type-size = 12pt                    // LBR 9004-1(A): no less than 12 point, footnotes included
#let page-margin = 1in                   // LBR 9004-1(A): margins no less than one inch
#let para-indent = 0.5in                 // first-line indent of every body paragraph; the allegation number stands there
#let list-indent = 1in                   // property lists (bulleted in the markdown): each item one line this far in
#let caption-left = 3.5in                // width of the party column of the caption
#let caption-pad = 0.2in                 // the party column's text this far off the rule
#let caption-gap = 0.3in                 // the number column's text this far off the rule
#let name-indent = 0.5in                 // the debtor's and each party's names
#let role-indent = 2.2in                 // "Debtor.", "Plaintiff,", "Defendants." under the names
#let versus-indent = 1.2in               // "v." between the parties
#let signature-indent = 3.25in           // the signature block stands this far from the left margin
#let rule = 0.75pt                       // the caption's rule
#let note-gap = 7pt                      // between two footnotes (Word: Footnote Text's space after)
#let note-clearance = 7.5pt              // from the text to the footnote rule (the space LibreOffice keeps above it)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 27.6pt               // LBR 9004-1(A): pleadings double spaced; Word's double (2 x 1.15 x 12 pt)
#let pitch-single = 13.8pt               // single spacing (1.15 x 12 pt): court, caption, property lists, footnotes, signature

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Inline or block markdown (the body, and footnote definitions folded into the chunk that refers to them).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("okeb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("okeb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A frontmatter value that is one string or a list of them, as a list.
#let strs(v) = if type(v) == array { v } else { (v,) }

/// One single-spaced line block (a paragraph of its own), with explicit space above it. An empty line keeps its
/// height. Caption and signature strings are text, not markdown.
#let line-block(above: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: 0pt,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, if type(body) == str { body } else { body })
})

/// A centered bold line at the body pitch (the title and the headings), kept with the block after it.
#let center-line(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  align(center, strong(upper(body)))
})

// ---------------------------------------------------------------------------
// Caption (Official Form 416D, LBR 9004-2): the court in two bold lines; a double line below, the party column
// (3.5 in, closed by a rule at its right) and the number column; one single line each, never split.
// ---------------------------------------------------------------------------

#let caption(meta) = {
  line-block(align(center, strong[UNITED STATES BANKRUPTCY COURT]))
  line-block(align(center, strong[EASTERN DISTRICT OF OKLAHOMA]))
  let left = (line-block("In re:"), line-block(""))
  for d in strs(need(meta, "debtor")) { left.push(line-block(left: name-indent, d)) }
  left.push(line-block(left: role-indent, meta.at("debtor_role", default: "Debtor.")))
  for (i, p) in need(meta, "parties").enumerate() {
    left.push(line-block(""))
    if i > 0 { left += (line-block(left: versus-indent, "v."), line-block("")) }
    left.push(line-block(left: name-indent, p.names))
    left.push(line-block(left: role-indent, p.role))
  }
  // LBR 9004-2: the case number with the judge's initials, the chapter directly under it, the adversary number
  let judge = meta.at("judge", default: "")
  let right = (
    line-block("Case No. " + need(meta, "case_number") + if judge != "" { "-" + judge } else { "" }),
    line-block("Chapter " + str(need(meta, "chapter"))),
    line-block(above: pitch-single, "Adv. Proc. No. " + need(meta, "adversary_number")),
  )
  block(width: 100%, above: pitch-double, below: 0pt, breakable: false, table(
    columns: (caption-left, 1fr), stroke: none, inset: 0pt,
    table.cell(stroke: (right: rule), inset: (right: caption-pad), left.join()),
    table.cell(inset: (left: caption-gap), right.join()),
  ))
}

// ---------------------------------------------------------------------------
// Body: blank-line-separated chunks. "# " and "## " headings; "N. " an allegation, numbered consecutively over the
// whole complaint (FRCP 10(b); the typed numbers are ignored); "- " lines a property list; anything else an
// unnumbered paragraph. Footnote definitions ("[^x]: ...") go with the chunk that refers to them.
// ---------------------------------------------------------------------------

#let complaint-body(body) = {
  let chunks = ()
  let notes = ()
  for c in body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "") {
    let m = c.match(regex("^\\[\\^([^\\]]+)\\]:"))
    if m != none { notes.push((m.captures.at(0), c)) } else { chunks.push(c) }
  }
  let n = 0
  for (k, t) in chunks.enumerate() {
    // the last block stays whole with the signature block
    let keep = k == chunks.len() - 1
    for (label, def) in notes { if t.contains("[^" + label + "]") { t += "\n\n" + def } }
    let h = t.match(regex("^#+\\s+(.*)$"))
    let li = t.match(regex("^\\d+\\.[ \\t]+([\\s\\S]*)$"))
    if h != none {
      center-line(md(h.captures.at(0)))
    } else if t.starts-with("- ") {
      // a property list: one single line each, an inch in, a single line above and below
      let items = t.split("\n").map(l => l.replace(regex("^-\\s+"), ""))
      block(width: 100%, above: pitch-single, below: pitch-single, sticky: keep, breakable: not keep,
        for it in items { line-block(left: list-indent, md(it)) })
    } else {
      let text = if li != none { n += 1; [#n. #md(li.captures.at(0))] } else { md(t) }
      if keep {
        block(width: 100%, above: 0pt, below: 0pt, sticky: true, breakable: false, [#text#parbreak()])
      } else {
        // Not a block: inside a block, typst places a footnote on a later page than its reference. The paragraph
        // break ends it (each chunk is its own paragraph).
        [#text#parbreak()]
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (LBR 9004-1(C): name, bar number, address, email, telephone, fax, party), a double line below the
// body: the dated line at the margin (if any), "Respectfully submitted:" 3.25 in from the margin, a single line below
// it the electronic signature and the block; single spaced, never split.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
    if "date" in meta { line-block("Dated: " + meta.date) }
    line-block(above: if "date" in meta { pitch-single } else { 0pt }, left: signature-indent,
      "Respectfully submitted:")
    line-block(above: pitch-single, left: signature-indent, "s/ " + sig.electronic)
    for l in sig.lines { line-block(left: signature-indent, l) }
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let okeb-adversary-complaint(meta, body) = {
  set document(title: need(meta, "title"))
  // Pages numbered at the foot, centered, in a single line box, where Word's footer sets it.
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (LBR 9004-1(A): double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled section sign stays with its number (xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // LBR 9004-1(A): footnotes at the text size, single lines, under a 30 % rule, 7 pt between notes; the mark and a
  // space before the text (Word's footnote).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  caption(meta)
  // the title a double line below the caption, at the body pitch
  center-line(above: pitch-double, need(meta, "title"))
  complaint-body(body)
  signature-block(meta)
}
