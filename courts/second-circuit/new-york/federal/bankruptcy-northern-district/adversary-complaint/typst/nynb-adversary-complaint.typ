// Adversary complaint for the U.S. Bankruptcy Court, N.D.N.Y. (nynb).
// Rules: FRBP 7001 (adversary proceeding), 7003 (Fed. R. Civ. P. 3 applies), 7008(a) (Fed. R. Civ. P. 8 applies;
// jurisdiction must reference the bankruptcy case; statement of consent to final orders), 7010 (Fed. R. Civ. P. 10
// applies; caption substantially conforms to Official Form 416A), 9004(a)-(b) (legible; caption elements);
// LBR 9004-1(a) (form), (c) (caption), (d) (noncompliance). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")     // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; --ignore-system-fonts means no other substitute
#let type-size = 12pt                // LBR 9004-1(a)(1)(A): minimum 12-point, text and footnotes
#let margin = 1in                    // LBR 9004-1(a)(2)(A): one-inch margin on all four sides
#let text-width = 8.5in - 2 * margin // LBR 9004-1(a)(2)(C): letter size
#let para-indent = 0.5in             // first line of each paragraph (FRCP 10(b))
#let num-box = 0.5in                 // the paragraph number in a box of this width; the text starts 1 in from the margin
#let prayer-indent = 0.5in           // prayer items "(a)" ... indented on every line
#let caption-left = 3.4in            // width of the party column of the caption
#let caption-gutter = 0.25in         // between the party column and the case numbers
#let caption-inset = 0.1in           // the case numbers' own inset
#let rule-pad = 10pt                 // the party text stops this far from the caption rule (right and bottom)
#let sig-left = 3in                  // the "Dated" column of the signature block

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/nynb-adversary-complaint.lua sets the same twips).
#let pitch-double = 24pt             // LBR 9004-1(a)(1)(B): double-spaced body
#let pitch-single = 13.8pt           // caption, counsel, signature: 1.15 x 12 pt
#let gap = 24pt                      // one blank double-spaced line between the cover's parts and before headings
#let caption-sep = 6pt               // between the bankruptcy and the adversary caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nynb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, section symbols, names with *et al.*).
#let inl(s) = cmarker.render(str(s), raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// Single-spaced stack of lines (caption, counsel, signature); an empty line keeps its full height.
#let line-stack(items) = for i in items {
  if i == "" { block(height: pitch-single, above: 0pt, below: 0pt) } else { line-block(inl(i)) }
}

// ---------------------------------------------------------------------------
// Caption and cover (LBR 9004-1(c); FRBP 9004(b); FRBP 7010 / Official Form 416A)
// ---------------------------------------------------------------------------

/// A caption: the left column ruled on its right and bottom, the right column beside it.
#let caption-grid(left, right) = grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: rule-pad, bottom: rule-pad),
    line-stack(left)),
  pad(left: caption-inset, line-stack(right)),
)

/// The bankruptcy caption: debtor on the left; case number and chapter on the right. Hearing information, when the
/// sample gives it, sits above the case number (LBR 9013-1(g)(1)).
#let bankruptcy-caption(meta) = caption-grid(
  ("In re:",) + meta.debtor.names + ("(" + meta.debtor.tin + ")", "Debtor."),
  (if "hearing" in meta and meta.hearing != none {
    ("Hearing: " + meta.hearing.date, "Time: " + meta.hearing.time, "Location: " + meta.hearing.location)
  } else { () }) + ("Case No. " + meta.case_number, "Chapter " + str(meta.chapter)),
)

/// The adversary caption: parties on the left; the adversary number on the right (LBR 9004-1(c)).
#let adversary-caption(meta) = {
  let rows = ()
  for (k, p) in meta.adversary.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  caption-grid(rows, ("Adv. Pro. No. " + meta.adversary.number,))
}

#let cover(meta) = {
  if "counsel" in meta and meta.counsel != none {
    block(width: 100%, below: gap, line-stack(meta.counsel))
  }
  line-block(align(center, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT")))
  line-block(below: gap, align(center, text(weight: "bold", "NORTHERN DISTRICT OF NEW YORK")))
  block(width: 100%, above: gap, below: caption-sep, bankruptcy-caption(meta))
  block(width: 100%, above: caption-sep, below: gap, adversary-caption(meta))
  line-block(above: gap, below: gap, align(center, text(weight: "bold", inl(meta.title))))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (FRCP 10(b) via FRBP 7010), headings, prayer sub-items
// ---------------------------------------------------------------------------

/// Each blank-line-separated chunk of markdown is one unit. A chunk starting with "#" is a heading (one "#"
/// centred, "##" flush left); a chunk starting with "(a)", "(b)", ... is an unnumbered prayer item; a chunk starting
/// with "<!-- unnumbered -->" is an unnumbered paragraph (a WHEREFORE clause); every other chunk is one numbered
/// paragraph. The first `preamble` chunks (frontmatter key, when given) are unnumbered; without it, the chunks
/// before the first heading are. All of it double-spaced, with no space between the units.
#let body-content(body, preamble: none) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let numbered = false
  let n = 0
  let item = regex("^\\([a-z]\\)[ \\t]")
  for (i, t) in chunks.enumerate() {
    if preamble != none and i >= preamble { numbered = true }
    // A paragraph that leads into a lettered item sticks to it (a lead-in is never left alone at a page foot); the
    // last prayer item stays with the signature block.
    let next = chunks.at(i + 1, default: none)
    let sticky = (next != none and next.starts-with(item) and not t.starts-with(item)) or (next == none and t.starts-with(item))
    if t.starts-with("<!-- unnumbered -->") {
      block(width: 100%, sticky: sticky, [#h(para-indent)#inl(t.slice("<!-- unnumbered -->".len()).trim())])
    } else if t.starts-with("#") {
      numbered = true
      let level = t.match(regex("^#+")).text.len()
      let words = text(weight: "bold", inl(t.slice(level).trim()))
      block(width: 100%, above: gap, sticky: true, if level == 1 { align(center, words) } else { words })
    } else if t.starts-with(item) {
      block(width: 100%, sticky: sticky, pad(left: prayer-indent, inl(t)))
    } else if not numbered {
      block(width: 100%, sticky: sticky, [#h(para-indent)#inl(t)])
    } else {
      n += 1
      block(width: 100%, sticky: sticky, [#h(para-indent)#box(width: num-box)[#n.]#inl(t)])
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (FRBP 9011 signature; LBR 9011-1 and 9011-3 are author duties, not rendered)
// ---------------------------------------------------------------------------

#let signature(meta) = block(width: 100%, breakable: false, above: gap, grid(
  columns: (sig-left, 1fr),
  column-gutter: caption-gutter,
  line-stack(("Dated: " + meta.dated,)),
  line-stack(("Respectfully submitted,",) + meta.signature.firm + ("", "By: /s/ " + meta.signature.signer)
    + meta.signature.lines),
))

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let nynb-adversary-complaint(meta, body) = {
  set document(title: meta.title)
  // LBR 9004-1(a)(2)(B): consecutively numbered pages, the number centred at the foot of every page, in a
  // single-spaced line box where Word's footer sets it.
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (double spaced). The template sets no lists.
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // A doubled sign stays with its number too ("§§ 151"; xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)
  cover(meta)
  body-content(body, preamble: meta.at("preamble", default: none))
  signature(meta)
}
