// Oregon Supreme Court (or): amicus-brief in the form of a brief (ORAP 5.05(3); ORAP 9.17 briefs on the merits; ORAP 8.15 amicus).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Oregon Rules of Appellate Procedure, ORAP 2019 compilation effective 2019-04-15, see ../rules.md rows
// OR-FORM-001 to -014, OR-LEN-006). No case-specific text, no coordinates measured off any filed brief,
// no forced line breaks. The markdown body is rendered by cmarker; the metadata is the YAML frontmatter.
//
// Layout: cover (and the page behind it carrying the counsel, when the filer puts them there), table of
// contents, optional indexes, table of authorities (lowercase roman page numbers), then the body (arabic
// page numbers from 1), signature block, certificate of compliance and certificate of filing and service.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // OR-FORM-003 (ORAP 5.05(3)(b)(ii)): proportionally spaced Times New Roman; Liberation Serif is the metric twin (docs/FONTS.md).
#let type-size = 14pt                      // OR-FORM-003: not smaller than 14 point, text and footnotes.
#let body-leading = 1.65em                 // OR-FORM-006 (ORAP 5.05(3)(b)(iv)): double-spaced; about 2 x the 1.15 em single line of this face at 14 pt.
#let single-leading = 0.45em               // OR-FORM-006 excludes quotations, headings and tables: single-spaced.
#let margin-top = 0.75in                   // OR-FORM-002 (ORAP 5.05(3)(a)(ii)): top 3/4 inch.
#let margin-bottom = 0.75in                // OR-FORM-002: bottom 3/4 inch.
#let margin-inside = 1.25in                // OR-FORM-002: inside 1 1/4 inch; single-sided print puts the inside on the left edge.
#let margin-outside = 1in                  // OR-FORM-002: outside 1 inch (the right edge).
#let page-number-ascent = 0.375in          // OR-FORM-007 (ORAP 5.05(3)(c)): page numbers at the top, within 3/8 inch of the top edge.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature block starts right of centre (style; the exemplars do the same).
#let cover-title-size = 14pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// The body page number, at the top (OR-FORM-007), set in the text face (14 pt Liberation Serif, the metric twin of
/// Times New Roman) but drawn from its glyph outlines in a vector image, not as a text run. The content gate
/// (tools/check/gate0.awk) drops page numbers only from the bottom margin, so a top-of-page number set as text would be
/// read into every paragraph that continues across a page. Outlines are in 1000 units to the em, y down.
#let folio-glyphs = (
  "0": (500, "M461.9 -330.1Q461.9 9.8 247.1 9.8Q143.6 9.8 90.8 -77.1Q38.1 -164.1 38.1 -330.1Q38.1 -492.7 90.8 -578.9Q143.6 -665 251 -665Q354.5 -665 408.2 -579.8Q461.9 -494.6 461.9 -330.1ZM372.1 -330.1Q372.1 -487.3 342.3 -556.6Q312.5 -626 247.1 -626Q183.6 -626 155.8 -560.5Q127.9 -495.1 127.9 -330.1Q127.9 -164.1 156.2 -96.4Q184.6 -28.8 247.1 -28.8Q311.5 -28.8 341.8 -99.9Q372.1 -170.9 372.1 -330.1Z"),
  "1": (500, "M306.2 -39.1 439.9 -25.9V0H87.9V-25.9L222.2 -39.1V-573.2L89.8 -525.9V-551.8L280.8 -660.2H306.2Z"),
  "2": (500, "M444.8 0H43.9V-71.8L134.8 -154.3Q222.2 -231 263.2 -278.3Q304.2 -325.7 322 -376Q339.8 -426.3 339.8 -491.2Q339.8 -554.7 311 -587.9Q282.2 -621.1 216.8 -621.1Q190.9 -621.1 163.6 -614Q136.2 -606.9 115.2 -595.2L98.1 -515.1H65.9V-641.1Q154.8 -662.1 216.8 -662.1Q324.2 -662.1 378.2 -617.4Q432.1 -572.8 432.1 -491.2Q432.1 -436.5 410.9 -387.9Q389.6 -339.4 345.7 -291.3Q301.8 -243.2 200.2 -156.7Q156.7 -119.6 107.9 -75.2H444.8Z"),
  "3": (500, "M460.9 -178.2Q460.9 -89.8 400.4 -40Q339.8 9.8 229 9.8Q136.2 9.8 53.2 -11.2L47.9 -148.9H80.1L102.1 -57.1Q121.1 -46.4 156 -38.6Q190.9 -30.8 221.2 -30.8Q297.9 -30.8 334.5 -65.9Q371.1 -101.1 371.1 -183.1Q371.1 -247.6 337.4 -281Q303.7 -314.5 232.9 -317.9L163.1 -321.8V-361.8L232.9 -366.2Q288.1 -369.1 314.5 -400.4Q340.8 -431.6 340.8 -495.1Q340.8 -561 312.3 -591.1Q283.7 -621.1 221.2 -621.1Q195.3 -621.1 167 -614Q138.7 -606.9 117.2 -595.2L100.1 -515.1H67.9V-641.1Q116.2 -653.8 151.4 -658Q186.5 -662.1 221.2 -662.1Q431.2 -662.1 431.2 -501Q431.2 -433.1 393.8 -392.8Q356.4 -352.5 288.1 -342.8Q377 -332.5 418.9 -291.7Q460.9 -251 460.9 -178.2Z"),
  "4": (500, "M395.5 -144V0H311.5V-144H19.5V-209L339.4 -658.2H395.5V-213.9H484.4V-144ZM311.5 -543.5H309.1L74.7 -213.9H311.5Z"),
  "5": (500, "M236.8 -382.8Q350.1 -382.8 405.5 -336.4Q460.9 -290 460.9 -194.8Q460.9 -96.2 400.9 -43.2Q340.8 9.8 229 9.8Q136.2 9.8 63.5 -11.2L58.1 -148.9H90.3L112.3 -57.1Q133.8 -45.4 163.8 -38.1Q193.8 -30.8 221.2 -30.8Q298.3 -30.8 334.7 -67.1Q371.1 -103.5 371.1 -189.9Q371.1 -250.5 355.5 -281.5Q339.8 -312.5 305.7 -327.1Q271.5 -341.8 213.9 -341.8Q169.4 -341.8 127 -330.1H80.1V-654.8H412.1V-580.1H124V-371.1Q176.8 -382.8 236.8 -382.8Z"),
  "6": (500, "M470.2 -203.1Q470.2 -101.1 418.7 -45.7Q367.2 9.8 270 9.8Q159.7 9.8 101.3 -76.2Q43 -162.1 43 -323.2Q43 -428.7 73.7 -505.4Q104.5 -582 159.9 -622.1Q215.3 -662.1 288.1 -662.1Q359.4 -662.1 430.2 -645V-532.2H397.9L380.9 -599.1Q364.7 -607.9 337.4 -614.5Q310.1 -621.1 288.1 -621.1Q216.8 -621.1 177 -552Q137.2 -482.9 133.3 -350.1Q212.9 -392.1 293 -392.1Q379.4 -392.1 424.8 -343.5Q470.2 -294.9 470.2 -203.1ZM268.1 -28.8Q327.1 -28.8 353.5 -67.1Q379.9 -105.5 379.9 -193.8Q379.9 -273.9 354.7 -309.6Q329.6 -345.2 274.9 -345.2Q208 -345.2 132.8 -320.8Q132.8 -171.9 166.5 -100.3Q200.2 -28.8 268.1 -28.8Z"),
  "7": (500, "M98.1 -500H65.9V-654.8H471.2V-617.2L179.2 0H116.2L402.8 -580.1H115.2Z"),
  "8": (500, "M441.9 -495.1Q441.9 -441.4 415.8 -404.1Q389.6 -366.7 345.2 -347.2Q400.9 -326.7 431.4 -283Q461.9 -239.3 461.9 -176.8Q461.9 -84 409.7 -37.1Q357.4 9.8 247.1 9.8Q38.1 9.8 38.1 -176.8Q38.1 -241.7 69.3 -284.4Q100.6 -327.1 153.8 -347.2Q111.3 -366.7 84.7 -403.8Q58.1 -440.9 58.1 -495.1Q58.1 -576.2 107.7 -620.6Q157.2 -665 251 -665Q341.8 -665 391.8 -620.8Q441.9 -576.7 441.9 -495.1ZM374 -176.8Q374 -254.9 343.5 -290Q313 -325.2 247.1 -325.2Q182.6 -325.2 154.3 -291.7Q126 -258.3 126 -176.8Q126 -94.2 154.8 -61.5Q183.6 -28.8 247.1 -28.8Q312 -28.8 343 -62.7Q374 -96.7 374 -176.8ZM354 -495.1Q354 -562.5 327.6 -594.2Q301.3 -626 248 -626Q196.3 -626 171.1 -595.2Q146 -564.5 146 -495.1Q146 -427.2 170.4 -397.7Q194.8 -368.2 248 -368.2Q302.7 -368.2 328.4 -398.2Q354 -428.2 354 -495.1Z"),
  "9": (500, "M32.2 -455.1Q32.2 -553.7 87.4 -607.9Q142.6 -662.1 243.2 -662.1Q355 -662.1 407 -581.5Q459 -501 459 -329.1Q459 -164.6 392.1 -77.4Q325.2 9.8 204.1 9.8Q124.5 9.8 58.1 -6.8V-120.1H89.8L106.9 -49.8Q122.6 -42.5 148.9 -36.6Q175.3 -30.8 202.1 -30.8Q280.3 -30.8 322.3 -99.4Q364.3 -168 368.7 -301.3Q294.4 -259.8 217.8 -259.8Q131.3 -259.8 81.8 -311.3Q32.2 -362.8 32.2 -455.1ZM244.1 -623Q122.1 -623 122.1 -453.1Q122.1 -378.4 151.4 -342.8Q180.7 -307.1 242.2 -307.1Q305.2 -307.1 369.1 -333Q369.1 -482.9 339.6 -553Q310.1 -623 244.1 -623Z"),
  "i": (278, "M185.1 -608.9Q185.1 -587.4 169.4 -571.8Q153.8 -556.2 131.8 -556.2Q110.4 -556.2 94.7 -571.8Q79.1 -587.4 79.1 -608.9Q79.1 -630.9 94.7 -646.5Q110.4 -662.1 131.8 -662.1Q153.8 -662.1 169.4 -646.5Q185.1 -630.9 185.1 -608.9ZM180.2 -34.2 258.8 -22V0H21V-22L99.1 -34.2V-424.8L34.2 -437V-459H180.2Z"),
  "v": (500, "M272 9.8H235.8L46.9 -424.8L0 -437V-459H213.9V-437L141.1 -423.8L274.9 -106.9L402.8 -424.8L330.1 -437V-459H500V-437L456.1 -426.8Z"),
  "x": (500, "M487.8 -22V0H279.8V-22L340.8 -33.2L234.9 -195.8L110.8 -32.2L173.8 -22V0H8.8V-22L62 -29.8L212.9 -229L80.1 -424.8L25.9 -437V-459H233.9V-437L172.9 -423.8L261.2 -292L362.8 -424.8L299.8 -437V-459H464.8V-437L412.1 -426.8L283.2 -259.8L434.1 -32.2Z"),
  "l": (278, "M179.2 -34.2 257.8 -22V0H20V-22L98.1 -34.2V-660.2L20 -671.9V-693.8H179.2Z"),
  "c": (444, "M413.1 -27.8Q389.2 -10.3 347.2 -0.2Q305.2 9.8 261.2 9.8Q38.1 9.8 38.1 -232.9Q38.1 -347.7 95 -409.4Q151.9 -471.2 257.8 -471.2Q323.7 -471.2 401.9 -456.1V-328.1H375L354 -409.2Q313.5 -432.1 256.8 -432.1Q126 -432.1 126 -232.9Q126 -129.4 165.8 -85.2Q205.6 -41 289.1 -41Q360.4 -41 413.1 -57.1Z"),
)

