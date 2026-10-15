-- Motion with notice and memorandum, United States District Court for the Eastern District of California
-- (caed), DOCX engine (docs/DOCX.md). Markdown contract -> Word document on docx/reference.docx. Mirrors
-- typst/caed-motion-brief.typ: the cover (counsel, court title, caption, title, hearing), the notice (arabic
-- from page 1), the table of contents and the table of authorities (roman), the memorandum (arabic from 1).
-- Section breaks carry the page-number format. The table of contents page numbers are written as
-- placeholders @PG<n>@ (n = the memorandum heading's index); docx/render.sh measures them and fills them in.
-- Everything case-specific comes from the sample's frontmatter, never from this file.

local PT = 20 -- twips per point
local SGL = 276 -- single-spaced line, 13.8 pt (typst single-leading 0.5em on a 0.65em line box)
local ROW = 480 -- one numbered line, 24 pt
local MIN_COUNSEL_ROWS = 7 -- L.R. 131(a)

local SECT = '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1080" w:bottom="960" w:left="2160" w:header="720" w:footer="600" w:gutter="0"/>'
  .. '<w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="12" w:color="000000"/><w:right w:val="single" w:sz="4" w:space="7" w:color="000000"/></w:pgBorders>'

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local function run(text, bold)
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

local function xpara(style, ppr, runs)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or '') .. '</w:pPr>' .. (runs or '') .. '</w:p>'
end

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

-- a section break: the paragraph that ends a section carries its sectPr (page-number format from 1)
local function section_end(fmt)
  return raw('<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/>'
    .. '<w:sectPr><w:type w:val="nextPage"/>' .. SECT .. '<w:pgNumType w:fmt="' .. fmt .. '" w:start="1"/></w:sectPr></w:pPr></w:p>')
end

local function is_marker(b, name)
  return b.t == "Para" and plain(b) == name
end

