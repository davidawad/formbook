// Motion to dismiss (Rules 12(b)(1), 12(b)(6)) for the U.S. District Court for the Southern District of Texas (txsd).
// Rules: Fed. R. Civ. P. 10(a) (caption: court name, title, file number), 10(b) (numbered paragraphs, each
// limited to a single set of circumstances); the district's form rules as far as they could be retrieved (see
// ../README.md: 13-point or larger, double-spaced, 1-inch margins, 8 1/2 by 11). Content-agnostic: every
// case-specific word comes from the sample's frontmatter or body, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // no face named by S.D. Tex. LR10.2 or the judges' procedures retrieved; kept (docs/FONTS.md "No face named"); see README.md
#let type-size = 13pt                   // Galveston Div. R. of Practice f and Judge Hanks Procs. 7.A: "13-point" (not in LR10.2; see README.md)
#let double = 1.35em                    // double spacing: EB Garamond's line box is 0.65em, so 0.65em + 1.35em = 2.0 x type size
#let single = 0.5em                     // single spacing for caption, counsel and signature blocks
#let para-indent = 0.5in                // first-line indent of numbered paragraphs; hanging indent of lettered items
#let page-margin = 1in                  // 1-inch margins on all sides
#let caption-left = 3.3in               // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txsd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Blank-line-separated chunks of the body: a heading, a list, or a paragraph.
#let chunks(body) = body.replace("\r\n", "\n").split("\n\n").map(s => s.trim()).filter(s => s != "")

// ---------------------------------------------------------------------------
// Page furniture and headings
// ---------------------------------------------------------------------------

/// Court title (Fed. R. Civ. P. 10(a)): single-spaced, bold, centered.
#let court-title(meta) = block(width: 100%, above: 0pt, below: double, {
  // One paragraph with explicit lines, so the single spacing holds between the court's lines.
  set par(leading: single, spacing: 0pt)
  align(center, text(weight: "bold", {
    [UNITED STATES DISTRICT COURT #linebreak() FOR THE SOUTHERN DISTRICT OF TEXAS]
    if "division" in meta and meta.division != none { [#linebreak() #upper(meta.division)] }
  }))
})

// ---------------------------------------------------------------------------
// Caption
// ---------------------------------------------------------------------------

/// Party lines with their indent: names flush left, designation indented, "v." between parties.
#let party-rows(parties) = {
  let rows = ()
  for (k, p) in parties.enumerate() {
    if k > 0 { rows.push(("v.", 0pt)) }
    for nm in p.names { rows.push((nm, 0pt)) }
    rows.push((p.designation, para-indent))
  }
  rows
}

/// Box caption (the form used in Schott, S.D. Tex. 2026): party column closed on the right and bottom,
/// "C.A. No." and "JURY DEMANDED" at the right.
#let caption-box(meta) = {
  let rows = party-rows(meta.caption.parties)
  grid(columns: (caption-left, 1fr), column-gutter: 0.2in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 0.12in, bottom: 0.12in), {
      stack(dir: ttb, spacing: single * 1.2, ..rows.map(r => block(width: 100%, inset: (left: r.at(1)), r.at(0))))
    }),
    block(inset: (left: 0.1in), {
      let cn = meta.at("case_number", default: none)
      [C.A. No. #if cn != none { cn } else { [#h(1.6in)] }]
      v(double)
      if meta.at("jury_demand", default: false) { [JURY DEMANDED] }
    }),
  )
}

/// Section-symbol caption (the form used in Dangelas, S.D. Tex. Houston Div. 2026): one row per line, "§" at
/// the middle column, the civil action number and judge at the right.
#let caption-section(meta) = {
  let left = party-rows(meta.caption.parties)
  let right = ()
  let cn = meta.at("case_number", default: none)
  if cn != none { right.push("Civil Action No. " + cn) }
  if "judge" in meta and meta.judge != none { right.push(meta.judge) }
  let n = calc.max(left.len(), right.len() + 2)
  let cells = ()
  for i in range(n) {
    let lc = if i < left.len() { pad(left: left.at(i).at(1), left.at(i).at(0)) } else { [] }
    let rc = if i >= 2 and i - 2 < right.len() { right.at(i - 2) } else { [] }
    cells += (lc, align(center, [§]), rc)
  }
  set par(leading: single, spacing: 0pt)
  grid(columns: (caption-left, 0.4in, 1fr), row-gutter: single * 1.5, ..cells)
}

#let caption(meta) = {
  set par(leading: single, spacing: 0pt)
  if meta.caption.style == "box" { caption-box(meta) } else { caption-section(meta) }
}

// ---------------------------------------------------------------------------
// Body: paragraphs (numbered or not), headings, lists
// ---------------------------------------------------------------------------

#let letters = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t")
#let unnumbered-headings = ("PRAYER FOR RELIEF", "JURY TRIAL DEMAND")