#let folio(n, anchor) = {
  let w = 60
  let size = 14
  let chars = n.clusters()
  let total = chars.map(c => folio-glyphs.at(c).first()).sum(default: 0) * size / 1000
  let x0 = if anchor == "end" { w - total } else { (w - total) / 2 }
  let paths = ()
  let x = x0
  for c in chars {
    let (adv, d) = folio-glyphs.at(c)
    paths.push("<path transform='translate(" + str(x) + " 12) scale(" + str(size / 1000) + ")' d='" + d + "'/>")
    x += adv * size / 1000
  }
  let svg = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 " + str(w) + " 16' width='" + str(w) + "' height='16'>" + paths.join() + "</svg>"
  align(if anchor == "end" { right } else { center }, image(bytes(svg), format: "svg", width: w * 1pt, height: 16pt))
}

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let as-array(x) = if type(x) == array { x } else { (x,) }

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("or-amicus-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("or-amicus-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

#let lines-of(xs) = as-array(xs).map(inl).join(linebreak())

/// One caption side: names, then designation lines (indented), as the filer sets them.
#let caption-side(side, centred) = {
  set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
  let names = as-array(need(side, "names")).map(inl).join(linebreak())
  let desig = as-array(need(side, "designation")).map(inl).join(linebreak())
  if centred {
    align(center)[#names \ #desig]
  } else {
    [#names]
    pad(left: 0.5in)[#desig]
  }
}

#let counsel-group(g, role-style) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  stack(dir: ttb, spacing: single-leading,
    block(width: 100%, lines-of(g.lines)),
    if "role" in g { block(width: 100%, inset: (left: if role-style == "italic" { 0pt } else { 0.5in }), if role-style == "italic" { emph(inl(g.role)) } else { inl(g.role) }) },
  )
}

#let counsel-list(groups, role-style) = for g in groups {
  block(breakable: false, below: 1.1em, counsel-group(g, role-style))
}

