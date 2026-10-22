-- Complaint for the Western District of Arkansas, DOCX engine (docs/DOCX.md): markdown -> Word on the reference
-- document fb render builds from reference.xml. The same layout as ../typst/arwd-complaint.typ: the court title and
-- the caption (a borderless table) single spaced, the title in bold capitals, the lead-in, numbered paragraphs (the
-- filter numbers them; the sample types no numbers), lettered lists (a., b., ...), unnumbered paragraphs that start
-- with "^ ", headings, and the signature block. Every word comes from the sample's frontmatter or body.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the body, 276 a single line), the spaces between blocks
-- those of the typst template (the larger of after and before applies), and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY = 552                       -- typst pitch-body 27.6 pt
local SINGLE = 276                     -- typst pitch-single 13.8 pt
local BLANK = 552                      -- typst blank-line
local TEXT_ABOVE = 396                 -- typst text-above 19.8 pt
local SIG_GAP = 240                    -- typst sig-gap 12 pt
local TEXTW = 9360                     -- typst text-width, 6.5 in
local INDENT = 720                     -- typst para-indent 0.5 in
local LABEL = 720                      -- typst label-box 0.5 in
local GAP = 288                        -- typst column-gap 0.2 in
local CAP_LEFT = 5184 + GAP            -- typst caption-left 3.6 in, plus the gutter
local SIG_LEFT = 3744 + GAP            -- typst sig-left 2.6 in, plus the gutter

local function need(meta, key)
  if meta[key] == nil then error("arwd-complaint.lua: missing required metadata field `" .. key .. "`") end
  return meta[key]
end

local function upper(v)
  if type(v) == "string" then return v:upper() end
  return pandoc.Inlines(v):walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

-- A paragraph: o = { style, before, after, line, left, hanging, first, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, o.hanging == nil and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A borderless table of fixed widths: rows of cells, each cell { width, paras, right_pad }; one row is never split.
local function tbl(widths, rows)
  local grid = {}
  local total = 0
  for _, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
  end
  local out = { '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
    .. '</w:tblPr><w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid>' }
  for _, r in ipairs(rows) do
    out[#out + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>'
    for i, c in ipairs(r) do
      local paras = #c > 0 and table.concat(c) or p("")
      local mar = i < #widths and ('<w:tcMar><w:right w:w="' .. GAP .. '" w:type="dxa"/></w:tcMar>') or ""
      out[#out + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. mar .. '</w:tcPr>'
        .. paras .. '</w:tc>'
    end
    out[#out + 1] = '</w:tr>'
  end
  out[#out + 1] = '</w:tbl>'
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- First page: court title, caption, title
-- ---------------------------------------------------------------------------

local function first_page(meta)
  local out = {}
  local lines = {}
  for _, c in ipairs(need(meta, "court")) do lines[#lines + 1] = c end
  if meta.division then lines[#lines + 1] = meta.division end
  for i, l in ipairs(lines) do
    out[#out + 1] = p(xe.inl(upper(l)), { jc = "center", after = i == #lines and BLANK or 0 })
  end

  -- party names on the left with their designation on the right; "v." and the case number share the row
  -- between two parties
  local rows = {}
  for k, party in ipairs(need(meta, "caption").parties) do
    if k > 1 then
      rows[#rows + 1] = { { p(xe.runs("v.")) }, { p(xe.runs("CASE NO. " .. pandoc.utils.stringify(meta.case_number))) } }
    end
    for i, n in ipairs(party.names) do
      rows[#rows + 1] = { { p(xe.inl(n)) }, i == 1 and { p(xe.inl(party.designation), { jc = "right" }) } or {} }
    end
  end
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, rows)

  out[#out + 1] = p(xe.inl(upper(need(meta, "title")), { b = true }), { jc = "center", before = BLANK })
  if meta.subtitle then out[#out + 1] = p(xe.inl(meta.subtitle, { b = true }), { jc = "center" }) end
  if meta.lead_in then
    out[#out + 1] = p(xe.inl(meta.lead_in), { style = "BodyText", line = BODY, first = INDENT, before = TEXT_ABOVE })
  end
  return out
end

-- "Dated:" on the left; the firm, "/s/" over the signer's name, and the signer's lines on the right
local function signature(meta)
  local sig = need(meta, "signature")
  local right = {}
  for i, l in ipairs(sig.firm or {}) do right[#right + 1] = p(xe.inl(l), { before = i == 1 and TEXT_ABOVE or 0 }) end
  right[#right + 1] = p(xe.runs("/s/ ") .. xe.inl(need(sig, "signer")),
    { before = sig.firm and SIG_GAP or TEXT_ABOVE })
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = p(xe.inl(l)) end
  local left = { p(xe.runs("Dated: ") .. xe.inl(need(meta, "date")), { before = TEXT_ABOVE }) }
  return tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { left, right } })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function letter(i) return string.char(96 + i) .. "." end

-- a paragraph that begins "^ " is unnumbered (the WHEREFORE clauses): the marker is dropped, the indent kept
local function unnumbered(b)
  local c = b.content
  return c[1] and c[1].t == "Str" and c[1].text == "^" and c[2] and c[2].t == "Space"
end

local function body(blocks)
  local out = {}
  local n = 0
  for i, b in ipairs(blocks) do
    if b.t == "Header" then
      -- headings in a row are one group, a blank line above and below it, one line apart inside it
      local prev, nxt = blocks[i - 1], blocks[i + 1]
      local lvl = math.min(b.level, 3)
      out[#out + 1] = p(xe.inl(b.level == 1 and upper(b.content) or b.content, { b = true }), {
        style = "Heading" .. lvl, keep = true, line = BODY, jc = lvl < 3 and "center" or "left",
        before = (prev and prev.t == "Header") and 0 or BLANK,
        after = (nxt and nxt.t == "Header") and 0 or BLANK,
      })
    elseif b.t == "Para" or b.t == "Plain" then
      if unnumbered(b) then
        local ils = pandoc.Inlines(b.content)
        ils:remove(1)
        ils:remove(1)
        out[#out + 1] = p(xe.inl(ils), { style = "BodyText", line = BODY, first = INDENT })
      else
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content),
          { style = "BodyText", line = BODY, first = INDENT, tab = INDENT + LABEL })
      end
    elseif b.t == "OrderedList" then
      local k = b.listAttributes.start or 1
      for _, item in ipairs(b.content) do
        local inls = pandoc.Inlines({})
        for j, blk in ipairs(item) do
          if j > 1 then inls:insert(pandoc.Space()) end
          inls:extend(pandoc.utils.blocks_to_inlines({ blk }))
        end
        out[#out + 1] = p(xe.runs(letter(k) .. "\t") .. xe.inl(inls),
          { style = "BodyText", line = BODY, left = INDENT + LABEL, hanging = LABEL, tab = INDENT + LABEL })
        k = k + 1
      end
    else
      error("arwd-complaint.lua: unsupported block " .. b.t .. " (README.md, Markdown contract)")
    end
  end
  return out
end

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("157(b)(2)(I)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

local function finish(doc)
  local meta = doc.meta
  local out = {}
  for _, x in ipairs(first_page(meta)) do out[#out + 1] = xe.raw(x) end
  for _, x in ipairs(body(doc.blocks)) do out[#out + 1] = xe.raw(x) end
  out[#out + 1] = xe.raw(signature(meta))
  return pandoc.Pandoc(out, {})
end

return { { Str = break_rules }, { Pandoc = finish } }
