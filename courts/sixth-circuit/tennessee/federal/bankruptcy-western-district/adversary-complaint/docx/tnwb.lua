-- tnwb DOCX engine (docs/DOCX.md): the markdown contract (README.md, "Markdown contract") -> a Word
-- document on docx/reference.docx. Mirrors typst/tnwb-*.typ: court heading, two-column caption with a
-- section-mark column, title, body (headings, transfer tables, quotations, footnotes), signature block
-- kept with the last body paragraph, and (motion) the certificate of service. Styles: docx/build-reference.sh.
-- Only Word-native features: paragraph styles, tables, footnotes, a PAGE footer. No forced page breaks.

local CFG = { numbered = true, closing_gap = 180 }

local function esc(x)
  return (x:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function s(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata list (or one value) as a Lua list of strings
local function L(v)
  local out = {}
  if v == nil then return out end
  if v.t == nil or v.t == "MetaList" then
    for _, x in ipairs(v) do out[#out + 1] = s(x) end
  else
    out[#out + 1] = s(v)
  end
  return out
end

-- a run with its hyphens as non-breaking hyphens (case and adversary numbers stay on one line)
local function runs_nb(text)
  local pieces, start = {}, 1
  while true do
    local i = text:find("-", start, true)
    if not i then
      pieces[#pieces + 1] = text:sub(start)
      break
    end
    pieces[#pieces + 1] = text:sub(start, i - 1)
    start = i + 1
  end
  local x = {}
  for k, p in ipairs(pieces) do
    if k > 1 then x[#x + 1] = "<w:r><w:noBreakHyphen/></w:r>" end
    x[#x + 1] = '<w:r><w:t xml:space="preserve">' .. esc(p) .. "</w:t></w:r>"
  end
  return table.concat(x)
end

local function run(text, bold, italic)
  local rpr = ""
  if bold or italic then
    rpr = "<w:rPr>" .. (bold and "<w:b/>" or "") .. (italic and "<w:i/>" or "") .. "</w:rPr>"
  end
  return "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

-- one raw paragraph: style id, then pPr children in schema order (keepNext, pBdr, spacing, ind), then runs
local function para(runs, style, ppr)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "")
    .. "</w:pPr>" .. (runs or "") .. "</w:p>")
end

local function para_xml(runs, style, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>" .. (runs or "") .. "</w:p>"
end

-- a borderless table; widths in twips; rows are lists of cell paragraph XML strings
local function plain_table(widths, rows, cant_split)
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  local x = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblBorders>' }
  for _, side in ipairs({ "top", "left", "bottom", "right", "insideH", "insideV" }) do
    x[#x + 1] = '<w:' .. side .. ' w:val="nil"/>'
  end
  x[#x + 1] = '</w:tblBorders><w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" '
    .. 'w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr><w:tblGrid>'
  for _, w in ipairs(widths) do x[#x + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  x[#x + 1] = "</w:tblGrid>"
  for _, r in ipairs(rows) do
    x[#x + 1] = cant_split and "<w:tr><w:trPr><w:cantSplit/></w:trPr>" or "<w:tr>"
    for j, cell in ipairs(r) do
      x[#x + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[j] .. '" w:type="dxa"/></w:tcPr>' .. cell .. "</w:tc>"
    end
    x[#x + 1] = "</w:tr>"
  end
  x[#x + 1] = "</w:tbl>"
  return pandoc.RawBlock("openxml", table.concat(x))
end

-- caption (FRBP 7010, Official Form 416 contents): 6.5 in text width = 9360 twips
local CAP = { 4795, 576, 3989 }

local function caption(meta)
  local debtor, chapter = L(meta.debtor), L(meta.chapter)
  local plaintiffs, defendants = L(meta.plaintiffs), L(meta.defendants)
  local dl = { "IN RE:", "" }
  for _, x in ipairs(debtor) do dl[#dl + 1] = x end
  dl[#dl + 1] = ""
  dl[#dl + 1] = "DEBTOR."
  local dr = { "CASE NO.: " .. s(meta.case_number), "" }
  for _, x in ipairs(chapter) do dr[#dr + 1] = x end
  local al = {}
  for _, x in ipairs(plaintiffs) do al[#al + 1] = x end
  for _, x in ipairs({ "Plaintiff,", "", "vs.", "" }) do al[#al + 1] = x end
  for _, x in ipairs(defendants) do al[#al + 1] = x end
  al[#al + 1] = "Defendants."
  local ar = { "ADVERSARY PROCEEDING NO.: " .. s(meta.adversary_number) }

  local rows = {}
  local function row(l, r)
    rows[#rows + 1] = {
      para_xml(run(l), "Single"),
      para_xml(run("§"), "Centered"),
      para_xml(runs_nb(r), "Single"),
    }
  end
  for i = 1, math.max(#dl, #dr) do row(dl[i] or "", dr[i] or "") end
  row("", "")
  for i = 1, #al do row(al[i], ar[i] or "") end
  return plain_table(CAP, rows, true)
end

-- transfer tables (markdown pipe tables): centered, auto-width, ruled (style "Table"); amounts right-aligned
-- (typst: align (left, right)). Written as raw OOXML so the width is the content's, not the page's.
local function table_rows(tbl)
  local head, body = {}, {}
  if tbl.head and tbl.head.rows then for _, r in ipairs(tbl.head.rows) do head[#head + 1] = r end end
  for _, bd in ipairs(tbl.bodies) do
    if bd.head then for _, r in ipairs(bd.head) do head[#head + 1] = r end end
    for _, r in ipairs(bd.body) do body[#body + 1] = r end
  end
  return head, body
end

local function transfer_table(tbl)
  local head, body = table_rows(tbl)
  local all = {}
  for _, r in ipairs(head) do all[#all + 1] = r end
  for _, r in ipairs(body) do all[#all + 1] = r end
  local ncol = #tbl.colspecs
  local widths = {}
  for j = 1, ncol do
    local w = 0
    for _, r in ipairs(all) do
      local c = r.cells[j]
      if c then w = math.max(w, #s(c.contents)) end
    end
    widths[j] = math.max(900, w * 118 + 320)
  end
  local x = { '<w:tbl><w:tblPr><w:tblStyle w:val="Table"/><w:tblW w:w="0" w:type="auto"/><w:jc w:val="center"/>'
    .. '<w:tblLayout w:type="autofit"/><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr><w:tblGrid>' }
  for j = 1, ncol do x[#x + 1] = '<w:gridCol w:w="' .. widths[j] .. '"/>' end
  x[#x + 1] = "</w:tblGrid>"
  local function row(r, is_head)
    x[#x + 1] = "<w:tr>" .. (is_head and "<w:trPr><w:tblHeader/></w:trPr>" or "")
    for j = 1, ncol do
      local c = r.cells[j]
      local text = c and s(c.contents) or ""
      local jc = j == ncol and '<w:jc w:val="right"/>' or ""
      x[#x + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[j] .. '" w:type="dxa"/></w:tcPr>'
        .. '<w:p><w:pPr><w:pStyle w:val="Compact"/>' .. jc .. "</w:pPr>" .. (text ~= "" and run(text) or "") .. "</w:p></w:tc>"
    end
    x[#x + 1] = "</w:tr>"
  end
  for _, r in ipairs(head) do row(r, true) end
  for _, r in ipairs(body) do row(r, false) end
  x[#x + 1] = "</w:tbl>"
  return pandoc.RawBlock("openxml", table.concat(x))
end

-- a blank line of the body's leading (typst: the block below a table)
local function gap()
  return para("", "Compact", '<w:spacing w:before="0" w:after="0" w:line="324" w:lineRule="exact"/>')
end

-- Lua helpers for body blocks
local function tab()
  return pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
end

local function upper_inlines(inl)
  local p = pandoc.Para(inl):walk({
    Str = function(x) return pandoc.Str(x.text:upper()) end,
  })
  return p.content
end

local function letter(i)
  return string.char(64 + i) .. "."
end

local function signature(sig)
  local out = {}
  local function last_kept(runs, style, extra)
    out[#out + 1] = para(runs, style, "<w:keepNext/>" .. (extra or ""))
  end
  out[#out + 1] = para(run(s(sig.closing)), "Single",
    '<w:keepNext/><w:spacing w:before="0" w:after="' .. CFG.closing_gap .. '" w:line="300" w:lineRule="exact"/><w:ind w:firstLine="720"/>')
  last_kept(run(s(sig.firm), true), "Signature")
  last_kept(run("/s/ " .. s(sig.signer)), "Signature")
  last_kept(run(s(sig.name_line ~= nil and sig.name_line or sig.signer)), "Signature")
  for _, line in ipairs(L(sig.lines)) do last_kept(run(line), "Signature") end
  out[#out + 1] = para(run(s(sig.role), false, true), "Signature")
  return out
end

-- certificate of service (motion): heading, the exemplar's wording, parties in two columns, /s/ signer
local function certificate(meta)
  local svc, sig = meta.service, meta.signature
  local out = {}
  out[#out + 1] = para(run("CERTIFICATE OF SERVICE", true), "CourtHeading1")
  out[#out + 1] = para(run("I hereby certify that on the " .. s(svc.date)
    .. ", the foregoing document has been served by electronic means via the Court’s electronic filing system, unless otherwise indicated below:"),
    "BodyKeepNext", '<w:spacing w:after="300"/>')
  local parties = {}
  if svc.parties then
    for _, p in ipairs(svc.parties) do parties[#parties + 1] = L(p) end
  end
  local rows = {}
  for i = 1, #parties, 2 do
    local left, right = parties[i], parties[i + 1]
    local function cell(lines)
      local ps = {}
      if lines == nil then return para_xml("", "Single") end
      for j, line in ipairs(lines) do
        local ppr = j == #lines and '<w:spacing w:before="0" w:after="320" w:line="300" w:lineRule="exact"/>' or ""
        ps[#ps + 1] = para_xml(run(line), "Single", ppr)
      end
      return table.concat(ps)
    end
    rows[#rows + 1] = { cell(left), para_xml("", "Single"), cell(right) }
  end
  out[#out + 1] = plain_table({ 4464, 432, 4464 }, rows, false)
  out[#out + 1] = para(run("/s/ " .. s(sig.signer)), "Signature", '<w:spacing w:before="160" w:after="0"/>')
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}

  -- court heading (single spaced, centered); the last line leaves the double-space gap below
  local heads = { "UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF TENNESSEE" }
  if meta.division then heads[#heads + 1] = s(meta.division):upper() end
  for i, h in ipairs(heads) do
    local ppr = i == #heads and '<w:spacing w:before="0" w:after="500" w:line="300" w:lineRule="exact"/>' or ""
    out[#out + 1] = para(run(h, true), "Centered", ppr)
  end
  out[#out + 1] = caption(meta)
  -- rule under the caption (typst: line(length: 100%))
  out[#out + 1] = para("", "Single", '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr><w:spacing w:before="144" w:after="0" w:line="20" w:lineRule="exact"/>')
  -- title: centered, bold, capitals
  out[#out + 1] = para(run(s(meta.title):upper(), true), "CourtHeading1")

  -- body
  local blocks = doc.blocks
  local n, first = 0, true
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    if b.t == "Header" then
      local style = b.level == 1 and "Court Heading 1" or (b.level == 2 and "Court Heading 2" or "Court Heading 3")
      local inl = b.level == 1 and upper_inlines(b.content) or b.content
      out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
    elseif b.t == "Para" then
      local txt = s(b)
      local unnumbered = first or txt:match("^WHEREFORE") or txt:match("^%[")
      first = false
      if CFG.numbered and not unnumbered then
        n = n + 1
        local inl = pandoc.List({ pandoc.Str(n .. "."), tab() })
        inl:extend(b.content)
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = last and "Allegation Last" or "Allegation" }))
      elseif last then
        out[#out + 1] = pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Body Keep Next" }))
      else
        out[#out + 1] = b
      end
    elseif b.t == "Table" then
      out[#out + 1] = gap()
      out[#out + 1] = transfer_table(b)
      out[#out + 1] = gap()
    elseif b.t == "BulletList" then
      for k, item in ipairs(b.content) do
        local inl = pandoc.List({ pandoc.Str(letter(k)), tab() })
        for _, blk in ipairs(item) do
          if blk.t == "Plain" or blk.t == "Para" then inl:extend(blk.content) end
        end
        local style = (last and k == #b.content) and "Prayer Last" or "Prayer"
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
      end
    else
      out[#out + 1] = b
    end
  end

  -- the signature block (LBR 1001-3(h)) follows the last body block, kept with it
  if meta.signature then
    for _, x in ipairs(signature(meta.signature)) do out[#out + 1] = x end
  end
  if meta.service then
    for _, x in ipairs(certificate(meta)) do out[#out + 1] = x end
  end
  return pandoc.Pandoc(out, {})
end