/// Signature block: the sign mark and the typed name, then the lines beneath (bar number, role, address).
#let signature-block(sig, first-only: false, with-closing: true) = {
  let all = if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: sig.at("lines", default: ())),) }
  let list = if first-only { (all.first(),) } else { all }
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if with-closing and "closing" in sig [ #inl(sig.closing) #v(0.8em) ]
    #if "firm" in sig [ #sig.firm #v(0.8em) ]
    #for (i, s) in list.enumerate() {
      if i > 0 { v(0.9em) }
      [#sig.at("mark", default: "s/") #s.name]
      for l in s.at("lines", default: ()) { linebreak() + inl(l) }
    }
  ])
}

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of the authority in
/// the body. A show rule on that string drops a marker after each occurrence; the table lists the pages of the
/// markers.
#let toa-marker(key) = [#metadata(key)<or-toa>]

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      if "find" in e {
        let key = e.find
        out = {
          show key: it => it + toa-marker(key)
          out
        }
      }
    }
  }
  out
}

#let toa-pages(key) = context {
  let pages = query(<or-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let leader-row(content, trailing) = block(above: 0.9em, below: 0.9em, breakable: false)[
  #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  #content #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #trailing
]

#let front-title(t) = align(center, block(below: 1.2em)[
  #set par(leading: single-leading, first-line-indent: 0pt)
  #text(weight: "bold", t)
])

