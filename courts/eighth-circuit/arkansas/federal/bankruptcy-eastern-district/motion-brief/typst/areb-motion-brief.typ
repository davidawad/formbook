// U.S. Bankruptcy Court, Eastern District of Arkansas: motion with memorandum (brief) in support.
//
// Rule-driven and content-agnostic. Rule IDs (AREB-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed motion, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML
// frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a convention)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")          // convention: vendored serif (no system fonts)
#let type-size = 12pt                      // AREB-FORM-004 (convention): no rule sets a size
#let body-leading = 1.2em                  // convention: about double spacing for body text
#let single-leading = 0.45em               // caption, counsel block, signature, quotations
#let page-margin = 1in                     // AREB-FORM-003 (convention): one-inch margins
#let paragraph-indent = 0.5in              // first-line indent of numbered motion paragraphs

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Several lines, one per element, with no paragraph gap between them. Used instead of
/// forced line breaks.
#let lines(items) = stack(dir: ttb, spacing: single-leading, ..items.map(inl))

#let need(meta, key) = {
  if key not in meta { panic("areb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("areb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Caption (FRBP 9004(b): court name, case title, case and adversary numbers, designation;
// the adversary block appears only when the motion is filed in an adversary proceeding)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  // Caption lines are ragged-right: justified names open gaps between words.
  set par(justify: false)
  let court = need(meta, "court")
  align(center, stack(
    dir: ttb,
    spacing: single-leading,
    text(weight: "bold", upper(need(court, "name"))),
    text(weight: "bold", upper(need(court, "district"))),
    text(weight: "bold", upper(need(court, "division"))),
  ))
  v(1.6em)

  let debtor = need(meta, "debtor")
  let in-adversary = "adversary_number" in meta

  grid(
    columns: (3.5in, 1fr),
    rect(
      width: 100%,
      fill: none,
      stroke: (right: 0.8pt + black, bottom: 0.8pt + black),
      inset: (right: 0.2in, bottom: 0.9em, top: 0.2em),
      stack(
        dir: ttb,
        spacing: 1.1em,
        stack(
          dir: ttb,
          spacing: single-leading,
          [IN RE:],
          ..debtor.names.map(n => align(center, inl(n))),
          align(right, [Debtor#if debtor.names.len() > 1 [s]. ]),
        ),
        if in-adversary {
          stack(
            dir: ttb,
            spacing: 1.1em,
            stack(
              dir: ttb,
              spacing: single-leading,
              ..need(meta, "plaintiffs").names.map(n => inl(n)),
              align(right, inl(need(meta, "plaintiff_designation"))),
            ),
            align(center, [v.]),
            stack(
              dir: ttb,
              spacing: single-leading,
              ..need(meta, "defendants").names.map(n => inl(n)),
              align(right, inl(need(meta, "defendant_designation"))),
            ),
          )
        } else { [] },
      ),
    ),
    align(horizon, pad(left: 0.25in, stack(
      dir: ttb,
      spacing: 0.9em,
      [Case No. #need(debtor, "case_number")],
      [Chapter #need(debtor, "chapter")],
      if in-adversary { [Adv. Proc. No. #meta.adversary_number] } else { [] },
    ))),
  )
  v(1.6em)

  align(center, text(weight: "bold", need(meta, "title")))
  v(1.2em)
}

// ---------------------------------------------------------------------------
// Counsel, signature and certificate of service
// (LR 5005-4: address, telephone and state bar number on every filing; FRBP 9011)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let counsel = need(meta, "counsel")
  block(breakable: false, {
    if "date" in meta [Dated: #meta.date]
    v(1.2em)
    align(right, block(width: 3.2in, stack(
      dir: ttb,
      spacing: 0.9em,
      [Respectfully submitted,],
      // Signature line as "s/ NAME" (FRBP 9011(a)); the signer's name is printed under it.
      lines((("s/ " + need(sig, "signer")),) + need(sig, "lines")),
    )))
  })
  v(1.5em)
  let counsel-lines = ()
  for g in counsel { counsel-lines += g.names + g.lines }
  counsel-lines.push(need(meta, "phone"))
  block(breakable: false, lines(counsel-lines))
}

/// Certificate of service: boilerplate wording, with the date, method and parties taken
/// from the metadata. The served list is printed one party per element.
#let certificate(meta) = {
  let svc = need(meta, "service")
  v(2em)
  block(breakable: false, {
    align(center, text(weight: "bold", [CERTIFICATE OF SERVICE]))
    v(0.9em)
    par(first-line-indent: paragraph-indent, [
      I certify that on #need(svc, "date"), the foregoing motion and memorandum in support were served electronically through the Court's CM/ECF system on the parties registered to receive notice, and by first-class United States mail, postage prepaid, on the parties listed below who are not registered.
    ])
    v(0.9em)
    lines(need(svc, "parties"))
    v(1.2em)
    align(right, block(width: 3.2in, lines((("s/ " + need(need(meta, "signature"), "signer")),))))
  })
}

// ---------------------------------------------------------------------------
// Page, text and heading styles
// ---------------------------------------------------------------------------

#let areb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    number-align: center,
  )
  set text(font: font-family, size: type-size, lang: "en", fill: black)
  set par(justify: true, leading: body-leading, first-line-indent: 0pt)

  // Headings print as written: upper() would turn "523(a)(6)" into "523(A)(6)".
  show heading.where(level: 1): it => block(above: 1.2em, below: 1em, width: 100%, align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 2): it => block(above: 1.1em, below: 0.9em, width: 100%, text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => block(above: 1em, below: 0.8em, width: 100%, text(size: type-size, style: "italic", it.body))

  // Numbered motion paragraphs: every Markdown ordered-list item in the body is one
  // numbered paragraph, numbered continuously (the grounds and relief of FRBP 9013(b)).
  let para-no = counter("areb-para-no")
  show enum: it => it.children.map(item => {
    para-no.step()
    context [#h(paragraph-indent)#para-no.display(). #h(0.3em)#item.body]
    v(body-leading * 0.5)
  }).join()

  show quote: it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.0em, {
    set par(leading: single-leading, justify: true)
    it.body
  })

  caption(meta)

  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)

  signature-block(meta)
  certificate(meta)
}
