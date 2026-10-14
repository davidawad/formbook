// Font proof for fonts/liberation-sans/ (see README.md).
// Compile: typst compile --font-path fonts --ignore-system-fonts fonts/tests/liberation-sans.typ OUT.pdf
// Must produce zero warnings, and pdffonts must list only Liberation Sans faces.
#set page(paper: "us-letter", margin: 1in)
#set text(font: "Liberation Sans", size: 12pt, lang: "en")
#set par(justify: true)

#text(size: 14pt, weight: "bold")[Liberation Sans: font proof]

#v(0.5em)

Regular: The quick brown fox jumps over the lazy dog. 0123456789 § ¶ “quoted” — end.

#text(weight: "bold")[Bold: The quick brown fox jumps over the lazy dog. 0123456789]

#text(style: "italic")[Italic: The quick brown fox jumps over the lazy dog. 0123456789]

#text(weight: "bold", style: "italic")[Bold italic: The quick brown fox jumps over the lazy dog. 0123456789]
