// N.D. Ohio bankruptcy court: motion with memorandum (FRBP 9013, 9014, 9004, 7010 caption; LBR 5005-1,
// 9013-1 (notice, response), 9013-2 (20-page limit, 12-point type), 9013-3 (certificate of service)).
// Content-agnostic: case facts come from the frontmatter (`meta`) and the markdown body. Sizes that the
// rules do not set are conventions, cited in README.md.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---- page and type ----
#let page-margin = 1in          // convention: no N.D. Ohio margin rule (LBR 5005-1 sets paper size only)
#let type-size = 12pt           // LBR 9013-2(a): at least 12 point, footnotes included (mandated)
#let serif = ("Times New Roman", "Liberation Serif") // vendored (fonts/); the docx names the same face

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the
// space below the one and above the other (Word's exact line spacing; docx/ohnb-motion-brief.lua sets the same
// twips, 20 x pt).
#let pitch-body = 24pt          // convention: double spacing, as both filed motions (docx 480)
#let pitch-single = 13.8pt      // court lines, caption, title, signature, service list, footer (docx 276)
#let blank = 13.8pt             // one blank single line: around the caption and the title, above a signature,
                                // above the notice and the certificate
#let para-indent = 0.5in        // first-line indent of every body paragraph (docx 720)
#let cap-left = 3.5in           // caption: the parties (docx 5040)
#let cap-mid = 0.3in            // caption: the ")" column (docx 432)
#let cap-right = 2.7in          // caption: case, chapter, judge and adversary numbers (docx 3888)
#let sig-indent = 3.25in        // signature blocks, at the middle of the line as in both filed motions (docx 4680)
#let footer-foot = 0.5in        // the page number's line ends this far above the bottom edge (docx footer 720)

#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

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

/// A centred bold heading on the body pitch, kept with what follows.
#let head(body, above: 0pt) = block(width: 100%, above: above, below: 0pt, sticky: true,
  align(center, par(first-line-indent: 0pt, strong(body))))

/// A body paragraph on the body pitch with the first-line indent.
#let body-par(body) = block(width: 100%, above: 0pt, below: 0pt, par(body))

/// Caption per FRBP 9004(b) and 7010 (court, title, case and adversary numbers, designation): the parties at the
/// left, a column of ")", the numbers at the right, one single line per row.
#let caption(meta) = {
  let court = meta.court + if "division" in meta { (meta.division,) } else { () }
  lines(court.map(l => align(center, strong(upper(l)))))

  let left = ()
  for d in meta.debtor-caption { left.push(d) }
  left.push("Debtor.")
  if "parties" in meta {
    left.push("")
    left.push(text("____________________________________"))
    left.push("")
    for p in meta.parties.plaintiffs { left.push(upper(p)) }
    left.push(meta.parties.plaintiff-designation)
    left.push("")
    left.push("v.")
    left.push("")
    for d in meta.parties.defendants { left.push(upper(d)) }
    left.push(meta.parties.defendant-designation)
  }

  let right = ("Case No. " + meta.case-number, "")
  if "chapter" in meta { right += ("Chapter " + meta.chapter, "") }
  if "judge" in meta { right += ("Judge " + meta.judge, "") }
  if "adversary-number" in meta { right += ("Adv. Pro. No. " + meta.adversary-number,) }

  let n = calc.max(left.len(), right.len())
  let cell(s) = block(width: 100%, above: 0pt, below: 0pt,
    if s == "" { block(height: pitch-single) } else if type(s) == str { inl(s) } else { s })
  let rows = ()
  for i in range(n) {
    rows.push((cell(left.at(i, default: "")), align(center, cell(")")), cell(right.at(i, default: ""))))
  }
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  block(width: 100%, above: blank, below: 0pt, grid(columns: (cap-left, cap-mid, cap-right), ..rows.flatten()))
  lines((align(center, strong(meta.title)),), above: blank)
  // one blank single line between the title and the body
  block(width: 100%, above: 0pt, below: 0pt, height: blank)
}

/// Signature block (LBR 5005-1(c)): "s/" name, typewritten name, firm, address, phone, e-mail, bar number; single
/// lines from the middle of the line.
#let signature(sig) = block(width: 100%, above: blank, below: 0pt, pad(left: sig-indent, lines(
  ("Respectfully submitted,", "", "s/ " + sig.signer, sig.signer-name-printed) + sig.lines,
)))

/// Body chunks: blank-line-separated markdown blocks.
#let chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")

/// A part of the body (the motion, the memorandum), its last chunk kept with the signature block that ends it.
#let part(body, sig) = {
  let cs = chunks(body)
  for c in cs.slice(0, -1) { md(c); parbreak() }
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    md(cs.last())
    parbreak()
    signature(sig)
  })
}

/// Notice and certificate of service, each kept on one page: the notice wording is LBR 9013-1(a)(2) (14 days; the
/// court may grant without further notice). The certificate content is LBR 9013-3(1)-(4).
#let certificate(meta) = {
  let svc = meta.service
  block(width: 100%, breakable: false, above: blank, below: 0pt, {
    head[NOTICE OF MOTION]
    body-par[Any objection to this motion must be filed within 14 days, or such other time as specified by applicable Federal Rule of Bankruptcy Procedure or statute or as the Court may order, from the date of service as set forth on the certificate of service below, if the relief sought is opposed. The Court is authorized to grant the relief requested without further notice unless a timely objection is filed.]
  })
  block(width: 100%, breakable: false, above: blank, below: 0pt, {
    head[CERTIFICATE OF SERVICE]
    body-par(inl("I hereby certify that on " + svc.date + ", a true copy of the foregoing " + svc.document
      + " was served " + svc.method-ecf + " " + svc.method-mail))
    lines(svc.entities)
    block(width: 100%, above: blank, below: 0pt,
      pad(left: sig-indent, lines(("s/ " + meta.signature.signer, meta.signature.signer-name-printed))))
  })
}

#let ohnb-motion-brief(meta, body) = {
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
  // A doubled sign stays with its number ("§§ 727(a)"; xengine binds a single sign; docx: a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)

  // Headings on the body pitch at the type size, centred bold, levels 1 and 2 in capitals, a blank single line above
  // level 1 (the memorandum after the motion.s signature); kept with the next line.
  show heading: it => {
    set text(size: type-size)
    head(if it.level <= 2 { upper(it.body) } else { it.body }, above: if it.level == 1 { blank } else { 0pt })
  }

  caption(meta)

  // The motion runs to the first "# MEMORANDUM" heading; the memorandum follows it. Each part is signed.
  let at = body.position("# MEMORANDUM")
  if at == none { panic("ohnb-motion-brief: the sample needs a '# MEMORANDUM' heading") }
  part(body.slice(0, at), meta.signature)
  part(body.slice(at), meta.signature)
  certificate(meta)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ohnb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}
