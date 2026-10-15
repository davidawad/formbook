-- N.D. Ind. complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- Mirrors typst/innd-complaint.typ: the cover, caption table (party column with a right and bottom rule), title,
-- numbered paragraphs (counted here, Fed. R. Civ. P. 10(b)), lettered prayer items, lists labelled "a.", the
-- signature block. Every case-specific word comes from the sample's frontmatter. Styles live in reference.docx.

local CFG = {
  case_label = "Case No.: ",
  list_style = "lower-alpha",          -- typst enum numbering "a." for ordinary lists
  caption_left = 4608,                 -- 3.2 in party column
  caption_gap = 432,                   -- 0.3 in gutter
  caption_right = 4320,
  designation_indent = 1728,           -- 1.2 in
  sig_left = 4320, sig_gap = 288, sig_right = 4752,   -- 3 in, 0.2 in, rest
}

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")
local NIL = '<w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/>'

local function s(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

local function esc(t)
  return (t:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- one paragraph of XML; opts.ind is a left indent in twips, opts.bold a bold run
local function p_xml(style, text, opts)
  opts = opts or {}
  local ppr = '<w:pPr><w:pStyle w:val="' .. style .. '"/>'
    .. (opts.ind and ('<w:ind w:left="' .. opts.ind .. '"/>') or "") .. '</w:pPr>'
  if text == nil or text == "" then return "<w:p>" .. ppr .. "</w:p>" end
  local rpr = opts.bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  return "<w:p>" .. ppr .. "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r></w:p>"
end

local function gap() return pandoc.RawBlock("openxml", p_xml("Gap", "")) end

local function tc(width, paras, borders)
  local b = borders and ("<w:tcBorders>" .. borders .. "</w:tcBorders>") or ""
  local mar = borders and '<w:tcMar><w:bottom w:w="144" w:type="dxa"/><w:right w:w="173" w:type="dxa"/></w:tcMar>' or ""
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. b .. mar .. '</w:tcPr>' .. table.concat(paras) .. "</w:tc>"
end

local function tbl(widths, cells)
  local total, grid = 0, {}
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblBorders>' .. NIL
    .. '</w:tblBorders><w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000"/></w:tblPr><w:tblGrid>'
    .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. "</w:tr></w:tbl>"
end

local BORDER_CAPTION = '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
  .. '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'

-- caption: the party column (names, designation indented, "v." between parties) and the case number
local function caption_xml(meta)
  local left = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then
      left[#left + 1] = p_xml("Single", "")
      left[#left + 1] = p_xml("Single", "v.")
      left[#left + 1] = p_xml("Single", "")
    end
    for _, n in ipairs(p.names) do left[#left + 1] = p_xml("Single", s(n)) end
    left[#left + 1] = p_xml("Single", s(p.designation), { ind = CFG.designation_indent })
  end
  local right = { p_xml("Single", CFG.case_label .. s(meta.case_number)) }
  if meta.jury_demand == true then
    right[#right + 1] = p_xml("Single", "")
    right[#right + 1] = p_xml("Single", "JURY TRIAL DEMANDED", { bold = true })
  end
  return tbl({ CFG.caption_left, CFG.caption_gap, CFG.caption_right }, {
    tc(CFG.caption_left, left, BORDER_CAPTION),
    tc(CFG.caption_gap, { p_xml("Single", "") }),
    tc(CFG.caption_right, right),
  })
end

-- signature block: "Dated" on the left; "Respectfully submitted," and the signer on the right
local function signature_xml(meta)
  local sig = meta.signature
  if not sig then return nil end
  local right = { p_xml("Single", "Respectfully submitted,"), p_xml("Gap", "") }
  if sig.party then
    right[#right + 1] = p_xml("Single", s(sig.party):upper())
    right[#right + 1] = p_xml("Single", "")
  end
  right[#right + 1] = p_xml("Single", "By: " .. s(sig.by))
  if sig.role then right[#right + 1] = p_xml("Single", s(sig.role)) end
  right[#right + 1] = p_xml("Gap", "")
  for _, line in ipairs(sig.counsel or {}) do right[#right + 1] = p_xml("Single", s(line)) end
  return tbl({ CFG.sig_left, CFG.sig_gap, CFG.sig_right }, {
    tc(CFG.sig_left, { p_xml("Single", "Dated: " .. s(sig.dated)) }),
    tc(CFG.sig_gap, { p_xml("Single", "") }),
    tc(CFG.sig_right, right),
  })
end

local function strip_lead(inl)
  if inl[1] and inl[1].t == "Str" and inl[1].text == "^" then
    local rest = pandoc.List({})
    local i = 2
    if inl[i] and inl[i].t == "Space" then i = i + 1 end
    for j = i, #inl do rest[#rest + 1] = inl[j] end
    return true, rest
  end
  return false, inl
end

local function labelled(style, label, inlines)
  local il = pandoc.List({ pandoc.Str(label), TAB })
  il:extend(inlines)
  return pandoc.Div({ pandoc.Para(il) }, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function upper_alpha(i) return string.char(64 + i) end
local function lower_alpha(i) return string.char(96 + i) end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- cover (typst cover): court lines and division in bold, centered, then one double-space pitch
  for _, line in ipairs(meta.court or {}) do
    add(pandoc.Div({ pandoc.Para({ pandoc.Strong({ pandoc.Str(s(line)) }) }) }, pandoc.Attr("", {}, { ["custom-style"] = "Centered" })))
  end
  if meta.division then
    add(pandoc.Div({ pandoc.Para({ pandoc.Strong({ pandoc.Str(s(meta.division):upper()) }) }) },
      pandoc.Attr("", {}, { ["custom-style"] = "Centered" })))
  end
  add(gap())
  add(pandoc.RawBlock("openxml", caption_xml(meta)))
  add(gap())
  add(pandoc.Div({ pandoc.Para({ pandoc.Str(s(meta.title):upper()) }) }, pandoc.Attr("", {}, { ["custom-style"] = "PaperTitle" })))

  -- body: numbered paragraphs, lead-ins ("^ ") unnumbered, headings and block quotes as native pandoc blocks
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local lead, rest = strip_lead(b.content)
      local letter = b.content[1] and b.content[1].t == "Str" and b.content[1].text:match("^%u%.$") and b.content[2] and b.content[2].t == "Space"
      if lead then
        b.content = rest
        add(b)
      elseif letter then
        -- "A. text": a lettered paragraph (typst: label, 0.3 in gap, text), not numbered
        local label = b.content[1].text
        local body = pandoc.List({})
        for j = 3, #b.content do body[#body + 1] = b.content[j] end
        add(labelled("Numbered", label, body))
      else
        n = n + 1
        add(labelled("Numbered", n .. ".", b.content))
      end
    elseif b.t == "OrderedList" then
      local start = b.listAttributes.start
      local upper = b.listAttributes.style == pandoc.UpperAlpha
      for k, item in ipairs(b.content) do
        local idx = start + k - 1
        if upper then
          -- prayer items "A." are lettered paragraphs (typst: label, 0.3 in gap, text)
          local first = item[1]
          if first and (first.t == "Para" or first.t == "Plain") then
            add(labelled("Numbered", upper_alpha(idx) .. ".", first.content))
            for j = 2, #item do add(item[j]) end
          else
            for _, blk in ipairs(item) do add(blk) end
          end
        else
          local lbl = CFG.list_style == "lower-alpha" and (lower_alpha(idx) .. ".") or (idx .. ".")
          local first = item[1]
          if first and (first.t == "Para" or first.t == "Plain") then
            add(labelled("ListItem", lbl, first.content))
            for j = 2, #item do add(item[j]) end
          else
            for _, blk in ipairs(item) do add(blk) end
          end
        end
      end
    else
      add(b)
    end
  end

  -- the signature block follows the last body paragraph
  add(gap())
  local sig = signature_xml(meta)
  if sig then
    add(pandoc.RawBlock("openxml", sig))
    add(gap())
  end

  doc.meta = pandoc.Meta({})
  doc.blocks = out
  return doc
end
