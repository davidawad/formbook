-- N.D. W. Va. adversary complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on
-- reference.docx. The caption, signature grid and the page break before the part after the signature are built
-- here as paragraphs and tables in the styles of reference.docx; they follow typst/wvnb-adversary-complaint.typ
-- (the reference for the form). Numbered paragraphs (FRCP 10(b)) are numbered once across the whole complaint.
-- Frontmatter values are printed as given; nothing in this file is case-specific.

-- an attachment: a level-2 heading "Schedule ..." starts the part that follows the signature (on its own page)
local function starts_attachment(b)
  return b.t == "Header" and b.level == 2 and pandoc.utils.stringify(b):match("^Schedule") ~= nil
end

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return s
end

local function str(v)
  if v == nil then return nil end
  return pandoc.utils.stringify(v)
end

-- a YAML list of strings (pandoc passes a YAML list as a plain table) as a Lua array
local function list(v)
  local out = {}
  if v == nil then return out end
  if v.t == nil or v.t == "MetaList" then
    for _, x in ipairs(v) do out[#out + 1] = str(x) end
  else
    out[#out + 1] = str(v)
  end
  return out
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

-- one paragraph. opts: bold, keepNext, keepLines, pageBreakBefore, before, after, ind (twips)
local function para(style, text, opts)
  opts = opts or {}
  local ppr = ""
  if style then ppr = '<w:pStyle w:val="' .. style .. '"/>' end
  if opts.keepNext then ppr = ppr .. "<w:keepNext/>" end
  if opts.keepLines then ppr = ppr .. "<w:keepLines/>" end
  if opts.pageBreakBefore then ppr = ppr .. "<w:pageBreakBefore/>" end
  if opts.before or opts.after then
    ppr = ppr .. "<w:spacing"
    if opts.before then ppr = ppr .. ' w:before="' .. opts.before .. '"' end
    if opts.after then ppr = ppr .. ' w:after="' .. opts.after .. '"' end
    ppr = ppr .. "/>"
  end
  if opts.ind then ppr = ppr .. '<w:ind w:left="' .. opts.ind .. '"/>' end
  local body = ""
  if text and text ~= "" then
    local rpr = opts.bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
    body = "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
  end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. body .. "</w:p>"
end

-- an empty paragraph of a fixed height (typst v(...) between blocks)
local function gap(twips)
  return '<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="0" w:after="0" w:line="' .. twips
    .. '" w:lineRule="exact"/></w:pPr></w:p>'
end

local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function table_xml(widths, cells, borders)
  local total, grid = 0, ""
  for _, w in ipairs(widths) do
    total = total + w
    grid = grid .. '<w:gridCol w:w="' .. w .. '"/>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. (borders or NOBORDER)
    .. '<w:tblLayout w:type="fixed"/><w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. grid
    .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. "</w:tr></w:tbl>"
end

local function tc(width, tcpr_extra, mar, paras)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (tcpr_extra or "") .. (mar or "")
    .. "</w:tcPr>" .. table.concat(paras) .. "</w:tc>"
end

-- the caption (typst court-caption): court lines, the two-column caption box, the complaint title
local function caption(m)
  local out = {}
  local court = list(m.court)
  for i, line in ipairs(court) do
    out[#out + 1] = raw(para("Centered", line:upper(), { after = (i == #court) and 288 or 72 }))
  end
  local L, R = {}, {}
  if m.debtor then
    L[#L + 1] = para("Single", "In re: " .. str(m.debtor.name) .. ",")
    L[#L + 1] = para("Single", "Debtor.", { ind = 576, after = 192 })
  end
  local sides = m.caption or {}
  for i, side in ipairs(sides) do
    for _, n in ipairs(list(side.names)) do L[#L + 1] = para("Single", n) end
    L[#L + 1] = para("Single", str(side.designation), { ind = 144, after = (i == 1) and 192 or 144 })
    if i == 1 then
      L[#L + 1] = para("Single", "v.", { ind = 2160, after = 192 })
    end
  end
  R[#R + 1] = para("Single", nil, { before = 144 })
  R[#R + 1] = para("Single", "Chapter " .. str(m.chapter), { after = 144 })
  R[#R + 1] = para("Single", "Case No. " .. str(m.case_number))
  if m.judge then R[#R + 1] = para("Single", "Judge " .. str(m.judge), { after = 144 }) end
  R[#R + 1] = para("Single", "Adv. Pro. No. " .. str(m.adversary_number))
  if m.adversary_title then R[#R + 1] = para("Single", str(m.adversary_title)) end
  out[#out + 1] = raw(gap(288))
  out[#out + 1] = raw(table_xml({ 4608, 4752 }, {
    tc(4608,
      '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
        .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>',
      '<w:tcMar><w:left w:w="144" w:type="dxa"/><w:right w:w="216" w:type="dxa"/><w:bottom w:w="216" w:type="dxa"/></w:tcMar>',
      L),
    tc(4752, "", '<w:tcMar><w:left w:w="360" w:type="dxa"/><w:right w:w="144" w:type="dxa"/></w:tcMar>', R),
  }))
  out[#out + 1] = raw(para("CenteredBody", str(m.complaint_title):upper(), { bold = true, before = 288, after = 144 }))
  return out
end

-- counsel block at the top left, only when the sample gives one (typst counsel-block)
local function counsel(m)
  local out = {}
  local lines = list(m.counsel)
  for i, line in ipairs(lines) do
    out[#out + 1] = raw(para("Single", line, { after = (i == #lines) and 288 or nil }))
  end
  return out
end

-- signature (typst signature-block): "Dated" at left, the signer in the 3.2 in right column, single lines
local function signature(m)
  local sig = m.signature
  local lines = list(sig.lines)
  local right = {
    para("Single", "Respectfully submitted,", { after = 192 }),
    para("Single", "s/ " .. str(sig.signer), { bold = true }),
  }
  for _, l in ipairs(lines) do right[#right + 1] = para("Single", l) end
  return {
    raw(gap(288)),
    raw(table_xml({ 4608, 4752 }, {
      tc(4608, "", "", { para("Single", m.date and ("Dated: " .. str(m.date)) or "") }),
      tc(4752, "", "", right),
    })),
  }
end

-- body headings: level 1 in capitals (typst upper(); the body text is kept as the author typed it)
local function fix_header(b)
  if b.t == "Header" and b.level == 1 then
    return b:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
  end
  return b
end

-- numbered paragraphs (typst: the number at the first-line indent, the text after it, wrapping to the margin)
local function numbered(items, counter)
  local out = {}
  for _, item in ipairs(items) do
    counter.n = counter.n + 1
    local first = item[1]
    local inl = {}
    if first and first.t == "Para" then
      inl = first.content
      table.insert(inl, 1, pandoc.Str(tostring(counter.n) .. "."))
      table.insert(inl, 2, pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>"))
      out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered" }))
      for k = 2, #item do out[#out + 1] = item[k] end
    else
      out[#out + 1] = pandoc.Div(item, pandoc.Attr("", {}, { ["custom-style"] = "Numbered" }))
    end
  end
  return out
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  local counter = { n = 0 }
  for _, x in ipairs(counsel(m)) do out[#out + 1] = x end
  for _, x in ipairs(caption(m)) do out[#out + 1] = x end

  -- the body, with the numbered paragraphs; the marker splits off the part after the signature
  local body, tail = {}, nil
  for _, b in ipairs(doc.blocks) do
    if not tail and starts_attachment(b) then
      tail = {}
      tail[#tail + 1] = fix_header(b)
    elseif b.t == "OrderedList" then
      for _, x in ipairs(numbered(b.content, counter)) do
        if tail then tail[#tail + 1] = x else body[#body + 1] = x end
      end
    else
      if tail then tail[#tail + 1] = fix_header(b) else body[#body + 1] = fix_header(b) end
    end
  end
  for _, x in ipairs(body) do out[#out + 1] = x end
  for _, x in ipairs(signature(m)) do out[#out + 1] = x end
  if tail then
    -- the part after the signature starts on a new page (an empty paragraph with pageBreakBefore)
    out[#out + 1] = raw('<w:p><w:pPr><w:pageBreakBefore/><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr></w:p>')
    for _, x in ipairs(tail) do out[#out + 1] = x end
  end
  return pandoc.Pandoc(out)
end
