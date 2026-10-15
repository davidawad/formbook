-- N.D. Ind. motion brief (supporting memorandum), DOCX engine (docs/DOCX.md): markdown -> Word on reference.docx.
-- Mirrors typst/innd-motion-brief.typ: the cover and caption table (party column with a right and bottom rule),
-- the title, unnumbered body paragraphs with a first-line indent, headings and block quotes as native pandoc
-- blocks, lists labelled "1.", the signature block and the certificate of service. Every case-specific word comes
-- from the sample's frontmatter. Styles live in reference.docx.

local CFG = {
  case_label = "Case No. ",
  judge_label = "Judge ",
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

-- caption: the party column (names, designation indented, "v." between parties) and the case number and judge
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
  if meta.judge then
    right[#right + 1] = p_xml("Single", "")
    right[#right + 1] = p_xml("Single", CFG.judge_label .. s(meta.judge))
  end
  return tbl({ CFG.caption_left, CFG.caption_gap, CFG.caption_right }, {
    tc(CFG.caption_left, left, BORDER_CAPTION),
    tc(CFG.caption_gap, { p_xml("Single", "") }),
    tc(CFG.caption_right, right),
  })
end

-- a two-column block with no rules: left cell (3 in), gutter, right cell
local function two_col(left_paras, right_paras)
  return tbl({ CFG.sig_left, CFG.sig_gap, CFG.sig_right }, {
    tc(CFG.sig_left, left_paras),
    tc(CFG.sig_gap, { p_xml("Single", "") }),
    tc(CFG.sig_right, right_paras),
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
  return two_col({ p_xml("Single", "Dated: " .. s(sig.dated)) }, right)
end

-- certificate of service (Fed. R. Civ. P. 5(b)): centered title, the text, then the signer on the right
local function certificate_blocks(meta)
  local c = meta.certificate
  if not c then return {} end
  local right = {}
  for _, line in ipairs(c.counsel or {}) do right[#right + 1] = p_xml("Single", s(line)) end
  return {
    pandoc.Div({ pandoc.Para({ pandoc.Strong({ pandoc.Str(s(c.title):upper()) }) }) },
      pandoc.Attr("", {}, { ["custom-style"] = "PaperTitle" })),
    pandoc.Para(c.text),
    gap(),
    pandoc.RawBlock("openxml", two_col({ p_xml("Single", "") }, right)),
    gap(),
  }
end

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
  add(pandoc.Div({ pandoc.Para({ pandoc.Str(s(meta.title):upper()) }) }, pandoc.Attr("", {}, { ["custom-style"] = "PaperTitle" })))

  -- body: unnumbered paragraphs (first-line indent), headings, block quotes and lists as native pandoc blocks;
  -- ordered lists are labelled "1." in the paragraph (typst enum numbering "1.")
  for _, b in ipairs(doc.blocks) do
    if b.t == "OrderedList" then
      local start = b.listAttributes.start
      for k, item in ipairs(b.content) do
        local first = item[1]
        if first and (first.t == "Para" or first.t == "Plain") then
          local il = pandoc.List({ pandoc.Str((start + k - 1) .. "."), TAB })
          il:extend(first.content)
          add(pandoc.Div({ pandoc.Para(il) }, pandoc.Attr("", {}, { ["custom-style"] = "ListItem" })))
          for j = 2, #item do add(item[j]) end
        else
          for _, blk in ipairs(item) do add(blk) end
        end
      end
    else
      add(b)
    end
  end

  -- the signature block and the certificate follow the last body paragraph
  add(gap())
  local sig = signature_xml(meta)
  if sig then
    add(pandoc.RawBlock("openxml", sig))
    add(gap())
  end
  for _, b in ipairs(certificate_blocks(meta)) do add(b) end

  doc.meta = pandoc.Meta({})
  doc.blocks = out
  return doc
end
