// Motion with memorandum (brief), United States Bankruptcy Court, N.D. Iowa.
// Governing rules and the reading of each: ../README.md. Entry point: main.typ.
// The markdown body (usage/<id>.md) is rendered by cmarker; the metadata comes from the
// YAML frontmatter of the same file (fields listed in ../README.md).
#import "@preview/cmarker:0.1.10"

#let font-family = ("Times New Roman", "Liberation Serif")   // vendored in fonts/. No N.D. Iowa rule names a font (README, gap 1).
#let type-size = 13pt              // EB Garamond at 13 pt sets close to Times 12 pt (README, gap 2).
#let body-leading = 1.2em          // double-spaced body text (README, gap 3).
#let para-indent = 0.5in
#let page-margin = 1in
#let heading-space = 12pt

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("(?s)^---\n(.*?)\n---\n"))
  assert(m != none, message: "sample needs YAML frontmatter")
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  assert(key in meta, message: "frontmatter field missing: " + key)
  meta.at(key)
}

#let ground-no = counter("ground-no")

/// Caption (FRBP 9004(b) and 7010; the layout follows the exemplars). A contested matter
/// (no adversary_no) has the debtor block and case number only.
#let caption(meta) = {
  let adv = "adversary_no" in meta
  align(center, stack(
    dir: ttb,
    spacing: 0.3em,
    text(weight: "bold")[UNITED STATES BANKRUPTCY COURT],
    text(weight: "bold")[FOR THE NORTHERN DISTRICT OF IOWA],
  ))
  v(1.5em)
  grid(
    columns: (3.3in, 1fr),
    block(width: 100%, inset: (right: 12pt, bottom: 10pt), stroke: (right: 0.75pt, bottom: 0.75pt))[
      In re:
      #v(0.6em)
      #pad(left: 0.5in)[#need(meta, "debtor")]
      #v(0.6em)
      #align(right)[Debtor.]
      #if adv [
        #v(0.8em)
        #pad(left: 0.5in)[#need(meta, "plaintiff")]
        #v(0.6em)
        #align(right)[Plaintiff,]
        #v(0.6em)
        #pad(left: 0.5in)[v.]
        #v(0.6em)
        #pad(left: 0.5in)[#need(meta, "defendant")]
        #v(0.6em)
        #align(right)[Defendant.]
      ]
    ],
    block(width: 100%, inset: (left: 16pt, top: 2em))[
      #need(meta, "chapter")
      #v(0.4em)
      #need(meta, "case_no")
      #if adv [
        #v(1.6em)
        #meta.adversary_no
      ]
      #v(1.6em)
      #text(weight: "bold")[#need(meta, "title")]
    ],
  )
  v(1.2em)
}

#let heading-block(t) = {
  v(heading-space, weak: true)
  block(sticky: true, width: 100%, align(center, text(weight: "bold", inl(t))))
  v(0.7em)
}

/// Argument heading in the brief (for example "I. PLAINTIFF HAS FAILED ..."): bold, left.
#let argument-heading(t) = {
  v(heading-space, weak: true)
  block(sticky: true, width: 100%, text(weight: "bold", inl(t)))
  v(0.6em)
}

/// Footnote definitions (`[^N]: text` chunks). cmarker drops them, so the template places each
/// reference as a typst footnote.
#let note-defs(md) = {
  let d = (:)
  for c in md.split("\n\n").map(x => x.trim()) {
    let m = c.match(regex("^\\[\\^(\\d+)\\]:\\s*([\\s\\S]*)$"))
    if m != none { d.insert(m.captures.at(0), m.captures.at(1)) }
  }
  d
}

/// Paragraph text with `[^N]` references replaced by typst footnotes.
#let with-notes(s, notes) = {
  let pos = 0
  let out = []
  for m in s.matches(regex("\\[\\^(\\d+)\\]")) {
    out += inl(s.slice(pos, m.start))
    out += footnote(inl(notes.at(m.captures.at(0))))
    pos = m.end
  }
  out + inl(s.slice(pos))
}

