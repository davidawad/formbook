-- okwb adversary complaint, DOCX engine (docs/DOCX.md). Markdown contract -> Word on docx/reference.docx.
-- Mirrors typst/okwb-adversary-complaint.typ: court heading, caption (a borderless table: party column,
-- ")" column, case column), the title, the lead-in, numbered paragraphs (1., 2., ...), unnumbered
-- paragraphs (blockquotes), lettered items ((a), (b), ...) from bullet lists, centered bold headings in
-- capitals (text after "§" keeps its case), and the signature and "Approved by:" blocks. Every style is
-- defined in reference.docx. Content comes from the sample only; nothing case-specific lives here.

local stringify = pandoc.utils.stringify
local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

-- A paragraph in a custom paragraph style (pandoc writes the style by name).
local function styled(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr("", {}, { ["custom-style"] = style }))
end

local function para(style, inlines)
  return styled(style, { pandoc.Para(inlines) })
end

-- An empty paragraph in the "Blank Line" style (pandoc drops an empty Para, so it is written as raw XML).
local function blank()
  return pandoc.RawBlock("openxml", '<w:p><w:pPr><w:pStyle w:val="BlankLine"/></w:pPr></w:p>')
end

-- Headings are capitals; a statute cited after "§" keeps its lowercase subsections (523(a)(2)(A)).
local function heading_caps(s)
  local i = s:find("§", 1, true)
  if not i then return s:upper() end
  return s:sub(1, i - 1):upper() .. s:sub(i)
end

-- Pandoc's YAML reader trims the leading space of a caption entry (" Debtor."), which the typst
-- template indents by one inch. The flags are read from the sample's frontmatter, in row order.
local function caption_indents()
  local flags = {}
  local file = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  local f = file and io.open(file, "r")
  if not f then return flags end
  local seen_open, in_fm = false, false
  for line in f:lines() do
    if not seen_open then
      if line == "---" then seen_open, in_fm = true, true end
    elseif in_fm then
      if line == "---" then break end
      local left = line:match('^%s*%-%s*%[%s*"(.-)"%s*,')
      if left then flags[#flags + 1] = left:sub(1, 1) == " " end
    end
  end
  f:close()
  return flags
end

local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function cell_p(text, opts)
  local ppr = '<w:pStyle w:val="SingleSpaced"/>'
  if opts.indent then ppr = ppr .. '<w:ind w:left="1440" w:firstLine="0"/>' end
  if opts.center then ppr = ppr .. '<w:jc w:val="center"/>' end
  local run = ""
  if text ~= "" then run = '<w:r><w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>" end
  return "<w:p><w:pPr>" .. ppr .. "</w:pPr>" .. run .. "</w:p>"
end

-- Caption: columns 3.3 in / 0.25 in / rest (6.5 in text width = 9360 twips), ")" on every row.
local function caption_table(rows, indents)
  local out = {
    '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>' .. NOBORDER
      .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
      .. '</w:tblPr><w:tblGrid><w:gridCol w:w="4752"/><w:gridCol w:w="360"/><w:gridCol w:w="4248"/></w:tblGrid>',
  }
  for i, row in ipairs(rows) do
    local left = stringify(row[1]):gsub("^%s+", ""):gsub("%s+$", "")
    local right = row[2] and stringify(row[2]) or ""
    out[#out + 1] = "<w:tr>"
      .. '<w:tc><w:tcPr><w:tcW w:w="4752" w:type="dxa"/></w:tcPr>'
      .. cell_p(left, { indent = indents[i] }) .. "</w:tc>"
      .. '<w:tc><w:tcPr><w:tcW w:w="360" w:type="dxa"/></w:tcPr>' .. cell_p(")", { center = true }) .. "</w:tc>"
      .. '<w:tc><w:tcPr><w:tcW w:w="4248" w:type="dxa"/></w:tcPr>' .. cell_p(right, {}) .. "</w:tc>"
      .. "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return pandoc.RawBlock("openxml", table.concat(out))
end

-- Inline content of a block list (Para/Plain), joined with a space, for a lettered item.
local function join_inlines(blocks)
  local inl = {}
  for _, b in ipairs(blocks) do
    if b.t == "Para" or b.t == "Plain" then
      if #inl > 0 then inl[#inl + 1] = pandoc.Space() end
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
    end
  end
  return inl
end

function Pandoc(doc)
  local meta = doc.meta
  local title = meta.title and stringify(meta.title):upper() or ""
  meta.title = nil -- the title is set by the cover below, not by pandoc's Title block
  local out = {}
  local function add(b) out[#out + 1] = b end

  -- Cover: court, caption, title
  add(para("Court Heading", { pandoc.Str("IN THE UNITED STATES BANKRUPTCY COURT") }))
  add(para("Court Heading", { pandoc.Str("FOR THE WESTERN DISTRICT OF OKLAHOMA") }))
  add(blank())
  if meta.caption and meta.caption.rows then
    add(caption_table(meta.caption.rows, caption_indents()))
  end
  add(blank())
  add(para("Court Heading", { pandoc.Str(title) }))
  add(blank())

  if meta.lead_in then
    add(para("Unnumbered Paragraph", meta.lead_in))
  end

  -- Body
  local k = 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      add(para("Centered Heading", { pandoc.Str(heading_caps(stringify(b.content))) }))
    elseif b.t == "Para" then
      k = k + 1
      local inl = { pandoc.Str(k .. "."), TAB }
      for _, x in ipairs(b.content) do inl[#inl + 1] = x end
      add(para("Numbered Paragraph", inl))
    elseif b.t == "BlockQuote" then
      for _, x in ipairs(b.content) do
        if x.t == "Para" or x.t == "Plain" then
          add(para("Unnumbered Paragraph", x.content))
        else
          add(x)
        end
      end
    elseif b.t == "BulletList" then
      for j, item in ipairs(b.content) do
        local inl = { pandoc.Str("(" .. string.char(96 + j) .. ")"), TAB }
        for _, x in ipairs(join_inlines(item)) do inl[#inl + 1] = x end
        add(para("Lettered Item", inl))
      end
    else
      add(b)
    end
  end

  -- Signature (LR 9004-1.D lines from the sample) and the approval line
  local sig = meta.signature and meta.signature.lines or {}
  add(blank())
  add(para("Signature Block", { pandoc.Str("Respectfully Submitted,") }))
  add(blank())
  for _, ln in ipairs(sig) do
    add(para("Signature Block", ln))
  end
  if meta.approval then
    add(blank())
    add(para("Single Spaced", { pandoc.Str("Approved by:") }))
    add(blank())
    for _, ln in ipairs(meta.approval) do
      add(para("Single Spaced", ln))
    end
  end

  return pandoc.Pandoc(out, meta)
end
