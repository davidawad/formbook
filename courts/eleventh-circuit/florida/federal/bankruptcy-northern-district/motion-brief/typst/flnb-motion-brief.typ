// Motion with incorporated memorandum of law, U.S. Bankruptcy Court, Northern District of Florida (flnb).
// Rules (primary sources, verified 2026-10-14 against the Local Rules effective Feb. 26, 2024 and the
// District Local Rules, PDF version effective Nov. 24, 2015): Bankr. N.D. Fla. LBR 1001-1(B)-(C) (District
// Local Rules apply in bankruptcy cases); LBR 9004-1(A) (caption; title states that the paper contains a
// memorandum); LBR 9013-1(A)(1)-(2) (one claim for relief per motion; conferral statement; "Agreed"/"Consent"
// in the title if consented), 9013-1(B) (memorandum of law with every motion in an adversary proceeding),
// 9013-1(D) (length limits of the District Local Rules); LBR 7007-1 (motions in adversary proceedings are
// governed by LBR 9013-1). District LR 5.1(B)-(F) (case style, 14-point double-spaced, 1-inch margins, page
// numbers, signature block, certificate of service); District LR 7.1(C) (certificate of conferral under a
// separate heading), 7.1(F) (8,000-word limit for a memorandum and a certificate stating its word count; the
// case style, signature block and certificate of service do not count). See ../README.md.
// Content-agnostic: case-specific words come from the sample's frontmatter or body.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // District LR 5.1 names no face; Times New Roman, the house standard and the filed exemplar's face
#let type-size = 14pt              // District LR 5.1(C): at least 14-point font (footnotes too)
#let margin = 1in                  // District LR 5.1(C): at least one inch on all four sides
#let para-indent = 0.5in           // first-line indent of every body paragraph (the filing)
#let caption-left = 3.95in         // the case-style column of the caption (its longest line, the rule, fits)
#let caption-gutter = 0.1in        // between the case style and the case numbers
#let sig-left = 2.9in              // the signature block's left edge (right half of the page, as filed)
#let word-limit = 8000             // District LR 7.1(F): memorandum limit
#let motion-words-threshold = 500  // District LR 7.1(F): motion words count toward the memorandum only above 500

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 16.1pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // District LR 5.1(C) double spacing: 32.2 pt, the filed exemplar's pitch

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("flnb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in *italics*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Whitespace-delimited words of a markdown fragment, markup and paragraph numbers removed.
#let count-words(md) = {
  let s = md.replace("\\", "").replace("*", "").replace("#", "").replace("\n", " ")
  s.split(" ").filter(w => w != "" and w.match(regex("^[0-9]+[.)]$")) == none).len()
}

/// Word count for LR 7.1(F): the memorandum, plus the motion's own words if the motion exceeds 500 words.
#let memorandum-words(body) = {
  let memo-at = body.position("## MEMORANDUM OF LAW")
  let cert-at = body.position("## CERTIFICATION")
  let motion = if memo-at == none { body } else { body.slice(0, memo-at) }
  let memo = if memo-at == none { "" } else if cert-at == none { body.slice(memo-at) } else { body.slice(memo-at, cert-at) }
  let motion-n = count-words(motion)
  count-words(memo) + if motion-n > motion-words-threshold { motion-n } else { 0 }
}

/// Footnote definitions ("[^k]: text") keyed by label. cmarker 0.1.10 has no footnote support, so they are
/// placed as typst footnotes at each reference ("[^k]") in the paragraph that cites them.
#let footnote-defs(md) = {
  let defs = (:)
  for m in md.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.+)$")) {
    defs.insert(m.captures.at(0), m.captures.at(1))
  }
  defs
}

/// Render one markdown paragraph (not a heading) with its footnote references as typst footnotes.
#let paragraph-with-notes(p, defs) = {
  let rest = p
  let out = []
  let m = rest.match(regex("\\[\\^([^\\]]+)\\]"))
  while m != none {
    out += inl(rest.slice(0, m.start))
    out += footnote(inl(defs.at(m.captures.at(0))))
    rest = rest.slice(m.end)
    m = rest.match(regex("\\[\\^([^\\]]+)\\]"))
  }
  out + inl(rest)
}

