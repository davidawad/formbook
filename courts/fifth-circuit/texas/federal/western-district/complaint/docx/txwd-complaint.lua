-- W.D. Tex. complaint, DOCX engine (docs/DOCX.md). Builds, from the markdown contract, the same form as
-- typst/txwd-complaint.typ: court title, caption table (party column, § column, case column), title,
-- numbered body paragraphs (Word list numbering in the "Numbered Para" style), headings, centred count lines,
-- prayer lead-in ("~ "), signature table (date on the left, signature block on the right, kept together).
-- Content-agnostic: every case word comes from the sample's frontmatter, never from this file.
-- Styles (reference.docx, built by build-reference.sh): Centered, Single, Sig, Count, Numbered Para.

-- The caption's leading spaces are indents in the typst form; pandoc drops them from YAML strings, so they
-- are read from the raw frontmatter lines (same order as the caption rows).
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

-- one paragraph: style, optional direct pPr (already in schema order), optional bold, text
local function P(style, text, ppr, bold)
  local run = ""
  if text ~= "" then
    run = "<w:r>" .. (bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or "") .. '<w:t xml:space="preserve">' .. esc(text) .. "</w:t></w:r>"
  end
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr or "") .. "</w:pPr>" .. run .. "</w:p>"
end

local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

-- a borderless fixed-width table; cells is a list of rows, each a list of {widths-matched cell XML strings}
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

local function caption(rows, leads)
  local xml = {}
  for i, r in ipairs(rows) do
    local left = plain(r[1])
    local right = r[2] and plain(r[2]) or ""
    local lead = leads[i] or 0
    local lpp = lead > 0 and ('<w:ind w:left="' .. (lead * INDENT_UNIT) .. '"/>') or ""
    local rpp = '<w:ind w:left="288"/>'
    xml[#xml + 1] = {
      P("Single", left, lpp),
      P("Single", "§", '<w:jc w:val="center"/>'),
      P("Single", right, rpp),
    }
  end
  return xml
end

local function signature_xml(meta)
  local sig = meta.signature
  if not sig then return nil end
  local right = {}
  right[#right + 1] = P("Sig", "Respectfully submitted,")
  right[#right + 1] = P("Sig", "")
  if sig.firm then
    for _, l in ipairs(sig.firm) do right[#right + 1] = P("Sig", plain(l)) end
    right[#right + 1] = P("Sig", "")
  end
  right[#right + 1] = P("Sig", "/s/ " .. plain(sig.signer))
  for _, l in ipairs(sig.lines or {}) do
    local t = plain(l)
    right[#right + 1] = P("Sig", t)
  end
  local left = P("Single", meta.date and ("Dated: " .. plain(meta.date)) or "", '<w:keepNext/><w:keepLines/>')
  return table_xml({ 4752, 4608 }, { { left, table.concat(right) } })
end

-- a Para whose text starts with "~ " is an unnumbered paragraph (the prayer lead-in)
local function unnumbered(b)
  local first = b.content[1]
  if first and first.t == "Str" and first.text == "~" then
    local rest = pandoc.List(b.content)
    rest:remove(1)
    if rest[1] and rest[1].t == "Space" then rest:remove(1) end
    return pandoc.Para(rest)
  end
  return nil
end

local function soft_to_line(inls)
  local out = pandoc.List({})
  for _, i in ipairs(inls) do
    if i.t == "SoftBreak" then out:insert(pandoc.LineBreak()) else out:insert(i) end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end
  local function raw(x) add(pandoc.RawBlock("openxml", x)) end
  local function gap(n) for _ = 1, n do raw(P("Single", "")) end end

  -- cover
  for _, line in ipairs(meta.court or {}) do raw(P("Single", plain(line), '<w:jc w:val="center"/>', true)) end
  gap(2)
  if meta.caption then
    raw(table_xml({ CAPTION_LEFT, CAPTION_MID, CAPTION_RIGHT }, caption(meta.caption, caption_leads())))
  end
  gap(2)
  if meta.title then raw(P("Single", plain(meta.title), '<w:jc w:val="center"/>', true)) end
  gap(1)

  -- body
  for _, b in ipairs(doc.blocks) do
    if b.t == "BlockQuote" then
      -- count headings: one centred single-spaced line per source line
      for _, p in ipairs(b.content) do
        if p.t == "Para" or p.t == "Plain" then
          add(pandoc.Div({ pandoc.Para(soft_to_line(p.content)) }, pandoc.Attr("", {}, { ["custom-style"] = "Count Heading" })))
        end
      end
    elseif b.t == "Para" then
      local u = unnumbered(b)
      if u then
        add(u)
      else
        add(pandoc.Div({ b }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered Para" })))
      end
    else
      add(b)
    end
  end

  -- signature block (CV-10(b)); kept on one page
  gap(1)
  if meta.signature then raw(signature_xml(meta)) end

  return pandoc.Pandoc(out, pandoc.Meta({}))
end
