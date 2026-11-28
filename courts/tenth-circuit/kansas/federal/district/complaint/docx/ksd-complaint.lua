-- ksd DOCX engine (complaint): markdown contract -> Word document on reference.docx (docs/DOCX.md).
-- Mirrors typst/ksd-complaint.typ: the cover (court name, caption, title), the lead-in, the body, the signature block
-- and (motion) the certificate of service are paragraphs in the "Ksd ..." styles of reference.docx. Body paragraphs,
-- headings and lists take their numbers and letters from the same rules as the typst template.
-- Known differences (see ../README.md, Engines): the caption has no ")" column and no pleading lines; the case
-- number sits below the parties; page-limit and facsimile checks are not run here.
local KIND = "complaint"
local NUMBER_PARAS = (KIND == "complaint")

local function md_inlines(s)
  if s == nil or s == "" then return pandoc.Inlines({}) end
  local d = pandoc.read(s, "markdown")
  local b = d.blocks[1]
  if b and (b.t == "Para" or b.t == "Plain") then return b.content end
  return pandoc.Inlines({})
end

-- a metadata value (markdown string, MetaInlines, or nil) as inlines
local function inl(v)
  if v == nil then return pandoc.Inlines({}) end
  if type(v) == "string" then return md_inlines(v) end
  if v.t == "MetaInlines" then return pandoc.Inlines(v) end
  if v.t == "MetaString" then return md_inlines(pandoc.utils.stringify(v)) end
  return md_inlines(pandoc.utils.stringify(v))
end

local function append(dst, src)
  for _, x in ipairs(src) do table.insert(dst, x) end
  return dst
end

