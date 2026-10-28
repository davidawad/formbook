local xe = require("docx.xengine")

function Pandoc(doc)
  local token = "922(g)(7)"
  local run_xml = xe.runs(token)
  assert(run_xml:find("922(g)\u{2060}(7)", 1, true),
    "plain runs must bind adjacent-parenthesis tokens")
  local split = pandoc.Inlines({ pandoc.Str("922(g)"), pandoc.Str("(7)") })
  local split_xml = xe.inl(split)
  assert(split_xml:find("\u{2060}", 1, true) and split_xml:find("922(g)", 1, true)
    and split_xml:find("(7)", 1, true), "inline conversion must bind a token split across Pandoc nodes")
  local walked = xe.inlines(pandoc.Inlines({ pandoc.Str(token) }))
  assert(pandoc.utils.stringify(walked):find("922(g)\u{2060}(7)", 1, true),
    "Pandoc-written body text must bind all breaks inside an adjacent-parenthesis token")
  local blocks = xe.blocks({ pandoc.Para({ pandoc.Str(token) }) })
  assert(pandoc.utils.stringify(blocks):find("922(g)\u{2060}(7)", 1, true),
    "whole-document normalization must bind body tokens")
  assert(xe.bind_raw("<w:r><w:t>" .. token .. "</w:t></w:r>"):find(")\u{2060}(", 1, true),
    "raw OpenXML runs must bind adjacent-parenthesis tokens")
  assert(xe.LEAD == "\u{00A0}\u{00A0}\u{00A0}\t", "the default leader gap remains three no-break spaces")
  assert(xe.LEAD_075EM == "\u{2060}\u{2005}\u{2060}\u{2005}\u{2060}\u{2005}\u{2060}\t",
    "the shared narrow leader gap must be a nonbreaking 0.75 em before the tab")
  return doc
end