/// The body. Paragraphs are numbered 1, 2, ... (Rule 10(b)) when `numbered` is true; a list is lettered (a), (b).
/// Prayer items ("A. ...") keep their letter and are not numbered. Headings use the heading show rules above.
#let body-content(body, numbered) = [
  #let n = 0
  #let unnum = false
  #for c in chunks(body) {
    let hm = c.match(regex("^(#{1,3})\\s+([\\s\\S]*)$"))
    let lines = c.split("\n").filter(l => l.trim() != "")
    if hm != none {
      let lvl = hm.captures.at(0).len()
      // Paragraphs under these headings are not numbered in the filed form (Schott, S.D. Tex. 2026).
      unnum = unnumbered-headings.any(t => upper(hm.captures.at(1)) == t)
      if lvl == 1 { heading(level: 1, upper(hm.captures.at(1))) } else { heading(level: 2, hm.captures.at(1)) }
    } else if lines.len() > 0 and lines.at(0).match(regex("^-\\s")) != none {
      for (i, l) in lines.enumerate() {
        let t = l.match(regex("^-\\s+([\\s\\S]*)$")).captures.at(0)
        block(width: 100%, above: 0pt, below: single * 2, sticky: false, grid(columns: (para-indent * 2, 1fr),
          inl("(" + letters.at(i) + ")"), inl(t)))
      }
    } else if c.match(regex("^\\d+\\.\\s")) != none {
      // A numbered list (the statement of the issues) keeps its own numbers, with a hanging indent.
      let m = c.match(regex("^(\\d+)\\.\\s+([\\s\\S]*)$"))
      pad(left: para-indent, block(width: 100%, above: 0pt, below: double, grid(columns: (para-indent * 1.5, 1fr),
        m.captures.at(0) + ".", inl(m.captures.at(1)))))
    } else if c.match(regex("^[A-Z]\\.\\s")) != none {
      let m = c.match(regex("^([A-Z])\\.\\s+([\\s\\S]*)$"))
      pad(left: para-indent, block(width: 100%, above: 0pt, below: double, grid(columns: (para-indent * 1.5, 1fr),
        m.captures.at(0) + ".", inl(m.captures.at(1)))))
    } else if numbered and not unnum {
      n += 1
      block(width: 100%, above: 0pt, below: double, sticky: false,
        [#h(para-indent) #(str(n) + ".") #h(para-indent) #inl(c)])
    } else {
      // An unnumbered lead-in (WHEREFORE, the jury demand) stays with the item that follows it.
      block(width: 100%, above: 0pt, below: double, sticky: unnum, [#inl(c)])
    }
  }
]

// ---------------------------------------------------------------------------
// Signature block and certificates (Fed. R. Civ. P. 11(a); 5(b) for service)
// ---------------------------------------------------------------------------

#let signature-block(sig, date) = block(width: 100%, above: double, below: double, sticky: true, {
  set par(leading: single, spacing: 0pt)
  if date != none { [#date] ; v(double) }
  pad(left: 3.25in, {
    if "lead" in sig and sig.lead != none { [#sig.lead] ; v(double * 0.5) }
    if "party" in sig and sig.party != none { [#text(weight: "bold", sig.party)] ; v(double * 0.5) }
    if "by" in sig and sig.by != none { [#sig.by] ; v(single) }
    for l in sig.signer_lines { [#l] ; linebreak() }
  })
})

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let txsd-motion-brief(meta, body) = {
  set page(paper: "us-letter", margin: page-margin, numbering: "1")
  set text(font: font-family, size: type-size, lang: "en", region: "us")
  set par(leading: double, spacing: double, justify: false, first-line-indent: 0pt)
  show heading.where(level: 1): it => block(width: 100%, above: double, below: double, sticky: true,
    align(center, text(weight: "bold", size: type-size, it.body)))
  show heading.where(level: 2): it => block(width: 100%, above: double, below: double, sticky: true,
    text(weight: "bold", size: type-size, it.body))

  court-title(meta)
  caption(meta)
  v(double)
  align(center, text(weight: "bold", upper(meta.brief_title)))

  // A brief with a table of contents: the cover (caption and title) is its own page; the contents follow.
  if "toc" in meta and meta.toc {
    pagebreak()
    outline(title: align(center, text(weight: "bold", [TABLE OF CONTENTS])), depth: 2, indent: 0pt)
    pagebreak()
  } else {
    v(double)
  }

  body-content(body, false)

  if "signature" in meta and meta.signature != none {
    signature-block(meta.signature, meta.at("date", default: none))
  }

  // Certificates (Fed. R. Civ. P. 5(b)(2)(E) service through CM/ECF; word count and conference are the
  // judge's procedures where the filing cites them, so each is printed only when the sample carries the text).
  for key in ("word_count_certificate", "certificate_of_conference", "certificate_of_service") {
    if key in meta and meta.at(key) != none {
      let title = if key == "word_count_certificate" { "CERTIFICATE OF WORD COUNT" }
        else if key == "certificate_of_conference" { "CERTIFICATE OF CONFERENCE" }
        else { "CERTIFICATE OF SERVICE" }
      heading(level: 1, title)
      block(width: 100%, below: double, [#inl(meta.at(key))])
      if "certificate_signature" in meta and meta.certificate_signature != none {
        pad(left: 3.25in, [#meta.certificate_signature])
      }
    }
  }
}