local function counsel(lines)
  local out = {}
  for _, l in ipairs(lines) do out[#out + 1] = raw(xpara("Single", "", run(plain(l)))) end
  local h = #lines * SGL
  local rows = math.max(MIN_COUNSEL_ROWS * ROW, math.ceil(h / ROW) * ROW)
  return out, rows - h
end

local function caption(meta)
  local left = ""
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then left = left .. xpara("Single", "", run("v.")) end
    for _, n in ipairs(p.names or {}) do left = left .. xpara("Single", "", run(plain(n))) end
    left = left .. xpara("Single", "", run(plain(p.designation)))
  end
  local cell = '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:left="144" w:firstLine="0"/>'
  local gap = '<w:spacing w:before="240" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:left="144" w:firstLine="0"/>'
  local right = xpara("Single", cell, run("Case No.: " .. plain(meta.case_number)))
  if meta.judge then right = right .. xpara("Single", cell, run(plain(meta.judge))) end
  if meta.magistrate then right = right .. xpara("Single", cell, run(plain(meta.magistrate))) end
  right = right .. xpara("Single", gap, run(plain(meta.brief_title), true))
  if meta.concurrent then right = right .. xpara("Single", gap, run(plain(meta.concurrent))) end
  if meta.hearing then
    right = right .. xpara("Single", gap, run("Date: " .. plain(meta.hearing.date)))
    right = right .. xpara("Single", cell, run("Time: " .. plain(meta.hearing.time)))
    right = right .. xpara("Single", cell, run("Place: " .. plain(meta.hearing.place)))
  end
  if meta.action_filed then right = right .. xpara("Single", gap, run("Action Filed: " .. plain(meta.action_filed))) end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  return raw('<w:tbl><w:tblPr><w:tblW w:w="9000" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4608"/><w:gridCol w:w="288"/><w:gridCol w:w="4104"/></w:tblGrid>'
    .. '<w:tr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4608" w:type="dxa"/>' .. rule .. '<w:tcMar><w:right w:w="200" w:type="dxa"/><w:bottom w:w="160" w:type="dxa"/></w:tcMar></w:tcPr>' .. left .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr>' .. xpara("Single", "") .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4104" w:type="dxa"/></w:tcPr>' .. right .. '</w:tc>'
    .. '</w:tr></w:tbl>')
end

local function cover(meta)
  local out, pad = counsel(meta.counsel or {})
  local courts = { "UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF CALIFORNIA" }
  if meta.division then courts[#courts + 1] = plain(meta.division):upper() end
  for i, l in ipairs(courts) do
    local ppr = '<w:jc w:val="center"/>'
    if i == 1 then ppr = '<w:spacing w:before="' .. math.floor(pad) .. '" w:after="0" w:line="' .. ROW .. '" w:lineRule="exact"/>' .. ppr end
    out[#out + 1] = raw(xpara("CourtTitle", ppr, run(l)))
  end
  out[#out + 1] = raw('<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="0" w:after="0" w:line="' .. ROW .. '" w:lineRule="exact"/></w:pPr></w:p>')
  out[#out + 1] = caption(meta)
  return out
end

-- Signature block (typst signature-block()): the date at left, the firm at right; "By: /s/" and the signer.
local function keep_last(blocks)
  local last = blocks[#blocks]
  if last and last.t == "Para" then
    blocks[#blocks] = styled("BodyKeep", { last })
  elseif last and last.t == "Div" and last.attributes["custom-style"] then
    last.attributes["custom-style"] = last.attributes["custom-style"] .. "Keep" -- the keep-with-next variant of that style
  end
end

local function signature(sig, date)
  local function lines(items)
    local s = ""
    for _, l in ipairs(items or {}) do s = s .. xpara("SingleKeep", "", run(plain(l))) end
    return s
  end
  local right = lines(sig.firm)
  right = right .. xpara("SingleKeep", '<w:spacing w:before="240" w:after="0" w:line="276" w:lineRule="exact"/>', run(""))
  right = right .. xpara("SingleKeep", "", run("By: /s/ " .. plain(sig.signer)))
  right = right .. xpara("SingleKeep", "", run(plain(sig.signer)))
  right = right .. lines(sig.lines)
  return raw('<w:tbl><w:tblPr><w:tblW w:w="9000" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="3744"/><w:gridCol w:w="288"/><w:gridCol w:w="4968"/></w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="3744" w:type="dxa"/></w:tcPr>' .. xpara("SingleKeep", "", run("Dated: " .. plain(date))) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr>' .. xpara("SingleKeep", "") .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4968" w:type="dxa"/></w:tcPr>' .. right .. '</w:tc>'
    .. '</w:tr></w:tbl>')
end

-- the memorandum's headings, in order (the table of contents lists them; render.sh numbers them the same way)
local function memo_headings(blocks)
  local hs, after = {}, false
  for _, b in ipairs(blocks) do
    if is_marker(b, "[[MEMO]]") then after = true
    elseif after and b.t == "Header" then hs[#hs + 1] = b end
  end
  return hs
end

local function toc(headings)
  local out = {}
  out[#out + 1] = styled("TOCTitle", { pandoc.Para({ pandoc.Str("TABLE OF CONTENTS") }) })
  out[#out + 1] = styled("PageRight", { pandoc.Para({ pandoc.Str("Page") }) })
  for i, h in ipairs(headings) do
    local p = pandoc.Para(h.content)
    table.insert(p.content, pandoc.RawInline("openxml", '<w:r><w:tab/></w:r><w:r><w:t>@PG' .. i .. '@</w:t></w:r>'))
    out[#out + 1] = styled("TOCEntry" .. math.min(h.level, 2), { p })
  end
  return out
end

local function toa(meta)
  local out = {}
  out[#out + 1] = styled("TOAPage", { pandoc.Para({ pandoc.Str("TABLE OF AUTHORITIES") }) })
  out[#out + 1] = styled("PageRight", { pandoc.Para({ pandoc.Str("Page(s)") }) })
  for _, group in ipairs(meta.authorities or {}) do
    out[#out + 1] = styled("TOAGroup", { pandoc.Para({ pandoc.Str(plain(group.category)) }) })
    for _, e in ipairs(group.entries or {}) do
      local p = pandoc.Para(e.cite) -- the cite keeps its italics (*case names*)
      table.insert(p.content, pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>' .. run(plain(e.pages))))
      out[#out + 1] = styled("TOAEntry", { p })
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = {}
  for _, b in ipairs(cover(meta)) do blocks[#blocks + 1] = b end
  local headings = memo_headings(doc.blocks)
  local first = true
  for _, b in ipairs(doc.blocks) do
    if is_marker(b, "[[TOC]]") then
      blocks[#blocks + 1] = section_end("decimal") -- end of the cover and the notice (arabic from 1)
      for _, x in ipairs(toc(headings)) do blocks[#blocks + 1] = x end
    elseif is_marker(b, "[[TOA]]") then
      for _, x in ipairs(toa(meta)) do blocks[#blocks + 1] = x end
    elseif is_marker(b, "[[MEMO]]") then
      blocks[#blocks + 1] = section_end("lowerRoman") -- end of the tables (roman)
      blocks[#blocks + 1] = styled("MemoTitle", { pandoc.Para({ pandoc.Str(plain(meta.memo_title):upper()) }) })
    elseif b.t == "Para" then
      if first then
        blocks[#blocks + 1] = styled("NoticeFirst", { b })
      else
        blocks[#blocks + 1] = b
      end
      first = false
    elseif b.t == "OrderedList" then
      local start = b.start or 1
      for i, item in ipairs(b.content) do
        local p = item[1]
        table.insert(p.content, 1, pandoc.RawInline("openxml", run((start + i - 1) .. ".") .. '<w:r><w:tab/></w:r>'))
        blocks[#blocks + 1] = styled("Relief", { p })
      end
    elseif b.t == "HorizontalRule" then
      keep_last(blocks)
      blocks[#blocks + 1] = raw('<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/></w:pPr></w:p>') -- the signature starts on the next numbered line (typst on-grid)
      blocks[#blocks + 1] = signature(meta.signature, meta.date)
    else
      blocks[#blocks + 1] = b
    end
  end
  return pandoc.Pandoc(blocks)
end