/// Render a markdown block sequence: headings as cmarker renders them; paragraphs with footnotes.
#let render-md(md, defs) = {
  let text = md.replace(regex("(?m)^\\[\\^[^\\]]+\\]:[ \\t]*.+$\\n?"), "")
  for p in text.split("\n\n").filter(p => p.trim() != "") {
    if p.trim().starts-with("#") { inl(p) } else { par(paragraph-with-notes(p.trim(), defs)) }
    parbreak()
  }
}

/// One single-spaced line (a paragraph of its own); an empty one keeps its line box.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if body == "" { block(height: pitch-single) } else { body }
})

/// The case style on the left and its numbers on the right, one grid row per line so the numbers stand at the
/// style's lines.
#let case-grid(left, right, above, below) = {
  let n = calc.max(left.len(), right.len())
  let at(list, i) = if i < list.len() { list.at(i) } else { "" }
  block(width: 100%, above: above, below: below, grid(
    columns: (caption-left, caption-gutter, 1fr),
    ..range(n).map(i => (line-block(at(left, i)), [], line-block(at(right, i)))).flatten(),
  ))
}

/// The caption (LBR 9004-1(A)): court name, the case style (debtor case, then adversary), and the title, which
/// states that the paper contains a memorandum.
#let caption(meta) = {
  for l in meta.court { line-block(align(center, upper(l))) }
  case-grid(meta.debtor_style, meta.debtor_numbers, pitch-double, 0pt)
  case-grid(meta.adversary_style, meta.adversary_numbers, pitch-single, 0pt)
  for (i, l) in meta.title_lines.enumerate() {
    line-block(above: if i == 0 { pitch-double } else { 0pt }, align(center, text(weight: "bold", l)))
  }
}

/// Signature block (District LR 5.1(D)): the attorney's signature and bar details, a single line below the text.
#let signature(meta) = block(width: 100%, breakable: false, above: pitch-single, below: 0pt,
  pad(left: sig-left, for l in meta.signature { line-block(l) }))

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let motion(meta, body) = {
  // LR 7.1(F): the word-count certificate states the computed count; the sample holds a placeholder.
  let words = memorandum-words(body)
  if words > word-limit { panic("flnb-motion-brief: memorandum of " + str(words) + " words exceeds the " + str(word-limit) + "-word limit (LR 7.1(F))") }
  let filled = body.replace("{{MEMO_WORDS}}", str(words))
  // The signature block sits after the WHEREFORE paragraph and before the certificates (LR 9013-1; LR 5.1(D)).
  let parts = filled.split("{{SIGNATURE}}")
  if parts.len() != 2 { panic("flnb-motion-brief: the sample must contain one {{SIGNATURE}} marker") }

  set document(title: meta.title)
  // District LR 5.1(C): pages numbered; centered in a single line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch (double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: none)
  // Headings: centered bold single-spaced lines a single line below the text before them; kept with the text after.
  show heading: it => block(sticky: true, width: 100%, above: pitch-single, below: 0pt, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    align(center, text(weight: "bold", it.body))
  })
  // Footnotes at the body's 14 pt (LR 5.1(C)), single-spaced: the mark, a space, the note.
  set footnote.entry(gap: 0pt, clearance: 12.6pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  caption(meta)

  let defs = footnote-defs(filled)
  // The paragraph before the marker (the WHEREFORE paragraph) stays with the signature block (one unbreakable
  // block), so the signature never stands alone on a page.
  let strip(s) = s.replace(regex("(?m)^\\[\\^[^\\]]+\\]:[ \\t]*.+$\\n?"), "")
  let chunks = strip(parts.at(0)).trim().split(regex("\\r?\\n[ \\t]*\\r?\\n"))
  let last = chunks.last()
  let keep = not last.starts-with("#")
  let head = if keep { chunks.slice(0, -1).join("\n\n") } else { parts.at(0) }
  block(width: 100%, above: pitch-single, below: 0pt, render-md(head, defs))
  if keep {
    block(width: 100%, breakable: false, above: 0pt, below: 0pt, { render-md(last, defs); signature(meta) })
  } else { signature(meta) }

  render-md(parts.at(1), defs)
}
