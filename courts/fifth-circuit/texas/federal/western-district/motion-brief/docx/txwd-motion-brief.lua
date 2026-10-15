-- W.D. Tex. motion with brief, DOCX engine (docs/DOCX.md). Builds, from the markdown contract, the same form as
-- typst/txwd-motion-brief.typ: cover (court title, caption table, title), table of contents (a TOC field whose
-- entries and page numbers are cached in the file: render.sh fills the numbers from a first pass), the body
-- (level-1 headings centred bold capitals, levels 2 and 3 left bold, paragraphs with a 0.5 in first-line
-- indent, block quotations, lists), the signature table and the certificate of service.
-- Content-agnostic: every case word comes from the sample's frontmatter, never from this file.
-- Environment (set by render.sh, not by the author):
--   TXWD_TOC_LIST   path to write the body headings to (first pass)
--   TXWD_TOC_PAGES  path to read the page numbers from, one per heading (second pass); if unset the entries
--                   carry the placeholder ZZ, which the first-pass page finder looks for.

local function frontmatter_lines()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then return {} end
  local h = io.open(f, "r")
  if not h then return {} end
  local text = h:read("a")
  h:close()
  local lines, dashes = {}, 0
  for line in (text .. "\n"):gmatch("(.-)\n") do
    if dashes < 2 then
      if line:match("^%-%-%-%s*$") then dashes = dashes + 1 end
    else
      break
    end
    if dashes == 1 and not line:match("^%-%-%-") then lines[#lines + 1] = line end
  end
  return lines
end

-- pandoc drops leading spaces from YAML strings; typst indents a caption row by its leading spaces
local function caption_leads()
  local leads, in_cap = {}, false
  for _, line in ipairs(frontmatter_lines()) do
    if line:match("^caption:%s*$") then
      in_cap = true
    elseif in_cap and line:match("^%S") then
      in_cap = false
    elseif in_cap then
      local q = line:match('%[%s*"([^"]*)"')
      if q then
        local stripped = q:gsub("^%s+", "")
        leads[#leads + 1] = #q - #stripped
      end
    end
  end
  return leads
end

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function plain(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- one paragraph: style, optional direct pPr (in schema order), bold, text
local function P(style, text, ppr, bold)
  local run = ""
  if text ~= "" then
    run = "<w:r>" .. (bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or "") .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
  end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>" .. run .. "</w:p>"
end

local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function table_xml(widths, rows)
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  local grid = {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. NOBORDER .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. "<w:tblGrid>" .. table.concat(grid) .. "</w:tblGrid>" }
  for _, row in ipairs(rows) do
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
    for i, cell in ipairs(row) do
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/></w:tcPr>' .. cell .. "</w:tc>"
    end
    out[#out + 1] = "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

local CAPTION_LEFT, CAPTION_MID, CAPTION_RIGHT = 5328, 432, 3600   -- 3.7 in, 0.3 in, the rest of 6.5 in
local INDENT_UNIT = 108                                            -- 0.075 in per leading space (typst form)

local function caption_rows(rows, leads)
  local out = {}
  for i, r in ipairs(rows) do
    local left = plain(r[1])
    local right = r[2] and plain(r[2]) or ""
    local lead = leads[i] or 0
    local lpp = lead > 0 and ('<w:ind w:left="' .. (lead * INDENT_UNIT) .. '"/>') or ""
    out[#out + 1] = {
      P("Single", left, lpp),
      P("Single", "§", '<w:jc w:val="center"/>'),
      P("Single", right, '<w:ind w:left="288"/>'),
    }
  end
  return out
end

local function signature_xml(sig)
  local right = {}
  right[#right + 1] = P("Sig", "Respectfully submitted,")
  right[#right + 1] = P("Sig", "")
  if sig.firm then
    for _, l in ipairs(sig.firm) do right[#right + 1] = P("Sig", plain(l)) end
    right[#right + 1] = P("Sig", "")
  end
  right[#right + 1] = P("Sig", "/s/ " .. plain(sig.signer))
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = P("Sig", plain(l)) end
  return table_xml({ 4752, 4608 }, { { P("Single", "", '<w:keepNext/><w:keepLines/>'), table.concat(right) } })
end

-- headings: level 1 is typst's upper(), levels 2 and 3 as written
local function upper_inlines(inls)
  local p = pandoc.Plain(inls):walk({
    Str = function(s) return pandoc.Str(s.text:upper()) end,
  })
  return p.content
end

local function soft_to_line(inls)
  local out = pandoc.List({})
  for _, i in ipairs(inls) do
    if i.t == "SoftBreak" then out:insert(pandoc.LineBreak()) else out:insert(i) end
  end
  return out
end

-- the table of contents: a TOC field whose cached result is the entries with dot leaders and page numbers
local function toc_block(entries, pages)
  local out = {}
  for i, e in ipairs(entries) do
    local pg = pages and pages[i] or "ZZ"
    local field = ""
    if i == 1 then
      field = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\o "1-3" </w:instrText></w:r>'
        .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    end
    local ending = ""
    if i == #entries then ending = '<w:r><w:fldChar w:fldCharType="end"/></w:r>' end
    out[#out + 1] = '<w:p><w:pPr><w:pStyle w:val="TOC' .. e.level .. '"/></w:pPr>' .. field
      .. '<w:r><w:t xml:space="preserve">' .. esc(e.text) .. '</w:t></w:r><w:r><w:tab/></w:r>'
      .. '<w:r><w:t>' .. esc(pg) .. "</w:t></w:r>" .. ending .. "</w:p>"
  end
  return table.concat(out)
end

local function read_pages(path, n)
  local h = io.open(path, "r")
  if not h then error("txwd-motion-brief: cannot read " .. path, 0) end
  local pages = {}
  for line in h:lines() do
    local v = line:match("^%s*(%d+)%s*$")
    if v then pages[#pages + 1] = v end
  end
  h:close()
  if #pages ~= n then error("txwd-motion-brief: " .. #pages .. " page numbers for " .. n .. " headings", 0) end
  return pages
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end
  local function raw(x) add(pandoc.RawBlock("openxml", x)) end
  local function gap(n) for _ = 1, n do raw(P("Single", "")) end end

  -- body headings, in order, for the table of contents
  local entries, blocks = {}, {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level <= 3 then
      local content = b.level == 1 and upper_inlines(b.content) or b.content
      local text = pandoc.utils.stringify(content)
      entries[#entries + 1] = { level = b.level, text = text }
      blocks[#blocks + 1] = pandoc.Header(b.level, content)
    else
      blocks[#blocks + 1] = b
    end
  end

  local list_path = os.getenv("TXWD_TOC_LIST")
  if list_path then
    local h = io.open(list_path, "w")
    if not h then error("txwd-motion-brief: cannot write " .. list_path, 0) end
    for _, e in ipairs(entries) do h:write(e.text, "\n") end
    h:close()
  end
  local pages_path = os.getenv("TXWD_TOC_PAGES")
  local pages = pages_path and read_pages(pages_path, #entries) or nil

  -- cover
  for _, line in ipairs(meta.court or {}) do raw(P("Single", plain(line), '<w:jc w:val="center"/>', true)) end
  gap(2)
  if meta.caption then
    raw(table_xml({ CAPTION_LEFT, CAPTION_MID, CAPTION_RIGHT }, caption_rows(meta.caption, caption_leads())))
  end
  gap(2)
  -- the title is double-spaced, as the typst form sets it (body leading)
  if meta.title then raw(P("Normal", plain(meta.title), '<w:jc w:val="center"/>', true)) end

  -- table of contents, on its own page
  raw(P("Single", plain(meta.toc_title), '<w:pageBreakBefore/><w:jc w:val="center"/>', true))
  gap(1)
  raw(toc_block(entries, pages))

  -- body, on its own page
  raw(P("BreakStart", ""))
  for _, b in ipairs(blocks) do
    add(b)
  end

  -- signature block (CV-10(b)), kept together
  gap(1)
  if meta.signature then raw(signature_xml(meta.signature)) end

  -- certificate of service
  if meta.certificate then
    local c = meta.certificate
    raw(P("Single", plain(c.heading), '<w:keepNext/><w:keepLines/><w:spacing w:before="624" w:after="0" w:line="312" w:lineRule="exact"/><w:jc w:val="center"/>', true))
    add(pandoc.Div({ pandoc.Para(c.text) }, pandoc.Attr("", {}, { ["custom-style"] = "Certificate Text" })))
    local right = {}
    right[#right + 1] = P("Sig", "/s/ " .. plain(c.signer), '<w:jc w:val="right"/>')
    for _, l in ipairs(c.lines or {}) do right[#right + 1] = P("Sig", plain(l), '<w:jc w:val="right"/>') end
    for _, x in ipairs(right) do raw(x) end
  end

  return pandoc.Pandoc(out, pandoc.Meta({}))
end
