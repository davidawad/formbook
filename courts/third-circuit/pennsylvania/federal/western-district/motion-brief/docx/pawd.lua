-- W.D. Pa. memorandum in support of a motion, DOCX engine (docs/DOCX.md): the markdown contract -> a Word
-- document on reference.docx. The court heading, caption, title, heading numbers (I., A., 1., a.), the table of
-- contents and the signature block are built here, as in typst/pawd-motion-brief.typ; the body keeps its
-- markdown structure, footnotes included.
-- Known limits (BLOCKED, see the PR): the table of contents is a TOC field whose cached entries carry no page
-- numbers, so the page numbers appear only after Word or LibreOffice updates fields; the caption page and the
-- table of contents share one section with no page number, so the typst roman "ii" on the contents page is not
-- printed (a second footer needs a relationship id that pandoc assigns at build time). The caption is a
-- borderless table, so its rows are spaced a little differently from the typst grid.

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
local DOUBLE_GAP = '<w:spacing w:before="520" w:after="0" w:line="325" w:lineRule="exact"/>'
local DOUBLE_LINE = '<w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/>'

-- the memorandum's own fields (see the typst template): the case label and judge come from the sample
local CFG = {
  efiled = "Electronically Filed",
  date_label = "Date:",
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

local function roman(n)
  local vals = { { 10, "x" }, { 9, "ix" }, { 5, "v" }, { 4, "iv" }, { 1, "i" } }
  local s = ""
  for _, p in ipairs(vals) do
    while n >= p[1] do
      s = s .. p[2]
      n = n - p[1]
    end
  end
  return s:upper()
end

-- the caption: parties in a left column, a ")" column, and the right column (case number, judge and the
-- filing line) spanning the rows; no borders
local function caption(meta)
  local rows = {}
  for i, p in ipairs(meta.caption or {}) do
    if i > 1 then rows[#rows + 1] = "v." end
    for _, n in ipairs(p.names or {}) do rows[#rows + 1] = plain(n) end
    rows[#rows + 1] = plain(p.designation)
  end
  local label = meta.case_label and plain(meta.case_label) or "Civil Action No."
  local right = { xpara("Single", xrun(label .. " " .. plain(meta.case_number))) }
  if meta.judge then right[#right + 1] = xpara("Single", xrun(plain(meta.judge)), DOUBLE_GAP) end
  if meta.electronically_filed == true then right[#right + 1] = xpara("Single", xrun(CFG.efiled), DOUBLE_GAP) end
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

-- the table of contents: a TOC field whose cached result lists the headings (no page numbers, see above)
local function toc(entries)
  if #entries == 0 then return {} end
  local paras = {}
  for i, e in ipairs(entries) do
    local runs = ""
    if i == 1 then
      runs = runs .. '<w:r><w:fldChar w:fldCharType="begin"/></w:r>'
        .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-4" \\h \\z \\u </w:instrText></w:r>'
        .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    end
    runs = runs .. xrun(e.label) .. '<w:r><w:tab/></w:r>' .. xrun(e.text)
    if i == #entries then runs = runs .. '<w:r><w:fldChar w:fldCharType="end"/></w:r>' end
    paras[#paras + 1] = xpara("Single", runs,
      DOUBLE_LINE .. '<w:ind w:left="' .. (720 * e.level) .. '" w:hanging="720"/>')
  end
  return { raw(table.concat(paras)) }
end

-- the signature block: the date, then the lead-in at 3 in, the signer and the attorney lines
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

  -- the caption page (no page number): court heading, caption, title
  add(raw(xpara("Court Head", xrun("IN THE UNITED STATES DISTRICT COURT"))))
  add(raw(xpara("Court Head", xrun("FOR THE WESTERN DISTRICT OF PENNSYLVANIA"))))
  add(spacer())
  add(caption(meta))
  add(spacer())
  add(custom("Title Block", { pandoc.Para(inlines(meta.title)) }))

  -- the body: headings numbered as the typst template numbers them (I., A., 1., a.); the contents list
  -- is collected in the same pass
  local c = { 0, 0, 0, 0 }
  local entries = {}
  local body = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      local L = b.level
      if L >= 1 and L <= 4 then
        c[L] = c[L] + 1
        for k = L + 1, 4 do c[k] = 0 end
        local label
        if L == 1 then label = roman(c[1]) .. "."
        elseif L == 2 then label = string.char(64 + c[2]) .. "."
        elseif L == 3 then label = tostring(c[3]) .. "."
        else label = string.char(96 + c[4]) .. "." end
        local text = plain(b)
        entries[#entries + 1] = { level = L, label = label, text = text }
        local p = pandoc.Para(b.content):walk({
          SoftBreak = function() return pandoc.LineBreak() end,
        })
        local inl = pandoc.List({ pandoc.Str(label) })
        inl:insert(TAB)
        inl:extend(p.content)
        body[#body + 1] = pandoc.Header(L, inl)
      else
        body[#body + 1] = b
      end
    else
      body[#body + 1] = b
    end
  end

  add(custom("Court Head", { pandoc.Para({ pandoc.Str("TABLE OF CONTENTS") }) }))
  add(spacer())
  for _, b in ipairs(toc(entries)) do add(b) end
  -- section break: the caption page and the contents page form one section with no footer, the body the next
  add(raw('<w:p><w:pPr><w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" '
    .. 'w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr></w:pPr></w:p>'))

  for _, b in ipairs(body) do add(b) end
  for _, b in ipairs(signature(meta)) do add(b) end

  doc.meta = pandoc.Meta({})
  doc.blocks = out
  return doc
end
