-- lib/docx/xengine.lua: the cross-engine layout model for a Word template (docs/EVAL-LOOP.md, "Cross-engine gate";
-- fb-595.54, fb-595.54.1). The typst render (lib/typst/xengine.typ) is the reference; Word and LibreOffice break
-- lines first fit and set no kerning or ligatures by default, so what is left to the filter is the break
-- opportunities and the paragraph layout, written as WordprocessingML. fb render puts lib/ on LUA_PATH:
--   local xe = require("docx.xengine")
-- The paragraph styles pandoc uses (Body Text, Footnote Text, Block Text, List Item) come from the template's
-- reference.docx, built with lib/docx/xengine-reference.sh.
--
-- What it provides:
--   xe.inl(inlines, o)        pandoc inlines (or a metadata value) as Word runs: a no-break hyphen before a digit,
--                             pandoc's abbreviation no-break spaces undone, a section sign bound to its number;
--   xe.runs(text, o)          plain text (tabs as tabs) as runs; o: { b, i, caps, sz, u, box } (xe.rpr);
--   xe.inlines(l)             the same break rules on pandoc inlines that pandoc itself writes (a walk filter);
--   xe.para(props, body), xe.raw(xml), xe.style(id), xe.spacing(before, after, line), xe.ind(left, hanging,
--   first, right), xe.jc(v), xe.leader_tab(pos), and xe.KEEP, xe.LINES, xe.BREAK, xe.BR, xe.LEAD;
--   xe.list_items(block)      a list as "List Item" paragraphs: the label, a tab to the hanging indent, the text.
-- Exact line spacing throughout (xe.spacing): Word sets each line in a box of that height, the baseline at 0.8 of it,
-- which is the layout the typst and LaTeX engines reproduce. Spacing between paragraphs is the larger of the one's
-- after and the next one's before, and is dropped at the top of a page.
local common = require("pandoc.xengine")
local M = {}

local stringify = pandoc.utils.stringify
local unabbrev, bind_signs = common.unabbrev, common.bind_signs

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function merge(a, b)
  local out = {}
  for k, v in pairs(a or {}) do out[k] = v end
  for k, v in pairs(b or {}) do out[k] = v end
  return out
end

local function rpr(o)
  local x = ""
  if o.b then x = x .. "<w:b/><w:bCs/>" end
  if o.i then x = x .. "<w:i/><w:iCs/>" end
  if o.caps then x = x .. "<w:caps/>" end
  if o.sz then x = x .. '<w:sz w:val="' .. o.sz .. '"/><w:szCs w:val="' .. o.sz .. '"/>' end
  if o.u then x = x .. '<w:u w:val="single"/>' end
  if o.box then x = x .. '<w:bdr w:val="single" w:sz="6" w:space="0" w:color="000000"/>' end
  if x == "" then return "" end
  return "<w:rPr>" .. x .. "</w:rPr>"
end