local function text_of(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

local function tab() return pandoc.RawInline("openxml", '<w:r><w:tab/></w:r>') end

local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function gap() return pandoc.Para({}) end  -- an empty body line: one double-spaced line

local function upper_inl(inlines)
  local out = {}
  for _, x in ipairs(inlines) do
    if x.t == "Str" then table.insert(out, pandoc.Str(x.text:upper())) else table.insert(out, x) end
  end
  return out
end

local function letter(n) return string.char(string.byte("a") + n - 1) end

local function roman(n)
  local vals = { { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do s = s .. p[2]; n = n - p[1] end
  end
  return s
end

-- ---------------------------------------------------------------------------------------------
local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function xp(style, s, rpr)
  local run = ""
  if s ~= "" then
    run = '<w:r>' .. (rpr or "") .. '<w:t xml:space="preserve">' .. xesc(s) .. '</w:t></w:r>'
  end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/></w:pPr>' .. run .. '</w:p>'
end

local function est_lines(s, col_pt)
  -- Conservative line-count estimate in 12pt TNR inside a 3.2 in (230.4 pt) caption column.
  local w = 0
  for i = 1, #s do
    local c = s:sub(i, i)
    w = w + (c:match("%u") and 7.4 or (c:match("[ ,.]") and 3.0 or 5.4))
  end
  return math.max(1, math.ceil(w / col_pt))
end

local function tbl_cell(w, paras, valign)
  local v = valign and ('<w:vAlign w:val="' .. valign .. '"/>') or ""
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. v .. '</w:tcPr>' .. table.concat(paras) .. '</w:tc>'
end

local function fixed_tbl(widths, cells)
  local grid = {}
  local total = 0
  for _, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    total = total + w
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. '</w:tr></w:tbl>'
end

local function caption_table(m)
  local parties = (m.caption and m.caption.parties) or {}
  local left_paras, n_lines = {}, 0
  for k, p in ipairs(parties) do
    if k > 1 then
      left_paras[#left_paras + 1] = xp("KsdCaptionV", "v.")
      n_lines = n_lines + 1
    end
    for _, n in ipairs(p.names or {}) do
      local txt = text_of(n)
      left_paras[#left_paras + 1] = xp("KsdCaption", txt)
      n_lines = n_lines + est_lines(txt, 230.4)
    end
    local desig = text_of(p.designation)
    left_paras[#left_paras + 1] = xp("KsdCaptionDesig", desig)
    n_lines = n_lines + 1
  end
  local mark_paras = {}
  for _ = 1, n_lines do mark_paras[#mark_paras + 1] = xp("KsdCaption", ")") end
  local number = text_of(m.case_number)
  if number == "" then number = "____________________" end
  local right_paras = { xp("KsdCaptionCase", "Case No. " .. number) }
  if m.jury_demand then
    right_paras[#right_paras + 1] = xp("KsdCaptionCase", "")
    right_paras[#right_paras + 1] = xp("KsdCaptionCase", "JURY DEMANDED", "<w:rPr><w:b/><w:bCs/></w:rPr>")
  end
  return pandoc.RawBlock("openxml", fixed_tbl({ 4608, 432, 4320 }, {
    tbl_cell(4608, left_paras),
    tbl_cell(432, mark_paras),
    tbl_cell(4320, right_paras, "center"),
  }))
end

local function cover(m, out)
  table.insert(out, styled("Ksd Cover", { pandoc.Str("IN THE UNITED STATES DISTRICT COURT") }))
  table.insert(out, styled("Ksd Cover Last", { pandoc.Str("FOR THE DISTRICT OF KANSAS") }))
  table.insert(out, caption_table(m))
  table.insert(out, styled("Ksd Title", upper_inl(md_inlines(text_of(m.title)))))
end

-- ---------------------------------------------------------------------------------------------
local function body(blocks, out)
  local num, numbered = 0, true
  local c2, c3, c4 = 0, 0, 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      if b.level == 1 then
        local up = text_of(b.content):upper()
        if KIND == "complaint" then numbered = (up:match("^PRAYER") == nil and up:match("^JURY") == nil) end
        table.insert(out, pandoc.Header(1, upper_inl(b.content)))
      elseif b.level == 2 then
        c2 = c2 + 1; c3 = 0; c4 = 0
        local label = (KIND == "complaint") and (roman(c2) .. ".") or (string.upper(letter(c2)) .. ".")
        table.insert(out, pandoc.Header(2, append({ pandoc.Str(label), tab() }, b.content)))
      elseif b.level == 3 then
        c3 = c3 + 1; c4 = 0
        if KIND == "complaint" then
          table.insert(out, pandoc.Header(3, b.content))
        else
          table.insert(out, pandoc.Header(3, append({ pandoc.Str(c3 .. "."), tab() }, b.content)))
        end
      elseif b.level == 4 then
        c4 = c4 + 1
        table.insert(out, pandoc.Header(4, append({ pandoc.Str(letter(c4) .. "."), tab() }, b.content)))
      else
        table.insert(out, b)
      end
    elseif b.t == "Para" then
      local c = b.content
      if NUMBER_PARAS and numbered then
        num = num + 1
        c = append({ pandoc.Str(num .. ".\u{2003}\u{2003}") }, c)
      end
      table.insert(out, pandoc.Para(c))
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- lists are lettered (a., b., ...) on every page, as in the typst template; bullets get a bullet
      for i, item in ipairs(b.content) do
        local label = (b.t == "OrderedList") and (letter(i) .. ".") or "\u{2022}"
        local first = true
        for _, blk in ipairs(item) do
          if blk.t == "Para" or blk.t == "Plain" then
            local c = blk.content
            if first then c = append({ pandoc.Str(label), tab() }, c) end
            table.insert(out, styled("Ksd Item", c))
            first = false
          else
            table.insert(out, blk)
          end
        end
      end
    else
      table.insert(out, b)
    end
  end
end

-- ---------------------------------------------------------------------------------------------
local function signature(m, out)
  local sig = m.signature
  if not sig then return end
  local left_paras = {}
  if m.date and text_of(m.date) ~= "" then
    left_paras[1] = xp("KsdCaption", "DATED: " .. text_of(m.date))
  else
    left_paras[1] = xp("KsdCaption", "")
  end
  local right_paras = {}
  for _, v in ipairs(sig.intro or {}) do
    right_paras[#right_paras + 1] = xp("KsdCaption", text_of(v))
  end
  right_paras[#right_paras + 1] = xp("KsdSigSpacer", "")
  if sig.signer then right_paras[#right_paras + 1] = xp("KsdCaption", text_of(sig.signer)) end
  for _, v in ipairs(sig.lines or {}) do
    right_paras[#right_paras + 1] = xp("KsdCaption", text_of(v))
  end
  table.insert(out, pandoc.RawBlock("openxml", fixed_tbl({ 4608, 4752 }, {
    tbl_cell(4608, left_paras),
    tbl_cell(4752, right_paras),
  })))
end

local function certificate(s, out)
  table.insert(out, styled("Ksd Center Bold", { pandoc.Str("CERTIFICATE OF SERVICE") }))
  table.insert(out, gap())
  for _, blk in ipairs(pandoc.read(text_of(s.text), "markdown").blocks) do table.insert(out, blk) end
  table.insert(out, gap())
  for _, r in ipairs(s.recipients or {}) do
    table.insert(out, styled("Ksd Recipient", inl(r.name)))
    for _, a in ipairs(r.address or {}) do table.insert(out, styled("Ksd Recipient", inl(a))) end
    table.insert(out, styled("Ksd Recipient", { pandoc.Str("Capacity: " .. text_of(r.capacity)) }))
    table.insert(out, styled("Ksd Recipient", { pandoc.Str("Manner of service: " .. text_of(r.manner)) }))
    table.insert(out, gap())
  end
  table.insert(out, gap())
  if s.signer then table.insert(out, styled("Ksd Signature", inl(s.signer))) end
  if s.signer_name then table.insert(out, styled("Ksd Signature", inl(s.signer_name))) end
end

local function unbind_abbrev_nbsp(blocks)
  -- pandoc markdown+smart inserts NBSP after abbreviations like "No."; typst/cmarker keeps a normal space.
  return pandoc.Blocks(blocks):walk({
    Str = function(el)
      if el.text:find("No%.\u{00A0}") then
        return pandoc.Str((el.text:gsub("No%.\u{00A0}", "No. ")))
      end
    end
  })
end

function Pandoc(doc)
  local m = doc.meta
  local out = {}
  cover(m, out)
  if m.lead_in and text_of(m.lead_in) ~= "" then
    table.insert(out, styled("Ksd Lead In", inl(m.lead_in)))
  end
  body(unbind_abbrev_nbsp(doc.blocks), out)
  table.insert(out, pandoc.RawBlock("openxml", xp("KsdSigSpacer", "")))
  signature(m, out)
  if m.service and KIND == "motion" then
    certificate(m.service, out)
  end
  doc.blocks = out
  doc.meta = pandoc.Meta({})
  return doc
end
