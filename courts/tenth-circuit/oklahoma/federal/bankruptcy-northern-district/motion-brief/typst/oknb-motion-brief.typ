// Motion with memorandum of law for the U.S. Bankruptcy Court, N.D. Oklahoma (oknb).
// Rules: Fed. R. Bankr. P. 9013 (a motion states its grounds with particularity and the relief sought),
// 9014 and 4003(d) (a motion to avoid a lien under 11 U.S.C. § 522(f) is a contested matter), 9004 (legibility,
// caption); Local Rules 9013-1(B) and (D)(6) (notice of opportunity for hearing: the title and a prescribed
// statement in the body; response time), 9013-1(G) and 5005-1(E) (service; certificate of service for
// parties not registered for electronic notice), 9004-1 (8 1/2 x 11, 12-point minimum including footnotes,
// margins of at least one inch, one side, double spaced), 9004-2 (caption), 9004-1(C) (signature block),
// 7007-1(A) (20-page brief limit: adversary proceedings only; no limit found for contested matters).
// See ../README.md for the rule text and dates.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/; the only typeface the build can use
#let type-size = 13pt                   // LBR 9004-1(A): no less than 12-point (footnotes included); 13 pt because EB Garamond sets small
#let page-w = 8.5in                     // LBR 9004-1(A): 8 1/2 by 11 inches
#let page-h = 11in
#let margin = 1in                       // LBR 9004-1(A): margins of no less than one inch
#let text-width = page-w - 2 * margin
#let body-leading = 1.35em              // double spacing: EB Garamond's line box is 0.65em, so 1.35em leading makes a 2.0em pitch (LBR 9004-1(A)); measured in README.md
#let single-leading = 0.5em             // single spacing for caption, notice box, signature block, certificate, footnotes
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.6in               // width of the party column of the caption (LBR 9004-2(A))
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "NORTHERN DISTRICT OF OKLAHOMA")  // LBR 9004-2(A): name of the court

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("oknb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown (paragraphs, lists).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line per item: the stack keeps single spacing between items.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Caption (LBR 9004-2(A)): court name, title of the case, case number, chapter, adversary number if any
// ---------------------------------------------------------------------------

#let court-title() = {
  set par(leading: single-leading, spacing: 0pt)
  align(center, stack(dir: ttb, spacing: single-leading,
    text(weight: "bold", court-name.at(0)),
    text(weight: "bold", court-name.at(1)),
  ))
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    let rows = ()
    if "in_re" in meta.caption {
      rows.push("In re:")
      rows.push(..meta.caption.in_re.names)
      rows.push(meta.caption.in_re.designation)
    }
    if "parties" in meta.caption {
      if rows.len() > 0 { rows.push("") }
      for (k, p) in meta.caption.parties.enumerate() {
        if k > 0 { rows.push("v.") }
        rows += p.names + (p.designation,)
      }
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    let rows = ("Case No. " + meta.case_number, "Chapter " + meta.chapter)
    if "adversary_number" in meta { rows.push("Adv. No. " + meta.adversary_number) }
    line-stack(rows)
  }),
)

#let title-block(meta) = {
  v(body-leading)
  block(width: text-width, breakable: false, align(center, text(weight: "bold", meta.title)))
  v(body-leading * 0.5)
}

// ---------------------------------------------------------------------------
// The notice of opportunity for hearing (LBR 9013-1(B)): the prescribed statement, in the body
// ---------------------------------------------------------------------------

#let notice-block(meta) = {
  let days = str(meta.response_days)
  block(width: text-width, stroke: 0.75pt, inset: 10pt, breakable: false, {
    set par(leading: single-leading, spacing: 0.6em, first-line-indent: 0pt, justify: false)
    align(center, text(weight: "bold", "NOTICE OF OPPORTUNITY FOR HEARING"))
    v(0.3em)
    [Your rights may be affected. You should read this document carefully and consult your attorney about your rights and the effect of this document. If you do not want the Court to grant the requested relief, or you wish to have your views considered, you must file a written response or objection to the requested relief with the Clerk of the United States Bankruptcy Court for the Northern District of Oklahoma, 224 South Boulder, Tulsa, Oklahoma 74103 no later than #days days from the date of filing of this request for relief. You should also serve a file-stamped copy of your response or objection to the undersigned movant/movant's attorney [and others who are required to be served] and file a certificate of service with the Court. If no response or objection is timely filed, the Court may grant the requested relief without a hearing or further notice. The #days day period includes the three (3) days allowed for mailing provided for in Fed. R. Bankr. P. 9006(f).]
  })
  v(body-leading * 0.5)
  block(width: text-width, breakable: false, {
    set par(leading: single-leading, spacing: 0.6em, first-line-indent: 0pt, justify: false)
    text(size: type-size)[The moving party shall calculate the appropriate response time. If a response time is prescribed by applicable statute, rule, or order, the moving party shall add to the prescribed response time unless service is accomplished by hand delivery, the three (3) days required for mailing under Bankruptcy Rule 9006(f). If a response time is not prescribed by applicable statute, rule, or order, the response time shall be fourteen (14) days, which includes the three (3) days required for mailing under Bankruptcy Rule 9006(f).]
  })
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Body flow. Paragraphs are not numbered (a memorandum of law); headings are numbered I., A., 1., and the
/// certificate of service is not. Footnote definitions are attached to the chunk that references them,
/// because each chunk is rendered separately; a definition-only chunk takes no space.
#let memorandum(body) = {
  let defs = body.matches(regex("(?m)^\\[\\^[^\\]]+\\]:[^\\n]*")).map(m => m.text)
  let notes-for(t) = {
    let refs = t.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0))
    defs.filter(d => refs.any(r => d.starts-with("[^" + r + "]:"))).join("\n\n")
  }
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "" and not c.trim().starts-with("[^"))
  set par(leading: body-leading, spacing: body-leading)
  let c1 = 0
  let c2 = 0
  let c3 = 0
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // A heading is a native typst heading (a block), so it takes its own vertical space.
      let level = t.find(regex("^#+")).len()
      let title = t.slice(level).trim()
      let label = if level == 1 {
        c1 += 1
        c2 = 0
        c3 = 0
        numbering("I.", c1)
      } else if level == 2 {
        c2 += 1
        c3 = 0
        numbering("A.", c2)
      } else if level == 3 {
        c3 += 1
        numbering("1.", c3)
      } else {
        panic("oknb-motion-brief: headings deeper than level 3 are not used")
      }
      if level == 1 {
        heading(level: level, numbering: none, label + h(0.5em) + title)
      } else {
        heading(level: level, numbering: none, box(width: 0.5in, label) + title)
      }
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      md(t + "\n\n" + notes-for(t))
      parbreak()
    } else {
      [#h(para-indent)#md(t + "\n\n" + notes-for(t))]
      parbreak()
    }
  }
}