-- Text with tabs (\t) as Word runs. No line breaks are ever written: lines wrap where they wrap.
local function runs(text, o)
  local x = rpr(o or {})
  local out = {}
  local pos = 1
  while pos <= #text do
    if text:sub(pos, pos) == "\t" then
      out[#out + 1] = "<w:r>" .. x .. "<w:tab/></w:r>"
      pos = pos + 1
    else
      local e = text:find("\t", pos, true) or (#text + 1)
      -- a hyphen before a digit does not end a line ("ER-178-82"; Unicode line breaking, as typst breaks)
      local t = esc(text:sub(pos, e - 1)):gsub("%-(%d)", '</w:t><w:noBreakHyphen/><w:t xml:space="preserve">%1')
      out[#out + 1] = "<w:r>" .. x .. '<w:t xml:space="preserve">' .. t .. "</w:t></w:r>"
      pos = e
    end
  end
  return table.concat(out)
end

-- A hyphen before a digit does not end a line ("ER-178-82"): Word's non-breaking hyphen, as typst breaks (Unicode
-- line breaking keeps a hyphen with the number after it) and LibreOffice would not. The hyphen is its own run.
local NBH = pandoc.RawInline("openxml", "<w:r><w:noBreakHyphen/></w:r>")
local function nobreak_hyphens(inlines)
  local out = pandoc.Inlines({})
  for _, el in ipairs(inlines) do
    if el.t == "Str" and el.text:find("%-%d") then
      local rest = el.text
      while true do
        local s = rest:find("%-%d")
        if not s then break end
        if s > 1 then out:insert(pandoc.Str(rest:sub(1, s - 1))) end
        out:insert(NBH)
        rest = rest:sub(s + 1)
      end
      if rest ~= "" then out:insert(pandoc.Str(rest)) end
    else
      out:insert(el)
    end
  end
  return out
end

-- Pandoc inlines (or a metadata value) as Word runs; links keep their text.
local function inl(x, o)
  o = o or {}
  if x == nil then return "" end
  if type(x) == "string" then return runs(x, o) end
  x = bind_signs(unabbrev(x))
  local out = {}
  for _, el in ipairs(x) do
    local t = el.t
    if t == "Str" then
      out[#out + 1] = runs(el.text, o)
    elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then
      out[#out + 1] = runs(" ", o)
    elseif t == "Emph" then
      out[#out + 1] = inl(el.content, merge(o, { i = true }))
    elseif t == "Strong" then
      out[#out + 1] = inl(el.content, merge(o, { b = true }))
    elseif t == "Quoted" then
      local q = el.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = runs(q[1], o) .. inl(el.content, o) .. runs(q[2], o)
    elseif t == "Link" or t == "Span" or t == "SmallCaps" or t == "Underline" then
      out[#out + 1] = inl(el.content, o)
    else
      out[#out + 1] = runs(stringify(el), o)
    end
  end
  return table.concat(out)
end

-- Paragraph properties are given in the schema's order: style, keep, page break, border, tabs, spacing, indent,
-- justification, outline level. Word refuses a file whose paragraph properties are out of order or repeated.
local function para(props, body)
  return "<w:p><w:pPr>" .. table.concat(props) .. "</w:pPr>" .. body .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function style(id)
  return '<w:pStyle w:val="' .. id .. '"/>'
end

-- Exact line spacing: a line box of `line` twips.
local function spacing(before, after, line)
  return string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="exact"/>', before, after, line)
end

local function ind(left, hanging, first, right)
  local x = '<w:ind w:left="' .. (left or 0) .. '"'
  if right then x = x .. ' w:right="' .. right .. '"' end
  if hanging then x = x .. ' w:hanging="' .. hanging .. '"' end
  if first then x = x .. ' w:firstLine="' .. first .. '"' end
  return x .. "/>"
end

local function jc(v)
  return '<w:jc w:val="' .. v .. '"/>'
end

-- A dot leader to `pos` (the page number of a table row follows the last tab).
local function leader_tab(pos)
  return '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="' .. pos .. '"/></w:tabs>'
end

local function list_items(b)
  if b.t ~= "OrderedList" and b.t ~= "BulletList" then return { b } end
  local out = {}
  local n = b.t == "OrderedList" and b.listAttributes.start or 1
  local delim = b.t == "OrderedList" and b.listAttributes.delimiter or "Period"
  for _, item in ipairs(b.content) do
    if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then return { b } end
    local lab = "\u{2022}"
    if b.t == "OrderedList" then
      lab = delim == "OneParen" and (n .. ")") or delim == "TwoParens" and ("(" .. n .. ")") or (n .. ".")
    end
    local inlines = pandoc.Inlines({ pandoc.Str(lab), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
    inlines:extend(item[1].content)
    out[#out + 1] = pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = "List Item" })
    n = n + 1
  end
  return out
end

M.esc, M.merge, M.rpr, M.runs, M.inl = esc, merge, rpr, runs, inl
M.unabbrev, M.bind_signs, M.nobreak_hyphens = unabbrev, bind_signs, nobreak_hyphens
M.para, M.raw, M.style, M.spacing, M.ind, M.jc, M.leader_tab = para, raw, style, spacing, ind, jc, leader_tab
M.list_items = list_items
M.KEEP = "<w:keepNext/><w:keepLines/>"
M.LINES = "<w:keepLines/>"
M.BREAK = "<w:pageBreakBefore/>"
-- A line break inside a paragraph (typst: linebreak()).
M.BR = "<w:r><w:br/></w:r>"
-- Before the leader tab of a table row: three no-break spaces, so the leader is never shorter than that and the
-- last word takes them along when it wraps (typst: h(0.75em), latex: \xe@leader).
M.LEAD = "\u{00A0}\u{00A0}\u{00A0}\t"

-- The break rules on inlines pandoc writes itself (the body text, footnotes, quotations).
function M.inlines(l)
  return nobreak_hyphens(bind_signs(unabbrev(l)))
end

return M
