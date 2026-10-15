-- D. Del. complaint, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document on reference.docx.
-- The caption, title, lead-in and signature block of typst/ded-complaint.typ are built here as paragraphs
-- and borderless tables (raw WordprocessingML) in the styles of reference.docx. The allegations keep their
-- markdown structure: each body paragraph is numbered (Fed. R. Civ. P. 10(b)) unless it starts with "!",
-- list items are lettered A., B., ... (the prayer), headings are the reference's Heading 1 to 3.
-- Content-agnostic: every word comes from the sample's frontmatter or body; nothing is case-specific here.
-- Known limits: see the Engines section of ../README.md.

local CFG = {
  pitch = 540,                  -- 27 pt exact: the double spacing of the template
  half = 270,                   -- 13.5 pt: half a line, the template's heading gap
  caption_left = 4752,          -- 3.3 in, the party column
  caption_gutter = 432,         -- 0.3 in
  caption_right = 4176,         -- the rest of the 6.5 in text width
  designation_indent = 2880,    -- 2 in, the designation under the names
  sig_left = 4176,              -- 2.9 in, the "Dated" column
  sig_gutter = 288,             -- 0.2 in
  sig_right = 4896,
  attorneys_indent = 4464,      -- 3.1 in
  court_lines = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF DELAWARE" },
}

-- ---------------------------------------------------------------------------
-- WordprocessingML helpers
-- ---------------------------------------------------------------------------

local function esc(s)
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
  return s
end

local function rpr(fl)
  local t = ""
  if fl.b then t = t .. "<w:b/><w:bCs/>" end
  if fl.i then t = t .. "<w:i/><w:iCs/>" end
  if fl.caps then t = t .. "<w:caps/>" end
  if t == "" then return "" end
  return "<w:rPr>" .. t .. "</w:rPr>"
end

local function run(text, fl)
  return '<w:r>' .. rpr(fl or {}) .. '<w:t xml:space="preserve">' .. esc(text) .. '</w:t></w:r>'
end

local function with(fl, k)
  local n = {}
  for a, b in pairs(fl or {}) do n[a] = b end
  n[k] = true
  return n
end

