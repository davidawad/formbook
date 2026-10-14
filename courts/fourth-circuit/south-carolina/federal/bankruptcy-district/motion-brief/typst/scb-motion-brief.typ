// Motion with memorandum of law, adversary proceeding, U.S. Bankruptcy Court, District of South Carolina (scb).
// Rules: Fed. R. Bankr. P. 7012(b) (Rule 12(b) defenses by motion in an adversary proceeding), 9013(b) (a
// motion states its grounds with particularity and the relief sought), 9004(a)-(b) (legible; caption), 9037(a)
// (redaction). Local: SC LBR 7012-1 (notice to a pro se party; text reproduced below), 9013-2(a) (a memorandum is filed and served
// no later than seven days before the hearing), 9011-4 (signature with "/s/" and typed name). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice; see README.md)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"        // vendored in /fonts. No SC bankruptcy rule names a typeface.
#let type-size = 13pt                   // style choice: EB Garamond sets smaller than Times at the same size (README.md)
#let pitch = 24pt                       // double spacing: the line pitch of body text
#let body-leading = 0.54em              // tuned so body lines fall on the pitch (README.md)
#let single-leading = 0.2em             // caption, signature, notice headings, footnotes
#let page-margin = 1in
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let number-tab = 0.3in                 // gap after a numbered fact
#let caption-left = 2.9in               // width of the party column of the caption
#let caption-paren = 0.25in             // the column of ")" marks
#let footer-size = 12pt

// Text of the notice that SC LBR 7012-1 requires where the non-moving party has no counsel
// (SC LBR 7012-1, as amended 2025; reproduced from the rule's text, 2026 local rules PDF, fetched 2026-10-14).
#let notice-text = "A motion to dismiss is a request that one or more issues in a case be decided without holding a trial. Motions to dismiss are governed by Rule 12, Federal Rules of Civil Procedure. Your complaint, or the portions of your complaint that the motion seeks to dismiss, may be dismissed if the court finds that the complaint does not contain sufficient allegations to state a claim upon which the court can grant relief. If you wish to oppose the motion to dismiss, you must file with the court and serve on the other party a written response within the time period set forth in a notice that will be separately mailed to you by the Clerk of Court. If you file a written response, a hearing will be held at the location and time set forth in the notice from the Clerk of Court. If you fail to file a timely written response to the motion, the court will consider the motion unopposed and may grant the motion without holding a hearing. This will result in the termination of the proceeding, or some part thereof, in favor of the moving party."

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("scb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Required frontmatter field: a missing key fails loudly rather than printing nothing.
#let need(meta, key) = {
  if key not in meta { panic("scb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Inline markdown (italic case names, smart quotes) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

// ---------------------------------------------------------------------------
// Cover: court title and caption (")" style, Fed. R. Bankr. P. 9004(b), 7010 by analogy)
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

/// One caption cell. A left entry starting with `~` is right-aligned (designations: "Debtors.",
/// "Plaintiff,", "Defendant."); one starting with `>` is indented (the "v." between the parties).
#let cap-cell(s) = {
  if s.starts-with("~") { pad(right: 0.12in, align(right, inl(s.slice(1)))) }
  else if s.starts-with(">") { pad(left: 0.4in, inl(s.slice(1))) }
  else { inl(s) }
}

/// The caption as one row per line: party names on the left, a ")" on every row, and the case
/// information on the right.
#let caption(meta) = {
  let rows = need(meta, "caption").rows
  block(width: 100%, {
    set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    table(
      columns: (caption-left, caption-paren, 1fr),
      inset: 0pt,
      stroke: none,
      ..rows.map(r => (
        cap-cell(r.at(0)),
        [)],
        pad(left: 0.15in, inl(r.at(1))),
      )).flatten(),
    )
  })
}

#let title-line(meta) = {
  v(pitch)
  align(center, strong(upper(need(meta, "title"))))
  v(pitch * 0.5)
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Bankr. P. 9011 and SC LBR 9011-4: "/s/" with the typed name)
// ---------------------------------------------------------------------------

#let signature-block(sig, respectfully: true) = block(breakable: false, above: pitch, {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt, justify: false)
  pad(left: 3.25in, {
    if respectfully {
      [Respectfully submitted,]
      v(pitch * 0.5)
    }
    inl(sig.firm)
    v(pitch * 0.5)
    [/s/ #sig.signer]
    linebreak()
    for l in sig.lines { inl(l); linebreak() }
    inl(sig.role)
  })
  v(pitch * 0.5)
  [#sig.date]
})

// ---------------------------------------------------------------------------
// Notice to a pro se party (SC LBR 7012-1), when the frontmatter has `notice`
// ---------------------------------------------------------------------------

