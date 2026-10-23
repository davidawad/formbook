// Trademark Trial and Appeal Board: notice of appearance of counsel, with or without a power of attorney and a
// change of correspondence address (37 CFR 2.17, 2.18, 2.19; TBMP 114.03, 117).
//
// Rule-driven and content-agnostic. Requirement IDs (TTAB-...) refer to ../rules.md, section
// "Doc type: notice-of-appearance". No case-specific text: the caption, the appearance, attorney, power-of-attorney
// and correspondence paragraphs, the signature blocks and the certificate of service are built from the YAML
// frontmatter (schema: ../README.md); the markdown body adds any further paragraphs.
//
// The generated paragraphs are markdown strings (`generated-paras`) set exactly like the body, so
// docx/ttab-notice-of-appearance.lua builds the identical string and the two engines break every line alike.
//
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other. The docx filter and docx/reference.xml set the same pitches and spaces
// (twips = 20 x pt).

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

// The rule names no face (TTAB-FORM-006). Times New Roman, or the vendored Liberation Serif with the same metrics.
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 12pt                     // TTAB-FORM-001: at least 11-point (the template uses 12)
#let pitch-double = 27.6pt                // TTAB-FORM-002: double-spaced; Word's "double" for Times New Roman at 12 pt
#let pitch-single = 13.8pt                // caption, correspondence block, signature blocks, certificate
#let page-margin = 1in                    // TTAB-FORM-005 (convention; the Board states no margin)
#let para-indent = 0.5in
#let block-indent = 1in                   // the correspondence block (TTAB-NOA-006), set off from the text
#let sig-indent = 3.25in                  // the signature block starts at the middle of the text width
#let caption-col = 58%                    // caption: the parties left, the proceeding, application and mark right
#let caption-gutter = 8.4pt               // between the parties' text and the rule down the right of their cell
#let caption-num-pad = 13.2pt             // between that rule and the right-hand lines
#let role-indent = 0.5in                  // a party's role under its name
#let versus-indent = 0.25in               // "v." between the parties
#let letter-width = 8.5in
#let letter-height = 11in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ttab-notice-of-appearance: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ttab-notice-of-appearance: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A caption string without its trailing punctuation ("Applicant," -> "Applicant").
#let clean(s) = s.trim().trim(regex("[,.;:]+"), at: end).trim()
/// A party name without the caption's trailing comma ("HAPPI CO.," -> "HAPPI CO.").
#let clean-name(s) = s.trim().trim(regex("[,;:]+"), at: end).trim()

/// "A", "A and B", "A, B, and C".
#let join-names(xs) = if xs.len() <= 2 { xs.join(" and ") } else { xs.slice(0, -1).join(", ") + ", and " + xs.last() }

/// One single-spaced line (or paragraph) of a block, with explicit spaces above and below.
#let line-par(body, above: 0pt, below: 0pt, indent: 0pt) = block(above: above, below: below,
  pad(left: indent, par(first-line-indent: 0pt, body)))

/// A rule under a signature line.
#let sig-rule(indent) = block(above: 3pt, below: 4pt, pad(left: indent, line(length: 100%, stroke: 0.5pt)))

// ---------------------------------------------------------------------------
// The party counsel appears for, and the paper's title (TTAB-NOA-001, -002)
// ---------------------------------------------------------------------------

#let party-of(meta) = {
  let side = meta.at("appearing_for", default: "defendant")
  if side not in ("plaintiff", "defendant") {
    panic("ttab-notice-of-appearance: `appearing_for` must be plaintiff or defendant")
  }
  let p = need(meta, side)
  (label: clean(p.role), name: clean-name(p.name))
}

#let title-of(meta) = {
  if "title" in meta { return meta.title }
  let parts = ()
  if meta.at("power_of_attorney", default: false) == true { parts.push("POWER OF ATTORNEY") }
  parts.push("NOTICE OF APPEARANCE")
  if "correspondence" in meta { parts.push("CHANGE OF CORRESPONDENCE ADDRESS") }
  let joined = if parts.len() <= 2 { parts.join(" AND ") } else { parts.slice(0, -1).join(", ") + " AND " + parts.last() }
  upper(party-of(meta).label) + "’S " + joined
}

// ---------------------------------------------------------------------------
// Generated paragraphs (TTAB-NOA-003 to -006). the docx filter builds the same strings; keep the two in step.
// ---------------------------------------------------------------------------

