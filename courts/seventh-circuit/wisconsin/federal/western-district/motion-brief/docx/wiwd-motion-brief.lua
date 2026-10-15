-- W.D. Wis. brief in support of a motion, DOCX engine (docs/DOCX.md; README.md "Engines"). The markdown contract
-- (README.md) becomes a Word document on docx/reference.docx, laid out as typst/wiwd-motion-brief.typ lays it out:
-- the court title, the caption (a table: parties left, closed by a rule; case number right), the title of the
-- brief, the body (paragraphs indented, unnumbered; headings; lettered markdown lists a., b., ...), and the
-- signature block in the right half of the page.
-- Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
-- Differences from typst are listed in README.md, "Engines": the caption and signature block are Word
-- paragraphs and a table, and the cover text is plain (markdown italics in the frontmatter are not carried).

local CFG = {
  court_lines = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE WESTERN DISTRICT OF WISCONSIN" },
  letters = "a",         -- markdown lists are lettered a., b., ...; briefs are not numbered
}

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- inline markdown of a metadata string as pandoc inlines; fancy lists are off so a line such as
-- "(608) 662-2285" stays text
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

-- signature block: preamble lines, then "/s/ name", the name and the lines for the signer (typst: pad 2.75 in)
local function signature(meta)
  local sig = meta.signature
  local out = {}
  for _, t in ipairs(sig.preamble) do out[#out + 1] = text_line(plain(t), "Signature") end
  out[#out + 1] = spacer("BodyText")
  out[#out + 1] = text_line("/s/ " .. plain(sig.signer), "Signature")
  out[#out + 1] = text_line(plain(sig.signer), "Signature")
  for _, t in ipairs(sig.lines) do out[#out + 1] = text_line(plain(t), "Signature") end
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
  for _, b in ipairs(doc.blocks) do
    if b.t == "BulletList" or b.t == "OrderedList" then
      for _, x in ipairs(lettered(b)) do blocks[#blocks + 1] = x end
    else
      -- paragraphs keep their markdown; the body style gives the first-line indent
      blocks[#blocks + 1] = b
    end
  end
  for _, x in ipairs(signature(doc.meta)) do blocks[#blocks + 1] = x end
  -- the cover and signature come from the frontmatter; pandoc's own title block must not repeat the date
  doc.meta.date = nil
  doc.blocks = blocks
  return doc
end
