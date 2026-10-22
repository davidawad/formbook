// Florida Fourth District Court of Appeal (fladistctapp4): motion and supporting memorandum, on the shared document
// model: the layout is data (layout.yaml, every number with its rule), set by lib/typst/xdoc.typ here and by the latex
// and docx engines `fb engines gen` generates from this folder (fb-595.54.12). Content-agnostic: no case-specific
// text, measured coordinates or forced breaks.
#import "/lib/typst/xdoc.typ": xdoc, split-frontmatter

// FLADISTCTAPP4-FORM-005 (Rule 9.045(b)): Arial 14 or Bookman Old Style 14; Bookman is named here (docs/FONTS.md:
// TeX Gyre Bonum, its visual clone).
#let font-family = "TeX Gyre Bonum"

#let fladistctapp4-motion-brief(meta, body) = xdoc(yaml("layout.yaml") + (font: font-family), meta, body)
