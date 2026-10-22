// Motion to dismiss with memorandum for the U.S. District Court for the Eastern District of Texas (txed).
// Rules: Local Rule CV-10(a) (style and number, caption with party designation and statement of the
// document's character, signature, double spacing, 12-point minimum, 8 1/2 x 11 paper); CV-7(a) (separate
// document; statement of the issues for a case dispositive motion; 30-page limit, excluding attachments,
// CV-7(a)(1)); CV-5(c) (certificate of service showing date and method); CV-7(i) (certificate of conference
// is not required for a motion to dismiss). Fed. R. Civ. P. 12(b)(6). See ../README.md and ../../rules.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // vendored in fonts/; no face in the rules, the exemplars' face
#let type-size = 12pt              // CV-10(a)(5): no smaller than 12-point (footnotes and page number too)
#let page-w = 8.5in                // CV-10(a)(4): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in
#let indent = 0.5in                // first-line indent of body paragraphs
#let caption-right = 2.6in         // width of the right-hand column of the caption
#let caption-gutter = 0.25in
#let designation-indent = 1.5in    // the party's designation in the party column
#let signature-indent = 3in        // the signature block stands at the right half of the page
#let quote-indent = 0.5in          // block quotations: indented from both margins
#let note-gap = 6pt                // between two footnotes
#let note-clearance = 7.8pt        // between the text and the footnote rule: with note-gap, Word's separator line (13.8 pt)
#let page-limit = 30               // CV-7(a)(1): case dispositive motions shall not exceed thirty pages, excluding attachments

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt         // a single line: 1.15 x the type size; caption, title, quotations, signature, footnotes
#let pitch-double = 2 * pitch-single // CV-10(a)(5): double spaced (27.6 pt, the exemplar's pitch)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txed-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced lines (a paragraph of its own; a long one wraps on the single pitch), with explicit space above it.
#let sline(above: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

// ---------------------------------------------------------------------------
// Cover: court (line 1 onward), caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(lines) = for l in lines {
  sline(align(center, text(weight: "bold", upper(l))))
}

/// Parties on the left ("v." between them, each designation indented); the case number and the bold line under it
/// (`jury_demand`) at the foot of the right column, a double line below the court.
#let caption(meta) = block(width: 100%, above: pitch-double, below: 0pt, grid(
  columns: (1fr, caption-right),
  column-gutter: caption-gutter,
  {
    for (k, p) in meta.caption.enumerate() {
      if k > 0 { sline[v.] }
      for n in p.names { sline(inl(n)) }
      sline(indent: designation-indent, inl(p.designation))
    }
  },
  align(bottom, {
    sline(inl(meta.case_number))
    if "jury_demand" in meta { sline(above: pitch-single, text(weight: "bold", meta.jury_demand)) }
  }),
))

/// The title states the filer and the character of the document (CV-10(a)(2)), e.g.
/// "Defendant John Doe's Motion to Dismiss under Rule 12(b)(6)". The sample supplies it whole. Bold capitals,
/// centered, single spaced, a double line below the caption; the text follows on its grid.
#let title-of-paper(meta) = block(width: 100%, above: pitch-double, below: 0pt, sticky: true,
  sline(align(center, text(weight: "bold", upper(inl(meta.brief_title))))))

// ---------------------------------------------------------------------------
// Signature block (CV-10(a)(3): signed by the lead attorney or with his or her permission), single spaced at the
// right half of the page, a double line below the text; it never breaks across a page.
// ---------------------------------------------------------------------------

#let signature(sig) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  sline(indent: signature-indent)[Respectfully submitted,]
  for (i, l) in sig.firm.enumerate() { sline(above: if i == 0 { pitch-single } else { 0pt }, indent: signature-indent, inl(l)) }
  sline(above: pitch-single, indent: signature-indent)[/s/ #sig.signer]
  sline(indent: signature-indent, inl(sig.signer))
  for l in sig.lines { sline(indent: signature-indent, inl(l)) }
  sline(above: pitch-single, indent: signature-indent, inl(sig.role))
})

/// Certificate of service (CV-5(c): the date and the method of service), a double line below the signature: the
/// heading and the statement at the body pitch, one unbreakable block. Generated from frontmatter, so the text is
/// not typed per case. Not a certificate of conference: CV-7(i) exempts motions to dismiss.
#let certificate-of-service(service) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  set par(first-line-indent: 0pt)
  align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
  [I hereby certify that on #inl(service.date), the foregoing document was served on all counsel of record #inl(service.method).]
})

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, quotations, lettered lists
// ---------------------------------------------------------------------------

