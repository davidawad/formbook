// Motion with memorandum of law for the United States Bankruptcy Court, Eastern District of New York (nyeb).
// Rules (sources and dates in ../README.md):
//   Fed. R. Bankr. P. 9013 (a motion is in writing and states its grounds with particularity), 7012 (Fed. R.
//   Civ. P. 12 applies in an adversary proceeding), 9004(b) (caption: court's name, case title, case number and
//   adversary-proceeding number, designation of the paper);
//   E.D.N.Y. LBR 9004-1(a) (plainly typed, no erasures, 8 1/2 x 11 paper, signed under Rule 9011, not bound
//   on the side); E.D.N.Y. LBR 9004-2(a) (caption states the court, the title and chapter, the case number and
//   judge code, and for an adversary proceeding the full title and the adversary number);
//   E.D.N.Y. LBR 9013-1(a) (the rules and authorities relied on, in the motion or a separate memorandum of law).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"       // no font is named by FRBP 9004 or E.D.N.Y. LBR 9004-1; vendored in fonts/
#let type-size = 12pt                  // no size is named either; 12 pt is the working convention (README.md)
#let page-w = 8.5in                    // E.D.N.Y. LBR 9004-1(a)(ii): 8 1/2 x 11 inch paper
#let margin = 1in                      // layout choice: 1 inch margins on all sides
#let text-width = page-w - 2 * margin
#let pitch = 24pt                      // double spacing: EB Garamond's line box is 0.65em, so leading 1.35em gives 24 pt at 12 pt
#let body-leading = 1.35em
#let single-leading = 0.5em            // single spacing for counsel block, caption, quotations, signature block
#let para-indent = 0.5in               // first-line indent of body paragraphs
#let quote-indent = 1in                // quotations are indented on both sides
#let signature-indent = 3.25in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nyeb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics for case names, emphasis) for one piece of text.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// The body's blank-line-separated chunks, in order.
#let chunks(body) = body.replace("\r\n", "\n").split("\n\n").map(s => s.trim()).filter(s => s != "")

/// Single-spaced stack of lines. Items are markdown strings or content.
#let line-stack(items) = stack(
  dir: ttb,
  spacing: single-leading,
  ..items.map(i => if type(i) == str { inl(i) } else { i }),
)

// ---------------------------------------------------------------------------
// Cover: counsel block (top left), court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let counsel-block(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  line-stack(meta.counsel)
  v(pitch)
}

#let court-title() = {
  set par(leading: single-leading, spacing: 0pt)
  align(center, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT"))
  v(single-leading * 2)
  align(center, text(weight: "bold", "EASTERN DISTRICT OF NEW YORK"))
  v(pitch)
}

/// One side of the adversary caption: its names, then its designation set in from the left.
#let party-block(p) = line-stack(p.names + (pad(left: 1.2in, p.designation),))

#let caption(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  let debtor = meta.caption.debtor
  // The bankruptcy case: "In re" and the debtor, with the case number and chapter at the right.
  block(width: text-width, stroke: (top: 0.75pt, bottom: 0.75pt), inset: (y: 8pt), grid(
    columns: (3.8in, 1fr),
    column-gutter: 0.2in,
    line-stack(("In re:", ..debtor.names, pad(left: 1.2in, debtor.designation))),
    align(left + horizon, line-stack(("Case No. " + meta.case_number, "Chapter " + meta.chapter))),
  ))
  // The adversary parties, with "v." between them; the adversary number at the right.
  block(width: text-width, stroke: (bottom: 0.75pt), inset: (y: 8pt), grid(
    columns: (3.8in, 1fr),
    column-gutter: 0.2in,
    {
      for (k, p) in meta.caption.parties.enumerate() {
        if k > 0 {
          v(single-leading * 2)
          align(center, "v.")
          v(single-leading * 2)
        }
        party-block(p)
      }
    },
    align(left + horizon, line-stack(("Adv. Pro. No. " + meta.adversary_number,))),
  ))
  v(pitch)
  align(center, text(weight: "bold", inl(meta.title)))
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// The signature block: the place and date at the left, the firm's block single-spaced at the right.
#let signature(sig) = block(width: text-width, breakable: false, above: pitch, {
  set par(leading: single-leading, spacing: 0pt)
  grid(
    columns: (signature-indent, 1fr),
    line-stack(sig.dated),
    line-stack(sig.lines),
  )
})

/// A bullet item: a bullet at the paragraph indent, text at the text indent.
#let bullet-item(txt) = grid(
  columns: (0.75in, 1fr),
  pad(left: 0.5in, "•"),
  inl(txt),
)

#let render-body(cs) = {
  for c in cs {
    if c.starts-with("### ") {
      block(width: text-width, above: pitch, below: body-leading, sticky: true,
        text(weight: "bold", style: "italic", inl(c.slice(4))))
    } else if c.starts-with("## ") {
      block(width: text-width, above: pitch, below: body-leading, sticky: true,
        text(weight: "bold", inl(c.slice(3))))
    } else if c.starts-with("# ") {
      block(width: text-width, above: pitch, below: body-leading, sticky: true,
        align(center, text(weight: "bold", inl(c.slice(2)))))
    } else if c.starts-with("- ") {
      // A bulleted list: one item per line of the chunk.
      let items = c.split("\n").map(s => s.trim()).filter(s => s != "")
      for it in items {
        bullet-item(it.replace(regex("^- "), ""))
      }
    } else if c.starts-with("> ") {
      // A quotation: single-spaced, indented on both sides.
      pad(x: quote-indent, {
        set par(leading: single-leading)
        inl(c.split("\n").map(s => s.replace(regex("^> ?"), "")).join(" "))
      })
    } else {
      // A body paragraph: double-spaced, first line indented.
      block(width: text-width, h(para-indent) + inl(c))
    }
  }
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let nyeb-motion-brief(meta, body) = {
  set document(title: meta.title)
  set page(
    paper: "us-letter",
    margin: margin,
    footer: context {
      set text(size: type-size)
      grid(
        columns: (1fr, 1fr, 1fr),
        align(left, text(size: 10pt, if "matter_number" in meta { meta.matter_number } else { "" })),
        align(center, counter(page).display()),
        [],
      )
    },
  )
  set text(font: font-family, size: type-size, lang: "en")
  // leading is the gap between the lines of a paragraph; spacing is the gap between paragraphs. Both are
  // the double-spacing pitch, so the last line of a paragraph never sits on the first line of the next.
  set par(justify: false, leading: body-leading, spacing: body-leading, first-line-indent: 0pt)

  counsel-block(meta)
  court-title()
  caption(meta)
  let cs = chunks(body)
  // The last paragraph and the signature block stay together: a signature never stands alone on a page.
  if "signature" in meta and cs.len() > 0 {
    render-body(cs.slice(0, cs.len() - 1))
    block(width: text-width, breakable: false, {
      render-body(cs.slice(cs.len() - 1))
      signature(meta.signature)
    })
  } else {
    render-body(cs)
  }
}
