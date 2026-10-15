-- mnb-adversary-complaint.lua (docx engine, see ../README.md "Engines"): the markdown contract -> Word, laid out as
-- typst/mnb-adversary-complaint.typ lays it out. The court title, the caption boxes and the signature block are Word
-- paragraphs and tables built here; the body keeps its markdown blocks, with the paragraph numbers the typst template
-- types in (Fed. R. Civ. P. 10(b), through Fed. R. Bankr. P. 7010). Nothing case-specific is in this file: every word
-- comes from the sample's frontmatter, as in the typst template.

local TEXT_W = 9360 -- 6.5 in, in twips
local CAPTION_LEFT = 5040 -- 3.5 in: the party column of the caption
local CAPTION_RIGHT = TEXT_W - CAPTION_LEFT
local SIG_LEFT = 4032 -- 2.8 in: a 2.6 in date column and a 0.2 in gutter, as the typst grid
local SIG_RIGHT = TEXT_W - SIG_LEFT
local RAW_TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

-- ---------------------------------------------------------------------------
-- WordprocessingML helpers
-- ---------------------------------------------------------------------------

local function esc(s)
  return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function run(text, flags)
  local rpr = ""
  if flags.b then rpr = rpr .. "<w:b/><w:bCs/>" end
  if flags.i then rpr = rpr .. "<w:i/><w:iCs/>" end
  if rpr ~= "" then rpr = "<w:rPr>" .. rpr .. "</w:rPr>" end
  return '<w:r>' .. rpr .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