/// Headings at the body pitch, bold, sticky (a heading never ends a page): level 1 centered capitals numbered I.,
/// II., ...; level 2 at the margin, A., B., ... within the section; level 3 bold italic, unnumbered.
#let section-heading(it) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  align(center, text(size: type-size, weight: "bold", [#counter("section").step()#counter("subsection").update(0)#context counter("section").display("I.") #upper(it.body)]))
})

#let subsection-heading(it) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  text(size: type-size, weight: "bold", [#counter("subsection").step()#context counter("subsection").display("A.") #it.body])
})

/// A lettered list: a. at the indent, the text hanging a further half inch.
#let lettered(items) = for (i, item) in items.enumerate() {
  block(width: 100%, above: 0pt, below: 0pt, pad(left: indent,
    par(first-line-indent: 0pt, hanging-indent: indent, [#box(width: indent, numbering("a.", i + 1))#item.body])))
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let txed-motion-brief(meta, body) = {
  // CV-7(a)(1): a case dispositive motion states the issues to be decided by the court.
  // An excerpt sample (frontmatter `excerpt: true`) is a transcription of part of a filing; its check is skipped.
  if not meta.at("excerpt", default: false) and not lower(body).contains("statement of the issue") {
    panic("txed-motion-brief: CV-7(a)(1) requires a statement of the issues to be decided (a level-1 heading 'Statement of the Issue(s)')")
  }

  set document(title: meta.case_number + " " + meta.brief_title)
  // Page numbers centered at the foot, arabic, at the type size (CV-10(a)(5)); the number in a single-spaced line
  // box, so it sits at the same place on every page (Word's footer).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // A paragraph that follows a paragraph is indented (typst's rule; not after a heading, a quotation or a list).
  set par(first-line-indent: indent)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (CV-10(a)(5): double spaced).
  show: xengine.with(pitch: pitch-double)
  // A doubled sign stays with its number ("¶¶ 92"), as in Word (xengine binds one sign only).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // A web address breaks only after "?", "=", "&", a hyphen or a slash that no digit (nor a second slash) follows:
  // each part is a box, so the PDF text keeps the author's characters. Without this typst breaks an address at any
  // character ("www.stark / 80.com"), which Word does not.
  show regex("(https?://|www\\.)\\S+"): it => {
    let parts = ("",)
    let cs = it.text.clusters()
    for (i, c) in cs.enumerate() {
      parts.last() += c
      let next = cs.at(i + 1, default: "")
      let prev = cs.at(i - 1, default: "")
      if c in ("?", "=", "&") or (c in ("/", "-") and next != "/" and not (c == "/" and prev == "/")
        and next.match(regex("^[0-9]$")) == none) { parts.push("") }
    }
    parts.filter(p => p != "").map(p => box(p)).join()
  }
  set heading(numbering: none)
  show heading.where(level: 1): it => section-heading(it)
  show heading.where(level: 2): it => subsection-heading(it)
  show heading.where(level: 3): it => block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
    set par(first-line-indent: 0pt)
    text(size: type-size, style: "italic", weight: "bold", it.body)
  })
  show list: it => lettered(it.children)
  // Block quotations: single spaced, indented half an inch from both margins, a single line above and below.
  show quote.where(block: true): it => block(width: 100%, above: pitch-single, below: pitch-single,
    pad(x: quote-indent, {
      set text(..edges(pitch-single))
      set par(first-line-indent: 0pt)
      it.body
    }))
  // Footnotes at the type size (CV-10(a)(5)) in single line boxes: the mark, a space, the note; a 0.5 pt rule a
  // third of the way across.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  court-title(meta.court)
  caption(meta)
  title-of-paper(meta)
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  signature(meta.signature)
  if "service" in meta { certificate-of-service(meta.service) }

  // CV-7(a)(1): 30 pages, excluding attachments (attachments are not part of this build).
  context {
    let n = counter(page).final().first()
    if n > page-limit {
      panic("txed-motion-brief: " + str(n) + " pages; CV-7(a)(1) limits a case dispositive motion to " + str(page-limit) + " pages, excluding attachments")
    }
  }
}
