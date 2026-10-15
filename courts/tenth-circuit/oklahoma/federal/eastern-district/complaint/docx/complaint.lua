-- Complaint, DOCX engine (docs/DOCX.md): the markdown contract (../README.md) -> Word, on reference.docx.
-- The form is that of ../typst/oked-complaint.typ: the court name, the caption (a borderless table: party
-- lines, a column of ")" marks, the case number and the legends), the title, the body with paragraph
-- numbers (Fed. R. Civ. P. 10(b)), lettered prayer items, and the signature block. Body paragraphs and
-- headings keep their pandoc styles from reference.docx. The "[unnumbered]" marker is removed.

local function xml(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function text_of(v)
  if v == nil then return nil end
  return pandoc.utils.stringify(v)
end

-- a run of text, optionally with run properties (xml)
local function wrun(text, rpr)
  local pr = ""
  if rpr and rpr ~= "" then pr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return "<w:r>" .. pr .. '<w:t xml:space="preserve">' .. xml(text) .. "</w:t></w:r>"
end

local function raw_para(ppr, runs)
  return pandoc.RawBlock("openxml", "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. runs .. "</w:p>")
end

-- single spacing of the caption rows: 13.8 pt, the typst single-pitch, so the ")" column lines up
local CAPTION_ROW = '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/>'
local SINGLE = '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>'
local SIG_LINE = '<w:keepNext/>' .. SINGLE

local function cell(width, paras)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>' .. paras .. "</w:tc>"
end

-- a borderless caption table: party column 3.5 in (5040), ")" column 0.3 in (432), right column 2.7 in (3888)
local function caption_table(rows_xml)
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid><w:gridCol w:w="5040"/><w:gridCol w:w="432"/>'
    .. '<w:gridCol w:w="3888"/></w:tblGrid>' .. rows_xml .. "</w:tbl>"
end

-- the caption rows, as typst's caption-rows(): each party's names (the first line numbered "(n)", LCvR 3.1),
-- a designation, a blank row between parties and the "v." between the sides
local function caption_rows(meta)
  local rows = {}
  local k = 0
  for si, key in ipairs({ "plaintiffs", "defendants" }) do
    if si > 1 then
      rows[#rows + 1] = { blank = true }
      rows[#rows + 1] = { vs = true }
      rows[#rows + 1] = { blank = true }
    end
    for pi, p in ipairs(meta.caption[key]) do
      if pi > 1 then rows[#rows + 1] = { blank = true } end
      k = k + 1
      for li, line in ipairs(p.names) do
        rows[#rows + 1] = { label = (li == 1) and ("(" .. k .. ")") or nil, text = text_of(line) }
      end
      if p.designation then rows[#rows + 1] = { desig = text_of(p.designation) } end
    end
  end
  return rows
end

local function cover(meta)
  local out = pandoc.List {}
  local court = meta.court
  for i, line in ipairs(court) do
    local last = (i == #court)
    out:insert(raw_para('<w:keepNext/>' .. SINGLE .. (last and '<w:spacing w:after="480"/>' or '') .. '<w:jc w:val="center"/>',
      wrun(string.upper(text_of(line)), "<w:b/><w:bCs/>")))
  end

  local rows = caption_rows(meta)
  local n = #rows
  -- the case number and the legends sit about the middle of the party column, as in the exemplar
  local r0 = math.max(0, math.floor(n / 2) - 1)
  local right = {}
  right[r0 + 1] = wrun("Case No. " .. text_of(meta.case_number))
  for i, l in ipairs(meta.legends or {}) do right[r0 + 3 + i] = wrun(text_of(l), "<w:b/><w:bCs/>") end

  local body = {}
  for i, r in ipairs(rows) do
    local left
    if r.blank then
      left = '<w:p><w:pPr>' .. CAPTION_ROW .. '</w:pPr></w:p>'
    elseif r.vs then
      left = '<w:p><w:pPr>' .. CAPTION_ROW .. '<w:ind w:left="1584"/></w:pPr>' .. wrun("v.") .. '</w:p>'
    elseif r.desig then
      left = '<w:p><w:pPr>' .. CAPTION_ROW .. '<w:ind w:left="2592"/></w:pPr>' .. wrun(r.desig) .. '</w:p>'
    elseif r.label then
      left = '<w:p><w:pPr>' .. CAPTION_ROW .. '<w:ind w:left="720" w:hanging="720"/></w:pPr>'
        .. wrun(r.label) .. '<w:r><w:tab/></w:r>' .. wrun(r.text) .. '</w:p>'
    else
      left = '<w:p><w:pPr>' .. CAPTION_ROW .. '<w:ind w:left="720"/></w:pPr>' .. wrun(r.text) .. '</w:p>'
    end
    local paren = '<w:p><w:pPr>' .. CAPTION_ROW .. '</w:pPr>' .. wrun(")") .. '</w:p>'
    local rt = '<w:p><w:pPr>' .. CAPTION_ROW .. '</w:pPr>' .. (right[i] or "") .. '</w:p>'
    body[#body + 1] = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="276" w:hRule="exact"/></w:trPr>'
      .. cell(5040, left) .. cell(432, paren) .. cell(3888, rt) .. "</w:tr>"
  end
  out:insert(pandoc.RawBlock("openxml", caption_table(table.concat(body))))

  out:insert(raw_para('<w:keepNext/><w:spacing w:before="480" w:after="240" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/>',
    wrun(string.upper(text_of(meta.title)), "<w:b/><w:bCs/>")))
  return out
end

-- a paragraph number or a letter, then a tab to 1 in (typst: the number in the first half inch)
local function labelled(label, content)
  local out = pandoc.List { pandoc.RawInline("openxml", wrun(label)), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
  for _, x in ipairs(content) do out:insert(x) end
  return pandoc.Para(out)
end

local function strip_marker(content, marker)
  if content[1] and content[1].t == "Str" and content[1].text == marker then
    local rest = pandoc.List(content)
    rest:remove(1)
    if rest[1] and rest[1].t == "Space" then rest:remove(1) end
    return true, rest
  end
  return false, content
end

local function signature(meta)
  local out = pandoc.List {}
  local sigs = meta.signature
  local lines = {}
  -- each entry: { text, bold, before }
  for i, s in ipairs(sigs) do
    if i > 1 then
      lines[#lines + 1] = { "and", false, 240 }
    end
    for j, f in ipairs(s.firm) do lines[#lines + 1] = { text_of(f), true, (j == 1) and 240 or 0 } end
    lines[#lines + 1] = { "By: /s/ " .. text_of(s.signer), false, 240 }
    for _, l in ipairs(s.lines) do lines[#lines + 1] = { text_of(l), false, 0 } end
  end
  if meta.attorneys_for then lines[#lines + 1] = { text_of(meta.attorneys_for), false, 240 } end

  out:insert(raw_para('<w:keepNext/><w:spacing w:before="480" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="4608"/>',
    wrun("Respectfully submitted,")))
  for i, l in ipairs(lines) do
    local keep = (i < #lines) and "<w:keepNext/>" or ""
    out:insert(raw_para(keep .. '<w:spacing w:before="' .. l[3] .. '" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="4608"/>',
      wrun(l[1], l[2] and "<w:b/><w:bCs/>" or nil)))
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local out = pandoc.List {}
  out:extend(cover(meta))

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" or b.t == "Plain" then
      local unnumbered, content = strip_marker(b.content, "[unnumbered]")
      if unnumbered then
        out:insert(pandoc.Para(content))
      else
        n = n + 1
        out:insert(labelled(n .. ".", content))
      end
    elseif b.t == "BulletList" then
      -- prayer items: lettered (a), (b), ... as in the exemplar's prayers
      for i, item in ipairs(b.content) do
        local first = item[1]
        local content = (first and (first.t == "Para" or first.t == "Plain")) and first.content or pandoc.Inlines {}
        out:insert(labelled("(" .. string.char(string.byte("a") + i - 1) .. ").", content))
      end
    else
      out:insert(b)
    end
  end

  out:extend(signature(meta))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
