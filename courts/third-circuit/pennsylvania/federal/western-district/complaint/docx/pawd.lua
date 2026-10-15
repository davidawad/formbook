-- W.D. Pa. complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- The court heading, the caption, the title, the paragraph numbers, the lettered lists, the jury lines and the
-- signature block are built here, as in typst/pawd-complaint.typ; the body keeps its markdown structure.
-- Paragraph numbers are typed text (number, tab) generated here, as the typst template generates them.
-- Known limits: the caption is a borderless table, so Word and LibreOffice space its rows a little differently
-- from the typst grid; nothing in the caption is a text box.

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
local LETTERS = "abcdefghijklmnopqrstuvwxyz"
local DOUBLE_GAP = '<w:spacing w:before="520" w:after="0" w:line="325" w:lineRule="exact"/>'
local DOUBLE_LINE = '<w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/>'

-- the complaint's own fields (see the typst template): the case label is fixed, a jury demand line and
-- "Electronically Filed." sit under the number in the caption
local CFG = {
  case_label = "Civil Action No.",
  efiled = "Electronically Filed.",
  judge = false,
  date_label = "Dated:",
}

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata value (inlines or blocks) as a list of inlines
local function inlines(v)
  if v == nil then return pandoc.List({}) end
  local t = pandoc.utils.type(v)
  if t == "Inlines" then return pandoc.List(v) end
  if t == "Blocks" then return pandoc.List(pandoc.utils.blocks_to_inlines(v)) end
  return pandoc.List({ pandoc.Str(tostring(v)) })
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

local function xrun(s, bold)
  return '<w:r>' .. (bold and '<w:rPr><w:b/><w:bCs/></w:rPr>' or '')
    .. '<w:t xml:space="preserve">' .. esc(s) .. '</w:t></w:r>'
end

local function xpara(style, inner, ppr)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or '') .. '</w:pPr>' .. (inner or '') .. '</w:p>'
end