#let generated-paras(meta) = {
  let party = party-of(meta)
  let counsel = need(meta, "counsel")
  let atts = need(counsel, "attorneys")
  if atts.len() == 0 { panic("ttab-notice-of-appearance: `counsel.attorneys` is empty") }
  let names = join-names(atts.map(a => a.name))
  let of-firm = if "firm" in counsel { " of " + counsel.firm } else { "" }
  let verb = if atts.len() == 1 { "appears" } else { "appear" }
  let paras = ()
  // TTAB-NOA-003: the appearance (37 CFR 2.17(b)(1)(iii); TBMP 114.03)
  paras.push("Please take notice that " + names + of-firm + " hereby " + verb + " as counsel for " + party.label +
    " " + party.name + " (“" + party.label + "”) in the above-captioned proceeding, pursuant to 37\u{a0}C.F.R. § 2.17(b)" +
    " and TBMP § 114.03.")
  // TTAB-NOA-004: each attorney is an attorney under 37 CFR 11.1, with the bar information of 37 CFR 2.17(b)(3)
  paras.push(atts.map(a => {
    let s = a.name + " is an attorney as defined in 37\u{a0}C.F.R. § 11.1"
    if "bar" in a {
      let b = a.bar
      s += ", an active member in good standing of the bar of the highest court of " + b.state
      let paren = ()
      if "admitted" in b { paren.push("admitted " + b.admitted) }
      if "number" in b { paren.push("Bar No. " + b.number) }
      if paren.len() > 0 { s += " (" + paren.join("; ") + ")" }
    }
    s + "."
  }).join(" "))
  // TTAB-NOA-005: the power of attorney (37 CFR 2.17(b)(1)(i), (c); 2.19(a)(4); TBMP 114.03)
  if meta.at("power_of_attorney", default: false) == true {
    let s = (party.label + " hereby appoints " + names + of-firm + " to represent " + party.label +
      " in this proceeding, with full power of substitution and revocation, and to transact all business in the" +
      " United States Patent and Trademark Office in connection therewith. 37\u{a0}C.F.R. § 2.17(b)(1)(i), (c);" +
      " TBMP § 114.03.")
    if meta.at("revoke_prior", default: false) == true {
      s += (" This power of attorney revokes any previous power of attorney given by " + party.label +
        " in this proceeding. 37\u{a0}C.F.R. § 2.19(a)(4).")
    }
    paras.push(s)
  }
  // TTAB-NOA-006: the change of correspondence address (37 CFR 2.18(a)(2), (c); 2.119(b); TBMP 117.01, 117.07)
  if "correspondence" in meta {
    paras.push(party.label + " requests that all correspondence from the Board in this proceeding be directed to," +
      " and all service on " + party.label + " be made on, " + party.label + "’s counsel at the following address" +
      " (37\u{a0}C.F.R. §§ 2.18(a)(2), 2.119(b); TBMP §§ 117.01, 117.07):")
  }
  paras
}

// ---------------------------------------------------------------------------
// Caption (TTAB-COVER-001, -002, TTAB-NOA-001)
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let plaintiff = need(meta, "plaintiff")
  let defendant = need(meta, "defendant")
  let kind = meta.at("kind", default: "opposition")
  let number-label = if kind == "cancellation" { "Cancellation No." } else { "Opposition No." }
  set text(..edges(pitch-single))
  block(width: 100%, above: 0pt, below: 0pt, align(center, par(first-line-indent: 0pt,
    strong[IN THE UNITED STATES PATENT AND TRADEMARK OFFICE])))
  block(width: 100%, above: 0pt, below: 0pt, align(center, par(first-line-indent: 0pt,
    strong[BEFORE THE TRADEMARK TRIAL AND APPEAL BOARD])))
  block(above: 13.8pt, below: 0pt, grid(
    columns: (caption-col, 100% - caption-col),
    column-gutter: 0pt,
    // left cell: the parties; a rule down its right edge and along its foot
    block(
      stroke: (right: 0.75pt, bottom: 0.75pt),
      inset: (top: 7.2pt, right: caption-gutter, bottom: 10.8pt),
      width: 100%,
      {
        line-par(inl(plaintiff.name))
        line-par(inl(plaintiff.role), indent: role-indent)
        line-par(emph[v.], above: 13.8pt, indent: versus-indent)
        line-par(inl(defendant.name), above: 13.8pt)
        line-par(inl(defendant.role), indent: role-indent)
      },
    ),
    // right cell: the proceeding number, then the application (or registration) and mark lines
    block(above: 0pt, below: 0pt, inset: (top: 7.2pt), {
      line-par([#number-label #need(meta, "proceeding_number")], indent: caption-num-pad)
      for (i, l) in meta.at("matter", default: ()).enumerate() {
        line-par(inl(l), above: if i == 0 { 13.8pt } else { 0pt }, indent: caption-num-pad)
      }
    }),
  ))
  block(width: 100%, above: 16.8pt, below: 10.8pt, align(center, par(first-line-indent: 0pt,
    text(weight: "bold", inl(title-of(meta))))))
}

// ---------------------------------------------------------------------------
// Correspondence block (TTAB-NOA-006)
// ---------------------------------------------------------------------------

#let correspondence-lines(c) = {
  let out = (c.name,)
  if "firm" in c { out.push(c.firm) }
  out += c.at("lines", default: ())
  if "phone" in c { out.push("Telephone: " + c.phone) }
  let emails = c.at("emails", default: ())
  if emails.len() > 0 { out.push("Email: " + emails.join("; ")) }
  out
}