#let authorities-table(meta) = {
  front-title[TABLE OF AUTHORITIES]
  if meta.at("toa_page_label", default: false) { align(right)[Page(s)] }
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      leader-row(inl(e.cite), if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") })
    }
  }
}

#let indexes-block(meta) = for ix in meta.indexes {
  front-title(lines-of(as-array(ix.heading)))
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  for e in ix.entries {
    block(above: 0.9em, below: 0.9em, breakable: false)[
      #if "label" in e {
        grid(columns: (1.4in, 1fr), column-gutter: 0.2in, inl(e.label), inl(e.text))
      } else {
        [#inl(e.text) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #strong(e.at("pages", default: ""))]
      }
    ]
  }
  v(1em)
}

// ---------------------------------------------------------------------------
// Cover (OR-FORM-008, OR-FORM-010: ORAP 5.05(3)(d), 1.45(1))
// ---------------------------------------------------------------------------

#let cover-rule(meta) = align(center, line(length: meta.at("rule_width_pct", default: 100) * 1%, stroke: 0.6pt))

#let caption-centred(meta) = {
  for (i, side) in meta.caption.enumerate() {
    if i > 0 { align(center, block(above: 0.9em, below: 0.9em)[v.]) }
    caption-side(side, true)
  }
  if "lower_court" in meta {
    for g in meta.lower_court { align(center, block(above: 1em, below: 0pt, lines-of(g))) }
  }
}

