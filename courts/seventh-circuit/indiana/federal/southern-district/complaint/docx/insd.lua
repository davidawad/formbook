-- S.D. Ind. (insd) complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on
-- reference.docx, laid out as typst/insd-complaint.typ lays it out. The cover (court lines, caption
-- table, title), the numbered paragraphs and the signature block are built here; the body keeps its
-- markdown structure. Page numbers come from the reference's footer.
-- Every case-specific word comes from the sample's frontmatter (the caption lines are read as written,
-- so their spacing survives); nothing is measured from an exemplar and no line is forced.

local CFG = {
  numbered = true,            -- Fed. R. Civ. P. 10(b): paragraphs after the first heading are numbered
  caption_party_tw = 4896,    -- 3.4 in, the party column (typst caption-party-w)
  caption_paren_tw = 432,     -- 0.3 in, the column of ")" marks (typst caption-paren-w)
  caption_total_tw = 9360,    -- 6.5 in, the text width
  sig_indent_tw = 4680,       -- 3.25 in, the signature block (typst pad left)
}

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------

local function esc(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function txt(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return pandoc.utils.stringify(v)
end

-- the sample's raw frontmatter lines (between the first two "---" lines)
local function frontmatter_lines()
  local f = PANDOC_STATE and PANDOC_STATE.input_files and PANDOC_STATE.input_files[1]
  if not f then return {} end
  local h = io.open(f, "r")
  if not h then return {} end
  local text = h:read("a")
  h:close()
  local lines, dashes = {}, 0
  for line in (text .. "\n"):gmatch("(.-)\r?\n") do
    if dashes >= 2 then break end
    if line == "---" then
      dashes = dashes + 1
    elseif dashes == 1 then
      lines[#lines + 1] = line
    end
  end
  return lines
end

-- the caption side ("left" or "right") as written in the frontmatter: leading spaces inside quotes
-- are kept (the markdown metadata parser would drop them)
local function caption_side(side)
  local out, in_caption, in_side = {}, false, false
  for _, line in ipairs(frontmatter_lines()) do
    if line:match("^caption:%s*$") then
      in_caption, in_side = true, false
    elseif in_caption and line:match("^%S") then
      in_caption, in_side = false, false
    elseif in_caption and line:match("^  %S+:%s*$") then
      in_side = (line:match("^  (%S+):") == side)
    elseif in_caption and in_side then
      local item = line:match("^%s*%-%s(.*)$")
      if item then
        local q = item:match('^"(.*)"%s*$') or item:match("^'(.*)'%s*$")
        out[#out + 1] = q or item
      elseif line:match("^%s*%-%s*$") then
        out[#out + 1] = ""
      end
    end
  end
  return out
end

local function meta_list(v)
  local out = {}
  if v == nil then return out end
  if type(v) == "string" or v.t == "MetaInlines" or v.t == "MetaString" then
    out[#out + 1] = txt(v)
  else
    for _, item in ipairs(v) do out[#out + 1] = txt(item) end
  end
  return out
end

local function run(s, bold)
  local rpr = bold and "<w:rPr><w:b/><w:bCs/></w:rPr>" or ""
  return "<w:r>" .. rpr .. '<w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r>"
end

-- one single-spaced paragraph (style "Single" or "Centered")
local function para(style, runs, ppr_extra)
  return '<w:p><w:pPr><w:pStyle w:val="' .. style .. '"/>' .. (ppr_extra or "") .. "</w:pPr>" .. (runs or "") .. "</w:p>"
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local function page_break()
  return raw('<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
end

-- ---------------------------------------------------------------------------
-- cover: court lines, caption, title (typst cover())
-- ---------------------------------------------------------------------------

local function caption_table(left, right)
  local n = math.max(#left, #right)
  local parens = {}
  for i = 1, n do parens[i] = ")" end
  local function cell(width, lines, style)
    local ps = {}
    for _, l in ipairs(lines) do
      if l == "" then
        ps[#ps + 1] = para("Single", "")
      else
        ps[#ps + 1] = para("Single", run(l))
      end
    end
    if #ps == 0 then ps[1] = para("Single", "") end
    return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/></w:tcPr>' .. table.concat(ps) .. "</w:tc>"
  end
  local none = '<w:top w:val="none" w:sz="0" w:space="0" w:color="auto"/>'
    .. '<w:left w:val="none" w:sz="0" w:space="0" w:color="auto"/>'
    .. '<w:bottom w:val="none" w:sz="0" w:space="0" w:color="auto"/>'
    .. '<w:right w:val="none" w:sz="0" w:space="0" w:color="auto"/>'
    .. '<w:insideH w:val="none" w:sz="0" w:space="0" w:color="auto"/>'
    .. '<w:insideV w:val="none" w:sz="0" w:space="0" w:color="auto"/>'
  local paren_w = CFG.caption_paren_tw
  local right_w = CFG.caption_total_tw - CFG.caption_party_tw - paren_w
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. CFG.caption_total_tw .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. "<w:tblBorders>" .. none .. "</w:tblBorders>"
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/></w:tblPr>'
    .. '<w:tblGrid><w:gridCol w:w="' .. CFG.caption_party_tw .. '"/><w:gridCol w:w="' .. paren_w .. '"/><w:gridCol w:w="' .. right_w .. '"/></w:tblGrid>'
    .. "<w:tr>" .. cell(CFG.caption_party_tw, left) .. cell(paren_w, parens) .. cell(right_w, right) .. "</w:tr></w:tbl>"
end

local function cover(meta, title)
  local out = {}
  local court = meta_list(meta.court)
  for i, l in ipairs(court) do
    local gap = (i == #court) and '<w:spacing w:before="0" w:after="480"/>' or nil
    out[#out + 1] = raw(para("Centered", run(l, true), gap))
  end
  out[#out + 1] = raw(caption_table(caption_side("left"), caption_side("right")))
  out[#out + 1] = raw(para("Centered", run(string.upper(txt(title)), true), '<w:spacing w:before="360" w:after="0"/>'))
  if meta.jury_demand == true then
    out[#out + 1] = raw(para("Centered", run("JURY TRIAL DEMANDED", true), '<w:spacing w:before="120" w:after="240"/>'))
  else
    out[#out + 1] = raw(para("Centered", "", '<w:spacing w:before="0" w:after="240"/>'))
  end
  return out
end

-- ---------------------------------------------------------------------------
-- signature block (typst signature-block(): date line, then the lines indented 3.25 in)
-- ---------------------------------------------------------------------------

local function signature(sig, meta)
  local out = {}
  if not sig then return out end
  local lines = meta_list(sig.lines)
  out[#out + 1] = raw(para("Single", run(txt(sig.date)), '<w:keepNext/><w:keepLines/><w:spacing w:before="480" w:after="240"/>'))
  local ind = '<w:ind w:left="' .. CFG.sig_indent_tw .. '" w:firstLine="0"/>'
  for i, l in ipairs(lines) do
    local keep = (i < #lines) and "<w:keepNext/>" or ""
    local runs = (l == "") and "" or run(l)
    out[#out + 1] = raw(para("Single", runs, keep .. "<w:keepLines/>" .. ind))
  end
  return out
end

-- ---------------------------------------------------------------------------
-- body
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  local function add(b) out[#out + 1] = b end
  local function addall(bs) for _, b in ipairs(bs) do add(b) end end

  -- the title is written by the cover; drop pandoc's own Title block
  local title = meta.title
  meta.title = nil
  addall(cover(meta, title))

  -- paragraphs before the first heading (the lead-in) are not numbered; paragraphs that begin
  -- "WHEREFORE" are not numbered (typst chunk() rules)
  local seen, n = false, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      seen = true
      if b.level == 1 then
        b.content = b.content:walk({
          Str = function(s) return pandoc.Str(string.upper(s.text)) end,
        })
      end
      add(b)
    elseif b.t == "Para" and seen and CFG.numbered and not txt(b):match("^WHEREFORE") then
      n = n + 1
      local inl = pandoc.List({ pandoc.Str(tostring(n) .. "."), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
      inl:extend(b.content)
      add(pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Numbered" })))
    else
      add(b)
    end
  end

  addall(signature(meta.signature, meta))

  doc.blocks = out
  return doc
end
