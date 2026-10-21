#import "@preview/cmarker:0.1.10"
#import "../../../../../../../lib/typst/tables.typ": leader-row

// Texas Rules of Appellate Procedure 9.4 (form), 9.5 (service), 68.3-68.4 (petition contents).
// Text is 14-point and double-spaced (9.4(d)-(e)); headings, the cover, and the identity block
// are single-spaced; footnotes are 12-point. Leading 1.645em gives a 32.2 pt baseline pitch
// (2 x 14 pt x 1.15) in Liberation Serif, whose line box is 0.655em.
#let font-family = "TeX Gyre Pagella"   // vendored in /fonts; declared so the default font check knows the face (DEF-FONT-002)
#let body-leading = 1.645em
#let single-leading = 0.65em

// A markdown block is single-spaced when it holds a hard line break (signature and address
// blocks) or a table-of-contents or index dot leader. Consecutive blocks of the same kind are
// rendered together so that numbered lists keep their numbers.
#let single-block(chunk) = chunk.contains("\\\n") or chunk.contains("....")

// A table-of-contents or index entry: one line, "title ..... page". The dots typed in the markdown only mark
// the entry; the template sets its own leader and keeps the page reference level with the title's last line
// (DEF-TOC-001), so a long title wraps under a hanging indent and the page never wraps alone.
#let leader-entry = regex("^([^\\n]*?[^\\s.]\\S*)\\s*\\.{4,}\\s*([^\\s.][^\\n]*?)\\s*$")
#let entry-hang = 0.5in
#let entry-min-leader = 1.5em   // at least four dots: a Gate 0 leader is four or more dots

// Footnotes: each definition line "[^n]: text" is removed from the body, and each reference
// "[^n]" becomes a token that the show rule below turns into a footnote with the rendered text.
#let footnote-split(body) = {
  let defs = (:)
  let kept = ()
  for line in body.split("\n") {
    let m = line.match(regex("^\\[\\^([0-9]+)\\]:\\s*(.*)$"))
    if m != none {
      defs.insert(m.captures.at(0), m.captures.at(1))
    } else {
      kept.push(line)
    }
  }
  let text = kept.join("\n").replace(regex("\\[\\^([0-9]+)\\]"), m => "ZQFN" + m.captures.at(0) + "ZQ")
  (text, defs)
}

#let pdr(source) = {
  let fm = source.match(regex("^---\\r?\\n([\\s\\S]*?)\\r?\\n---[ \\t]*\\r?\\n"))
  if fm == none { panic("PDR sample requires YAML frontmatter") }
  let meta = yaml(bytes(fm.captures.at(0)))
  let body = source.slice(fm.end)
  let required = ("case_number", "style_petitioner", "style_respondent", "filing_party", "brief_title", "appeal_from", "lead_counsel", "counsel_lines")
  for key in required { if key not in meta { panic("PDR sample missing frontmatter field: " + key) } }
  set document(title: meta.brief_title, author: meta.filing_party)
  set page(
    paper: "us-letter",
    margin: 1in,
    footer: context {
      // the cover is unnumbered; the page after it is page 1
      if here().page() > 1 { align(center, text(size: 14pt, counter(page).display())) }
    },
  )
  set text(font: font-family, size: 14pt, lang: "en")
  set par(leading: body-leading, first-line-indent: 0.5in, justify: false)
  show footnote.entry: set text(size: 12pt)
  show footnote.entry: set par(leading: single-leading, first-line-indent: 0pt)
  show heading.where(level: 1): it => {
    set par(first-line-indent: 0pt, leading: single-leading)
    block(width: 100%, sticky: true, above: 1.1em, below: 0.8em, align(center, strong(upper(it.body))))
  }
  show heading.where(level: 2): it => {
    set par(first-line-indent: 0pt, leading: single-leading)
    block(sticky: true, above: 0.8em, below: 0.7em, strong(it.body))
  }
  show heading.where(level: 3): it => {
    set par(first-line-indent: 0pt, leading: single-leading)
    block(sticky: true, above: 0.6em, below: 0.35em, emph(it.body))
  }
  // the cover is a single-spaced, centered block on its own page
  set par(leading: single-leading)
  align(center)[
    #v(0.4in)
    #text(weight: "bold")[IN THE COURT OF CRIMINAL APPEALS OF TEXAS]
    #v(0.3in)
    No. #meta.case_number
    #v(0.2in)
    #strong(meta.style_petitioner)
    #v(0.08in)
    v.
    #v(0.08in)
    #strong(meta.style_respondent)
    #v(0.2in)
    #meta.appeal_from
    #v(0.32in)
    #text(size: 16pt, weight: "bold")[#upper(meta.brief_title)]
    #v(0.35in)
    #meta.filing_party
    #v(0.12in)
    #meta.lead_counsel
    #for line in meta.counsel_lines { linebreak(); line }
    #if "filed_date" in meta { v(0.25in); meta.filed_date }
  ]
  pagebreak()
  counter(page).update(1)
  set par(leading: body-leading)

  // group consecutive blocks by spacing kind, keeping list items together
  let (text, defs) = footnote-split(body)
  show regex("ZQFN[0-9]+ZQ"): it => footnote(cmarker.render(defs.at(it.text.slice(4, -2)), smart-punctuation: false, raw-typst: false))
  let groups = ()
  for chunk in text.split("\n\n") {
    let single = single-block(chunk)
    if groups.len() > 0 and groups.last().at(0) == single {
      groups.last().at(1).push(chunk)
    } else {
      groups.push((single, (chunk,)))
    }
  }
  for (single, chunks) in groups {
    let text = chunks.join("\n\n")
    if single {
      // short single-spaced blocks (signatures, certificates) do not split across pages
      let keep = text.len() < 700
      block(breakable: not keep, {
        set par(leading: single-leading, first-line-indent: 0pt)
        // runs of ordinary blocks are rendered together (list numbering); each leader entry on its own
        let pending = ()
        for chunk in chunks {
          let m = chunk.trim().match(leader-entry)
          if m == none { pending.push(chunk); continue }
          if pending.len() > 0 { cmarker.render(pending.join("\n\n"), smart-punctuation: false, raw-typst: false) }
          pending = ()
          let inline(s) = cmarker.render(s, smart-punctuation: false, raw-typst: false)
          block(leader-row(inline(m.captures.at(0)), inline(m.captures.at(1)), hang: entry-hang,
            dot-gap: 0pt, lead-gap: 0.25em, min-leader: entry-min-leader))
        }
        if pending.len() > 0 { cmarker.render(pending.join("\n\n"), smart-punctuation: false, raw-typst: false) }
      })
    } else {
      cmarker.render(text, smart-punctuation: false, raw-typst: false)
    }
  }
}