-- markdown inlines -> runs: emphasis and strong keep their formatting, anything else is its text
local function runs(inlines, flags)
  flags = flags or {}
  local out = {}
  for _, el in ipairs(inlines) do
    if el.t == "Str" then
      out[#out + 1] = run(el.text, flags)
    elseif el.t == "Space" or el.t == "SoftBreak" then
      out[#out + 1] = run(" ", flags)
    elseif el.t == "Emph" then
      out[#out + 1] = runs(el.content, { b = flags.b, i = true })
    elseif el.t == "Strong" then
      out[#out + 1] = runs(el.content, { b = true, i = flags.i })
    elseif el.t == "Quoted" then
      local q = el.quotetype == "DoubleQuote" and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = run(q[1], flags) .. runs(el.content, flags) .. run(q[2], flags)
    else
      out[#out + 1] = run(pandoc.utils.stringify(el), flags)
    end
  end
  return table.concat(out)
end

-- one paragraph in a named style; extra is pPr children (after pStyle)
local function para(style, inlines, flags, extra)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (extra or "") .. '</w:pPr>'
    .. runs(inlines or {}, flags) .. '</w:p>'
end

local function gap()
  return '<w:p><w:pPr><w:pStyle w:val="Gap"/></w:pPr></w:p>'
end

local function edge(name, on)
  if on then return '<w:' .. name .. ' w:val="single" w:sz="6" w:space="0" w:color="000000"/>' end
  return '<w:' .. name .. ' w:val="nil"/>'
end

-- A table of rows, each row two cells. A caption box (box = true) has a 3.5 in party column, a 0.1 in gap inside
-- each column edge, 8 pt above and below its text, and the 0.75 pt rules each row asks for (top, bottom). The
-- signature table (box = false) has no rules and no padding: its right column starts 2.8 in from the margin.
local function table_xml(rows, box)
  local pad = box and 160 or 0
  local w1 = box and CAPTION_LEFT or SIG_LEFT
  local w2 = box and CAPTION_RIGHT or SIG_RIGHT
  local out = {}
  for _, r in ipairs(rows) do
    -- pad_top: more space above a row (the adversary box sits 9.5 pt below the debtor box, as the typst caption)
    local top = r.pad_top and ('<w:top w:w="' .. r.pad_top .. '" w:type="dxa"/>') or ""
    local lmar = box and ('<w:tcMar>' .. top .. '<w:right w:w="144" w:type="dxa"/></w:tcMar>') or (top ~= "" and ('<w:tcMar>' .. top .. '</w:tcMar>') or "")
    local rmar = box and ('<w:tcMar>' .. top .. '<w:left w:w="432" w:type="dxa"/></w:tcMar>') or lmar
    local rules = ""
    if r.top or r.bottom then
      rules = "<w:tcBorders>" .. (r.top and edge("top", true) or "") .. (r.bottom and edge("bottom", true) or "")
        .. "</w:tcBorders>"
    end
    out[#out + 1] = '<w:tr><w:tc><w:tcPr><w:tcW w:w="' .. w1 .. '" w:type="dxa"/>' .. rules .. lmar .. '</w:tcPr>'
      .. r.left .. '</w:tc><w:tc><w:tcPr><w:tcW w:w="' .. w2 .. '" w:type="dxa"/>' .. rules .. rmar .. '</w:tcPr>'
      .. r.right .. '</w:tc></w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXT_W .. '" w:type="dxa"/>'
    .. '<w:tblBorders>' .. edge("top", false) .. edge("left", false) .. edge("bottom", false)
    .. edge("right", false) .. edge("insideH", false) .. edge("insideV", false) .. '</w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="' .. pad .. '" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
    .. '<w:bottom w:w="' .. pad .. '" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. w1 .. '"/><w:gridCol w:w="' .. w2 .. '"/></w:tblGrid>'
    .. table.concat(out) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Frontmatter values
-- ---------------------------------------------------------------------------

-- a metadata value as inlines (a plain string, a paragraph of markdown, or several blocks)
local function inlines_of(v)
  if v == nil then return {} end
  if type(v) == "string" then return { pandoc.Str(v) } end
  if v.t == "MetaBlocks" then return pandoc.utils.blocks_to_inlines(v) end
  return v
end

-- the caption and signature lines: an empty entry is no line (the typst template draws none); "> x" is indented
local function line_items(list)
  local out = {}
  for _, v in ipairs(list or {}) do
    local inl, indent = inlines_of(v), false
    if v.t == "MetaBlocks" and v[1] and v[1].t == "BlockQuote" then
      inl, indent = pandoc.utils.blocks_to_inlines(v[1].content), true
    elseif inl[1] and inl[1].t == "Str" and inl[1].text == "INDENTMARK" then
      -- render.sh writes INDENTMARK where a designation's ">" was ("> Debtor."): the line is indented, the mark is not printed
      indent = true
      inl = pandoc.List(inl)
      table.remove(inl, 1)
      if inl[1] and inl[1].t == "Space" then table.remove(inl, 1) end
    end
    if pandoc.utils.stringify(inl) ~= "" then
      out[#out + 1] = { inl = inl, indent = indent }
    end
  end
  return out
end

local function lines_xml(items)
  local out = {}
  for _, it in ipairs(items) do
    out[#out + 1] = para(it.indent and "SingleIndent" or "Single", it.inl)
  end
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Caption and signature (Fed. R. Bankr. P. 7010, Official Form 416A; typst caption() and signature-block())
-- ---------------------------------------------------------------------------

local function court_title(page_break)
  local extra = page_break and "<w:pageBreakBefore/>" or nil
  return para("CourtTitle", { pandoc.Str("UNITED STATES BANKRUPTCY COURT") }, nil, extra)
    .. para("CourtTitle", { pandoc.Str("DISTRICT OF MINNESOTA") })
end

local function complaint_caption(meta)
  local c = meta.caption
  local adversary = lines_xml(line_items(c.adversary)) .. para("GapShort", {}) .. para("SingleBold", inlines_of(meta.title))
  if meta.jury_demand == true then
    adversary = adversary .. para("SingleBold", { pandoc.Str("DEMAND FOR JURY TRIAL") }, nil, '<w:spacing w:before="120"/>')
  end
  return court_title(false) .. para("GapTitle", {})
    .. table_xml({
      { left = lines_xml(line_items(c.debtor)), right = lines_xml(line_items(c.debtor_case)), top = true, bottom = true },
      { left = lines_xml(line_items(c.parties)), right = adversary, bottom = true, pad_top = 350 },
    }, true)
    .. gap()
end

local function signature(meta)
  local s = meta.signature
  local left = para("Single", { pandoc.Str("Dated: " .. pandoc.utils.stringify(meta.date)) })
  local right = para("Single", { pandoc.Str("/s/ " .. pandoc.utils.stringify(s.signer)) }) .. lines_xml(line_items(s.lines))
  return gap() .. table_xml({ { left = left, right = right } }, false)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function styled(blocks, style)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function is_wherefore(p)
  local first = p.content[1]
  return first ~= nil and first.t == "Str" and first.text:match("^WHEREFORE") ~= nil
end

-- the body in typst's terms: each paragraph numbered, lists lettered A., B., ..., block quotations single-spaced
local function body(blocks)
  local out, n = {}, 0
  for _, b in ipairs(blocks) do
    if b.t == "Para" then
      if not is_wherefore(b) then
        n = n + 1
        table.insert(b.content, 1, RAW_TAB)
        table.insert(b.content, 1, pandoc.Str(n .. "."))
      end
      out[#out + 1] = b
    elseif b.t == "BulletList" then
      for _, item in ipairs(b.content) do
        for _, blk in ipairs(item) do
          if blk.t == "Plain" or blk.t == "Para" then
            out[#out + 1] = styled({ pandoc.Para(blk.content) }, "ListItem")
          else
            out[#out + 1] = blk
          end
        end
      end
    elseif b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        if i > 26 then error("mnb-adversary-complaint: a list longer than 26 items cannot be lettered", 0) end
        local label = string.char(64 + i) .. "."
        for j, blk in ipairs(item) do
          if j == 1 and (blk.t == "Plain" or blk.t == "Para") then
            local content = { pandoc.Str(label), RAW_TAB }
            for _, el in ipairs(blk.content) do content[#content + 1] = el end
            out[#out + 1] = styled({ pandoc.Para(content) }, "ListLetter")
          elseif blk.t == "Plain" or blk.t == "Para" then
            out[#out + 1] = styled({ pandoc.Para(blk.content) }, "ListItem")
          else
            out[#out + 1] = blk
          end
        end
      end
    elseif b.t == "BlockQuote" then
      for i, blk in ipairs(b.content) do
        if blk.t == "Plain" or blk.t == "Para" then
          out[#out + 1] = styled({ pandoc.Para(blk.content) }, i == 1 and "BlockQuoteFirst" or "BlockQuote")
        else
          out[#out + 1] = blk
        end
      end
    else
      out[#out + 1] = b
    end
  end
  -- the signature block is kept with the last paragraph before it
  for i = #out, 1, -1 do
    if out[i].t == "Para" then
      out[i] = styled({ out[i] }, "BodyKeepNext")
      break
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  if not meta.caption then error("mnb-adversary-complaint: the sample frontmatter needs a caption", 0) end

  local blocks = { pandoc.RawBlock("openxml", complaint_caption(meta)) }
  if meta.lead_in then
    blocks[#blocks + 1] = pandoc.Para(inlines_of(meta.lead_in))
  end
  for _, b in ipairs(body(doc.blocks)) do
    blocks[#blocks + 1] = b
  end
  blocks[#blocks + 1] = pandoc.RawBlock("openxml", signature(meta))
  -- Word needs a paragraph after a table that ends the body
  blocks[#blocks + 1] = pandoc.RawBlock("openxml", gap())

  -- the title and the date are in the caption and the signature; pandoc would print them again
  doc.meta.title = nil
  doc.meta.date = nil
  doc.blocks = blocks
  return doc
end
