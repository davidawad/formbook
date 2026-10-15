-- S.D.N.Y. complaint, DOCX engine: the markdown contract -> Word, on docx/reference.docx.
-- Mirrors typst/nysd-complaint.typ (see ../README.md, "Engines"). Built here, as openxml blocks in the
-- reference's styles: the caption (a two-column table with a rule at the right and bottom of the party
-- block), the court title, the signature block. Built here, as text: the paragraph numbers (Fed. R. Civ.
-- P. 10(b)) and the lettered lists "(a)", "(b)". The numbering rules are the typst template's: a
-- paragraph under a heading that contains "JURY TRIAL" and a paragraph starting "WHEREFORE" are not numbered;
-- block quotations are not numbered; a heading resets nothing else.

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;")
  return s
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function is_true(v)
  return v == true or (v ~= nil and plain(v) == "true")
end

-- one paragraph of openxml: style id, optional extra pPr, and the text runs (bold, caps as given)
local function para(style, text, opts)
  opts = opts or {}
  local ppr = '<w:pStyle w:val="' .. style .. '"/>' .. (opts.ppr or "")
  local rpr = ""
  if opts.bold then rpr = rpr .. "<w:b/>" end
  if opts.caps then rpr = rpr .. "<w:caps/>" end
  local r = ""
  if text and text ~= "" then
    r = '<w:r>' .. (rpr ~= "" and ("<w:rPr>" .. rpr .. "</w:rPr>") or "") .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
  end
  return pandoc.RawBlock("openxml", "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. r .. "</w:p>")
end

local function spacer(after)
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="Single"/><w:spacing w:before="0" w:after="' .. after .. '" w:line="276" w:lineRule="auto"/></w:pPr></w:p>')
end

local BORDER = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
local NOBORDER = '<w:tcBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/></w:tcBorders>'

local function cell(width, borders, margins, inner)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. borders .. margins .. '</w:tcPr>' .. inner .. '</w:tc>'
end

local function table_xml(widths, rows)
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>'
    .. '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' .. rows .. '</w:tbl>'
end

-- caption (Fed. R. Civ. P. 10(a)): parties left, file number and title right
local function caption(meta)
  local left, right = {}, {}
  local sides = meta.caption
  for i, side in ipairs(sides) do
    for _, n in ipairs(side.names) do
      left[#left + 1] = para("Single", plain(n))
    end
    left[#left + 1] = para("Single", plain(side.designation), { ppr = '<w:ind w:left="2592" w:firstLine="0"/>' })
    if i < #sides then
      left[#left + 1] = para("Centered", "v.", { ppr = '<w:spacing w:before="240" w:after="240" w:line="276" w:lineRule="auto"/>' })
    end
  end
  if is_true(meta.electronic) then right[#right + 1] = para("Single", "ELECTRONICALLY FILED", { ppr = '<w:spacing w:after="240" w:line="276" w:lineRule="auto"/>' }) end
  right[#right + 1] = para("Single", "No. " .. plain(meta.case_number))
  if meta.judge then right[#right + 1] = para("Single", plain(meta.judge), { ppr = '<w:spacing w:after="240" w:line="276" w:lineRule="auto"/>' }) end
  for _, l in ipairs(meta.legends or {}) do right[#right + 1] = para("Single", plain(l):upper(), { bold = true }) end
  right[#right + 1] = para("Single", "", { ppr = '<w:spacing w:after="240" w:line="276" w:lineRule="auto"/>' })
  right[#right + 1] = para("Single", plain(meta.title):upper(), { bold = true })
  for _, l in ipairs(meta["legends-after"] or {}) do right[#right + 1] = para("Single", plain(l):upper(), { bold = true }) end
  local lxml, rxml = "", ""
  for _, p in ipairs(left) do lxml = lxml .. p.text end
  for _, p in ipairs(right) do rxml = rxml .. p.text end
  return table_xml({ 4680, 4680 }, '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(4680, BORDER, '<w:tcMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="240" w:type="dxa"/><w:right w:w="288" w:type="dxa"/></w:tcMar>', lxml)
    .. cell(4680, NOBORDER, '<w:tcMar><w:top w:w="72" w:type="dxa"/><w:left w:w="288" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tcMar>', rxml)
    .. '</w:tr>')
end

-- signature block (typst: a grid of 1fr and 3.2in; the date at left, the signer at right)
local function signature(meta)
  local sig = meta.signature
  local rightx = {}
  rightx[#rightx + 1] = para("Single", "Respectfully submitted,", { ppr = '<w:spacing w:after="480" w:line="276" w:lineRule="auto"/>' })
  rightx[#rightx + 1] = para("Single", "By: /s/ " .. plain(sig.signer))
  rightx[#rightx + 1] = para("Single", plain(sig.signer))
  for _, l in ipairs(sig.lines or {}) do rightx[#rightx + 1] = para("Single", plain(l)) end
  local rx = ""
  for _, p in ipairs(rightx) do rx = rx .. p.text end
  local lx = para("Single", "Dated: " .. plain(meta.date)).text
  return table_xml({ 4752, 4608 }, '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. cell(4752, NOBORDER, '<w:tcMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tcMar>', lx)
    .. cell(4608, NOBORDER, '<w:tcMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tcMar>', rx)
    .. '</w:tr>')
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

function Pandoc(doc)
  local meta = doc.meta
  local blocks = {}
  local function add(b) blocks[#blocks + 1] = b end

  -- cover: court, caption, title (the court's name is centered bold caps)
  for _, l in ipairs(meta.court) do
    add(para("Centered", plain(l):upper(), { bold = true }))
  end
  add(spacer(240))
  add(raw(caption(meta)))
  add(spacer(480))
  if meta.lead_in then
    add(pandoc.Para(meta.lead_in))
  end

  -- body: numbered paragraphs, lettered lists, unnumbered headings and paragraphs
  local unnumbered = false
  local n = 0
  local function letter(i) return string.char(string.byte("a") + i - 1) end
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      unnumbered = plain(b):find("JURY TRIAL", 1, true) ~= nil
      add(b)
    elseif b.t == "Para" then
      local t = plain(b)
      if t:sub(1, 9) == "WHEREFORE" or unnumbered then
        add(b)
      else
        n = n + 1
        local content = { pandoc.Str(n .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
        for _, x in ipairs(b.content) do content[#content + 1] = x end
        add(pandoc.Para(content))
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local lab = "(" .. letter(i) .. ")"
        for j, ib in ipairs(item) do
          if j == 1 and (ib.t == "Para" or ib.t == "Plain") then
            local content = { pandoc.Str(lab), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }
            for _, x in ipairs(ib.content) do content[#content + 1] = x end
            add(pandoc.Div({ pandoc.Para(content) }, pandoc.Attr("", {}, { ["custom-style"] = "Lettered" })))
          else
            add(ib)
          end
        end
      end
    else
      add(b)
    end
  end
  add(spacer(240))
  add(raw(signature(meta)))

  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