#let caption-columns(meta) = {
  let paren = meta.at("parens", default: false)
  let left = {
    for (i, side) in meta.caption.enumerate() {
      if i > 0 { block(above: 0.9em, below: 0.9em, pad(left: 0.5in)[v.]) }
      caption-side(side, false)
    }
  }
  let right = {
    set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
    for g in meta.at("lower_court", default: ()) { block(below: 1em, lines-of(g)) }
  }
  layout(size => {
    let paren-w = if paren { 0.3in } else { 0pt }
    let left-w = size.width * 0.54
    if paren {
      let h = measure(width: left-w, left).height
      let stack-of(k) = { set par(leading: single-leading, spacing: 0pt); for _ in range(k) [) \ ] }
      let pitch = measure(stack-of(2)).height - measure(stack-of(1)).height
      let n = calc.ceil(h / pitch)
      grid(
        columns: (left-w, paren-w, 1fr),
        left,
        stack-of(n),
        right,
      )
    } else {
      grid(columns: (left-w, 1fr), column-gutter: 0.15in, left, right)
    }
  })
}

#let cover-page(meta) = page(header: none, margin: (top: margin-top, bottom: margin-bottom, left: margin-inside, right: margin-outside))[
  #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.6em)
  #if "case_number_above" in meta [ #align(center, inl(meta.case_number_above)) #v(0.3em) ]
  #align(center)[IN THE SUPREME COURT OF THE STATE OF OREGON]
  #v(0.25in)
  #if meta.at("caption_rule", default: false) { cover-rule(meta); v(0.12in) }
  #if meta.at("cover_style", default: "centred") == "centred" { caption-centred(meta) } else { caption-columns(meta) }
  #v(0.2in)
  #cover-rule(meta)
  #v(0.15in)
  #align(center, text(weight: "bold", size: cover-title-size, lines-of(need(meta, "brief_title"))))
  #v(0.15in)
  #cover-rule(meta)
  #v(0.2in)
  #if "review_lines" in meta {
    align(center, lines-of(meta.review_lines))
    if meta.at("review_rule", default: false) { v(0.15in); cover-rule(meta) }
  }
  #v(0.2in)
  #if "counsel_cover" in meta {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    set text(size: meta.at("counsel_size", default: 12pt))
    grid(columns: (1fr, 1fr), column-gutter: 0.3in, row-gutter: 0.8em,
      ..meta.counsel_cover.map(g => counsel-group(g, meta.at("role_style", default: "indent"))))
  }
  #v(1fr)
  #grid(columns: (1fr, auto),
    if "cover_note" in meta { emph(inl(meta.cover_note)) },
    inl(need(meta, "filed_month_year")))
  #v(0.1in)
]

