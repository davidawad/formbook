-- nced-complaint.lua (docx engine): what the Word output adds to pandoc's conversion, in the form of the typst template
-- (typst/nced-complaint.typ) and docs/DOCX.md:
--   * the cover (court and division, "No." line, caption with the ")" column, title block): raw WordprocessingML, because
--     the caption is a borderless table with a column of ")" marks, which markdown cannot write;
--   * the signature block, single-spaced, at 3 in from the left margin;
--   * allegations numbered 1, 2, ... (Fed. R. Civ. P. 10(b)): the number, then a tab, at the 0.5 in first-line indent;
--     headings, lists and the WHEREFORE clause are not numbered;
--   * the prayer's list lettered A., B., ... (the template's enum numbering) with a hanging indent.
-- All case-specific text comes from the sample's frontmatter, never from this file.

local function xml(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- One WordprocessingML paragraph, as a string. Child elements in schema order (keepNext, pageBreakBefore, spacing,
-- ind, jc). opts: keepNext, pageBreakBefore, after (twips), ind (left, twips), jc, bold.
local function Px(style, s, opts)
  opts = opts or {}
  local ppr = '<w:pStyle w:val="' .. style .. '"/>'
  if opts.keepNext then ppr = ppr .. "<w:keepNext/>" end
  if opts.pageBreakBefore then ppr = ppr .. "<w:pageBreakBefore/>" end
  if opts.after then ppr = ppr .. '<w:spacing w:before="0" w:after="' .. opts.after .. '"/>' end
  if opts.ind then ppr = ppr .. '<w:ind w:left="' .. opts.ind .. '" w:firstLine="0"/>' end
  if opts.jc then ppr = ppr .. '<w:jc w:val="' .. opts.jc .. '"/>' end
  local run = ""
  if s ~= "" then
    local rpr = opts.bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
    run = "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. xml(s) .. "</w:t></w:r>"
  end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. run .. "</w:p>"
end

local function P(style, s, opts)
  return pandoc.RawBlock("openxml", Px(style, s, opts))
end

-- A blank vertical gap of a given height in twips (exact line height), for the cover and the signature block.
local function gap(twips, keep)
  return pandoc.RawBlock("openxml", "<w:p><w:pPr><w:pStyle w:val=\"Normal\"/>" .. (keep and "<w:keepNext/>" or "") .. "<w:spacing w:before=\"0\" w:after=\"0\" w:line=\"" .. twips .. "\" w:lineRule=\"exact\"/></w:pPr></w:p>")
end

-- The body double line (typst v(body-leading)).
local function blank()
  return P("Normal", "")
end

local GAP_COVER = { 276, 0, 254 } -- twips: after the court title, after "No.", after the caption (measured against the typst render)

-- Caption: a borderless three-column table: party lines | ")" marks | title block (vertically centred).
local COL1, COL2, COL3 = 4896, 360, 4104 -- 3.4 in, 0.25 in, the rest of the 6.5 in text width

local function caption(meta)
  local rows = {}
  local lines = meta.caption and meta.caption.lines or {}
  for _, item in ipairs(lines) do
    if item.t ~= nil then
      table.insert(rows, { t = text(item.t), i = tonumber(text(item.i)) or 0 })
    else
      table.insert(rows, { t = text(item), i = 0 })
    end
  end
  local title = Px("CaptionTitle", text(meta.brief_title))
  if meta.jury_demand then
    title = title .. Px("CaptionTitle", "")
    title = title .. Px("CaptionTitle", "(JURY TRIAL DEMANDED)", { bold = true })
  end
  local out = {}
  table.insert(out, '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. ''
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. COL1 .. '"/><w:gridCol w:w="' .. COL2 .. '"/><w:gridCol w:w="' .. COL3 .. '"/></w:tblGrid>')
  for k, r in ipairs(rows) do
    local lcell = Px("CaptionLine", r.t, { ind = (r.i > 0) and (r.i * 720) or nil })
    local pcell = Px("CaptionLine", ")")
    local tcell
    if k == 1 then
      tcell = '<w:tc><w:tcPr><w:tcW w:w="' .. COL3 .. '" w:type="dxa"/><w:vMerge w:val="restart"/><w:vAlign w:val="center"/></w:tcPr>' .. title .. "</w:tc>"
    else
      tcell = '<w:tc><w:tcPr><w:tcW w:w="' .. COL3 .. '" w:type="dxa"/><w:vMerge/></w:tcPr>' .. Px("CaptionLine", "") .. "</w:tc>"
    end
    table.insert(out, "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. COL1 .. '" w:type="dxa"/></w:tcPr>' .. lcell .. "</w:tc>"
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. COL2 .. '" w:type="dxa"/></w:tcPr>' .. pcell .. "</w:tc>"
      .. tcell .. "</w:tr>")
  end
  table.insert(out, "</w:tbl>")
  return pandoc.RawBlock("openxml", table.concat(out))
end

local function cover(meta)
  local blocks = pandoc.List()
  blocks:insert(P("CourtTitle", "IN THE UNITED STATES DISTRICT COURT"))
  blocks:insert(P("CourtTitle", "FOR THE EASTERN DISTRICT OF NORTH CAROLINA"))
  blocks:insert(P("CourtTitle", string.upper(text(meta.division)) .. " DIVISION"))
  blocks:insert(gap(GAP_COVER[1]))
  local num = text(meta.case_number)
  if num == "" then
    blocks:insert(P("Normal", "No. " .. string.rep("_", 14), { jc = "center" }))
  else
    blocks:insert(P("Normal", "No. " .. num, { jc = "center" }))
  end
  blocks:insert(gap(GAP_COVER[2]))
  blocks:insert(caption(meta))
  blocks:insert(gap(GAP_COVER[3]))
  return blocks
end

-- The date line and signature block (LR 10.1(f) to (i)), as signature-block() in the typst template.

local function signature(meta, date)
  local blocks = pandoc.List()
  local sig = meta.signature or {}
  blocks:insert(P("Single", "This the " .. date .. ".", { keepNext = true }))
  blocks:insert(gap(280, true))
  local function group(items)
    for _, s in ipairs(items) do
      blocks:insert(P("SigBlock", s, { ind = 4320, keepNext = true }))
    end
  end
  local firm = {}
  for _, s in ipairs(sig.firm or {}) do table.insert(firm, text(s)) end
  local signers = sig.signers or {}
  local by = sig.by and text(sig.by) or (signers[1] and text(signers[1].name)) or ""
  group(firm)
  if #firm > 0 then
    group({ "BY: /s/ " .. by })
  else
    group({ "/s/ " .. by })
  end
  for _, s in ipairs(signers) do
    local items = { text(s.name) }
    for _, l in ipairs(s.lines or {}) do table.insert(items, text(l)) end
    group(items)
  end
  local address = {}
  for _, s in ipairs(sig.address or {}) do table.insert(address, text(s)) end
  group(address)
  local counsel = {}
  for _, s in ipairs(sig.counsel_for or {}) do table.insert(counsel, text(s)) end
  group(counsel)
  return blocks
end

local function starts_with(s, prefix)
  return s:sub(1, #prefix) == prefix
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

function Pandoc(doc)
  local meta = doc.meta
  local date = text(meta.date)
  local out = pandoc.List()
  out:extend(cover(meta))
  if meta.lead_in then
    out:insert(pandoc.Para(pandoc.Inlines(meta.lead_in)))
  end
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      if starts_with(text(pandoc.Para(b.content)), "WHEREFORE") then
        out:insert(b)
      else
        n = n + 1
        b.content:insert(1, TAB)
        b.content:insert(1, pandoc.Str(tostring(n) .. "."))
        out:insert(b)
      end
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          first.content:insert(1, TAB)
          first.content:insert(1, pandoc.Str(string.char(64 + i) .. "."))
        end
        out:insert(pandoc.Div(item, { ["custom-style"] = "PrayerItem" }))
      end
    else
      out:insert(b)
    end
  end
  out:insert(blank())
  out:extend(signature(meta, date))
  -- pandoc would print date and title at the top of the body; the date sits in the signature block instead
  meta.date = nil
  meta.title = nil
  return pandoc.Pandoc(out, meta)
end