local function custom(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function spacer()
  return raw(xpara("Single", "", DOUBLE_LINE))
end

-- the caption: parties in a left column, a ")" column, the right column (case number and the rest)
-- spanning the rows; no borders
local function caption(meta)
  local rows = {}
  for i, p in ipairs(meta.caption or {}) do
    if i > 1 then rows[#rows + 1] = "v." end
    for _, n in ipairs(p.names or {}) do rows[#rows + 1] = plain(n) end
    rows[#rows + 1] = plain(p.designation)
  end
  local right = { xpara("Single", xrun(CFG.case_label .. " " .. plain(meta.case_number))) }
  if CFG.judge and meta.judge then
    right[#right + 1] = xpara("Single", xrun(plain(meta.judge)), DOUBLE_GAP)
  end
  if meta.jury_demand == true then
    right[#right + 1] = xpara("Single", xrun("JURY TRIAL DEMANDED", true), DOUBLE_GAP)
  end
  if meta.electronically_filed == true then
    right[#right + 1] = xpara("Single", xrun(CFG.efiled), DOUBLE_GAP)
  end
  local out = {}
  for k, r in ipairs(rows) do
    local right_cell
    if k == 1 then
      right_cell = '<w:tc><w:tcPr><w:tcW w:w="4176" w:type="dxa"/><w:vMerge w:val="restart"/>'
        .. '<w:vAlign w:val="center"/></w:tcPr>' .. table.concat(right) .. '</w:tc>'
    else
      right_cell = '<w:tc><w:tcPr><w:tcW w:w="4176" w:type="dxa"/><w:vMerge/></w:tcPr>' .. xpara("Single", "") .. '</w:tc>'
    end
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
      .. '<w:tc><w:tcPr><w:tcW w:w="4608" w:type="dxa"/></w:tcPr>' .. xpara("Single", xrun(r)) .. '</w:tc>'
      .. '<w:tc><w:tcPr><w:tcW w:w="576" w:type="dxa"/></w:tcPr>' .. xpara("Centered", xrun(")")) .. '</w:tc>'
      .. right_cell .. '</w:tr>'
  end
  return raw('<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4608"/><w:gridCol w:w="576"/><w:gridCol w:w="4176"/></w:tblGrid>'
    .. table.concat(out) .. '</w:tbl>')
end

-- the signature block: the date, then the lead-in at 3 in, the firm, the signer and the attorney lines
local function signature(meta)
  local sig = meta.signature
  if not sig then return {} end
  local out = {}
  if meta.date then
    out[#out + 1] = custom("Single Gap", { pandoc.Para({ pandoc.Str(CFG.date_label .. " " .. plain(meta.date)) }) })
  end
  out[#out + 1] = custom("Signature Gap", { pandoc.Para({ pandoc.Str(plain(sig.lead)) }) })
  local firm = sig.firm or {}
  for i, f in ipairs(firm) do
    out[#out + 1] = custom(i == 1 and "Signature Gap" or "Signature", { pandoc.Para({ pandoc.Str(plain(f)) }) })
  end
  if #firm == 0 then out[#out + 1] = spacer() end
  out[#out + 1] = custom("Signature Gap", { pandoc.Para({ pandoc.Str(plain(sig.signer)) }) })
  for _, l in ipairs(sig.lines or {}) do
    out[#out + 1] = custom("Signature", { pandoc.Para(inlines(l)) })
  end
  return out
end

-- A count heading ("## ") may run on to the lines after it with no blank line between (the typst template
-- keeps each source line on its own line). Pandoc makes those lines a paragraph after the heading, so the source
-- is read once to find which "## " headings continue, and the paragraph is merged into the heading here.
local function count_heading_flags()
  local flags = {}
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then return flags end
  local h = io.open(f, "r")
  if not h then return flags end
  local text = h:read("a")
  h:close()
  local lines, dashes = {}, 0
  for line in (text .. "\n"):gmatch("(.-)\r?\n") do
    if dashes < 2 then
      if line == "---" then dashes = dashes + 1 end
    else
      lines[#lines + 1] = line
    end
  end
  for i, line in ipairs(lines) do
    if line:match("^##%s") and not line:match("^###") then
      flags[#flags + 1] = lines[i + 1] ~= nil and lines[i + 1]:match("%S") ~= nil
    end
  end
  return flags
end

local function merge_count_lines(blocks)
  local flags = count_heading_flags()
  local out, k, i = {}, 0, 1
  while i <= #blocks do
    local b = blocks[i]
    if b.t == "Header" and b.level == 2 then
      k = k + 1
      if flags[k] and blocks[i + 1] and blocks[i + 1].t == "Para" then
        local inl = pandoc.List(b.content)
        inl:insert(pandoc.LineBreak())
        inl:extend(pandoc.Para(blocks[i + 1].content):walk({
          SoftBreak = function() return pandoc.LineBreak() end,
        }).content)
        out[#out + 1] = pandoc.Header(2, inl)
        i = i + 2
      else
        out[#out + 1] = b
        i = i + 1
      end
    else
      out[#out + 1] = b
      i = i + 1
    end
  end
  return out
end

function Pandoc(doc)
  doc.blocks = merge_count_lines(doc.blocks)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- court heading, caption, title, lead-in (typst: the first block and the caption page)
  add(raw(xpara("CourtHead", xrun("IN THE UNITED STATES DISTRICT COURT"))))
  add(raw(xpara("CourtHead", xrun("FOR THE WESTERN DISTRICT OF PENNSYLVANIA"))))
  add(spacer())
  add(caption(meta))
  add(spacer())
  add(custom("Title Block", { pandoc.Para(inlines(meta.title)) }))
  if meta.lead_in then
    add(spacer())
    add(pandoc.Para(inlines(meta.lead_in)))
  end

  -- body: sections (# caps, ## counts, ### sub-heads), numbered paragraphs, lettered lists
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local p = pandoc.Para(b.content):walk({
        SoftBreak = function() return pandoc.LineBreak() end,
        Str = function(s) if b.level == 1 then return pandoc.Str(s.text:upper()) end end,
      })
      add(pandoc.Header(b.level, p.content))
    elseif b.t == "Para" then
      local s = plain(b)
      if s:match("^WHEREFORE") then
        add(b)
      elseif s:match("^JURY TRIAL DEMANDED") then
        add(spacer())
        add(custom("Court Head", { b }))
      else
        n = n + 1
        local inl = pandoc.List({ pandoc.Str(n .. ".") })
        inl:insert(TAB)
        inl:extend(b.content)
        add(pandoc.Para(inl))
      end
    elseif b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local blocks = pandoc.List(item)
        local first = blocks[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          local inl = pandoc.List({ pandoc.Str(LETTERS:sub(i, i) .. ".") })
          inl:insert(TAB)
          inl:extend(first.content)
          add(custom("Lettered", { pandoc.Para(inl) }))
          for k = 2, #blocks do add(blocks[k]) end
        else
          for _, bb in ipairs(blocks) do add(bb) end
        end
      end
    else
      add(b)
    end
  end

  for _, b in ipairs(signature(meta)) do add(b) end

  doc.meta = pandoc.Meta({})
  doc.blocks = out
  return doc
end