/// Signature block (LBR 9004-1(C)): the signer's full name, state bar number, address, email, telephone,
/// and the party represented appear beneath the signature line.
#let signature-block(meta) = {
  let s = meta.signature
  assert("bar_number" in s, message: "oknb-motion-brief: signature.bar_number is required (LBR 9004-1(C))")
  assert("telephone" in s, message: "oknb-motion-brief: signature.telephone is required (LBR 9004-1(C))")
  assert("email" in s, message: "oknb-motion-brief: signature.email is required (LBR 9004-1(C))")
  block(width: text-width, breakable: false, above: body-leading, {
    grid(
      columns: (2.6in, 1fr),
      column-gutter: 0.2in,
      [Dated: #meta.date],
      {
        set par(leading: single-leading, spacing: 0pt, justify: false)
        [Respectfully submitted,]
        v(12pt)
        line-stack((s.firm,))
        v(12pt)
        line-stack((
          "By: /s/ " + s.signer,
          s.signer + " (" + s.bar_number + ")",
          ..s.address,
          "Telephone: " + s.telephone,
          "Email: " + s.email,
          "Attorneys for " + s.for,
        ))
      },
    )
  })
}

/// Certificate of service (LBR 9013-1(G)(2), 5005-1(E)): for parties not registered for electronic notice.
#let certificate-block(meta) = {
  let c = meta.certificate
  pagebreak(weak: true)
  block(width: text-width, breakable: false, above: body-leading, {
    align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
    v(body-leading * 0.5)
  })
  block(width: text-width, {
    set par(leading: body-leading, spacing: body-leading)
    [#h(para-indent)I certify that on #c.date, I served a true and correct copy of the #c.document, by #c.method, on the parties listed below. Parties registered to receive electronic notice through the Court's CM/ECF system were served by the Notice of Electronic Filing (LBR 5005-1(E)).]
    for s in c.served {
      block(width: text-width, inset: (left: 0.5in), {
        set par(leading: single-leading, spacing: 0pt)
        inl(s)
      })
      v(body-leading * 0.5)
    }
  })
  block(width: text-width, breakable: false, above: body-leading, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(("/s/ " + meta.signature.signer, meta.signature.signer))
  })
}

#let oknb-motion-brief(meta, body) = {
  assert("chapter" in meta, message: "oknb-motion-brief: chapter is required (LBR 9004-2(A))")
  assert("signature" in meta, message: "oknb-motion-brief: signature is required (LBR 9004-1(C))")
  assert("certificate" in meta, message: "oknb-motion-brief: certificate is required (LBR 9013-1(G))")
  if meta.notice_of_opportunity {
    assert("response_days" in meta, message: "oknb-motion-brief: response_days is required when notice_of_opportunity is true (LBR 9013-1(B))")
    assert(meta.title.contains("And Notice of Opportunity for Hearing"), message: "oknb-motion-brief: the title must include 'And Notice of Opportunity for Hearing' (LBR 9013-1(B))")
  }

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
    footer-descent: 0.4in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set heading(numbering: none)

  // Headings: level 1 centered bold capitals; level 2 bold, hanging from its label; level 3 bold italic.
  show heading.where(level: 1): it => block(width: text-width, above: body-leading, below: body-leading, breakable: false,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, above: body-leading, below: body-leading, breakable: false,
    par(hanging-indent: 0.5in, first-line-indent: 0pt, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: text-width, above: body-leading, below: body-leading, breakable: false,
    pad(left: 0.5in, par(hanging-indent: 0.5in, first-line-indent: 0pt, text(weight: "bold", style: "italic", it.body))))

  // Footnotes: the same size as the text (LBR 9004-1(A) includes footnotes in the 12-point minimum).
  set footnote.entry(
    gap: 0.5em, clearance: 0.9em, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(left: para-indent, right: para-indent, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
    it.body
  }))

  // Cover: court title, caption, title of the paper (LBR 9004-2(A)).
  court-title()
  v(body-leading)
  caption(meta)
  title-block(meta)

  // Notice of opportunity for hearing (LBR 9013-1(B)), then the motion and its memorandum.
  if meta.notice_of_opportunity { notice-block(meta) }

  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  memorandum(body)

  signature-block(meta)
  certificate-block(meta)
}