-- inline markdown content -> runs (italics and bold kept; links and spans keep their text)
local function runs(inls, fl, out)
  out = out or {}
  fl = fl or {}
  for _, el in ipairs(inls) do
    local t = el.t
    if t == "Str" then out[#out + 1] = run(el.text, fl)
    elseif t == "Space" or t == "SoftBreak" or t == "LineBreak" then out[#out + 1] = run(" ", fl)
    elseif t == "Emph" then runs(el.content, with(fl, "i"), out)
    elseif t == "Strong" then runs(el.content, with(fl, "b"), out)
    elseif t == "Span" or t == "Link" then runs(el.content, fl, out)
    elseif t == "Quoted" then
      local q = (el.quotetype == "DoubleQuote") and { "\u{201C}", "\u{201D}" } or { "\u{2018}", "\u{2019}" }
      out[#out + 1] = run(q[1], fl)
      runs(el.content, fl, out)
      out[#out + 1] = run(q[2], fl)
    else
      out[#out + 1] = run(pandoc.utils.stringify(el), fl)
    end
  end
  return table.concat(out)
end

-- a metadata value (MetaInlines, MetaString or empty) as inlines
local function inlines_of(v)
  if v == nil then return {} end
  if type(v) == "string" then return { pandoc.Str(v) } end
  return v
end

local function para(ppr, body)
  local p = ppr ~= "" and ("<w:pPr>" .. ppr .. "</w:pPr>") or ""
  return "<w:p>" .. p .. body .. "</w:p>"
end

local function spacer(twips)
  return para('<w:spacing w:before="0" w:after="0" w:line="' .. twips .. '" w:lineRule="exact"/>', "")
end

local function raw(xml)
  return pandoc.RawBlock("openxml", xml)
end

local SINGLE = '<w:pStyle w:val="Single"/>'
local CENTERED = '<w:pStyle w:val="Centered"/>'

-- borderless table with one row; cells: { xml = paragraphs }
local function row_table(widths, cells)
  local total, grid, tcs = 0, {}, {}
  for i, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    local c = cells[i] or { xml = "<w:p/>" }
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (c.borders or "")
      .. '</w:tcPr>' .. c.xml .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
    .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>'
    .. '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: court, caption (Fed. R. Civ. P. 10(a)), title
-- ---------------------------------------------------------------------------

local function caption_left(parties)
  local ps = {}
  for k, p in ipairs(parties) do
    if k > 1 then ps[#ps + 1] = para(SINGLE, run("v.")) end
    for _, n in ipairs(p.names) do ps[#ps + 1] = para(SINGLE, runs(inlines_of(n))) end
    ps[#ps + 1] = para(SINGLE .. '<w:ind w:left="' .. CFG.designation_indent .. '" w:firstLine="0"/>',
      runs(inlines_of(p.designation)))
  end
  return table.concat(ps)
end

local function cover(meta)
  local out = {}
  for _, line in ipairs(CFG.court_lines) do
    out[#out + 1] = raw(para(CENTERED, run(line, { b = true })))
  end
  out[#out + 1] = raw(spacer(CFG.pitch))
  local right = para(SINGLE .. '<w:spacing w:before="' .. CFG.half .. '" w:after="0" w:line="240" w:lineRule="auto"/>',
    run("C.A. No. " .. pandoc.utils.stringify(inlines_of(meta.case_number))))
  if meta.jury_demand == true then
    right = right .. para(SINGLE .. '<w:spacing w:before="' .. CFG.pitch .. '" w:after="0" w:line="240" w:lineRule="auto"/>',
      run("JURY TRIAL DEMANDED"))
  end
  out[#out + 1] = raw(row_table(
    { CFG.caption_left, CFG.caption_gutter, CFG.caption_right },
    { { xml = caption_left(meta.caption.parties) }, { xml = "<w:p/>" }, { xml = right } }))
  out[#out + 1] = raw(spacer(CFG.pitch))
  out[#out + 1] = raw(para(CENTERED, runs(inlines_of(meta.title), { b = true, caps = true })))
  out[#out + 1] = raw(spacer(CFG.half))
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block (Delaware counsel block under the signature line: LR 5.1.1(a))
-- ---------------------------------------------------------------------------

local function signature(meta)
  local out = {}
  local sig = meta.signature
  out[#out + 1] = raw(spacer(CFG.pitch))
  local left = para(SINGLE, run("Dated: " .. pandoc.utils.stringify(inlines_of(meta.date))))
  local right = ""
  for _, l in ipairs(sig.firm or {}) do right = right .. para(SINGLE, runs(inlines_of(l))) end
  right = right .. spacer(CFG.half)
  for _, l in ipairs(sig.lines or {}) do right = right .. para(SINGLE, runs(inlines_of(l))) end
  out[#out + 1] = raw(row_table({ CFG.sig_left, CFG.sig_gutter, CFG.sig_right },
    { { xml = left }, { xml = "<w:p/>" }, { xml = right } }))
  if meta.attorneys_for then
    out[#out + 1] = raw(spacer(CFG.half))
    for _, l in ipairs(meta.attorneys_for) do
      out[#out + 1] = raw(para(SINGLE .. '<w:ind w:left="' .. CFG.attorneys_indent .. '" w:firstLine="0"/>',
        runs(inlines_of(l))))
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Body: numbered allegations, lettered list items, headings from the markdown
-- ---------------------------------------------------------------------------

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

local function letter(i)
  return string.char(64 + i) .. "."   -- A., B., ...
end

local function body_blocks(doc)
  local out, n = {}, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Para" then
      local first = b.content[1]
      local unnumbered = first and first.t == "Str" and first.text:sub(1, 1) == "!"
      if unnumbered then
        first.text = first.text:sub(2)
        out[#out + 1] = b
      else
        n = n + 1
        table.insert(b.content, 1, pandoc.Str(n .. ".\u{2003}"))
        out[#out + 1] = b
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        local inl = pandoc.List({ pandoc.Str(letter(i)), TAB })
        local first = item[1]
        if first and (first.t == "Plain" or first.t == "Para") then
          inl:extend(first.content)
          for j = 2, #item do out[#out + 1] = item[j] end
        else
          for _, x in ipairs(item) do out[#out + 1] = x end
        end
        out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, pandoc.Attr("", {}, { ["custom-style"] = "List Letter" }))
      end
    else
      out[#out + 1] = b
    end
  end
  return out
end

function Pandoc(doc)
  local meta = doc.meta
  for _, k in ipairs({ "case_number", "caption", "title", "date", "signature" }) do
    if meta[k] == nil then error("ded: missing required metadata field `" .. k .. "`", 0) end
  end
  if meta.caption.parties == nil then error("ded: caption.parties is required", 0) end
  local out = {}
  local function add(xs) for _, x in ipairs(xs) do out[#out + 1] = x end end

  add(cover(meta))

  if meta.lead_in then
    out[#out + 1] = raw(para('<w:pStyle w:val="FirstParagraph"/>', runs(inlines_of(meta.lead_in))))
  end

  -- the body keeps the markdown's blocks (after the numbering pass)
  local body = pandoc.Pandoc(doc.blocks)
  for _, b in ipairs(body_blocks(body)) do out[#out + 1] = b end

  add(signature(meta))

  doc.blocks = out
  return doc
end
