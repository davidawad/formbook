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

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // District LR 5.1 names no face; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 14pt              // District LR 5.1(C): at least 14-point font
#let body-leading = 1.65em         // District LR 5.1(C): double spaced (baseline pitch about 32 pt at 14 pt)
#let single-leading = 0.45em       // caption, counsel block, signature block
#let margin = 1in                  // District LR 5.1(C): at least one inch on all four sides
#let text-width = 8.5in - 2 * margin
#let word-limit = 8000             // District LR 7.1(F): memorandum limit
#let motion-words-threshold = 500  // District LR 7.1(F): motion words count toward the memorandum only above 500

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
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

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

/// One caption block: a stack of single-spaced lines, each taken from the frontmatter.
#let lines-block(items) = stack(dir: ttb, spacing: single-leading, ..items.map(t => [#t]))

/// The caption (LBR 9004-1(A)): court name, then the case style (debtor case, then adversary).
#let caption(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  align(center, lines-block(meta.court.map(t => upper(t))))
  v(1.5em)
  grid(
    columns: (text-width * 0.62, 1fr),
    gutter: 1em,
    lines-block(meta.debtor_style),
    lines-block(meta.debtor_numbers),
  )
  v(1em)
  grid(
    columns: (text-width * 0.62, 1fr),
    gutter: 1em,
    lines-block(meta.adversary_style),
    lines-block(meta.adversary_numbers),
  )
  v(1.5em)
}

/// Signature block (District LR 5.1(D)): the attorney's signature and bar details.
#let signature(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt)
  v(1.5em)
  pad(left: text-width * 0.45, lines-block(meta.signature))
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let motion(meta, body) = {
  // LR 7.1(F): the word-count certificate states the computed count; the sample holds a placeholder.
  let words = memorandum-words(body)
  if words > word-limit { panic("flnb-motion-brief: memorandum of " + str(words) + " words exceeds the " + str(word-limit) + "-word limit (LR 7.1(F))") }
  let filled = body.replace("{{MEMO_WORDS}}", str(words))
  // The signature block sits after the WHEREFORE paragraph and before the certificates (LR 9013-1; LR 5.1(D)).
  let parts = filled.split("<!--SIGNATURE-->")
  if parts.len() != 2 { panic("flnb-motion-brief: the sample must contain one <!--SIGNATURE--> marker") }

  set document(title: meta.title)
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center + bottom,         // District LR 5.1(C): pages must be numbered
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(justify: false, leading: body-leading, spacing: body-leading, first-line-indent: 0.5in)
  // Headings stay with the paragraph that follows them (sticky), so none is left alone at a page foot.
  show heading.where(level: 2): it => block(sticky: true, {
    set par(leading: single-leading, first-line-indent: 0pt)
    v(0.8em)
    align(center, text(weight: "bold", it.body))
    v(0.4em)
  })
  show heading.where(level: 3): it => block(sticky: true, {
    set par(leading: single-leading, first-line-indent: 0pt)
    v(0.6em)
    align(center, text(weight: "bold", it.body))
    v(0.3em)
  })
  show heading.where(level: 4): it => block(sticky: true, {
    set par(leading: single-leading, first-line-indent: 0pt)
    align(center, it.body)
    v(0.6em)
  })

  caption(meta)

  // Title (LBR 9004-1(A)): designation, contents, and "MEMORANDUM" when the paper contains one.
  set par(leading: single-leading, first-line-indent: 0pt)
  align(center, text(weight: "bold", lines-block(meta.title_lines)))
  v(1.5em)

  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0.5in)
  let defs = footnote-defs(filled)
  render-md(parts.at(0), defs)

  signature(meta)

  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0.5in)
  render-md(parts.at(1), defs)
}
