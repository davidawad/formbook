// Word 2013+ paragraph composition, shared by every template whose exemplars are Word output
// (fb-w0vj; calibration and residuals: docs/EVAL-LOOP.md, "Word compatibility").
//
// Apply it once in a court entry point, after the template's own `set text`/`set par` rules:
//
//   #import "/lib/typst/word-compat.typ": word-compat
//   show: word-compat.with(meta.at("word", default: (:)))
//
// It sets only composition (how a paragraph is cut into lines), never the template's type size,
// leading, margins or indents. What it always does, as Word does for ordinary prose:
//   - kerning off (Word's "Kerning for fonts" is off by default),
//   - hyphenation off (Word's automatic hyphenation is off by default),
//   - greedy line breaking (Word fills a line, then moves on; typst "simple"),
//   - no letter-spacing adjustment in justified lines (Word changes only the spaces),
//   - no hanging punctuation (typst lets line-final punctuation protrude into the margin; Word does not).
// Two choices belong to the filed document, not the court, so they come from the INPUT's frontmatter
// map `word:` (absent keys keep the template's own setting):
//   justify: true | false   body paragraphs justified (Word "Justify") or ragged right (Word "Left");
//   shrink:  ratio          the narrowest an inter-word space may be set in a justified line. Word
//                           2013+ documents compress spaces to about 76% of normal before moving the
//                           next word down (measured floor 0.757 to 0.763 on 12 calibration
//                           exemplars); documents in an older compatibility mode never compress
//                           (shrink: 100%). Default 100%.
#let word-compat(opts, body) = {
  let shrink = opts.at("shrink", default: 100%)
  if type(shrink) in (int, float) { shrink = shrink * 100% }
  set text(kerning: false, hyphenate: false, overhang: false)
  set par(
    linebreaks: "simple",
    justification-limits: (
      spacing: (min: 100%, max: 10000%),
      tracking: (min: 0em, max: 0em),
    ),
  )
  // typst's greedy breaker tests a line at its natural width and never counts on shrinking spaces,
  // so Word's compression is applied as a narrower natural space wherever text is justified (a show
  // rule on text, not on par: typst 0.15 lays out inline content of a block without a par element);
  // the justification then stretches every full line back to the measure.
  show text: it => context if par.justify and shrink < 100% {
    set text(spacing: shrink)
    it
  } else { it }
  if "justify" in opts {
    set par(justify: opts.justify)
    body
  } else {
    body
  }
}

// For blocks whose Word paragraph style has an exact line pitch: baseline-to-baseline `pitch` at type
// size `size`, independent of the glyphs on the line.
#let word-compat-pitch(size, pitch, body) = {
  set text(size: size, top-edge: "ascender", bottom-edge: "descender")
  set par(leading: pitch - size)
  body
}