#let title-line-plain(s) = {
  v(pitch * 0.5)
  align(center, strong(s))
  v(pitch * 0.5)
}

#let notice-part(meta) = {
  caption(meta)
  title-line-plain("NOTICE REQUIRED BY SC LBR 7012-1")
  set par(leading: body-leading, first-line-indent: para-indent, justify: false)
  par(first-line-indent: 0pt)[TO: #need(meta, "notice").addressee]
  parbreak()
  notice-text
  parbreak()
  signature-block(need(meta, "signature"), respectfully: false)
}

// ---------------------------------------------------------------------------
// Body: the motion and memorandum. Paragraphs are numbered only inside the section named by the
// frontmatter field `numbered_section` (the facts); argument prose is not numbered. Headings are
// level 2 (centered), level 3 (A., B., ...) and level 4 (1., 2., ...).
// ---------------------------------------------------------------------------

#let chunk-kind(t) = {
  if t.starts-with("#") { "heading" }
  else if t.starts-with(">") { "quote" }
  else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) { "list" }
  else { "para" }
}

/// Walk the markdown body chunk by chunk. Numbering is applied per chunk, not with a `show par` rule:
/// a show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let motion-body(md, prefix, para-counter) = {
  // Footnote definitions are rendered with the chunk that cites them: cmarker sees a reference and its
  // definition in the same call, and the definition lines are taken out of the body here.
  let defs = (:)
  for m in md.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$")) {
    defs.insert(m.captures.at(0), m.captures.at(1))
  }
  let text = md.replace(regex("(?m)^\\[\\^[^\\]]+\\]:.*$"), "")
  let chunks = text.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let numbered = false
  let out = ()
  for c in chunks {
    if c.starts-with("## ") {
      numbered = prefix != none and c.slice(3).trim().starts-with(prefix)
    }
    let refs = c.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0)).dedup()
    let src = c + refs.map(l => "\n\n[^" + l + "]: " + defs.at(l)).fold("", (a, b) => a + b)
    if chunk-kind(c) == "para" and numbered {
      out.push([#para-counter.step()#context [#para-counter.display().#h(number-tab)#inl(src)]])
    } else {
      out.push(inl(src))
    }
  }
  out
}

/// Place the chunks, then the signature. The last two chunks (a closing heading and its paragraph, or a
/// lead-in and its list) go on one page with the signature block, so a signature never stands alone.
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

#let motion-part(meta, md) = {
  let para-counter = counter("fact")
  caption(meta)
  title-line(meta)
  let parts = motion-body(md, meta.at("numbered_section", default: none), para-counter)
  place-with-signature(parts, signature-block(need(meta, "signature")))
}

// ---------------------------------------------------------------------------
// The filing
// ---------------------------------------------------------------------------

#let scb-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "bankruptcy", "caption", "title", "signature") {
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
  set par(leading: body-leading, spacing: 0pt, first-line-indent: (amount: para-indent, all: true), justify: false)
  set enum(numbering: "a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  show enum: set par(first-line-indent: 0pt)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Heading counters step on every heading (labels are drawn by the show rules below).
  set heading(numbering: "1.")
  show heading.where(level: 2): it => block(width: 100%, above: pitch * 0.5, below: 0pt, sticky: true,
    align(center, strong(it.body)))
  show heading.where(level: 3): it => context {
    let n = counter(heading).at(it.location())
    block(width: 100%, above: pitch * 0.5, below: 0pt, sticky: true,
      par(hanging-indent: 0.5in, first-line-indent: 0pt, leading: body-leading,
        [#box(width: 0.5in, numbering("A.", n.at(2)))#strong(it.body)]))
  }
  show heading.where(level: 4): it => context {
    let n = counter(heading).at(it.location())
    block(width: 100%, above: pitch * 0.5, below: 0pt, sticky: true,
      par(hanging-indent: 1in, first-line-indent: 0pt, leading: body-leading,
        [#h(0.5in)#box(width: 0.5in, numbering("1.", n.at(3)))#strong(it.body)]))
  }

  // Block quotations: single-spaced, indented both sides.
  show quote.where(block: true): it => block(width: 100%, above: pitch * 0.5, below: pitch * 0.5,
    pad(left: 0.5in, right: 0.5in, {
      set par(leading: single-leading, spacing: 0.9em, first-line-indent: 0pt, justify: false)
      it.body
    }))

  // Authorities are cited inline; the filer's footnotes are numbered by typst.
  if "notice" in meta and meta.notice != none {
    notice-part(meta)
    pagebreak()
  }
  motion-part(meta, md)
}
