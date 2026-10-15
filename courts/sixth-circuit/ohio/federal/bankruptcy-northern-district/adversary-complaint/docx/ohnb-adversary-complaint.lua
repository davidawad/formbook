-- N.D. Ohio bankruptcy adversary complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on
-- reference.docx. Mirrors typst/ohnb-adversary-complaint.typ: court lines (centered), a caption table (the parties and
-- their designations on the left, a column of ")" marks, the case, chapter, judge and adversary numbers on the right),
-- the bold centered title, the body (headings centered bold caps; paragraphs with a 0.5 in first-line indent, double
-- spaced), and the signature block at the left margin. Nothing case-specific is written here: every string comes from
-- the sample's YAML frontmatter.

-- widths in twips: the typst caption grid (1.3fr, 0.3 in, 1fr) on the 6.5 in text width
local CAP_W = { 5046, 432, 3882 }

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return (s:gsub('"', "&quot;"))
end

local function text(v)
  if v == nil then return "" end
  return pandoc.utils.stringify(v)
end

-- a metadata list (or one value) as a Lua list of strings
local function strings(v)
  local out = {}
  if v == nil then return out end
  if type(v) == "table" and (v.t == nil or v.t == "MetaList") then
    for _, item in ipairs(v) do out[#out + 1] = text(item) end
  else
    out[1] = text(v)
  end
  return out
end

local function need(meta, key)
  if meta[key] == nil then error("ohnb-adversary-complaint: missing required metadata field `" .. key .. "`", 0) end
  return meta[key]
end

-- one raw paragraph: style, left indent, first-line indent (twips), justification, keep-with-next, run properties
local function p(s, opts)
  opts = opts or {}
  local ppr = ""
  if opts.style then ppr = ppr .. '<w:pStyle w:val="' .. opts.style .. '"/>' end
  if opts.keepNext then ppr = ppr .. "<w:keepNext/>" end
  if opts.line then
    ppr = ppr .. '<w:spacing w:before="0" w:after="0" w:line="' .. opts.line .. '" w:lineRule="exact"/>'
  end
  if opts.ind then ppr = ppr .. '<w:ind w:left="' .. opts.ind .. '" w:firstLine="0"/>' end
  if opts.jc then ppr = ppr .. '<w:jc w:val="' .. opts.jc .. '"/>' end
  local run = ""
  if s ~= nil and s ~= "" then
    run = "<w:r>" .. (opts.rpr and ("<w:rPr>" .. opts.rpr .. "</w:rPr>") or "")
      .. '<w:t xml:space="preserve">' .. esc(s) .. "</w:t></w:r>"
  end
  return "<w:p>" .. (ppr ~= "" and ("<w:pPr>" .. ppr .. "</w:pPr>") or "") .. run .. "</w:p>"
end

local BOLD = "<w:b/><w:bCs/>"

-- a blank paragraph of the given exact height in twips (typst v(1.2em) is 288 twips at 12 pt)
local function gap(twips)
  return p("", { style = "Single", line = twips })
end

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'

local function table_xml(widths, rows)
  local total = 0
  for _, w in ipairs(widths) do total = total + w end
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. NO_BORDERS
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/>'
    .. "</w:tblCellMar></w:tblPr><w:tblGrid>" }
  for _, w in ipairs(widths) do out[#out + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  out[#out + 1] = "</w:tblGrid>"
  for _, row in ipairs(rows) do
    out[#out + 1] = "<w:tr><w:trPr><w:cantSplit/></w:trPr>"
    for c, cell in ipairs(row) do
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[c] .. '" w:type="dxa"/></w:tcPr>' .. cell .. "</w:tc>"
    end
    out[#out + 1] = "</w:tr>"
  end
  out[#out + 1] = "</w:tbl>"
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- caption (FRBP 9004(b), 7010: court, parties, case, chapter, judge, adversary number; typst caption())
-- ---------------------------------------------------------------------------

local function caption(meta)
  local out = {}
  for _, l in ipairs(strings(need(meta, "court"))) do
    out[#out + 1] = p(string.upper(l), { style = "Centered" })
  end
  if meta.division ~= nil then out[#out + 1] = p(string.upper(text(meta.division)), { style = "Centered" }) end
  out[#out + 1] = gap(288)

  local left = {}
  for _, d in ipairs(strings(need(meta, "debtor-caption"))) do left[#left + 1] = d end
  left[#left + 1] = ""
  left[#left + 1] = "Debtor."
  left[#left + 1] = ""
  left[#left + 1] = "____________________________________"
  left[#left + 1] = ""
  for _, pl in ipairs(strings(need(meta, "plaintiffs"))) do left[#left + 1] = string.upper(pl) end
  left[#left + 1] = "Plaintiff,"
  left[#left + 1] = ""
  left[#left + 1] = "v."
  left[#left + 1] = ""
  for _, d in ipairs(strings(need(meta, "defendants"))) do left[#left + 1] = string.upper(d) end
  left[#left + 1] = "Defendant."

  local right = { "Case No. " .. text(need(meta, "case-number")), "" }
  if meta.chapter ~= nil then right[#right + 1] = "Chapter " .. text(meta.chapter); right[#right + 1] = "" end
  if meta.judge ~= nil then right[#right + 1] = "Judge " .. text(meta.judge); right[#right + 1] = "" end
  if meta["adversary-number"] ~= nil then right[#right + 1] = "Adv. Pro. No. " .. text(meta["adversary-number"]) end

  local n = math.max(#left, #right)
  local rows = {}
  for i = 1, n do
    rows[#rows + 1] = {
      p(left[i] or "", { style = "Single" }),
      p(")", { style = "Single", jc = "center" }),
      p(right[i] or "", { style = "Single" }),
    }
  end
  out[#out + 1] = table_xml(CAP_W, rows)

  out[#out + 1] = gap(288)
  out[#out + 1] = p(text(need(meta, "title")), { style = "Centered", rpr = BOLD })
  out[#out + 1] = gap(288)
  return out
end

-- ---------------------------------------------------------------------------
-- signature block (LBR 5005-1(c); typst signature()): at the left margin, kept together
-- ---------------------------------------------------------------------------

-- the markdown of one signature line (italics as written) as a list of Word paragraphs in the Signature style
local function md_para(s)
  local doc = pandoc.read(s, "markdown+smart")
  local inl = pandoc.utils.blocks_to_inlines(doc.blocks)
  return pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "Signature" }))
end

local function signature(meta)
  local sig = need(meta, "signature")
  local out = {}
  out[#out + 1] = pandoc.RawBlock("openxml", p("Respectfully submitted,", { style = "Signature", keepNext = true }))
  out[#out + 1] = pandoc.RawBlock("openxml", gap(240))
  out[#out + 1] = pandoc.RawBlock("openxml", p("s/ " .. text(need(sig, "signer")), { style = "Signature", keepNext = true }))
  out[#out + 1] = pandoc.RawBlock("openxml", p(text(need(sig, "signer-name-printed")), { style = "Signature", keepNext = true }))
  local lines = strings(need(sig, "lines"))
  for _, l in ipairs(lines) do
    out[#out + 1] = md_para(l)
  end
  return out
end

-- ---------------------------------------------------------------------------
-- body: the markdown blocks as written (headings centered bold caps, paragraphs indented; Reference styles)
-- ---------------------------------------------------------------------------

function Pandoc(doc)
  local meta = doc.meta
  local out = {}
  for _, x in ipairs(caption(meta)) do out[#out + 1] = pandoc.RawBlock("openxml", x) end
  -- the caption carries the title; pandoc would otherwise write the metadata title again
  meta.title = nil
  for _, b in ipairs(doc.blocks) do out[#out + 1] = b end
  out[#out + 1] = pandoc.RawBlock("openxml", gap(360))
  for _, b in ipairs(signature(meta)) do out[#out + 1] = b end
  return pandoc.Pandoc(out, meta)
end
