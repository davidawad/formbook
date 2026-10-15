-- W.D. Wis. complaint, DOCX engine (docs/DOCX.md; README.md "Engines"). The markdown contract (README.md) becomes
-- a Word document on docx/reference.docx, laid out as typst/wiwd-complaint.typ lays it out: the court title, the
-- caption (a table: parties left, closed by a rule; case number right), the title of the paper, the body with
-- numbered allegations (Fed. R. Civ. P. 10(b)), lettered markdown lists (A., B., ...), and the signature block.
-- Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
-- Differences from typst are listed in README.md, "Engines": the allegation numbers are typed text (not Word list
-- numbering), and the caption and signature block are Word paragraphs and a table.

local CFG = {
  court_lines = { "UNITED STATES DISTRICT COURT", "WESTERN DISTRICT OF WISCONSIN" },
  numbered = true,       -- top-level paragraphs are numbered 1, 2, ...; a paragraph starting "^" is not
  letters = "A",         -- markdown lists are lettered A., B., ...
}

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- inline markdown of a metadata string (italics, smart quotes) as pandoc inlines; fancy lists are off so
-- a line such as "(715) 495-7445" stays text
local function md(s)
  local b = pandoc.read(s, "markdown-fancy_lists").blocks[1]
  if b and b.t == "Para" then return b.content end
  return { pandoc.Str(s) }
end

local function raw(xml) return pandoc.RawBlock("openxml", xml) end

-- one raw WordprocessingML paragraph: style, text (may be empty), bold flag, extra pPr children
local function xpara(style, text, bold, ppr_extra)
  local run = ""
  if text ~= "" then
    local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
    run = "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
  end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr_extra or "") .. "</w:pPr>" .. run .. "</w:p>"
end

local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function text_line(s, style)
  return styled(style or "Single", { pandoc.Para(md(s)) })
end

local function spacer(style)
  return raw(xpara(style or "Single", ""))
end

-- caption: parties in a left cell closed by a right rule and a bottom rule ("v." between parties),
-- "Case No." in the right cell (typst: caption-left 3.2 in, gutter 0.2 in, text width 6.5 in = 9360 twips)
local function caption_xml(meta)
  local left = {}
  for k, p in ipairs(meta.caption.parties) do
    if k > 1 then left[#left + 1] = xpara("Single", "v.") end
    for _, n in ipairs(p.names) do left[#left + 1] = xpara("Single", plain(n)) end
    left[#left + 1] = xpara("Single", plain(p.designation))
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblLook w:val="0000"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="4608"/><w:gridCol w:w="288"/><w:gridCol w:w="4464"/></w:tblGrid><w:tr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="4608" w:type="dxa"/><w:tcBorders>'
    .. '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
    .. '</w:tcBorders><w:tcMar><w:right w:w="144" w:type="dxa"/><w:bottom w:w="115" w:type="dxa"/></w:tcMar></w:tcPr>'
    .. table.concat(left) .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="288" w:type="dxa"/></w:tcPr>' .. xpara("Single", "") .. "</w:tc>"
    .. '<w:tc><w:tcPr><w:tcW w:w="4464" w:type="dxa"/></w:tcPr>'
    .. xpara("Single", "Case No. " .. plain(meta.case_number), false, '<w:ind w:left="144"/>') .. "</w:tc>"
    .. "</w:tr></w:tbl>"
end

local function cover(meta)
  local out = {}
  for _, t in ipairs(CFG.court_lines) do out[#out + 1] = raw(xpara("Centered", t, true)) end
  out[#out + 1] = spacer("Single")
  out[#out + 1] = raw(caption_xml(meta))
  out[#out + 1] = spacer("Single")
  out[#out + 1] = raw(xpara("Centered", plain(meta.brief_title), true))
  out[#out + 1] = spacer("BodyText")
  return out
end

local function signature(meta)
  local sig = meta.signature
  local out = {}
  out[#out + 1] = text_line("Dated: " .. plain(meta.date))
  out[#out + 1] = spacer("Single")
  out[#out + 1] = text_line("Respectfully submitted,")
  out[#out + 1] = spacer("Single")
  for _, t in ipairs(sig.firm) do out[#out + 1] = text_line(plain(t)) end
  for _, s in ipairs(sig.signers) do
    out[#out + 1] = spacer("BodyText")
    out[#out + 1] = text_line("/s/ " .. plain(s.name))
    for _, t in ipairs(s.lines) do out[#out + 1] = text_line(plain(t)) end
  end
  out[#out + 1] = spacer("Single")
  out[#out + 1] = text_line(plain(sig.role))
  return out
end

local function lettered(list)
  local out = {}
  for i, item in ipairs(list.content) do
    local letter = string.char(string.byte(CFG.letters) + i - 1)
    local first = true
    for _, blk in ipairs(item) do
      if first and (blk.t == "Para" or blk.t == "Plain") then
        local c = { pandoc.Str(letter .. "."), TAB }
        for _, x in ipairs(blk.content) do c[#c + 1] = x end
        out[#out + 1] = styled("Lettered", { pandoc.Para(c) })
        first = false
      else
        out[#out + 1] = blk
      end
    end
  end
  return out
end

function Pandoc(doc)
  local blocks = cover(doc.meta)
  local n = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local c = b.content
      local first = c[1]
      if first and first.t == "Str" and first.text:sub(1, 1) == "^" then
        -- "^" marks a paragraph that is not numbered (the WHEREFORE lead-in, the jury demand)
        local rest = {}
        local head = first.text:sub(2)
        if head ~= "" then rest[#rest + 1] = pandoc.Str(head) end
        for i = 2, #c do rest[#rest + 1] = c[i] end
        while rest[1] and rest[1].t == "Space" do table.remove(rest, 1) end
        blocks[#blocks + 1] = pandoc.Para(rest)
      elseif CFG.numbered then
        n = n + 1
        local c2 = { pandoc.Str(n .. "."), TAB }
        for _, x in ipairs(c) do c2[#c2 + 1] = x end
        blocks[#blocks + 1] = pandoc.Para(c2)
      else
        blocks[#blocks + 1] = b
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for _, x in ipairs(lettered(b)) do blocks[#blocks + 1] = x end
    else
      blocks[#blocks + 1] = b
    end
  end
  for _, x in ipairs(signature(doc.meta)) do blocks[#blocks + 1] = x end
  -- the cover and signature come from the frontmatter; pandoc's own title block must not repeat the date
  doc.meta.date = nil
  doc.blocks = blocks
  return doc
end
