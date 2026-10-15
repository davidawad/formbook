-- ncmd-motion-brief.lua (docx engine). Builds the parts of typst/ncmd-motion-brief.typ that pandoc cannot write
-- from the frontmatter: the cover (court title, caption), the table of contents and the table of authorities
-- (page numbers come from a first pass on the LibreOffice PDF, see render.sh), the heading labels (I., A., 1., a.),
-- the sign-off, the signature blocks and the certificates. Every string comes from the sample's frontmatter.
-- Environment (set by render.sh): BRIEF_FRONT=1 writes only the front matter (to count its pages);
-- BRIEF_MAP=<file> gives the page numbers; BRIEF_NEEDLES=<file> receives the search strings for the first pass.

local FRONT_ONLY = os.getenv("BRIEF_FRONT") == "1"
local MAP_FILE = os.getenv("BRIEF_MAP")
local NEEDLES_FILE = os.getenv("BRIEF_NEEDLES")
local PASSIM_AT = 7
local TAB = "<w:r><w:tab/></w:r>"
local BR = "<w:r><w:br/></w:r>"

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end
local function R(text, rpr)
  local pr = rpr and ("<w:rPr>" .. rpr .. "</w:rPr>") or ""
  return "<w:r>" .. pr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end
local function P(style, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>" .. (inner or "") .. "</w:p>"
end
local function TC(width, borders, mar, inner)
  local b = borders and ("<w:tcBorders>" .. borders .. "</w:tcBorders>") or ""
  local m = mar and ("<w:tcMar>" .. mar .. "</w:tcMar>") or ""
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. b .. m .. "</w:tcPr>" .. inner .. "</w:tc>"
end
local function TBL(cols, rows)
  local sum, grid = 0, ""
  for _, c in ipairs(cols) do
    sum = sum + c
    grid = grid .. '<w:gridCol w:w="' .. c .. '"/>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. sum .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>'
    .. "</w:tblPr><w:tblGrid>" .. grid .. "</w:tblGrid><w:tr>" .. rows .. "</w:tr></w:tbl>"
end
local function str(v) return pandoc.utils.stringify(v) end
local function strs(list)
  local out = {}
  for _, v in ipairs(list) do out[#out + 1] = str(v) end
  return out
end
local function need(meta, key)
  local v = meta[key]
  if v == nil then error("ncmd-motion-brief.lua: missing required metadata field `" .. key .. "`") end
  return v
end
-- Normalised search string: NBSP and runs of white space become one space; clipped to n characters.
local function norm(s)
  local t = s:gsub("\194\160", " "):gsub("%s+", " ")
  return (t:match("^%s*(.-)%s*$"))
end
local function copy_inlines(list)
  local c = pandoc.List({})
  for _, x in ipairs(list) do c:insert(x) end
  return c
end
local function clip(s, n)
  local i = utf8.offset(s, n + 1)
  if i then return s:sub(1, i - 1) end
  return s
end
local function roman(n)
  local out = ""
  for _, v in ipairs({ { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }) do
    while n >= v[1] do
      out = out .. v[2]
      n = n - v[1]
    end
  end
  return out
end

-- Page numbers of the first pass (render.sh): H<TAB>index<TAB>page and A<TAB>key<TAB>pages (comma-separated).
local HMAP, AMAP = {}, {}
if MAP_FILE then
  local f = io.open(MAP_FILE, "r")
  if f then
    for line in f:lines() do
      local kind, k, pages = line:match("^(%u)\t([^\t]*)\t(.*)$")
      if kind == "H" then HMAP[tonumber(k)] = pages end
      if kind == "A" then AMAP[k] = pages end
    end
    f:close()
  end
end

local function sect(footer, fmt)
  local ref = footer and '<w:footerReference w:type="default" r:id="RIDPLACE"/>' or ""
  return '<w:p><w:pPr><w:sectPr>' .. ref .. '<w:pgSz w:w="12240" w:h="15840"/>'
    .. '<w:pgMar w:top="1800" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="576" w:gutter="0"/>'
    .. '<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/><w:cols w:space="720"/></w:sectPr></w:pPr></w:p>'
end

local function cover(meta)
  local out = {}
  for _, l in ipairs(strs(need(meta, "court"))) do
    out[#out + 1] = P("CoverTitle", R(l:upper(), "<w:b/><w:bCs/>"))
  end
  out[#out + 1] = P("Normal", "")
  local sides = need(meta, "caption")
  local left = {}
  for i, side in ipairs(sides) do
    for _, n in ipairs(strs(side.names)) do
      left[#left + 1] = P("SingleSpaced", R(n))
    end
    left[#left + 1] = P("SingleSpaced", R(str(side.designation)), '<w:ind w:left="2592" w:firstLine="0"/>')
    if i < #sides then
      left[#left + 1] = P("SingleSpaced", R("v."), '<w:spacing w:before="230" w:after="230" w:line="420" w:lineRule="exact"/><w:jc w:val="center"/>')
    end
  end
  local right = P("CaptionText", R(str(need(meta, "case_number"))))
    .. P("CaptionText", R(str(need(meta, "brief_title")), "<w:b/><w:bCs/>"), '<w:spacing w:before="230" w:after="0" w:line="420" w:lineRule="exact"/>')
  out[#out + 1] = TBL({ 4680, 4680 },
    TC(4680, '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>',
      '<w:right w:w="288" w:type="dxa"/><w:bottom w:w="260" w:type="dxa"/>', table.concat(left))
    .. TC(4680, nil, '<w:left w:w="288" w:type="dxa"/>', right))
  out[#out + 1] = P("Normal", "")
  return pandoc.RawBlock("openxml", table.concat(out))
end

local function signature(meta)
  local sigs = need(meta, "signatures")
  local right = P("SignatureBlockWide", R("Respectfully submitted,"), '<w:spacing w:before="460" w:after="0" w:line="420" w:lineRule="exact"/>')
  for _, s in ipairs(sigs) do
    local lines = {}
    if s.firm ~= nil then lines[#lines + 1] = R(str(s.firm)) end
    lines[#lines + 1] = R("/s/ " .. str(s.signer))
    lines[#lines + 1] = R(str(s.signer))
    if s.bar_number ~= nil then lines[#lines + 1] = R(str(s.bar_number)) end
    for _, l in ipairs(strs(s.address)) do lines[#lines + 1] = R(l) end
    lines[#lines + 1] = R(str(s.phone))
    lines[#lines + 1] = R(str(s.email))
    lines[#lines + 1] = R(str(s.role), "<w:i/><w:iCs/>")
    right = right .. P("SignatureBlockWide", table.concat(lines, BR), '<w:spacing w:before="230" w:after="0" w:line="420" w:lineRule="exact"/>')
  end
  local left = P("SingleSpaced", R("Dated: " .. str(need(meta, "date"))), '<w:spacing w:before="460" w:after="0" w:line="420" w:lineRule="exact"/>')
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="Normal"/><w:keepNext/></w:pPr></w:p>'
    .. TBL({ 4752, 4608 }, TC(4752, nil, nil, left) .. TC(4608, nil, nil, right)))
end

local function certificates(meta)
  local sig = need(meta, "signatures")[1]
  local out = {}
  out[#out + 1] = P("FrontHeading", R("Certificate of Word Count"), "<w:keepNext/>")
  out[#out + 1] = P("BodyText", R("I hereby certify that this brief complies with Local Rule 7.3(d)(1) in that it does not exceed 6,250 words in length, including the body of the brief, headings, and footnotes."))
  out[#out + 1] = P("BodyText", R("This the " .. str(need(meta, "certificate_date")) .. "."), "<w:keepNext/>")
  out[#out + 1] = P("SignatureBlockWide", R("/s/ " .. str(sig.signer)) .. BR .. R(str(sig.signer)), '<w:spacing w:before="460" w:after="0" w:line="420" w:lineRule="exact"/><w:ind w:left="4752" w:firstLine="0"/>')
  out[#out + 1] = P("FrontHeading", R("Certificate of Service"), "<w:keepNext/>")
  out[#out + 1] = P("BodyText", R("I certify that, on " .. str(need(meta, "service_date")) .. ", a copy of the foregoing document was filed with the Clerk of the Court using the CM/ECF System, which will send notification of the filing to the parties and counsel of record who are registered with that system."), "<w:keepNext/>")
  out[#out + 1] = P("SignatureBlockWide", R("/s/ " .. str(sig.signer)) .. BR .. R(str(sig.signer)), '<w:spacing w:before="460" w:after="0" w:line="420" w:lineRule="exact"/><w:ind w:left="4752" w:firstLine="0"/>')
  return pandoc.RawBlock("openxml", table.concat(out))
end

local function para_div(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "court", "caption", "brief_title", "date", "certificate_date", "service_date", "signatures" }) do
    need(meta, k)
  end
  local authorities = meta.authorities or {}

  -- one walk over the body: heading labels and table-of-authorities links (typst counts the links only)
  local heads, hits = {}, {}
  local cnt = { 0, 0, 0, 0, 0, 0 }
  local body = doc:walk({
    Header = function(el)
      local L = el.level
      cnt[L] = cnt[L] + 1
      for k = L + 1, 6 do cnt[k] = 0 end
      local lab = ""
      if L == 2 then lab = roman(cnt[2]) .. "."
      elseif L == 3 then lab = string.char(64 + cnt[3]) .. "."
      elseif L == 4 then lab = tostring(cnt[4]) .. "."
      elseif L == 5 then lab = string.char(96 + cnt[5]) .. "." end
      local text = str(el.content)
      heads[#heads + 1] = {
        level = L, idx = #heads + 1, label = lab, content = copy_inlines(el.content),
        needle = clip(norm((lab ~= "" and (lab .. " ") or "") .. text), 50),
      }
      if lab ~= "" then
        table.insert(el.content, 1, pandoc.RawInline("openxml", TAB))
        table.insert(el.content, 1, pandoc.Str(lab))
      end
      return el
    end,
    Link = function(el)
      if el.target:sub(1, 4) == "toa:" then
        local key = el.target:sub(5)
        if authorities[key] == nil then
          error("ncmd-motion-brief.lua: link `toa:" .. key .. "` has no entry under `authorities:` in the frontmatter")
        end
        hits[#hits + 1] = { key = key, needle = clip(norm(str(el.content)), 28) }
        return el.content
      end
      return nil
    end,
  })

  local out = { cover(meta), pandoc.RawBlock("openxml", sect(false, "decimal")) }

  -- table of contents: headings of levels 2 to 4 with their page numbers
  out[#out + 1] = pandoc.RawBlock("openxml", P("FrontHeading", R("Table of Contents")))
  out[#out + 1] = pandoc.RawBlock("openxml", P("PageLabel", R("Page")))
  for _, h in ipairs(heads) do
    if h.level >= 2 and h.level <= 4 then
      local content = pandoc.List({})
      if h.label ~= "" then content:insert(pandoc.Str(h.label)); content:insert(pandoc.RawInline("openxml", TAB)) end
      content:extend(h.content)
      content:insert(pandoc.RawInline("openxml", TAB))
      content:insert(pandoc.Str(HMAP[h.idx] or "0"))
      out[#out + 1] = para_div("TOC Level " .. h.level, content)
    end
  end

  out[#out + 1] = pandoc.RawBlock("openxml", P("FrontHeadingBreak", R("Table of Authorities")))
  out[#out + 1] = pandoc.RawBlock("openxml", P("PageLabel", R("Page(s)")))
  local used = {}
  for _, h in ipairs(hits) do used[h.key] = true end
  local groups = {
    { "case", "Cases" }, { "statute", "Federal Statutes" }, { "rule", "Federal Rules" },
    { "regulation", "Federal Regulations" }, { "other", "Other Authorities" },
  }
  for _, g in ipairs(groups) do
    local members = {}
    for key, a in pairs(authorities) do
      if used[key] and str(a.kind) == g[1] then members[#members + 1] = key end
    end
    if #members > 0 then
      local function sk(key)
        local a = authorities[key]
        local n = a.name ~= nil and str(a.name) or str(a.cite)
        return n:lower()
      end
      table.sort(members, function(x, y) return sk(x) < sk(y) end)
      out[#out + 1] = pandoc.RawBlock("openxml", P("TOAGroup", R(g[2])))
      for _, key in ipairs(members) do
        local a = authorities[key]
        local pages = AMAP[key] or "0"
        local n = 0
        for _ in pages:gmatch("[^,]+") do n = n + 1 end
        if n >= PASSIM_AT then pages = "passim" end
        local content = pandoc.List({})
        if a.name ~= nil then
          if str(a.kind) == "case" then
            content:insert(pandoc.Emph({ pandoc.Str(str(a.name)) }))
          else
            content:insert(pandoc.Str(str(a.name)))
          end
          content:insert(pandoc.Str(", "))
        end
        content:insert(pandoc.Str(str(a.cite)))
        content:insert(pandoc.RawInline("openxml", TAB))
        content:insert(pandoc.Str(pages))
        out[#out + 1] = para_div("TOA Entry", content)
      end
    end
  end

  out[#out + 1] = pandoc.RawBlock("openxml", sect(true, "lowerRoman"))

  if NEEDLES_FILE then
    local f = io.open(NEEDLES_FILE, "w")
    if f then
      for _, h in ipairs(heads) do
        if h.level >= 2 and h.level <= 4 then f:write("H\t" .. h.idx .. "\t" .. h.needle .. "\n") end
      end
      for _, h in ipairs(hits) do f:write("A\t" .. h.key .. "\t" .. h.needle .. "\n") end
      f:close()
    end
  end

  if FRONT_ONLY then
    doc.blocks = pandoc.List(out)
    doc.meta = pandoc.Meta({})
    return doc
  end

  -- body: the conclusion (the last level-2 heading on) is kept with the signature block
  local blocks = body.blocks
  local last2 = 0
  for i, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 2 then last2 = i end
  end
  for i, b in ipairs(blocks) do
    if last2 > 0 and i >= last2 and b.t == "Para" then
      b = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Keep Next Body" }))
    end
    out[#out + 1] = b
  end
  out[#out + 1] = signature(meta)
  out[#out + 1] = certificates(meta)
  doc.blocks = pandoc.List(out)
  doc.meta = pandoc.Meta({})
  return doc
end
