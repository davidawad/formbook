-- N.D. W. Va. motion with memorandum, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on
-- reference.docx. The counsel block, caption, negative notice, signature block and certificate of service are
-- built here as paragraphs and tables in the styles of reference.docx; they follow typst/wvnb-motion-brief.typ
-- (the reference for the form). The body keeps its markdown structure. Page numbers come from the footer.
-- Frontmatter values are printed as given; nothing in this file is case-specific.

local TW_IN = 1440 -- twips per inch
local SIG_IND = 4608 -- 3.2 in: the signature column (typst h(3.2in))

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return s
end

local function str(v)
  if v == nil then return nil end
  return pandoc.utils.stringify(v)
end

-- a YAML list of strings (MetaList of inlines) as a Lua array
local function list(v)
  local out = {}
  if v == nil then return out end
  if v.t == nil or v.t == "MetaList" then -- pandoc passes a YAML list as a plain table
    for _, x in ipairs(v) do out[#out + 1] = str(x) end
  else
    out[#out + 1] = str(v)
  end
  return out
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

-- one paragraph. opts: bold, keepNext, keepLines, pageBreakBefore, before, after, ind (twips), jc
local function para(style, text, opts)
  opts = opts or {}
  local ppr = ""
  if style then ppr = '<w:pStyle w:val="' .. style .. '"/>' end
  if opts.keepNext then ppr = ppr .. "<w:keepNext/>" end
  if opts.keepLines then ppr = ppr .. "<w:keepLines/>" end
  if opts.pageBreakBefore then ppr = ppr .. "<w:pageBreakBefore/>" end
  if opts.before or opts.after then
    ppr = ppr .. '<w:spacing'
    if opts.before then ppr = ppr .. ' w:before="' .. opts.before .. '"' end
    if opts.after then ppr = ppr .. ' w:after="' .. opts.after .. '"' end
    ppr = ppr .. "/>"
  end
  if opts.ind then ppr = ppr .. '<w:ind w:left="' .. opts.ind .. '"/>' end
  if opts.jc then ppr = ppr .. '<w:jc w:val="' .. opts.jc .. '"/>' end
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

local BOX = '<w:top w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
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

-- the caption (typst court-caption): court lines, the two-column caption box, the document title
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
  -- right column: chapter, case and judge, adversary; typst v(0.6em) gaps are the 144 twip spacing
  R[#R + 1] = para("Single", nil, { before = 144 })
  if m.chapter then
    R[#R + 1] = para("Single", "Chapter " .. str(m.chapter), { after = 144 })
  end
  R[#R + 1] = para("Single", "Case No. " .. str(m.case_number))
  if m.judge then R[#R + 1] = para("Single", "Judge " .. str(m.judge), { after = 144 }) end
  R[#R + 1] = para("Single", "Adv. Pro. No. " .. str(m.adversary_number))
  if m.motion_docket then R[#R + 1] = para("Single", "Motion Docket No. " .. str(m.motion_docket)) end
  out[#out + 1] = raw(table_xml({ 4608, 4752 }, {
    tc(4608,
      '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
        .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>',
      '<w:tcMar><w:left w:w="144" w:type="dxa"/><w:right w:w="216" w:type="dxa"/><w:bottom w:w="216" w:type="dxa"/></w:tcMar>',
      L),
    tc(4752, "", '<w:tcMar><w:left w:w="360" w:type="dxa"/><w:right w:w="144" w:type="dxa"/></w:tcMar>', R),
  }))
  out[#out + 1] = raw(para("CenteredBody", str(m.motion_title):upper(), { bold = true, before = 288, after = 144 }))
  return out
end

-- counsel block at the top left (typst counsel-block): single lines, then 1.2 em
local function counsel(m)
  local out = {}
  local lines = list(m.counsel)
  for i, line in ipairs(lines) do
    out[#out + 1] = raw(para("Single", line, { after = (i == #lines) and 288 or nil }))
  end
  return out
end

-- LBR 9013-1(c)(2)(B) negative notice in a box (typst negative-notice): only when the sample gives it
local function notice(m)
  if not m.notice then return {} end
  local paras = {
    para("Single", "NOTICE OF OPPORTUNITY TO OBJECT", { bold = true, after = 120 }),
    para("Single", str(m.notice.text)),
  }
  local cellmar = '<w:tcMar><w:top w:w="200" w:type="dxa"/><w:left w:w="200" w:type="dxa"/>'
    .. '<w:bottom w:w="200" w:type="dxa"/><w:right w:w="200" w:type="dxa"/></w:tcMar>'
  local box = '<w:tblBorders>' .. BOX
    .. '<w:left w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tblBorders>'
  return { raw(table_xml({ 9360 }, { tc(9360, "", cellmar, paras) }, box)), raw(gap(288)) }
end

-- signature block (typst signature-block, single lines; 3.2 in column; the parties lines are optional)
local function signature(m)
  local sig = m.signature
  local out = {}
  local parties = list(sig.parties)
  local lines = list(sig.lines)
  out[#out + 1] = raw(para("Single", m.date and ("Dated: " .. str(m.date)) or nil, { before = 288, after = 192, keepNext = true }))
  out[#out + 1] = raw(para("SigSingle", "Respectfully submitted,", { after = 192, keepNext = true }))
  for _, p in ipairs(parties) do out[#out + 1] = raw(para("SigSingle", p, { keepNext = true })) end
  out[#out + 1] = raw(para("SigSingle", "s/ " .. str(sig.signer), { bold = true, keepNext = true }))
  for i, l in ipairs(lines) do
    out[#out + 1] = raw(para("SigSingle", l, { keepNext = i < #lines }))
  end
  return out
end

-- certificate of service on its own page (typst certificate-of-service): the sentence as the sample gives it,
-- or built from date and method; parties only when the sample lists them; the signature in the 3.2 in column
local function certificate(m)
  local svc = m.service
  local sig = m.signature
  local out = {}
  out[#out + 1] = raw(para("CenteredBody", "CERTIFICATE OF SERVICE", { bold = true, pageBreakBefore = true, after = 192 }))
  if svc.text then
    out[#out + 1] = raw(para("Single", str(svc.text), { after = 192 }))
  else
    out[#out + 1] = raw(para("Single",
      "I certify that on " .. str(svc.date) .. ", I " .. str(svc.method) .. " the foregoing "
      .. str(m.motion_title) .. " and this certificate of service, which were served on the following parties:",
      { after = 192 }))
  end
  local parties = svc.parties or {}
  for i, p in ipairs(parties) do
    local ls = list(p.lines)
    local last_party = i == #parties
    if #ls == 0 then
      out[#out + 1] = raw(para("Single", str(p.name), { after = last_party and 192 or 144 }))
    else
      out[#out + 1] = raw(para("Single", str(p.name), { keepNext = true }))
      for j, l in ipairs(ls) do
        local last = j == #ls
        out[#out + 1] = raw(para("Single", l, { keepNext = not last, after = last and (last_party and 192 or 144) or nil }))
      end
    end
  end
  out[#out + 1] = raw(para("SigSingle", "s/ " .. str(sig.signer), { bold = true, keepNext = true }))
  local lines = list(sig.lines)
  for i, l in ipairs(lines) do
    out[#out + 1] = raw(para("SigSingle", l, { keepNext = i < #lines }))
  end
  return out
end

-- body headings: level 1 in capitals (typst upper(); the body text is kept as the author typed it)
local function fix_block(b)
  if b.t == "Header" and b.level == 1 then
    return b:walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
  end
  return b
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  local function add_all(xs) for _, x in ipairs(xs) do out[#out + 1] = x end end

  add_all(counsel(m))
  add_all(caption(m))
  add_all(notice(m))
  for _, b in ipairs(doc.blocks) do out[#out + 1] = fix_block(b) end
  add_all(signature(m))
  add_all(certificate(m))
  -- the frontmatter (title, date) is printed by the helpers above, not by pandoc's title block
  return pandoc.Pandoc(out)
end