#let plain-para(c, notes) = block(width: 100%, below: 0.6em, par(first-line-indent: 0pt)[#h(para-indent) #with-notes(c, notes)])

/// Items of a markdown ordered list, one string per item (continuation lines are joined).
#let list-items(c) = {
  let out = ()
  for line in c.split("\n") {
    let m = line.match(regex("^\\s*\\d+\\.\\s+(.*)$"))
    if m != none {
      out.push(m.captures.at(0))
    } else if out.len() > 0 {
      let k = out.len() - 1
      out.at(k) = out.at(k) + " " + line.trim()
    }
  }
  out
}

/// Numbered grounds or facts (FRBP 9013(b): the motion states its grounds with particularity).
/// The template numbers them; numbering restarts under each heading.
#let numbered-list(c, notes) = {
  for it in list-items(c) {
    block(width: 100%, below: 0.6em, par(first-line-indent: 0pt)[
      #h(para-indent) #ground-no.step()#context ground-no.display()#h(0.25in) #with-notes(it, notes)
    ])
  }
}

/// Body chunks are blank-line separated. `#` is a centered bold heading (the motion's own
/// title and section names); `##` is a bold argument heading. A numbered-list chunk is
/// numbered by the template, restarting under each heading. Other paragraphs are unnumbered.
#let render-body(md) = {
  let notes = note-defs(md)
  for c in md.split("\n\n").map(x => x.trim()).filter(x => x != "") {
    if c.match(regex("^\\[\\^\\d+\\]:")) != none {
      continue
    } else if c.starts-with("## ") {
      ground-no.update(0)
      argument-heading(c.slice(3))
    } else if c.starts-with("# ") {
      ground-no.update(0)
      heading-block(c.slice(2))
    } else if c.match(regex("^\\d+\\. ")) != none {
      numbered-list(c, notes)
    } else {
      plain-para(c, notes)
    }
  }
}

/// Signature block (FRBP 9011; N.D. Iowa L.R. 9010-1(b): business address, telephone,
/// e-mail and FAX below the signature).
#let signature(meta) = {
  let s = need(meta, "signature")
  block(breakable: false, above: 1.8em, grid(
    columns: (1fr, 3.9in),
    if "date" in s [Dated: #s.date] else [],
    stack(
      dir: ttb,
      spacing: 0.25em,
      [Respectfully submitted,],
      v(2.4em),
      [#text(style: "italic")[/s/ #s.signer]],
      [#s.signer, #s.bar],
      ..s.address.map(l => [#l]),
      [#s.firm],
      [Telephone: #s.phone],
      [Fax: #s.fax],
      [E-mail: #s.email],
      v(1em),
      [#s.role],
    ),
  ))
}

/// Certificate of service (FRBP 9013-3): the date and the manner of service must appear.
#let certificate-of-service(meta) = {
  let sv = need(meta, "service")
  block(breakable: false, above: 2em, {
    align(center, text(weight: "bold")[CERTIFICATE OF SERVICE])
    v(0.6em)
    par(first-line-indent: para-indent, [
      The undersigned certifies that on #sv.date, #sv.manner.
    ])
    v(1.2em)
    align(right, stack(dir: ttb, spacing: 0.25em, [#text(style: "italic")[/s/ #sv.by]], [#sv.by]))
  })
}

#let motion-brief(meta, md) = {
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: 10pt)[
      Page #counter(page).display() of #counter(page).final().first()
    ]),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, justify: false, linebreaks: "optimized")
  // FRBP 9013(b): a motion must set out the relief requested. The check is a keyword test
  // only (README, gap 6).
  assert(md.contains("relief") or md.contains("requests") or md.contains("request"), message: "FRBP 9013(b): the motion must set out the relief requested")
  caption(meta)
  render-body(md)
  signature(meta)
  certificate-of-service(meta)
}
