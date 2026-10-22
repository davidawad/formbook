// Complaint for the U.S. District Court for the Southern District of Georgia (gasd).
// Rules: Fed. R. Civ. P. 10(a) (caption), 10(b) (numbered paragraphs); S.D. Ga. LR 10.1 (double-spaced,
// numbered pages), LR 5.4 (letter paper), LR 11.1 (counsel name, address, telephone, State Bar number).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no S.D. Ga. typeface rule found (README.md); Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // the exemplar and the usual practice; not set by an S.D. Ga. rule
#let page-w = 8.5in                     // LR 5.4: paper 8 1/2 by 11 inches
#let page-h = 11in
#let margin = 1in                       // not set by a rule (README.md); the usual 1-inch margin
#let para-indent = 0.5in                // first-line indent of numbered paragraphs, and the number's box after it
#let item-indent = 0.5in                // prayer items: the label stands half an inch in
#let item-label = 0.4in                 // the label's box; the text hangs after it
#let quote-indent = 0.75in              // block quotations, both sides
#let caption-party-width = 3.1in        // width of the party column in the caption
#let caption-paren-width = 0.3in        // the ")" column of the caption

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt                  // LR 10.1 double-spacing: a 24 pt pitch at 12 pt
#let pitch-single = 13.8pt              // single spacing (caption, quotations, signature): Word's single line, 1.15 x 12 pt
#let gap = 16.2pt                       // between paragraphs, around headings and quotations
#let sig-gap = gap / 2                  // inside the signature block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gasd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, italics, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

/// A paragraph at the body pitch, a gap below it.
#let body-par(content) = block(width: 100%, above: 0pt, below: gap, par(first-line-indent: 0pt, content))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("IN THE UNITED STATES DISTRICT COURT", "SOUTHERN DISTRICT OF GEORGIA")
  if "division" in meta { lines.push(upper(meta.division)) }
  for (i, l) in lines.enumerate() {
    line-block(below: if i == lines.len() - 1 { gap } else { 0pt }, align(center, text(weight: "bold", l)))
  }
}

/// Caption: one row per line of the party column, a ")" in the middle, and the file number beside it.
/// Each row of frontmatter `caption.rows` is `{left: ..., right: ...}`; "right" may be empty.
#let caption(meta) = block(above: 0pt, below: 0pt, grid(
  columns: (caption-party-width, caption-paren-width, 1fr),
  ..meta.caption.rows.map(r => (line-block(r.left), line-block[)], line-block(r.right))).flatten(),
))

#let title-block(meta) = line-block(above: gap, below: gap, align(center, text(weight: "bold", upper(inl(meta.title)))))

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lettered list items, quotations
// ---------------------------------------------------------------------------

/// Headings: level 1 is a centered bold section; level 2 a centered bold sub-heading (a count); level 3 is bold,
/// flush left. A gap above and below, kept with the text after them.
#let heading-block(t) = {
  let lv = t.position(regex("[^#]"))
  let body = inl(t.slice(lv).trim())
  block(width: 100%, above: gap, below: gap, sticky: true, {
    set par(first-line-indent: 0pt)
    if lv == 1 { align(center, text(weight: "bold", upper(body))) }
    else if lv == 2 { align(center, text(weight: "bold", body)) }
    else { text(weight: "bold", body) }
  })
}

/// A block quotation: indented and single-spaced; each quoted line is a paragraph of its own, set as typed (its
/// list labels are text), a single line between paragraphs.
#let quotation(t) = {
  let paras = t.split(regex("\\r?\\n[ \\t]*>[ \\t]*\\r?\\n")).map(p => p.split("\n").map(l => l.trim().trim(">", at: start).trim()).filter(l => l != ""))
  let lines = ()
  for (i, p) in paras.enumerate() { for (j, l) in p.enumerate() { lines.push((l, i > 0 and j == 0)) } }
  block(width: 100%, above: 0pt, below: gap, {
    for (l, sep) in lines { line-block(above: if sep { pitch-single } else { 0pt }, pad(x: quote-indent, text(l))) }
  })
}

/// Lettered items (a), (b) ... of a list: the label half an inch in, the text hanging after it.
#let items(t) = {
  let marker = regex("^(\\d+\\.|[-*+])[ \\t]+")
  let its = ()
  for l in t.split("\n").map(l => l.trim()).filter(l => l != "") {
    if l.starts-with(marker) or its.len() == 0 { its.push(l.replace(marker, "")) } else { its.last() += " " + l }
  }
  for (i, s) in its.enumerate() {
    block(width: 100%, above: 0pt, below: gap, par(hanging-indent: item-indent + item-label,
      first-line-indent: 0pt, [#h(item-indent)#box(width: item-label, numbering("(a)", i + 1))#inl(s)]))
  }
}

/// The signature block: firm, each signer, the address, the party represented (LR 11.1).
#let signature-block(meta) = {
  let sig = meta.signature
  line-block(above: gap, text(weight: "bold", upper(sig.firm)))
  for s in sig.signers {
    line-block(above: gap)[/s/ #s.name]
    for l in s.lines { line-block(inl(l)) }
  }
  for (i, l) in sig.address.enumerate() { line-block(above: if i == 0 { gap } else { 0pt }, inl(l)) }
  line-block(above: sig-gap, inl(sig.counsel-for))
}

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither a
/// heading, a list nor a quotation is one numbered paragraph. The last list (the prayer) is kept whole with the
/// signature block, so the signature never stands alone on a page.
#let allegations(body, tail) = {
  let n = 0
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  for (k, t) in chunks.enumerate() {
    let last = k == chunks.len() - 1
    if t.starts-with("#") {
      heading-block(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      if last { block(breakable: false, width: 100%, { items(t); tail }) } else { items(t) }
    } else if t.starts-with(">") {
      quotation(t)
    } else {
      n += 1
      body-par[#h(para-indent)#box(width: para-indent)[#n.]#inl(t)]
    }
  }
  if chunks.len() == 0 or not chunks.last().starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
    block(breakable: false, width: 100%, tail)
  }
}

#let gasd-complaint(meta, body) = {
  // Page number "- N -" centered in the bottom margin, on every page including the first (LR 10.1), in a single-
  // spaced line box (Word's footer).
  set page(paper: "us-letter", margin: margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("- 1 -"))))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 1334"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  court-title(meta)
  caption(meta)
  title-block(meta)
  if "lead_in" in meta { body-par[#h(para-indent)#inl(meta.lead_in)] }
  allegations(body, signature-block(meta))
}
