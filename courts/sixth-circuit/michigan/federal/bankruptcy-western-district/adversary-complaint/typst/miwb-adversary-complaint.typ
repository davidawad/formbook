// U.S. Bankruptcy Court, Western District of Michigan: adversary complaint (Fed. R. Bankr. P. 7001, 7008,
// 7010; LBR 7008, 9004). Rule IDs (MIWB-...) refer to ../README.md, which quotes the rules and their
// source, fetched 2026-10-14. Content-agnostic: every case-specific word comes from the sample's
// frontmatter, never from this file. The body is markdown rendered by cmarker.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // MIWB-FORM-001: the rules name no face (LBR 9004(f): "typewritten in at least 12-point type"); EB Garamond kept (docs/FONTS.md, "No face named")
#let type-size = 13pt                   // MIWB-FORM-001: at least 12-point type (LBR 9004(f)); 13 pt matches the exemplar's visual size
#let pitch = 27.6pt                     // MIWB-FORM-001: double-spaced; the filed exemplars measure 27.6 pt baseline to baseline
#let body-leading = 1.477em              // gap between lines of body text; with EB Garamond's 0.646em line box this gives the 27.6 pt baseline pitch (measured, README.md)
#let single-leading = 0.45em            // caption, counsel, signature, footers: single-spaced (about 14 pt pitch)
#let page-margin = 1in                  // MIWB-FORM-011: letter paper; margins are a layout choice (the exemplars use 1 in)
#let para-indent = 0.5in                // first-line indent of numbered paragraphs (exemplars: 0.5 in)
#let caption-left = 3.5in               // width of the left (party) column of the caption
#let footer-size = 11pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("miwb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A required frontmatter field: a missing one stops the build (no silent blank in a filing).
#let need(meta, key) = {
  if key not in meta { panic("miwb-adversary-complaint: missing required frontmatter field `" + key + "`") }
  meta.at(key)
}

/// Inline markdown (names with *et al.*, italic case names) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Underscored rule ending a party block, as on the filed exemplars: "_______/".
#let slash-rule(width) = block(width: width, stack(dir: ltr, box(width: 1fr, repeat("_")), "/"))

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 7010 and Form 416A; Fed. R. Civ. P. 10(a); LBR 9004(a), (b))
// ---------------------------------------------------------------------------

