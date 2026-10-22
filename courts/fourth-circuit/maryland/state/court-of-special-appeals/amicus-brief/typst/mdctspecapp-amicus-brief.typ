// Appellate Court of Maryland (formerly the Court of Special Appeals; mdctspecapp): amicus-brief, on the shared document model:
// the layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex and
// docx engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific text,
// measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// MDCTSPECAPP-FONT-001 (Rule 8-112(c)(1); the Supreme Court's approved-font order of Sept. 27, 2023): Times New Roman
// (Liberation Serif its metric twin).
#let font-family = ("Times New Roman", "Liberation Serif")

#let mdctspecapp-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
