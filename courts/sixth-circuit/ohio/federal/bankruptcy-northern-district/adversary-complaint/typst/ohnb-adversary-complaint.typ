// N.D. Ohio bankruptcy court: adversary complaint (FRBP 7001, 7003, 7008, 7010; LBR 5005-1, 7003-1).
// Content-agnostic: everything case-specific comes from the frontmatter of the sample (`meta`) or the
// markdown body. Numbers and sizes below are the court's rules or project conventions, cited in README.md.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---- page and type (LBR 5005-1(a)(1): 8 1/2 x 11 inch, one side) ----
#let page-margin = 1in          // convention: no N.D. Ohio margin rule for complaints (LBR 5005-1 silent)
#let type-size = 12pt           // convention: LBR 9013-2(a) sets 12 pt for motions and briefs; complaints follow
#let serif = ("Times New Roman", "Liberation Serif") // vendored (fonts/); the docx names the same face

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the
// space below the one and above the other (Word's exact line spacing; docx/ohnb-adversary-complaint.lua sets the
// same twips, 20 x pt).
#let pitch-body = 24pt          // double spacing, as both filed complaints (docx 480)
#let pitch-single = 13.8pt      // court lines, caption, title, signature, footer (docx 276)
#let blank = 13.8pt             // one blank single line: court lines to caption, caption to title, title to body
#let para-indent = 0.5in        // first-line indent of every body paragraph (docx 720)
#let cap-left = 3.5in           // caption: the parties (docx 5040)
#let cap-mid = 0.3in            // caption: the ")" column (docx 432)
#let cap-right = 2.7in          // caption: case, chapter, judge and adversary numbers (docx 3888)
#let sig-indent = 3.25in        // the signature block, at the middle of the line as in both filed complaints (docx 4680)
#let footer-foot = 0.5in        // the page number's line ends this far above the bottom edge (docx footer 720)

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced lines, one paragraph each; an empty item is a blank single line. `above`: space above the first.
#let lines(items, above: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let gap = above
  for i in items {
    if i == "" { gap += pitch-single } else {
      block(width: 100%, above: gap, below: 0pt, if type(i) == str { inl(i) } else { i })
      gap = 0pt
    }
  }
}

/// Caption per FRBP 9004(b) (court name, title, case number and adversary number, designation of the
/// document) and FRBP 7010 (the caption substantially conforms to Official Form 416A): the parties at the left,
/// a column of ")", the numbers at the right, one single line per row.
#let caption(meta) = {
  let court = meta.court + if "division" in meta { (meta.division,) } else { () }
  lines(court.map(l => align(center, strong(upper(l)))))

  let left = ()
  for d in meta.debtor-caption { left.push(d) }
  left.push("")
  left.push("Debtor.")
  left.push("")
  left.push(text("____________________________________"))
  left.push("")
  for p in meta.plaintiffs { left.push(upper(p)) }
  left.push("Plaintiff,")
  left.push("")
  left.push("v.")
  left.push("")
  for d in meta.defendants { left.push(upper(d)) }
  left.push("Defendant.")

  let right = ("Case No. " + meta.case-number, "")
  if "chapter" in meta { right += ("Chapter " + meta.chapter, "") }
  if "judge" in meta { right += ("Judge " + meta.judge, "") }
  if "adversary-number" in meta { right += ("Adv. Pro. No. " + meta.adversary-number,) }
  let n = calc.max(left.len(), right.len())
  let cell(s) = block(width: 100%, above: 0pt, below: 0pt, if s == "" { block(height: pitch-single) } else if type(s) == str { inl(s) } else { s })
  let rows = ()
  for i in range(n) {
    rows.push((
      cell(left.at(i, default: "")),
      align(center, cell(")")),
      cell(right.at(i, default: "")),
    ))
  }
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  block(width: 100%, above: blank, below: 0pt, grid(
    columns: (cap-left, cap-mid, cap-right),
    ..rows.flatten(),
  ))
  lines((align(center, strong(meta.title)),), above: blank)
}

/// Signature block (LBR 5005-1(c): typewritten name, firm, address, phone, e-mail, bar number, "s/name"),
/// single-spaced from the middle of the line.
#let signature(sig) = block(width: 100%, above: blank, below: 0pt, pad(left: sig-indent, lines(
  ("Respectfully submitted,", "", "s/ " + sig.signer, sig.signer-name-printed) + sig.lines,
)))

/// Body chunks: blank-line-separated markdown blocks.
#let chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")

#let ohnb-adversary-complaint(meta, body) = {
  set document(title: meta.title)
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: none,
    // the page number, centred, its single line ending footer-foot above the bottom edge
    foreground: place(bottom + left, dx: page-margin, dy: -footer-foot, block(width: 8.5in - 2 * page-margin,
      context {
        set text(font: serif, size: type-size, ..edges(pitch-single))
        set par(first-line-indent: 0pt, leading: 0pt)
        align(center, str(counter(page).get().first()))
      })),
  )
  set text(font: serif, size: type-size, lang: "en", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  show: xengine.with(pitch: pitch-body)
  // A doubled sign stays with its number ("§§ 1107(a)"; xengine binds a single sign; docx: a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  // Headings on the body pitch at the type size, kept with the text after them: centred bold capitals.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    block(width: 100%, above: 0pt, below: 0pt, sticky: true,
      align(center, par(strong(if it.level <= 2 { upper(it.body) } else { it.body }))))
  }

  caption(meta)
  // one blank single line between the title and the body
  block(width: 100%, above: 0pt, below: 0pt, height: blank)

  let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
  // The last chunk is kept with the signature block, so a sign-off never stands alone on a page.
  let cs = chunks(body)
  for c in cs.slice(0, -1) { md(c); parbreak() }
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    md(cs.last())
    parbreak()
    signature(meta.signature)
  })
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ohnb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}
