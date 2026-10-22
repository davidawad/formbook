-- lib/latex/xeschola.lua: TeX Gyre Schola at the vendored font's advance widths (lib/latex/xeschola.sty). A court
-- filter of a Schola template runs it after the cross-engine inline rules (lib/latex/xengine.lua), top down:
--   local xs = require("latex.xeschola")
--   doc = doc:walk({ Inlines = xe.inlines }):walk(xs.filter)
-- Each glyph whose advance differs between TeX Gyre Schola 2.609 (typst and Word) and TeX Live's Type 1 Schola
-- (pdfLaTeX) is written as \xeglyph{<glyph>}{<regular>}{<bold>}{<italic>}{<bold italic>}, the 2.609 advances in
-- thousandths of an em (typst's measure() on fonts/tex-gyre-schola, kerning off), a slash as \xeglyphscaled (a
-- line may end after it); every segment of text ends with \xeflush: before a space, a line break, a footnote, a
-- break opportunity written as raw LaTeX (\allowbreak), and at the end of the block.
local M = {}

-- glyph -> { LaTeX for the glyph, regular, bold, italic, bold italic }
local W = {
  ["("] = { "(", 483, 519, 483, 519 },
  [")"] = { ")", 483, 519, 483, 519 },
  ["["] = { "[", 452, 482, 452, 482 },
  ["]"] = { "]", 452, 482, 452, 482 },
  ["{"] = { "\\{", 465, 498, 465, 498 },
  ["}"] = { "\\}", 465, 498, 465, 498 },
  ["/"] = { "/", 447, 462, 447, 462, scaled = true },
  ["\\"] = { "\\textbackslash{}", 447, 462, 447, 462 },
  ["|"] = { "\\textbar{}", 225, 245, 225, 245 },
  ["*"] = { "*", 420, 483, 420, 483 },
  ["+"] = { "+", 780, 800, 780, 800 },
  ["<"] = { "\\textless{}", 788, 810, 788, 810 },
  ["="] = { "=", 780, 800, 780, 800 },
  [">"] = { "\\textgreater{}", 788, 810, 788, 810 },
  ["\u{2026}"] = { "\\textellipsis{}", 860, 1000, 860, 1000 },
  ["\u{2022}"] = { "\\textbullet{}", 510, 560, 510, 560 },
}

local function raw(s)
  return pandoc.RawInline("latex", s)
end

local FLUSH = "\\xeflush{}"

local function glyph(c)
  local w = W[c]
  return raw(string.format("\\xeglyph" .. (w.scaled and "scaled" or "") .. "{%s}{%d}{%d}{%d}{%d}", w[1], w[2], w[3], w[4], w[5]))
end

local filter

-- The inlines of one list; `outer`: the list is a block's own (its end ends a segment).
local function run(inlines, outer)
  local out = pandoc.Inlines({})
  for _, el in ipairs(inlines) do
    local t = el.t
    if t == "Str" then
      local buf = ""
      for _, cp in utf8.codes(el.text) do
        local c = utf8.char(cp)
        if W[c] then
          if buf ~= "" then out:insert(pandoc.Str(buf)) end
          buf = ""
          out:insert(glyph(c))
        else
          buf = buf .. c
        end
      end
      if buf ~= "" then out:insert(pandoc.Str(buf)) end
    elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then
      out:insert(raw(FLUSH))
      out:insert(el)
    elseif t == "Note" then
      out:insert(raw(FLUSH))
      el.content = el.content:walk(filter)
      out:insert(el)
    elseif t == "RawInline" then
      if el.format == "latex" and el.text:find("\\allowbreak", 1, true) then out:insert(raw(FLUSH)) end
      out:insert(el)
    elseif t == "Code" or t == "Math" then
      out:insert(el)
    elseif el.content ~= nil then
      el.content = run(el.content, false)
      out:insert(el)
    else
      out:insert(el)
    end
  end
  if outer then out:insert(raw(FLUSH)) end
  return out
end

-- Top down: each block's inline list once (the nested lists are handled by run itself).
filter = {
  traverse = "topdown",
  Inlines = function(l) return run(l, true), false end,
}
M.filter = filter

-- The inlines of a metadata value or a template argument, a segment of their own.
function M.inlines(l)
  return run(l, true)
end

return M
