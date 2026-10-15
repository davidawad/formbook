-- Adversary complaint for the U.S. Bankruptcy Court, S.D. Mississippi (mssb): pandoc filter for the docx engine.
-- The same content and rules as typst/mssb-adversary-complaint.typ, from the same markdown contract:
-- the cover and caption (FRBP 9004(b)), the title, the lead-in and consent statement (FRBP 7008(a)), numbered
-- paragraphs (Fed. R. Civ. P. 10(b)), lettered sub-items, headings and the signature block. Every case word comes
-- from the frontmatter. Styles (MSSB ...) come from reference.docx (make-reference.sh). See ../README.md, "Engines".

local TEXT_W = 9360 -- 6.5 in in twips (8.5 in less two 1 in margins)
local CAP_LEFT = 5184 -- 3.6 in: the party column of the caption (typst caption-left)
local CAP_GAP = 360 -- 0.25 in gutter
local CAP_RIGHT = TEXT_W - CAP_LEFT - CAP_GAP

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function txt(x)
  if x == nil then return "" end
  return pandoc.utils.stringify(x)
end

local function need(v, msg)
  if v == nil or txt(v) == "" then error("mssb-adversary-complaint: " .. msg) end
  return v
end

-- A block of one paragraph in a named MSSB style (defined in reference.docx).
local function styled(style, inlines)
  return pandoc.Div({ pandoc.Para(inlines or {}) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function blank(style)
  return styled(style, {})
end

-- The inlines of a markdown string from the frontmatter (the lead-in and consent may carry markup).
local function md_inlines(s)
  local d = pandoc.read(s, "markdown")
  local b = d.blocks[1]
  if b == nil or b.content == nil then return pandoc.Inlines({ pandoc.Str(s) }) end
  return b.content
end

local function tab_run()
  return pandoc.RawInline("openxml", "<w:r><w:tab /></w:r>")
end

local function has_line_break(blk)
  local found = false
  pandoc.walk_block(blk, {
    LineBreak = function()
      found = true
    end,
  })
  return found
end

-- Caption: one borderless three-column table (party names | gutter | case facts and designations), as in typst.
local function xml_para(text, style, jc)
  local ppr = '<w:pStyle w:val="' .. style .. '" />'
  if jc then ppr = ppr .. '<w:jc w:val="' .. jc .. '" />' end
  return '<w:p><w:pPr>' .. ppr .. '</w:pPr><w:r><w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r></w:p>'
end

local function xml_cell(width, paras)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa" /></w:tcPr>' .. table.concat(paras) .. '</w:tc>'
end

local function caption_row(left, right, right_jc)
  local lp, rp = {}, {}
  for _, s in ipairs(left) do
    lp[#lp + 1] = xml_para(s, "MSSBSingle")
  end
  for _, s in ipairs(right) do
    rp[#rp + 1] = xml_para(s, "MSSBSingle", right_jc)
  end
  return '<w:tr>' .. xml_cell(CAP_LEFT, lp) .. xml_cell(CAP_GAP, { '<w:p />' }) .. xml_cell(CAP_RIGHT, rp) .. '</w:tr>'
end

-- A spacer row exactly 12 pt high: half a double-spaced row, as typst's v(pitch * 0.5).
local SPACER = '<w:tr><w:trPr><w:trHeight w:val="240" w:hRule="exact" /></w:trPr>'
  .. '<w:tc><w:tcPr><w:tcW w:w="' .. TEXT_W .. '" w:type="dxa" /><w:gridSpan w:val="3" /></w:tcPr>'
  .. '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr></w:p></w:tc></w:tr>'

local function names_of(list)
  local out = {}
  for _, n in ipairs(list) do
    out[#out + 1] = txt(n)
  end
  return out
end

local function caption_table(meta)
  local c = need(meta.caption, "frontmatter needs caption (debtor, case_number, chapter, parties, adversary_number)")
  local rows = {}
  rows[#rows + 1] = caption_row(names_of(c.debtor.names), { "CASE NO. " .. txt(c.case_number), txt(c.chapter) }, nil)
  rows[#rows + 1] = SPACER
  for k, p in ipairs(c.parties) do
    if k > 1 then
      rows[#rows + 1] = caption_row({ "V." }, { "ADV. PROC. NO. " .. txt(c.adversary_number) }, nil)
      rows[#rows + 1] = SPACER
    end
    rows[#rows + 1] = caption_row(names_of(p.names), { txt(p.designation) }, "right")
    if k < #c.parties then rows[#rows + 1] = SPACER end
  end
  local borders = '<w:tblBorders><w:top w:val="nil" /><w:left w:val="nil" /><w:bottom w:val="nil" />'
    .. '<w:right w:val="nil" /><w:insideH w:val="nil" /><w:insideV w:val="nil" /></w:tblBorders>'
  local xml = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa" />' .. borders .. '<w:tblLayout w:type="fixed" />'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa" /><w:right w:w="0" w:type="dxa" /></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '" /><w:gridCol w:w="' .. CAP_GAP .. '" /><w:gridCol w:w="' .. CAP_RIGHT .. '" /></w:tblGrid>'
    .. table.concat(rows) .. '</w:tbl>'
  return pandoc.RawBlock("openxml", xml)
end

-- Cover: court name, division, caption, title (typst cover()).
local function cover(meta)
  local out = {
    styled("MSSB Cover", { pandoc.Str("IN THE UNITED STATES BANKRUPTCY COURT") }),
    styled("MSSB Cover", { pandoc.Str("FOR THE SOUTHERN DISTRICT OF MISSISSIPPI") }),
  }
  local division = txt(meta.division)
  if division ~= "" then
    out[#out + 1] = styled("MSSB Cover", { pandoc.Str(division:upper()) })
  end
  out[#out + 1] = blank("MSSB Body")
  out[#out + 1] = caption_table(meta)
  out[#out + 1] = blank("MSSB Single")
  local title = need(meta.title, "frontmatter needs title (FRBP 9004(b)(4); 5005-1(a)(2)(I))")
  out[#out + 1] = styled("MSSB Cover", { pandoc.Str(txt(title):upper()) })
  out[#out + 1] = blank("MSSB Body")
  return out
end

-- Signature block: date, "Respectfully submitted," and the counsel lines, indented to the right half (typst).
local function signature(meta)
  local s = need(meta.signature, "frontmatter needs signature")
  local out = {
    blank("MSSB Body"),
    styled("MSSB Single", md_inlines(txt(s.date))),
    blank("MSSB Body"),
    styled("MSSB Signature", { pandoc.Str("Respectfully submitted,") }),
    blank("MSSB Single"),
    styled("MSSB Signature", { pandoc.Str("/s/ " .. txt(s.signer)) }),
    styled("MSSB Signature", { pandoc.Str(txt(s.signer)) }),
    styled("MSSB Signature", { pandoc.Str(txt(s.role)) }),
  }
  for _, line in ipairs(s.counsel) do
    out[#out + 1] = styled("MSSB Signature", { pandoc.Str(txt(line)) })
  end
  return out
end

-- Inline markup as WordprocessingML runs (italic and bold kept; other markup is flattened to its text).
local function run_xml(text, flags)
  local rpr = ""
  if flags.b then rpr = rpr .. "<w:b />" end
  if flags.i then rpr = rpr .. "<w:i />" end
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
end

local function runs_xml(inlines, flags)
  local out = {}
  for _, x in ipairs(inlines) do
    if x.t == "Str" then
      out[#out + 1] = run_xml(x.text, flags)
    elseif x.t == "Space" or x.t == "SoftBreak" then
      out[#out + 1] = run_xml(" ", flags)
    elseif x.t == "Emph" then
      out[#out + 1] = runs_xml(x.content, { b = flags.b, i = true })
    elseif x.t == "Strong" then
      out[#out + 1] = runs_xml(x.content, { b = true, i = flags.i })
    else
      out[#out + 1] = run_xml(txt(x), flags)
    end
  end
  return table.concat(out)
end

-- A pandoc table as a borderless table, 5.5 in wide and indented 1 in, single spaced, with the cell
-- insets of typst's table (0.12 in across): the fee table of the filed complaint (typst table()).
local TABLE_W = 7920
local TABLE_IND = 1440
local CELL_INSET = 173

local function table_xml(tbl)
  local ncols = #tbl.colspecs
  local total = 0
  for _, cs in ipairs(tbl.colspecs) do
    total = total + (cs[2] or 0)
  end
  local widths = {}
  for i, cs in ipairs(tbl.colspecs) do
    widths[i] = (total > 0 and cs[2]) and math.floor(TABLE_W * cs[2] / total) or math.floor(TABLE_W / ncols)
  end
  local function cell(c, i)
    local jc = ({ AlignRight = "right", AlignCenter = "center" })[tostring(c.alignment)]
    local paras = {}
    for _, blk in ipairs(c.contents) do
      local ppr = '<w:pStyle w:val="MSSBSingle" />' .. (jc and ('<w:jc w:val="' .. jc .. '" />') or "")
      paras[#paras + 1] = "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. runs_xml(blk.content or {}, {}) .. "</w:p>"
    end
    if #paras == 0 then paras[1] = "<w:p />" end
    return '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa" /></w:tcPr>' .. table.concat(paras) .. "</w:tc>"
  end
  local function row(r)
    local cells = {}
    for i, c in ipairs(r.cells) do
      cells[#cells + 1] = cell(c, i)
    end
    return "<w:tr>" .. table.concat(cells) .. "</w:tr>"
  end
  local rows = {}
  for _, r in ipairs(tbl.head.rows) do
    rows[#rows + 1] = row(r)
  end
  for _, body in ipairs(tbl.bodies) do
    for _, r in ipairs(body.body) do
      rows[#rows + 1] = row(r)
    end
  end
  local none = '<w:tblBorders><w:top w:val="nil" /><w:left w:val="nil" /><w:bottom w:val="nil" /><w:right w:val="nil" /><w:insideH w:val="nil" /><w:insideV w:val="nil" /></w:tblBorders>'
  local grid = {}
  for i = 1, ncols do
    grid[#grid + 1] = '<w:gridCol w:w="' .. widths[i] .. '" />'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TABLE_W .. '" w:type="dxa" /><w:tblInd w:w="' .. TABLE_IND .. '" w:type="dxa" />' .. none
    .. '<w:tblLayout w:type="fixed" /><w:tblCellMar><w:left w:w="' .. CELL_INSET .. '" w:type="dxa" /><w:right w:w="' .. CELL_INSET .. '" w:type="dxa" /></w:tblCellMar></w:tblPr>'
    .. "<w:tblGrid>" .. table.concat(grid) .. "</w:tblGrid>" .. table.concat(rows) .. "</w:tbl>"
end

-- Lettered sub-items: "(a)" hangs at 0.5 in, the text starts at 1 in (typst allegations()).
local function lettered(items)
  local out = {}
  for i, item in ipairs(items) do
    local first = item[1]
    local body = (first and first.content) or pandoc.Inlines({})
    local inl = pandoc.Inlines({ pandoc.Str("(" .. string.char(96 + i) .. ")"), tab_run() })
    for _, x in ipairs(body) do
      inl:insert(x)
    end
    out[#out + 1] = styled("MSSB Sub Item", inl)
  end
  return out
end

local HEADING_STYLE = { [1] = "MSSB Heading Caps", [2] = "MSSB Heading Center", [3] = "MSSB Heading Italic" }

function Pandoc(doc)
  local meta = doc.meta
  local out = cover(meta)

  if meta.lead_in ~= nil and txt(meta.lead_in) ~= "" then
    out[#out + 1] = styled("MSSB Body", md_inlines(txt(meta.lead_in)))
  end
  -- Consent statement (FRBP 7008(a); Miss. Bankr. L.R. 7008-1): an unnumbered paragraph after the lead-in.
  out[#out + 1] = styled("MSSB Body", md_inlines(txt(need(meta.consent, "frontmatter needs consent (FRBP 7008(a); Miss. Bankr. L.R. 7008-1)"))))

  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = styled(HEADING_STYLE[b.level] or HEADING_STYLE[3], b.content)
    elseif b.t == "Para" then
      local t = txt(b)
      if t:sub(1, 9) == "WHEREFORE" or t:sub(1, 9) == "COMES NOW" then
        out[#out + 1] = styled("MSSB Body", b.content)
      elseif has_line_break(b) then
        out[#out + 1] = styled("MSSB Address", b.content)
      else
        n = n + 1
        local inl = pandoc.Inlines({ pandoc.Str(n .. "."), tab_run() })
        for _, x in ipairs(b.content) do
          inl:insert(x)
        end
        out[#out + 1] = styled("MSSB Body", inl)
      end
    elseif b.t == "BulletList" then
      for _, x in ipairs(lettered(b.content)) do
        out[#out + 1] = x
      end
    elseif b.t == "Table" then
      out[#out + 1] = pandoc.RawBlock("openxml", table_xml(b))
      out[#out + 1] = blank("MSSB Single")
    else
      out[#out + 1] = b
    end
  end

  for _, x in ipairs(signature(meta)) do
    out[#out + 1] = x
  end
  return pandoc.Pandoc(out, meta)
end
