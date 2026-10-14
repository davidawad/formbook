// Complaint in an adversary proceeding, U.S. Bankruptcy Court, District of South Carolina (scb).
// Rules: Fed. R. Bankr. P. 7010 (caption: Official Form 416, the adversary-complaint version; Fed. R. Civ. P. 10), 7008(a) (jurisdiction
// statement and consent to final orders), 9004(a)-(b) (legible; caption with court, title, case and
// adversary numbers, and the document's character), 9037(a) (redaction of identifiers). Local: SC LBR
// 9011-4 (signature block). Fed. R. Civ. P. 10(b) (numbered paragraphs, as applied by Rule 7010). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice; see README.md)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"        // vendored in /fonts. No SC bankruptcy rule names a typeface.
#let type-size = 13pt                   // style choice: EB Garamond sets smaller than Times at the same size (README.md)
#let pitch = 24pt                       // double spacing: the line pitch of body text
#let body-leading = 0.54em              // tuned so body lines fall on the pitch (README.md)
#let single-leading = 0.2em             // caption, signature, block quotations
#let page-margin = 1in
#let para-indent = 0.5in                // first-line indent of unnumbered opening text
#let number-tab = 0.5in                 // gap after an allegation number; wrapped lines return to the margin
#let caption-left = 3.4in               // width of the party column of the caption
#let footer-size = 12pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("scb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Required frontmatter field: a missing key fails loudly rather than printing nothing.
#let need(meta, key) = {
  if key not in meta { panic("scb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Inline markdown (italic case names, smart quotes) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

// ---------------------------------------------------------------------------
// Cover: court title and caption (Official Form 416A layout; Fed. R. Bankr. P. 7010, 9004(b))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = need(meta, "court")
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  align(center, {
    for (i, l) in lines.enumerate() {
      if i == lines.len() - 1 { text(weight: "bold", l) } else { l }
      if i < lines.len() - 1 { linebreak() }
    }
  })
}

/// The caption: the bankruptcy case (In re: / Debtor.) above the adversary parties, with the case number,
/// chapter, adversary number and document title in the right column. Lines close the debtor block and the
/// party block, as on the filed form.
#let caption(meta) = {
  let b = need(meta, "bankruptcy")
  let parties = need(meta, "caption").parties
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    block(width: 100%, stroke: (right: 0.75pt), inset: (right: 0.15in), {
      set par(leading: single-leading, first-line-indent: 0pt, justify: false)
      stack(dir: ttb, spacing: pitch * 0.5,
        [In re:],
        stack(dir: ttb, spacing: single-leading, ..b.debtor.map(inl)),
        align(right)[Debtor.],
      )
      line(length: 100%, stroke: 0.75pt)
      v(pitch * 0.5)
      for (i, p) in parties.enumerate() {
        stack(dir: ttb, spacing: single-leading, ..p.names.map(inl))
        v(single-leading)
        pad(left: 1.4in, p.designation)
        if i < parties.len() - 1 {
          v(pitch * 0.5)
          pad(left: 0.4in, [v.])
          v(pitch * 0.5)
        }
      }
      line(length: 100%, stroke: 0.75pt)
    }),
    block(inset: (left: 0.25in), {
      set par(leading: single-leading, first-line-indent: 0pt, justify: false)
      [#b.case_number]
      linebreak()
      [#b.chapter]
      v(pitch * 3)
      [#need(meta, "adversary_number")]
      v(pitch * 1.5)
      text(weight: "bold", need(meta, "title"))
    }),
  )
}

#let cover(meta) = {
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body: numbered allegations (Fed. R. Civ. P. 10(b), by Rule 7010). Headings, quotations and lists are not
// numbered. A paragraph that directly follows a quotation or list is a continuation and is not numbered; a
// paragraph that leads into a list ("WHEREFORE ... for:") is not numbered either.
// ---------------------------------------------------------------------------

#let chunk-kind(t) = {
  if t.starts-with("#") { "heading" }
  else if t.starts-with(">") { "quote" }
  else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) { "list" }
  else { "para" }
}

#let numbered-para(kinds, i) = {
  let prev = if i > 0 { kinds.at(i - 1) } else { "heading" }
  let next = if i + 1 < kinds.len() { kinds.at(i + 1) } else { "" }
  kinds.at(i) == "para" and prev not in ("quote", "list") and next != "list"
}

/// Walk the markdown body chunk by chunk (a chunk is one blank-line-separated block).
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let kinds = chunks.map(chunk-kind)
  let out = ()
  for (i, c) in chunks.enumerate() {
    if numbered-para(kinds, i) {
      out.push([#para-counter.step()#context [#para-counter.display().#h(number-tab)#inl(c)]])
    } else {
      out.push(inl(c))
    }
  }
  out
}

/// The last two chunks (the prayer's lead-in and its list, or a closing heading and its paragraph) go on
/// one page with the signature block, so a signature never stands alone.
#let place-with-signature(parts, sig-block) = {
  let keep = calc.max(0, parts.len() - 2)
  for p in parts.slice(0, keep) {
    p
    parbreak()
  }
  block(breakable: false, {
    for p in parts.slice(keep) {
      p
      parbreak()
    }
    sig-block
  })
}

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: pitch, {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt, justify: false)
    pad(left: 3.25in, {
      [/s/ #sig.signer]
      linebreak()
      for l in sig.lines { inl(l); linebreak() }
      inl(sig.role)
    })
    v(pitch)
    [Dated: #sig.date]
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let scb-adversary-complaint(meta, md) = {
  let para-counter = counter("allegation")

  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "bankruptcy", "caption", "adversary_number", "title", "signature") {
    let _ = need(meta, k)
  }

  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: footer-size, counter(page).display("1"))),
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set enum(numbering: "a.", indent: 0.5in, body-indent: 0.5in, spacing: body-leading)

  // Headings: `##` is a centered bold line, with a half line of space above. The heading stays with the text after it.
  show heading.where(level: 2): it => block(width: 100%, above: pitch * 0.5, below: 0pt, sticky: true,
    align(center, strong(it.body)))

  // Block quotations: single-spaced, indented both sides.
  show quote.where(block: true): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5,
    pad(left: 0.5in, right: 0.5in, {
      set par(leading: single-leading, spacing: 0.9em, first-line-indent: 0pt, justify: false)
      it.body
    }))

  cover(meta)

  if "lead_in" in meta and meta.lead_in != none {
    block(width: 100%, {
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  let parts = allegations(md, para-counter)
  place-with-signature(parts, signature-block(meta))
}