#let back-page(meta, groups) = page(header: none, margin: (top: margin-top, bottom: margin-bottom, left: margin-inside, right: margin-outside))[
  #set text(size: meta.at("counsel_size", default: 12pt))
  #let role-style = meta.at("role_style", default: "indent")
  #if meta.at("counsel_back_columns", default: 1) == 2 {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    grid(columns: (1fr, 1fr), column-gutter: 0.3in, row-gutter: 1.1em, ..groups.map(g => counsel-group(g, role-style)))
  } else {
    counsel-list(groups, role-style)
  }
]

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let or-amicus-brief(meta, body) = {
  set document(title: lines-of(need(meta, "brief_title")))
  // Heading numbers: `number_sections: true` (default) numbers level 1 as I., II. and the levels below as A., 1., a.;
  // `false` leaves level 1 unnumbered (INTRODUCTION) and numbers level 2 as I., level 3 as A.; `"typed"` numbers
  // nothing: the filer types the numbers in the heading text.
  let number-sections = meta.at("number_sections", default: true)
  let typed = number-sections == "typed"

  // OR-FORM-001, -002, -007: US letter; margins as above; consecutive page numbers at the top.
  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-inside, right: margin-outside),
    header-ascent: page-number-ascent,
    header: context {
      let n = numbering(page.numbering, counter(page).get().first())
      // Body pages (arabic): the outline number, right; front matter (roman): text, centred (no paragraph runs across it).
      if page.numbering == "1" { folio(n, "end") } else { align(center, n) }
    },
    footer: none,
    numbering: "i",
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: if typed { none } else { (..nums) => {
    let n = nums.pos()
    let level = n.len()
    let kinds = ("I.", "A.", "1.", "a.", "(i)")
    let k = if number-sections == true { level - 1 } else { level - 2 }
    if k < 0 { [] } else { numbering(kinds.at(calc.min(k, kinds.len() - 1)), n.last()) }
  } })

  // Heading levels in the markdown body: level 1 is a section (centred, bold); deeper levels are bold, left,
  // with the number hanging.
  show heading: it => {
    let num = if it.numbering != none { counter(heading).display(it.numbering) } else { [] }
    if it.level == 1 {
      block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
        #set text(size: type-size)
        #set par(leading: single-leading, first-line-indent: 0pt)
        #align(center, text(weight: "bold", if number-sections == true and it.numbering != none { [#num #h(0.5em) #it.body] } else { it.body }))
      ]
    } else {
      block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
        #set text(size: type-size)
        #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
        #pad(left: (it.level - 2) * 0.5in, text(weight: "bold", style: if it.level >= 4 { "italic" } else { "normal" }, [#if it.numbering != none { box(width: 0.5in, num) }#it.body]))
      ]
    }
  }

  // Block quotations: indented, single-spaced, double space above and below (OR-FORM-006).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: body-leading, below: body-leading)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 14 pt like the text (OR-FORM-003), single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(bottom: 0.25em, mark-authorities(meta, it))  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover, and the page behind it when the counsel are listed there ----
  cover-page(meta)
  if "counsel_back" in meta { back-page(meta, meta.counsel_back) }

  // ---- Table of contents ----
  counter(page).update(1)
  page[
    #front-title[TABLE OF CONTENTS]
    #set par(leading: single-leading, first-line-indent: 0pt)
    #show outline.entry.where(level: 1): it => block(above: 1.1em, below: 0.9em, strong(it))
    #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
    #outline(title: none, depth: toc-depth, indent: auto)
  ]

  // ---- Indexes of the excerpt of record and appendices; table of authorities ----
  if "indexes" in meta { page(indexes-block(meta)) }
  if "authorities" in meta { page(authorities-table(meta)) }

  // ---- Body: arabic page numbers from 1 ----
  counter(page).update(1)
  page(numbering: "1", {
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Signature block (OR-FORM-009): name and signature of the author, firm, party ----
  v(0.3in)
  block(width: 100%, breakable: false)[#signature-block(need(meta, "signature"))]

  // ---- Certificate of compliance (OR-LEN-006, ORAP 5.05(1)(d)(i)): wording is filer-supplied ----
  if "compliance" in meta {
    let cc = meta.compliance
    pagebreak(weak: true)
    heading(level: 1, outlined: false, numbering: none)[#inl(cc.at("heading", default: "CERTIFICATE OF COMPLIANCE"))]
    for p in cc.at("paragraphs", default: ()) { par(inl(p)) }
    if "date" in cc { par(inl(cc.date)) }
    v(0.4em)
    signature-block(need(meta, "signature"), first-only: true, with-closing: false)
  }

  // ---- Certificate of filing and service (ORAP 16.45) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1, outlined: false, numbering: none)[#inl(svc.at("heading", default: "CERTIFICATE OF FILING AND SERVICE"))]
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #lines-of(r)
      ])
    }
    if "closing" in svc { par(inl(svc.closing)) }
    v(0.4em)
    signature-block(svc.at("signature", default: need(meta, "signature")), first-only: svc.at("first_signer_only", default: true), with-closing: false)
  }
  })
}
