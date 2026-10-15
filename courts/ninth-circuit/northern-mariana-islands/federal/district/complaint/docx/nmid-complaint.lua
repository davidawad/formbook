-- nmid complaint, docx: the cover (counsel, court title, caption, title of the paper), the numbered paragraphs
-- (Fed. R. Civ. P. 10(b)), the lettered prayer items, the signature block. Mirrors typst/nmid-complaint.typ.
-- Every case word comes from the sample's frontmatter; nothing here is case-specific.
-- Lines: 24 pt exact (double), the cover's single-spaced lines use the "Single" style (see build-reference.sh).

local PITCH = 480      -- twips: 24 pt, one numbered line
local TEXT_W = 10080   -- twips: 7.0 in between the margins (8.5 - 1.0 - 0.5)
local counter = 0

local function xesc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function str(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function run(text, bold)
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. xesc(text) .. '</w:t></w:r>'
end

local function para(style, runs, extra)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (extra or "") .. '</w:pPr>' .. (runs or "") .. '</w:p>'
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function cell(width, paras, borders, mar)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (borders or "") ..
    (mar or "") .. '</w:tcPr>' .. table.concat(paras) .. '</w:tc>'
end

local function table_xml(grid, rows, row_height)
  local cols = {}
  for _, w in ipairs(grid) do table.insert(cols, '<w:gridCol w:w="' .. w .. '"/>') end
  local trh = row_height and ('<w:trPr><w:cantSplit/><w:trHeight w:val="' .. row_height .. '" w:hRule="atLeast"/></w:trPr>') or '<w:trPr><w:cantSplit/></w:trPr>'
  local tr = '<w:tr>' .. trh .. table.concat(rows) .. '</w:tr>'
  local total = 0
  for _, w in ipairs(grid) do total = total + w end
  return raw('<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>' ..
    '<w:tblLayout w:type="fixed"/><w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>' .. table.concat(cols) .. '</w:tblGrid>' .. tr .. '</w:tbl>')
end

local function line_paras(items, style, extra)
  local out = {}
  for _, t in ipairs(items) do table.insert(out, para(style or "Single", run(t), extra)) end
  return out
end

-- The first page: counsel (at least lines 1 to 7), court title (lines 8 and 9), a blank line, the caption.
local function cover(meta)
  local blocks = {}
  local counsel = {}
  for _, v in ipairs(meta.counsel or {}) do table.insert(counsel, str(v)) end
  table.insert(blocks, table_xml({ 5184 }, { cell(5184, line_paras(counsel, "Single"), nil, nil) }, 3360))
  table.insert(blocks, raw(para("CourtTitle", run("IN THE UNITED STATES DISTRICT COURT", true))))
  table.insert(blocks, raw(para("CourtTitle", run("FOR THE NORTHERN MARIANA ISLANDS", true))))
  table.insert(blocks, raw(para("Normal", "")))

  -- caption: the parties (names, designation, "v." between them) left, with a right and bottom rule
  local left = {}
  local parties = meta.caption and meta.caption.parties or {}
  for k, p in ipairs(parties) do
    if k > 1 then table.insert(left, "v.") end
    for _, n in ipairs(p.names or {}) do table.insert(left, str(n)) end
    table.insert(left, str(p.designation))
  end
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  local right = { para("Single", run("CIVIL CASE NO. " .. str(meta.case_number)), '<w:spacing w:before="0" w:after="240" w:line="276" w:lineRule="atLeast"/>') }
  table.insert(right, para("Single", run(str(meta.brief_title), true)))
  if meta.jury_demand then
    table.insert(right, para("Single", run("DEMAND FOR JURY TRIAL", true), '<w:spacing w:before="240" w:after="0" w:line="276" w:lineRule="atLeast"/>'))
  end
  table.insert(blocks, table_xml({ 4464, 360, 5256 }, {
    cell(4464, line_paras(left, "Single", '<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="atLeast"/>'), rule, '<w:tcMar><w:right w:w="144" w:type="dxa"/></w:tcMar>'),
    cell(360, { para("Single", "") }),
    cell(5256, right, nil, '<w:tcMar><w:left w:w="144" w:type="dxa"/></w:tcMar>'),
  }, 2400))
  return blocks
end

-- The signature block: a date at left and the signature at right, kept together.
local function signature(meta)
  local sig = meta.signature or {}
  local left = { para("Single", run("Dated: " .. str(meta.date))) }
  local right = {}
  table.insert(right, para("Single", run("Respectfully submitted,"), '<w:spacing w:before="0" w:after="240" w:line="276" w:lineRule="atLeast"/>'))
  local firm = {}
  for _, v in ipairs(sig.firm or {}) do table.insert(firm, str(v)) end
  for _, p in ipairs(line_paras(firm, "Single")) do table.insert(right, p) end
  local signer = str(sig.signer)
  table.insert(right, para("Single", run("/s/ " .. signer), '<w:spacing w:before="240" w:after="0" w:line="276" w:lineRule="atLeast"/>'))
  table.insert(right, para("Single", run(signer)))
  for _, v in ipairs(sig.lines or {}) do table.insert(right, para("Single", run(str(v)))) end
  return table_xml({ 3744, 6336 }, { cell(3744, left), cell(6336, right, nil, '<w:tcMar><w:left w:w="288" w:type="dxa"/></w:tcMar>') })
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function text_of_first(b)
  return b.content and b.content[1] and b.content[1].t == "Str" and b.content[1].text or nil
end

function Pandoc(doc)
  local meta = doc.meta
  local out = cover(meta)
  local n = #doc.blocks
  for i, b in ipairs(doc.blocks) do
    local keep = (i == n)  -- the last unit of the body is kept with the signature block
    if b.t == "Para" then
      local first = b.content[1]
      if first and first.t == "Str" and first.text == "~" then
        -- an unnumbered paragraph (the prayer's lead-in): first-line indent, no number
        local inl = {}
        for k = 3, #b.content do table.insert(inl, b.content[k]) end
        table.insert(out, pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = "Body Text" }))
      else
        counter = counter + 1
        local inl = { pandoc.Str(tostring(counter) .. "."), TAB }
        for _, x in ipairs(b.content) do table.insert(inl, x) end
        table.insert(out, pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = keep and "Numbered Keep" or "Numbered" }))
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for k, item in ipairs(b.content) do
        local label = "(" .. string.char(string.byte("a") + k - 1) .. ")"
        local blocks = {}
        for _, ib in ipairs(item) do
          if ib.t == "Plain" or ib.t == "Para" then
            local inl = { pandoc.Str(label), TAB }
            for _, x in ipairs(ib.content) do table.insert(inl, x) end
            local last = keep and k == #b.content
            table.insert(blocks, pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = last and "Item Keep" or "Item" }))
          else
            table.insert(blocks, ib)
          end
        end
        for _, bb in ipairs(blocks) do table.insert(out, bb) end
      end
    else
      table.insert(out, b)
    end
  end
  table.insert(out, raw(para("Normal", "")))
  table.insert(out, signature(meta))
  return pandoc.Pandoc(out, {})
end
