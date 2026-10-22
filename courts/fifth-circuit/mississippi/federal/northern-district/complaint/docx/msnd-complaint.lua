-- Complaint for the U.S. District Court for the Northern District of Mississippi (msnd), docx engine: what the Word
-- output adds to pandoc's conversion, so that it reads and breaks as typst/msnd-complaint.typ does (README
-- "Engines"): the court title and caption (Fed. R. Civ. P. 10(a); "JURY TRIAL DEMANDED" when jury_demand is set),
-- the title, the unnumbered lead-in, the numbered paragraphs (Fed. R. Civ. P. 10(b); a paragraph that starts with
-- "WHEREFORE" is the unnumbered lead-in of the prayer), the headings (level 1 in capitals), the numbered prayer
-- items, the jury demand and the signature block (L.U.Civ.R. 11(a)). pandoc writes the body paragraphs (styles Body
-- Text, Body Number, the last one Body Keep) and their footnotes (Footnote Text). Caption and signature are OOXML
-- tables, because pandoc has no caption construct. Everything printed comes from the sample's frontmatter and body:
-- no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local ITEM_LEFT, ITEM_BOX = 1296, 576    -- typst item-indent + item-box (0.9 in), item-box 0.4 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 4680, 360   -- typst caption-left 3.25 in, caption-gutter 0.25 in
local CAP_INSET = 240                    -- typst caption-inset 12 pt
local CAP_PAD = 123                      -- typst caption-pad (half a single line, 138) less the 0.75 pt rule, which
                                         -- LibreOffice adds to the cell height
local RIGHT_INSET = 288                  -- typst right-inset 0.2 in
local SIG_LEFT, SIG_GUTTER = 3744, 288   -- typst sig-left 2.6 in, sig-gutter 0.2 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { style, keep, before, after, line, left, hanging, first, jc }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tbl(widths, cells)
  local grid, tcs = {}, {}
  for i, w in ipairs(widths) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) ..
    '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption (Fed. R. Civ. P. 10(a)), title of the pleading
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  -- The caption stands a single line below the title lines (Word has no space before a table: the last title line
  -- takes it as space after).
  local lines = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF MISSISSIPPI" }
  if plain(meta.division) ~= "" then lines[#lines + 1] = pandoc.text.upper(plain(meta.division)) .. " DIVISION" end
  for k, l in ipairs(lines) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = k == #lines and SINGLE or 0 })
  end
  -- Left cell: each party's names, then its designation; "v." between the parties.
  local left = {}
  local parties = meta.caption.parties
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation), { after = k == #parties and CAP_PAD or 0 })
  end
  -- Right cell: "CIVIL ACTION NO.:", the number, the jury demand.
  local right = { p(xe.runs("CIVIL ACTION NO.:")), p(xe.inl(meta.case_number)) }
  if meta.jury_demand == true then
    right[#right + 1] = p(xe.runs("JURY TRIAL DEMANDED"), { before = SINGLE })
  end
  local rule = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { pr = '<w:tcBorders><w:bottom ' .. rule .. '/><w:right ' .. rule .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { pr = '<w:tcMar><w:left w:w="' .. (CAP_GUTTER + RIGHT_INSET) .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
  -- The title: centered, bold, a line of the body pitch; Word has no space after a table, so it takes the single
  -- line below the caption as space before.
  out[#out + 1] = p(xe.inl(meta.title, { b = true }), { line = BODY, jc = "center", before = SINGLE, keep = true })
end

-- ---------------------------------------------------------------------------
-- Signature block: "Dated" at the left; "Respectfully submitted,", then "By: /s/" and the counsel lines
-- (L.U.Civ.R. 11(a)) at the right; the row never splits. The double line above it is Body Keep's space after.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local right = {
    p(xe.runs("Respectfully submitted,")),
    p(xe.runs("By: /s/ ") .. xe.inl(sig.signer), { before = SINGLE }),
  }
  for _, l in ipairs(sig.counsel or {}) do right[#right + 1] = p(xe.inl(l)) end
  return tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { body = { p(xe.runs("Dated: ") .. xe.inl(meta.date)) } },
    { pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right } })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings, kept with what follows: bold and centered (level 1 in capitals) in a line of the body pitch.
local function heading(level, content)
  if level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. math.min(level, 2)), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc("center") }, xe.inl(content, { b = true }))
