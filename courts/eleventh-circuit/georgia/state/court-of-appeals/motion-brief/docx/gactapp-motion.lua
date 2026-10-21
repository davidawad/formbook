-- gactapp-motion.lua (docx engine, motion types: motion-brief, petition-for-rehearing).
-- Adds what the typst template (typst/gactapp-motion-brief.typ, same form in gactapp-petition-for-rehearing.typ)
-- does around the markdown body, in Word-native form (docs/DOCX.md): the cover (court, a two-column caption with
-- a vertical rule, title), the body starting on the cover page as in the typst form, the certificate of word count,
-- the signature block and the certificate of service. One section; the footer PAGE field numbers every page
-- from 1, the cover included, as the typst template does.
-- Cover, certificate and signature text is plain (pandoc.utils.stringify); the body is pandoc's own conversion.

local BOLD = "<w:b /><w:bCs />"
local TEXT_WIDTH = 9360 -- twips: 8.5 in less two 1-in margins
local SIG_INDENT = 4680 -- 3.25 in

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function run(text, rpr)
  local rp = rpr and ("<w:rPr>" .. rpr .. "</w:rPr>") or ""
  return "<w:r>" .. rp .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

local function para(content, ppr)
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. content .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function str(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- Lines are exact, at the reference's pitches: single (240) is 20 pt, double (480) the typst body pitch of 32.3 pt.
-- An auto line in TeX Gyre Schola is taller than its type and would rise into the top margin at a page head.
local EXACT = { [240] = 400, [480] = 646 }
local function spacing(before, after, line)
  line = line or 240
  return string.format('<w:spacing w:before="%d" w:after="%d" w:line="%d" w:lineRule="exact" />', before, after, EXACT[line] or line)
end

-- Single-spaced paragraph, no first-line indent. left/right: twips; jc: alignment.
local function single(text, rpr, before, after, left, right, jc)
  local ind = string.format('<w:ind w:left="%d" w:right="%d" w:firstLine="0" />', left or 0, right or 0)
  local j = jc and ('<w:jc w:val="' .. jc .. '" />') or ""
  return raw(para(text and run(text, rpr) or "", spacing(before or 0, after or 0) .. ind .. j))
end

-- Double-spaced paragraph with the first-line indent (the Normal style carries both).
local function body_para(text, before)
  return raw(para(run(text), spacing(before or 0, 0, 480) .. '<w:ind w:firstLine="720" />'))
end

local function sectpr_final()
  return ""
end

local function cover(meta)
  local out = {}
  local function add(b) out[#out + 1] = b end
  add(single(str(meta.court):upper(), BOLD, 0, 0, 0, 0, "center"))
  add(single(nil, nil, 0, 240))
  -- caption: parties in the left cell (vertical rule on its right), case number in the right cell
  local left_w, gutter_w = 4183, 576
  local right_w = TEXT_WIDTH - left_w - gutter_w
  local left = {}
  for _, p in ipairs(meta.parties or {}) do
    left[#left + 1] = single(str(p.name), nil, 0, 0)
    left[#left + 1] = single(str(p.role), nil, 0, 0, 420)
  end
  local right = {}
  right[#right + 1] = single("Case No. " .. str(meta.case_number), nil, 0, 0)
  if meta.lower_court_case then
    right[#right + 1] = single(str(meta.lower_court_case), nil, 240, 0)
  end
  local function texts(list)
    local t = {}
    for i, b in ipairs(list) do t[i] = b.text end
    return t
  end
  local function cell(w, paras, extra)
    return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa" />' .. (extra or "") .. "</w:tcPr>" .. table.concat(texts(paras), "") .. "</w:tc>"
  end
  local tbl = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_WIDTH .. '" w:type="dxa" /><w:tblLayout w:type="fixed" />'
    .. '<w:tblBorders><w:top w:val="nil" /><w:left w:val="nil" /><w:bottom w:val="nil" /><w:right w:val="nil" /><w:insideH w:val="nil" /><w:insideV w:val="nil" /></w:tblBorders>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. left_w .. '" /><w:gridCol w:w="' .. gutter_w .. '" /><w:gridCol w:w="' .. right_w .. '" /></w:tblGrid>'
    .. "<w:tr>"
    .. cell(left_w, left, '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000" /></w:tcBorders><w:tcMar><w:right w:w="170" w:type="dxa" /></w:tcMar>')
    .. cell(gutter_w, { single(nil, nil, 0, 0) })
    .. cell(right_w, right)
    .. "</w:tr></w:tbl>"
  add(raw(tbl))
  add(single(nil, nil, 0, 0))
  add(single(nil, nil, 480, 0))
  -- title: centred, bold, inset to 85% of the text width
  local inset = math.floor(TEXT_WIDTH * 0.075)
  add(single(str(meta.title), BOLD, 0, 0, inset, inset, "center"))
  add(single(nil, nil, 480, 0))
  return out
end

local function word_count(meta)
  if not meta.word_count then return {} end
  return {
    raw(para(run("CERTIFICATE OF WORD COUNT", BOLD), "<w:keepNext />" .. spacing(240, 0) .. '<w:ind w:firstLine="0" />' .. '<w:jc w:val="center" />')),
    body_para("I certify that this motion contains " .. str(meta.word_count)
      .. " words, excluding the caption, the signature block, and this certificate, as counted by the word-processing software used to prepare it.", 240),
  }
end

local function signature(meta)
  local out = {}
  local sig = meta.signature
  if not sig then return out end
  out[#out + 1] = body_para("Respectfully submitted this " .. str(sig.date) .. ".", 240)
  out[#out + 1] = single(nil, nil, 240, 0)
  local function sline(text, rpr)
    out[#out + 1] = raw(para(text and run(text, rpr) or "", '<w:keepNext />' .. spacing(0, 0) .. '<w:ind w:left="' .. SIG_INDENT .. '" w:firstLine="0" />'))
  end
  for _, l in ipairs(sig.lines or {}) do sline(str(l)) end
  sline(nil)
  sline(str(sig.signer_line))
  for _, l in ipairs(sig.signer or {}) do sline(str(l)) end
  return out
end

local function service(meta)
  local svc = meta.service
  local sig = meta.signature
  if not svc then return {} end
  local out = {}
  out[#out + 1] = raw(para(run("CERTIFICATE OF SERVICE", BOLD), "<w:keepNext />" .. spacing(240, 0) .. '<w:ind w:firstLine="0" />' .. '<w:jc w:val="center" />'))
  out[#out + 1] = body_para("I certify that on " .. str(svc.date) .. ", I served a copy of this " .. str(svc.doc_type)
    .. " on " .. str(svc.served_on) .. " by " .. str(svc.method) .. ", addressed as follows:", 240)
  for _, l in ipairs(svc.address or {}) do out[#out + 1] = single(str(l), nil, 0, 0) end
  if sig and sig.signer_line then
    out[#out + 1] = raw(para("", '<w:keepNext />' .. spacing(0, 0) .. '<w:ind w:left="' .. SIG_INDENT .. '" w:firstLine="0" />'))
    out[#out + 1] = single(str(sig.signer_line), nil, 0, 0, SIG_INDENT)
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  doc.meta = pandoc.Meta({})
  local blocks = {}
  local function add_all(list)
    for _, b in ipairs(list) do blocks[#blocks + 1] = b end
  end
  add_all(cover(meta))
  add_all(doc.blocks)
  add_all(word_count(meta))
  add_all(signature(meta))
  add_all(service(meta))
  doc.blocks = blocks
  return doc
end
