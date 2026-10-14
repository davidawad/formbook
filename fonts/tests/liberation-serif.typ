// Font proof for fonts/liberation-serif/ (Times-metric substitute for Times New Roman).
// Compile: typst compile --font-path fonts --ignore-system-fonts fonts/tests/liberation-serif.typ OUT.pdf
// Must produce zero warnings, and pdffonts must list only Liberation Serif faces.
#set page(paper: "us-letter", margin: 1in)
#set text(font: "Liberation Serif", size: 12pt, lang: "en")
#set par(justify: true)

#text(size: 14pt, weight: "bold")[Liberation Serif: font proof]

#v(0.5em)

Regular: The quick brown fox jumps over the lazy dog. 0123456789 § ¶ “quoted” — end.

#text(weight: "bold")[Bold: The quick brown fox jumps over the lazy dog. 0123456789]

#text(style: "italic")[Italic: The quick brown fox jumps over the lazy dog. 0123456789]

#text(weight: "bold", style: "italic")[Bold italic: The quick brown fox jumps over the lazy dog. 0123456789]