#let correspondence-block(meta) = {
  set text(..edges(pitch-single))
  let ls = correspondence-lines(meta.correspondence)
  block(breakable: false, width: 100%, above: 6pt, below: 0pt,
    for l in ls { line-par(inl(l), indent: block-indent) })
}

// ---------------------------------------------------------------------------
// Signature blocks (TTAB-CERT-001 to -003, TTAB-NOA-007; 37 CFR 2.17(c)(2), 2.119(e), 2.193(c), (d))
// ---------------------------------------------------------------------------

#let sig-group(heading, s) = {
  line-par(strong(inl(heading)), above: 13.8pt, indent: sig-indent)
  line-par(inl("By: " + s.esign), above: 13.2pt, indent: sig-indent)
  sig-rule(sig-indent)
  line-par(inl(s.name), indent: sig-indent)
  line-par(inl(s.title), indent: sig-indent)
  for l in s.at("lines", default: ()) { line-par(inl(l), indent: sig-indent) }
}

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let poa = meta.at("power_of_attorney", default: false) == true
  if poa and "party_signature" not in meta {
    panic("ttab-notice-of-appearance: a power of attorney must be signed by the party (37 CFR 2.17(c)(2)); add `party_signature`")
  }
  set text(..edges(pitch-single))
  block(breakable: false, width: 100%, above: 19.2pt, below: 0pt, {
    line-par(inl("Dated: " + sig.date))
    line-par(inl("Respectfully submitted,"), above: 6pt, indent: sig-indent)
    if "party_signature" in meta {
      let ps = meta.party_signature
      sig-group(ps.party, ps)
    }
    sig-group(sig.firm, sig)
  })
}

// ---------------------------------------------------------------------------
// Certificate of service (TTAB-CERT-004, -005, TTAB-NOA-008; 37 CFR 2.119(a), (b); TBMP 113.03)
// ---------------------------------------------------------------------------

#let certificate-of-service(meta) = {
  let sv = need(meta, "service")
  set text(..edges(pitch-single))
  block(width: 100%, above: 0pt, below: 0pt, align(center, par(first-line-indent: 0pt,
    text(weight: "bold", underline[CERTIFICATE OF SERVICE]))))
  let by = if sv.at("method", default: "email") == "email" { "by email" } else { sv.method }
  block(above: 14.4pt, below: 10pt, par(first-line-indent: para-indent, {
    [I hereby certify that on ]
    inl(sv.date)
    [, a true and complete copy of the foregoing ]
    inl(sv.at("paper", default: title-of(meta)))
    [ was served #by on:]
  }))
  for r in sv.recipients {
    block(breakable: false, above: 0pt, below: 12pt, {
      line-par(inl(r.name + ", " + r.role), indent: para-indent)
      for l in r.at("lines", default: ()) { line-par(inl(l), indent: para-indent) }
      line-par(inl(r.email), indent: para-indent)
    })
  }
  block(breakable: false, width: 100%, above: 18pt, below: 0pt, {
    line-par(inl(sv.esign), indent: sig-indent)
    sig-rule(sig-indent)
    line-par(inl(sv.name), indent: sig-indent)
    line-par(inl(sv.title), indent: sig-indent)
  })
}

// ---------------------------------------------------------------------------
// The paper
// ---------------------------------------------------------------------------

#let ttab-notice-of-appearance(meta, body) = {
  set document(title: title-of(meta))
  set page(
    width: letter-width,
    height: letter-height,
    margin: page-margin,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: sys.inputs.at("font", default: font-family), size: type-size, lang: "en", region: "US",
           fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)

  // Drafting markers: a paragraph that is entirely bold text beginning with "[" is a drafting note
  // (TTAB-TOOL-002, as in the answer). It is set flush left, single-spaced, in italics.
  let plain(c) = {
    if type(c) == str { c }
    else if c == [] { "" }
    else if c.has("text") { c.text }
    else if c.has("children") { c.children.map(plain).join() }
    else if c.has("body") { plain(c.body) }
    else { "" }
  }
  show strong: it => if plain(it.body).starts-with("[") {
    block(width: 100%, above: 10.8pt, below: 10.8pt, breakable: false, sticky: true, {
      set text(..edges(pitch-single))
      par(first-line-indent: 0pt, text(style: "italic", weight: "regular", it.body))
    })
  } else { it }

  let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
  let generate = meta.at("generate", default: true) != false

  caption(meta)
  if generate {
    let paras = generated-paras(meta)
    if "correspondence" in meta {
      // the request paragraph never ends a page without the block it introduces (TTAB-NOA-006)
      render(paras.slice(0, -1).join("\n\n"))
      block(breakable: false, width: 100%, above: 0pt, below: 13.8pt, {
        render(paras.last())
        correspondence-block(meta)
      })
    } else {
      render(paras.join("\n\n"))
    }
    if body.trim() != "" { render(body) }
  } else {
    render(body)
    if "correspondence" in meta { correspondence-block(meta) }
  }
  signature-block(meta)
  if "service" in meta {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
}