/// The court's title, as the court prints it on its own papers (MIWB-FORM-002).
#let court-title() = {
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  align(center, text(weight: "bold", [UNITED STATES BANKRUPTCY COURT #linebreak() FOR THE WESTERN DISTRICT OF MICHIGAN]))
}

#let caption(meta) = {
  let debtor = need(meta, "debtor")
  let plaintiff = need(meta, "plaintiff")
  let defendants = need(meta, "defendants")
  let case = need(meta, "case")
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  // Each column is a stack of single lines, so every line gets the same single spacing.
  let names(list) = stack(dir: ttb, spacing: single-leading, ..list.map(n => inl(n)))
  let gap = block(height: pitch * 0.5)
  let rule = slash-rule(caption-left - 0.1in)
  let case-lines = ([Case No. #inl(case.number)], [Chapter #inl(case.chapter)])
  if "judge" in case and case.judge != none { case-lines.push(inl(case.judge)) }
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.25in,
    row-gutter: 0.6em,
    // Row 1: the debtor, in re; the case number, and the chapter directly below it (LBR 9004(a)).
    stack(dir: ttb, spacing: single-leading,
      [In re:], gap, pad(left: 0.5in, names(debtor.names)), pad(left: 1.2in, inl(debtor.designation)), rule),
    stack(dir: ttb, spacing: single-leading, ..case-lines),
    // Row 2: the adversary parties; the adversary proceeding number on the right.
    stack(dir: ttb, spacing: single-leading,
      names(plaintiff.names), pad(left: 1.2in, inl(plaintiff.designation)), block(height: 0.4em), [v.],
      block(height: 0.4em), names(defendants.names), pad(left: 1.2in, inl(defendants.designation)), rule),
    [Adv. Proc. No. #inl(need(meta, "adversary_number"))],
  )
}

// ---------------------------------------------------------------------------
// Numbered paragraphs (Fed. R. Civ. P. 10(b), applied by Fed. R. Bankr. P. 7010)
// ---------------------------------------------------------------------------

/// One numbered paragraph. The number sits at the half-inch indent; following lines return to the margin,
/// as on the filed exemplars.
#let numbered(t, para-counter) = {
  para-counter.step()
  block(width: 100%, above: 0pt, below: body-leading, breakable: true, {
    set par(leading: body-leading, first-line-indent: 0pt, justify: false)
    h(para-indent)
    // The text starts at the one-inch stop whatever the width of the number (the exemplars' tab stop).
    context {
      let label = [#(para-counter.display()).]
      h(para-indent)
      label
      h(para-indent - measure(label).width)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    }
  })
}

/// A paragraph that is not numbered: a WHEREFORE clause (the prayer), as on the filed exemplars.
#let unnumbered(t) = block(width: 100%, above: 0pt, below: body-leading, breakable: true, {
  set par(leading: body-leading, first-line-indent: 0pt, justify: false)
  h(para-indent)
  cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
})

/// Generated statements (MIWB-FORM-005 and MIWB-FORM-007): numbered in place, right after the first
/// paragraph under the Jurisdiction heading. Their wording comes from the frontmatter.
#let generated-statements(meta) = {
  let case = need(meta, "case")
  let debtor = need(meta, "debtor")
  let dates = need(meta, "dates")
  let scope = "the United States Bankruptcy Court for the Western District of Michigan"
  if "division" in meta and meta.division != none {
    scope = "the " + meta.division + " of " + scope
  }
  // MIWB-FORM-005: the petition date and any conversion, dismissal or reinstatement (LBR 9004(c)).
  let petition = "The petition commencing the underlying Chapter " + case.chapter + " case was filed on " + dates.petition + ". " + dates.later
  // MIWB-FORM-007: the case this proceeding relates to, its name, number, chapter, district and division
  // (Fed. R. Bankr. P. 7008(a)).
  let relation = "This Adversary Proceeding arises in and relates to *In re " + debtor.name + "*, Case No. " + case.number + " (Chapter " + case.chapter + "), pending in " + scope + "."
  // MIWB-FORM-007: core or non-core, and consent to final judgment (LBR 7008).
  let core = if need(meta, "core") {
    "This Adversary Proceeding is a core proceeding under 28 U.S.C. § 157(b)(2). "
  } else {
    "This Adversary Proceeding is a non-core proceeding under 28 U.S.C. § 157(c). "
  }
  let consent = if need(meta, "consent") {
    "The Plaintiff consents to the entry of a final order or judgment by the Bankruptcy Court."
  } else {
    "The Plaintiff does not consent to the entry of a final order or judgment by the Bankruptcy Court."
  }
  (petition, relation, core + consent)
}

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph. A heading stays in one block with the chunk after it. The statements
/// that the rules require after the jurisdictional paragraph are inserted there.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(meta, body, para-counter) = {
  // Footnote definitions ("[^key]: text") are collected here and inlined into each chunk that refers to them:
  // cmarker renders one chunk at a time, so a reference and its definition must be in the same string.
  let notes = (:)
  for line in body.split("\n") {
    if line.starts-with("[^") and line.contains("]:") {
      let key = line.slice(2, line.position("]:"))
      notes.insert(key, line.slice(line.position("]:") + 2).trim())
    }
  }
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "" and not c.trim().starts-with("[^"))
  let pending = []
  let has-pending = false
  let after-jurisdiction = false
  let generated-done = false
  let prayer = false
  for c in chunks {
    let t = c.trim()
    for (key, note) in notes.pairs() {
      if t.contains("[^" + key + "]") { t += "\n\n[^" + key + "]: " + note }
    }
    if t.starts-with("#") {
      prayer = false
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
      // The Jurisdiction heading opens the section where the generated statements go.
      after-jurisdiction = lower(t.replace(regex("^#+\\s*"), "")).starts-with("jurisdiction") and not generated-done
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages. Items are numbered by the template as A., B., ...
      let items = {
        // Sub-lists are lettered a., b., ...; the prayer after a WHEREFORE is lettered A., B., ... (as the exemplars do).
        set enum(numbering: if prayer { "A." } else { "a." }, indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      if has-pending {
        block(breakable: false, width: 100%, below: body-leading, { pending; items })
      } else {
        items
      }
      pending = []
      has-pending = false
    } else {
      // A block quotation is not numbered; a WHEREFORE clause is not numbered either (the prayer).
      let piece = if t.starts-with(">") {
        block(width: 100%, below: body-leading, pad(left: 0.5in, {
          set par(leading: body-leading, first-line-indent: 0pt, justify: false)
          cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        }))
      } else if t.starts-with("WHEREFORE") {
        prayer = true
        unnumbered(t)
      } else {
        numbered(t, para-counter)
      }
      if has-pending {
        block(breakable: false, width: 100%, below: body-leading, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
      if after-jurisdiction {
        for g in generated-statements(meta) { numbered(g, para-counter) }
        after-jurisdiction = false
        generated-done = true
      }
    }
  }
  if pending != [] { block(breakable: false, width: 100%, pending) }
}

// ---------------------------------------------------------------------------
// Signature block (LBR 9004(d): telephone, office address, email and bar number directly below the signature)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: pitch, {
    set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    grid(
      columns: (2.9in, 1fr),
      column-gutter: 0.2in,
      [Dated: #need(meta, "date")],
      {
        [Respectfully submitted,]
        v(pitch * 0.5)
        line-stack(sig.firm)
        v(pitch * 0.5)
        line-stack(("By: /s/ " + sig.signer, sig.signer + " (" + sig.bar_id + ")", sig.role))
        v(pitch * 0.5)
        line-stack(("BUSINESS ADDRESS:",) + sig.address + ("Telephone " + sig.phone, "Email " + sig.email))
      },
    )
  })
}

// ---------------------------------------------------------------------------
// The pleading
// ---------------------------------------------------------------------------

#let miwb-adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    footer: context align(center, text(size: footer-size, [Page #counter(page).display() of #counter(page).final().first()])),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  // Headings: level 1 and 2 are centered bold capitals; level 3 is bold, left-aligned.
  show heading.where(level: 1): it => block(width: 100%, above: 0pt, below: body-leading, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: 0pt, below: body-leading, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 3): it => block(width: 100%, above: 0pt, below: body-leading, sticky: true,
    text(size: type-size, weight: "bold", it.body))
  set enum(numbering: "a.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  court-title()
  v(pitch)
  caption(meta)
  v(pitch)
  // LBR 9004(b): the description of the document, centered, immediately before the body.
  align(center, text(weight: "bold", upper(need(meta, "title"))))
  v(pitch * 0.5)
  allegations(meta, body, para-counter)
  signature-block(meta)
}