end

-- Inlines as runs, a line break where the author wrote one (typst: cmarker's linebreak()).
local function runs_br(inlines)
  local out, seg = {}, pandoc.Inlines({})
  for _, el in ipairs(inlines) do
    if el.t == "LineBreak" then
      out[#out + 1] = xe.inl(seg) .. xe.BR
      seg = pandoc.Inlines({})
    else
      seg:insert(el)
    end
  end
  out[#out + 1] = xe.inl(seg)
  return table.concat(out)
end

-- The prayer: the number half an inch in, in a 0.4 in box, the text hanging after it; double-spaced.
local function prayer(b, out)
  local n = b.t == "OrderedList" and b.listAttributes.start or 1
  for _, item in ipairs(b.content) do
    for k, blk in ipairs(item) do
      local lab = k == 1 and ((b.t == "OrderedList" and (n .. ".") or "\u{2022}") .. "\t") or ""
      out[#out + 1] = xe.raw(p(xe.runs(lab) .. runs_br(blk.content), { line = BODY, left = ITEM_LEFT, hanging = ITEM_BOX }))
    end
    n = n + 1
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space), none between a doubled section sign and its number (typst boxes the
-- last sign with the number).
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end
local function signs(inls)
  for i = 1, #inls - 1 do
    local a, b = inls[i], inls[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}]+$") and b.t == "Space" then inls[i + 1] = pandoc.Str("\u{00A0}") end
  end
  return inls
end
-- A space before a footnote mark is dropped, as the typst template does (its markdown renderer trims it).
local function tight_marks(inls)
  local out = pandoc.Inlines({})
  for i, el in ipairs(inls) do
    local nxt = inls[i + 1]
    if not (el.t == "Space" and nxt and nxt.t == "Note") then out:insert(el) end
  end
  return out
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs }):walk({ Inlines = tight_marks })
  -- the body inlines pandoc writes itself; the metadata strings stay text (xe.inl applies the same rules to them)
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  local raw = {}
  cover(meta, raw)
  local out = { xe.raw(table.concat(raw)) }

  -- the paragraph before the signature (typst: `last`) is the jury demand, or else the last body paragraph
  local jury = meta.jury_demand_text ~= nil
  local last_para = 0
  if not jury then
    for i, b in ipairs(doc.blocks) do
      if b.t == "Para" or b.t == "Plain" then last_para = i end
    end
  end
  local function body(inlines, style)
    out[#out + 1] = pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
  end

  if meta.lead_in then body(xe.inlines(pandoc.Inlines(meta.lead_in)), "Body Text") end
  local n = 0
  for i, b in ipairs(doc.blocks) do
    local keep = i == last_para
    if b.t == "Header" then
      out[#out + 1] = xe.raw(heading(b.level, b.content))
    elseif b.t == "Para" or b.t == "Plain" then
      if plain(b.content):match("^WHEREFORE") then
        body(b.content, keep and "Body Keep" or "Body Text")
      else
        n = n + 1
        local inls = pandoc.Inlines({ pandoc.Str(n .. "."), TAB })
        inls:extend(b.content)
        body(inls, keep and "Body Keep" or "Body Number")
      end
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      prayer(b, out)
    else
      error("msnd-complaint.lua: unsupported block " .. b.t)
    end
  end
  if jury then
    out[#out + 1] = xe.raw(heading(1, pandoc.Inlines({ pandoc.Str("JURY DEMAND") })))
    body(xe.inlines(pandoc.Inlines(meta.jury_demand_text)), "Body Keep")
  end
  out[#out + 1] = xe.raw(signature(meta))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
