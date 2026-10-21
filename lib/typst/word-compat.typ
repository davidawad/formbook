// Shared approximations for Word 2013+ paragraph composition.
// Import this from a court entry point and wrap its body content with
// word-compat(...).  Court-specific type sizes, margins, and paragraph
// spacing remain parameters at the call site.
#let word-compat(
  body,
  font: "Times New Roman",
  size: 12pt,
  line-pitch: 24pt,
  justify: true,
) = {
  // Word's ordinary paragraph composer does not use TeX-style optical
  // kerning.  Simple line breaking keeps line selection greedy; disabling
  // hyphenation matches the default for ordinary legal prose.
  set text(font: font, size: size, kerning: false, hyphenate: false,
    top-edge: "ascender", bottom-edge: "descender")
  set par(justify: justify, linebreaks: "simple", leading: line-pitch - size)
  body
}

// Use for blocks whose Word paragraph style has exact line spacing.  The
// ascender/descender edges above make the pitch independent of glyph ink.
#let word-compat-pitch(size, pitch, body) = {
  set text(size: size, top-edge: "ascender", bottom-edge: "descender")
  set par(leading: pitch - size)
  body
}
