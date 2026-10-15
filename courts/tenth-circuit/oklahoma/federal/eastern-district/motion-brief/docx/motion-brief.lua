-- Motion to dismiss with brief in support, DOCX engine (docs/DOCX.md): the markdown contract (../README.md)
-- -> Word, on reference.docx. The form is that of ../typst/oked-motion-brief.typ: the court name, a boxed caption
-- (a table: the party box, and the case number and judge at the right), the title, the body (paragraphs numbered
-- only where marked "[numbered]"), headings labelled "I." and "A." by the filter, the date and the signature
-- block, and the certificate of service on a new page. Footnotes are pandoc's. The "[numbered]" marker is removed.

local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX" }

local function xml(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function text_of(v)
  if v == nil then return nil end
  return pandoc.utils.stringify(v)
end

local function wrun(text, rpr)
  local pr = ""
  if rpr and rpr ~= "" then pr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return "<w:r>" .. pr .. '<w:t xml:space="preserve">' .. xml(text) .. "</w:t></w:r>"
end

local function raw_para(ppr, runs)
  return pandoc.RawBlock("openxml", "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. runs .. "</w:p>")
end

local CAPTION_ROW = '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/>'
local SINGLE = '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>'

local function bar(v, side)
  return '<w:' .. side .. ' w:val="' .. v .. '" w:sz="6" w:space="0" w:color="000000"/>'
end

-- one row of the caption table; the party box is a border around the left cell (top on the first row,
-- bottom on the last)
local function caption_table(rows_xml)
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr><w:tblGrid><w:gridCol w:w="5040"/><w:gridCol w:w="432"/>'
    .. '<w:gridCol w:w="3888"/></w:tblGrid>' .. rows_xml .. "</w:tbl>"
end

local function cell(width, paras, borders)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (borders or "") .. "</w:tcPr>" .. paras .. "</w:tc>"
end

-- the party box rows, as typst's caption-box(): names, designations (italic, indented 1.9 in), a blank row,
-- "v." (indented 1.1 in), a blank row, the defendants
local function box_rows(meta)
  local rows = {}
  for _, p in ipairs(meta.caption.plaintiffs) do
    for _, l in ipairs(p.names) do rows[#rows + 1] = { text = text_of(l) } end
    if p.designation then rows[#rows + 1] = { desig = text_of(p.designation) } end
  end
  rows[#rows + 1] = { blank = true }
  rows[#rows + 1] = { vs = true }
  rows[#rows + 1] = { blank = true }
  for _, p in ipairs(meta.caption.defendants) do
    for _, l in ipairs(p.names) do rows[#rows + 1] = { text = text_of(l) } end
    if p.designation then rows[#rows + 1] = { desig = text_of(p.designation) } end
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

  local rows = box_rows(meta)
  local n = #rows
  local right = {}
  right[3] = wrun("Case No. " .. text_of(meta.case_number))          -- two rows down, as typst's v(2 rows)
  if meta.judge then right[4] = wrun(text_of(meta.judge)) end

  local body = {}
  for i, r in ipairs(rows) do
    local top = (i == 1) and bar("single", "top") or bar("nil", "top")
    local bottom = (i == n) and bar("single", "bottom") or bar("nil", "bottom")
    local borders = "<w:tcBorders>" .. top .. bar("single", "left") .. bottom .. bar("single", "right") .. "</w:tcBorders>"
    local left
    if r.blank then
      left = '<w:p><w:pPr>' .. CAPTION_ROW .. '<w:ind w:left="144" w:right="144"/></w:pPr></w:p>'
    elseif r.vs then
      left = '<w:p><w:pPr>' .. CAPTION_ROW .. '<w:ind w:left="1584" w:right="144"/></w:pPr>' .. wrun("v.") .. '</w:p>'
    elseif r.desig then
      left = '<w:p><w:pPr>' .. CAPTION_ROW .. '<w:ind w:left="2736" w:right="144"/></w:pPr>' .. wrun(r.desig, "<w:i/><w:iCs/>") .. '</w:p>'
    else
      left = '<w:p><w:pPr>' .. CAPTION_ROW .. '<w:ind w:left="144" w:right="144"/></w:pPr>' .. wrun(r.text) .. '</w:p>'
    end
    local gap = '<w:p><w:pPr>' .. CAPTION_ROW .. '</w:pPr></w:p>'
    local rt = '<w:p><w:pPr>' .. CAPTION_ROW .. '</w:pPr>' .. (right[i] or "") .. '</w:p>'
    body[#body + 1] = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="276" w:hRule="exact"/></w:trPr>'
      .. cell(5040, left, borders) .. cell(432, gap) .. cell(3888, rt) .. "</w:tr>"
  end
  out:insert(pandoc.RawBlock("openxml", caption_table(table.concat(body))))

  out:insert(raw_para('<w:keepNext/><w:spacing w:before="480" w:after="240" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/>',
    wrun(string.upper(text_of(meta.brief_title)), "<w:b/><w:bCs/>")))
  return out
end

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

-- the signature block (typst's signature-block): "Date:" at the left, "Respectfully submitted," and the
-- signer's lines at 3 in. Every line but the last is kept with the next, so the block stays together.
local function signature(sig, date, attorneys)
  local out = pandoc.List {}
  local lines = {}
  lines[#lines + 1] = { "/s/ " .. text_of(sig.signer), 240 }
  for _, l in ipairs(sig.lines) do lines[#lines + 1] = { text_of(l), 0 } end
  if attorneys then lines[#lines + 1] = { text_of(attorneys), 240 } end

  local first
  if date then
    first = raw_para('<w:keepNext/><w:tabs><w:tab w:val="left" w:pos="4320"/></w:tabs>'
      .. '<w:spacing w:before="480" w:after="0" w:line="240" w:lineRule="auto"/>',
      wrun("Date: " .. text_of(date)) .. "<w:r><w:tab/></w:r>" .. wrun("Respectfully submitted,"))
  else
    first = raw_para('<w:keepNext/><w:spacing w:before="480" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="4320"/>',
      wrun("Respectfully submitted,"))
  end
  out:insert(first)
  for i, l in ipairs(lines) do
    local keep = (i < #lines) and "<w:keepNext/>" or ""
    out:insert(raw_para(keep .. '<w:spacing w:before="' .. l[2] .. '" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="4320"/>',
      wrun(l[1])))
  end
  return out
end

-- the last paragraph before the signature is kept with it (typst keeps the conclusion with the signature)
local function keep_with_next(out)
  local last = out[#out]
  if last and last.t == "Para" then
    out[#out] = pandoc.Div({ last }, pandoc.Attr("", {}, { ["custom-style"] = "KeepNext" }))
  end
end

function Pandoc(doc)
  local meta = doc.meta
  local out = pandoc.List {}
  out:extend(cover(meta))

  local n, h2, h3 = 0, 0, 0
  local in_cert = false
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and text_of(b) == "CERTIFICATE OF SERVICE" then
      -- the brief's signature, then the certificate on a new page with its own signature
      keep_with_next(out)
      out:extend(signature(meta.signature, meta.date, meta.attorneys_for))
      out:insert(pandoc.Div({ pandoc.Para({ pandoc.Str("CERTIFICATE OF SERVICE") }) },
        pandoc.Attr("", {}, { ["custom-style"] = "CertificateTitle" })))
      in_cert = true
    elseif b.t == "Header" and b.level == 2 then
      h2 = h2 + 1
      h3 = 0
      local content = pandoc.List { pandoc.RawInline("openxml", wrun(ROMAN[h2] .. ".")), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
      for _, x in ipairs(b.content) do content:insert(x) end
      out:insert(pandoc.Header(2, content))
    elseif b.t == "Header" and b.level == 3 then
      h3 = h3 + 1
      local content = pandoc.List { pandoc.RawInline("openxml", wrun(string.char(64 + h3) .. ".")), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
      for _, x in ipairs(b.content) do content:insert(x) end
      out:insert(pandoc.Header(3, content))
    elseif b.t == "Para" or b.t == "Plain" then
      local numbered, content = strip_marker(b.content, "[numbered]")
      if numbered then
        n = n + 1
        out:insert(labelled(n .. ".", content))
      else
        out:insert(pandoc.Para(content))
      end
    else
      out:insert(b)
    end
  end

  if in_cert then
    if meta.certificate then
      out:extend(signature(meta.certificate, nil, meta.certificate.attorneys_for))
    end
  else
    keep_with_next(out)
    out:extend(signature(meta.signature, meta.date, meta.attorneys_for))
  end
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
