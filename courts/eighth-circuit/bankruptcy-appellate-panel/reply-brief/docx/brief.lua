-- brief.lua: pandoc filter for the BAP 8th Cir. brief (docx engine). Run by docx/render.sh.
-- It does what the typst template does in bap8-*.typ, on the pandoc AST:
--   * numbers the body headings (Argument: I. / A. / 1. / a.; elsewhere A. / 1. / a. / (1)) and sets each
--     heading as a paragraph style (Section Heading, Point Heading, Sub2..Sub5, ArgSub3..ArgSub5) so the
--     hanging label positions match the typst output; the outline level is kept in the style;
--   * writes the table of contents (levels 1-4, dot leaders) and the table of authorities (grouped by kind,
--     "passim" at 7 or more pages) at the two placeholders, from the page map in $BAP8_MAP;
--   * removes the toa: link targets, so citations are plain text (no hyperlinks).
-- Page map (tab separated), written by render.sh:
--   H<TAB><page>                      one line per body heading, in order
--   T<TAB><key><TAB><kind><TAB><cite> one line per cited authority, in order of first citation
--   A<TAB><key><TAB><pages>           "3, 5, 9" or "passim"

local TAB = pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>')
-- The cross-engine layout model (lib/docx/xengine.lua): the break rules of typst on every run (a no-break hyphen
-- before a digit, pandoc's abbreviation no-break spaces undone, a section sign bound to its number).
local xe = require("docx.xengine")
-- Before the page number of a table row: three no-break spaces, so the leader is never shorter than that.
local LEAD = pandoc.Str("\u{00A0}\u{00A0}\u{00A0}")
local ACOL = 1120   -- the authorities' page column, twips (typst toa-page-col, 56 pt)

-- No break inside a token of adjacent parentheses ("8015(a)(7)(B)"), as typst's xengine boxes it: LibreOffice would
-- break between ")" and "(" (Unicode line breaking allows it); a word joiner forbids it.
local function joined(s)
  return (s:gsub("%)%(", ")\u{2060}("))
end

-- The width of a page list in twips, Times New Roman 14 pt: digits 500/1000 em, comma and space 250, "passim" in
-- italics 2778 (the font's advances; typst measures the same list).
local function page_width(s)
  if s == "passim" then return math.ceil(2778 * 0.28) end
  local units = 0
  for c in s:gmatch(".") do
    if c:match("%d") then units = units + 500 elseif c == "," or c == " " then units = units + 250
    else error("brief.lua: unexpected character in a page list: " .. s) end
  end
  return math.ceil(units * 0.28)
end

local function read_map()
  local path = os.getenv("BAP8_MAP")
  if not path then error("brief.lua: BAP8_MAP is not set") end
  local H, T, A = {}, {}, {}
  local f = assert(io.open(path, "r"))
  for line in f:lines() do
    local fields = {}
    for s in (line .. "\t"):gmatch("(.-)\t") do fields[#fields + 1] = s end
    if fields[1] == "H" then H[#H + 1] = fields[2]
    elseif fields[1] == "T" then T[#T + 1] = { key = fields[2], kind = fields[3], cite = fields[4] }
    elseif fields[1] == "A" then A[fields[2]] = fields[3] end
  end
  f:close()
  return H, T, A
end

local function roman(n)
  local vals = { {1000, "M"}, {900, "CM"}, {500, "D"}, {400, "CD"}, {100, "C"}, {90, "XC"}, {50, "L"},
                 {40, "XL"}, {10, "X"}, {9, "IX"}, {5, "V"}, {4, "IV"}, {1, "I"} }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do s = s .. p[2]; n = n - p[1] end
  end
  return s
end

-- the printed label of a heading, as typst's heading-label()
local function label_for(level, n, in_arg)
  if in_arg then
    if level == 2 then return roman(n) .. "." end
    if level == 3 then return string.char(64 + n) .. "." end
    if level == 4 then return tostring(n) .. "." end
    if level == 5 then return string.char(96 + n) .. "." end
  else
    if level == 2 then return string.char(64 + n) .. "." end
    if level == 3 then return tostring(n) .. "." end
    if level == 4 then return string.char(96 + n) .. "." end
    if level == 5 then return "(" .. tostring(n) .. ")" end
  end
  error("brief.lua: headings deeper than level 5 are not supported")
end

local function plain(inlines) return pandoc.utils.stringify(inlines) end

local function upper_inlines(inlines)
  return inlines:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

local function sort_key(cite)
  return (cite:lower():gsub("[^a-z0-9 ]", ""))
end

local function div(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function para_div(style, inlines)
  return div(style, { pandoc.Para(inlines) })
end

-- heading styles (outline level kept in each style): returns style name for a non-point heading
local function sub_style(level, in_arg)
  if in_arg then return "ArgSub" .. level end
  return "Sub" .. level
end

-- TOC paragraph style: where the label sits (typst's label-indent), as in the heading styles
local function toc_style(level, in_arg, numbered)
  if level == 1 then return "TOC1" end
  if in_arg and level == 2 then return "TOCArg" end
  if in_arg then return level == 3 and "TOC2" or "TOC3" end
  return ({ [2] = "TOC2", [3] = "TOC3", [4] = "TOC4" })[level]
end

function Pandoc(doc)
  local H, T, A = read_map()

  -- 1. number the body headings (top-level Headers, in order), building their replacement blocks
  local counters = { 0, 0, 0, 0, 0 }
  local first_section = true   -- the first heading of the body starts a new section: no space above it
  local in_arg = false
  local heads = {}     -- { level, in_arg, label, content }
  local body = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local level = b.level
      counters[level] = counters[level] + 1
      for i = level + 1, 5 do counters[i] = 0 end
      local title = plain(b.content):lower():gsub("^%s+", ""):gsub("%s+$", "")
      local rec = { level = level, in_arg = in_arg, content = b.content, label = nil, title = title }
      if level == 1 then
        in_arg = (title == "argument" or title == "reply argument")
        rec.in_arg = false
        local out = para_div(first_section and "SectionHeadingTop" or "SectionHeading", b.content)
        first_section = false
        body[#body + 1] = out
      else
        rec.label = label_for(level, counters[level], in_arg)
        rec.in_arg = in_arg
        if in_arg and level == 2 then
          -- point heading: label and title on one centered line
          local inl = { pandoc.Str(rec.label), pandoc.Space() }
          for _, x in ipairs(b.content) do inl[#inl + 1] = x end
          body[#body + 1] = para_div("PointHeading", inl)
        else
          local inl = { pandoc.Str(rec.label), TAB }
          for _, x in ipairs(b.content) do inl[#inl + 1] = x end
          body[#body + 1] = para_div(sub_style(level, in_arg), inl)
        end
      end
      heads[#heads + 1] = rec
    else
      body[#body + 1] = b
    end
  end
  if #heads ~= #H then
    error("brief.lua: " .. #heads .. " headings in the document but " .. #H .. " in the page map")
  end

  -- 2. the table of contents: levels 1-4 (typst toc-depth = 4), with page numbers from the map
  local function toc_blocks()
    local out = { para_div("FrontHeading", { pandoc.Str("Table of Contents") }) }
    out[#out + 1] = para_div("PageLabel", { pandoc.Strong(pandoc.Underline(pandoc.Str("Page"))) })
    for k, h in ipairs(heads) do
      if h.level <= 4 then
        local inl = {}
        if h.level == 1 then
          for _, x in ipairs(upper_inlines(h.content)) do inl[#inl + 1] = x end
        else
          inl[#inl + 1] = pandoc.Str(h.label)
          inl[#inl + 1] = TAB
          for _, x in ipairs(h.content) do inl[#inl + 1] = x end
        end
        inl[#inl + 1] = LEAD
        inl[#inl + 1] = TAB
        inl[#inl + 1] = pandoc.Str(H[k])
        out[#out + 1] = para_div(toc_style(h.level, h.in_arg, h.label ~= nil), inl)
      end
    end
    return out
  end

  -- 3. the table of authorities: groups as typst's toa-groups, sorted by cite
  local groups = {
    { "case", "Cases:" }, { "constitution", "Constitutional Provisions:" }, { "statute", "Statutes:" },
    { "regulation", "Regulations:" }, { "rule", "Rules:" }, { "other", "Other Authorities:" },
  }
  local function toa_blocks()
    local out = { para_div("FrontHeading", { pandoc.Str("Table of Authorities") }) }
    local first = true
    for _, g in ipairs(groups) do
      local members = {}
      for _, t in ipairs(T) do
        if t.kind == g[1] then members[#members + 1] = t end
      end
      if #members > 0 then
        table.sort(members, function(x, y) return sort_key(x.cite) < sort_key(y.cite) end)
        local head = { pandoc.Strong(pandoc.Str(g[2])) }
        if first then
          head[#head + 1] = TAB
          head[#head + 1] = pandoc.Strong(pandoc.Underline(pandoc.Str("Page(s)")))
        end
        out[#out + 1] = para_div(first and "TOAGroupFirst" or "TOAGroup", head)
        first = false
        for _, t in ipairs(members) do
          local pages = A[t.key]
          if pages == nil then error("brief.lua: no page entry for " .. t.key) end
          local prun = pages == "passim" and xe.runs("passim", { i = true }) or xe.runs(pages)
          -- the cite wraps before the page column: 56 pt, or the page list's own width when longer (typst
          -- calc.max(toa-page-col, measure(page-text).width)); a section sign stays with its number
          local cite = joined(t.cite):gsub("§ ", "§\u{00A0}"):gsub("¶ ", "¶\u{00A0}")
          out[#out + 1] = xe.raw(xe.para({ xe.style("TOAEntry"), xe.ind(504, 504, nil, math.max(ACOL, page_width(pages))) },
            xe.runs(cite) .. xe.runs(xe.LEAD) .. prun))
        end
      end
    end
    return out
  end

  -- 4. placeholders and link handling
  local final = {}
  for _, b in ipairs(body) do
    local placeholder = b.t == "Div" and b.attr.attributes["custom-style"] or nil
    if placeholder == "TOCPlaceholder" then
      for _, x in ipairs(toc_blocks()) do final[#final + 1] = x end
    elseif placeholder == "TOAPlaceholder" then
      for _, x in ipairs(toa_blocks()) do final[#final + 1] = x end
    else
      final[#final + 1] = b
    end
  end

  -- bullet items (interested parties): a bullet, a tab, then the text, in a hanging-indent style
  for i, b in ipairs(final) do
    if b.t == "Div" and b.attr.attributes["custom-style"] == "BulletItem" then
      local p = b.content[1]
      local inl = { pandoc.Str("\u{2022}"), TAB }
      for _, x in ipairs(p.content) do inl[#inl + 1] = x end
      final[i] = para_div("BulletItem", inl)
    elseif b.t == "Div" and b.attr.attributes["custom-style"] == "CertBox" then
      -- a certificate's check box: a ruled box around an X (a bordered run, typst checkbox), then a tab to the text
      local p = b.content[1]
      local c = p.content
      if not (c[1] and c[1].t == "Str" and c[1].text == "CHECKBOXMARK" and c[2] and c[2].t == "Space") then
        error("brief.lua: a check-box row must start with CHECKBOXMARK")
      end
      local inl = { pandoc.RawInline("openxml", xe.runs("X", { box = true })), TAB }
      for j = 3, #c do inl[#inl + 1] = c[j] end
      final[i] = para_div("CertBox", inl)
    end
  end

  local result = pandoc.Pandoc(final, doc.meta)
  -- citations are plain text: the toa: target is only a key for the table of authorities
  result = result:walk({
    Link = function(l)
      if l.target:match("^toa:") then return l.content end
      return nil
    end,
  })
  -- the break rules of typst on every run pandoc writes
  return result:walk({ Inlines = xe.inlines, Str = function(s) return pandoc.Str(joined(s.text)) end })
end
