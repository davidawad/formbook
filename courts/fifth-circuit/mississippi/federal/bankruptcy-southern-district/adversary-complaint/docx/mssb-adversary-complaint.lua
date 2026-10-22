-- Adversary complaint for the U.S. Bankruptcy Court, S.D. Mississippi (mssb), docx engine: what the Word output adds
-- to pandoc's conversion, so that it reads and breaks as typst/mssb-adversary-complaint.typ does: the court name and
-- caption (FRBP 9004(b)), the title (Miss. Bankr. L.R. 5005-1(a)(2)(I)), the lead-in and the consent statement
-- (FRBP 7008(a); L.R. 7008-1), the numbered paragraphs (Fed. R. Civ. P. 10(b)), lettered sub-items, headings, the
-- fee table and the signature block (L.R. 5005-1(a)(2)(H)(i), 9011-1). pandoc writes the paragraphs that may carry
-- footnotes (styles Body Text, Numbered, Lettered and their Keep variants, from docx/reference.xml) and the notes
-- (Footnote Text). Everything printed comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local GAP = 276                          -- typst gap: one blank single line
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_GUTTER = 5184, 360   -- typst caption-left 3.6 in, caption-gutter 0.25 in
local SIG_INDENT = 4680                  -- typst signature-indent 3.25 in
local TABLE_IND, TABLE_COL = 1440, 3240  -- typst table-indent 1 in, table-col 2.25 in
local CELL_INSET = 173                   -- typst cell-inset 8.65 pt

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function need(v, msg)
  if v == nil or plain(v) == "" then error("mssb-adversary-complaint: " .. msg) end
  return v
end

-- A single-pitch paragraph: o = { keep, before, after, line, left, jc }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = o.keep == "next" and "<w:keepNext/>" or xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, nil, 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local NO_BORDERS = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
  '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
local LOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

local function cell_mar(l, r)
  return '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="' .. l .. '" w:type="dxa"/>' ..
    '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="' .. r .. '" w:type="dxa"/></w:tblCellMar>'
end

local function tc(w, body, pr)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") .. '</w:tcPr>' .. body .. '</w:tc>'
end

-- ---------------------------------------------------------------------------
-- Cover: court name, caption (one table: names | case facts and designations, a blank single line between the
-- blocks), title
-- ---------------------------------------------------------------------------

local function caption(meta)
  local c = need(meta.caption, "frontmatter needs caption (debtor, case_number, chapter, parties, adversary_number)")
  local right_w = TEXTW - CAP_LEFT
  local rows = {}
  local function stack(list, jc)
    local out = {}
    for _, s in ipairs(list) do out[#out + 1] = p(xe.inl(s), { jc = jc }) end
    return table.concat(out)
  end
  local function row(left, right, jc)
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. tc(CAP_LEFT, stack(left)) ..
      tc(right_w, stack(right, jc), '<w:tcMar><w:left w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcMar>') .. '</w:tr>'
  end
  local function spacer()
    rows[#rows + 1] = '<w:tr><w:trPr><w:trHeight w:val="' .. GAP .. '" w:hRule="exact"/></w:trPr>' ..
      tc(TEXTW, p("", { line = GAP }), '<w:gridSpan w:val="2"/>') .. '</w:tr>'
  end
  row(c.debtor.names, { "CASE NO. " .. plain(c.case_number), c.chapter })
  spacer()
  for k, party in ipairs(c.parties) do
    if k > 1 then
      spacer()
      row({ "V." }, { "ADV. PROC. NO. " .. plain(c.adversary_number) })
      spacer()
    end
    row(party.names, { party.designation }, "right")
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. NO_BORDERS .. cell_mar(0, 0) .. LOOK ..
    '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. right_w .. '"/></w:tblGrid>' ..
    table.concat(rows) .. '</w:tbl>'
end

local function cover(meta)
  local court = { "IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE SOUTHERN DISTRICT OF MISSISSIPPI" }
  if plain(meta.division) ~= "" then court[#court + 1] = pandoc.text.upper(plain(meta.division)) end
  local out = {}
  for k, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", after = k == #court and GAP or 0 })
  end
  out[#out + 1] = caption(meta)
  local title = need(meta.title, "frontmatter needs title (FRBP 9004(b)(4); 5005-1(a)(2)(I))")
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(title)), { b = true }), { jc = "center", before = GAP, after = GAP })
  return table.concat(out)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A heading, one line at the double pitch, kept with the block after it: level 1 centered bold capitals, level 2
-- centered bold, level 3 bold italic at the left.
local function heading(el)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local lvl = math.min(el.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl == 3 and "left" or "center") }, xe.inl(content, { b = true, i = lvl == 3 }))
end

-- A pipe table: single-spaced, indented 1 in, columns of 2.25 in, each cell aligned as the markdown says; a blank
-- single line after it (typst pipe-table).
local function fee_table(tbl)
  local n = #tbl.colspecs
  local jcs = {}
  for i, cs in ipairs(tbl.colspecs) do
    local a = tostring(cs[1])
    jcs[i] = a == "AlignRight" and "right" or a == "AlignCenter" and "center" or "left"
  end
  local function row(r)
    local cells = {}
    for i, c in ipairs(r.cells) do
      local inl = {}
      for _, blk in ipairs(c.contents) do inl[#inl + 1] = xe.inl(blk.content) end
      cells[#cells + 1] = tc(TABLE_COL, p(table.concat(inl, xe.runs(" ")), { jc = jcs[i] }))
    end
    return '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(cells) .. '</w:tr>'
  end
  local rows = {}
  for _, r in ipairs(tbl.head.rows) do rows[#rows + 1] = row(r) end
  for _, b in ipairs(tbl.bodies) do
    for _, r in ipairs(b.body) do rows[#rows + 1] = row(r) end
  end
  local grid = {}
  for _ = 1, n do grid[#grid + 1] = '<w:gridCol w:w="' .. TABLE_COL .. '"/>' end
  -- the rows stay together, as typst's unbreakable table block
  for i = 1, #rows - 1 do
    rows[i] = rows[i]:gsub("<w:pPr><w:spacing", "<w:pPr><w:keepNext/><w:spacing")
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. (n * TABLE_COL) .. '" w:type="dxa"/><w:tblInd w:w="' .. TABLE_IND ..
    '" w:type="dxa"/>' .. NO_BORDERS .. cell_mar(CELL_INSET, CELL_INSET) .. LOOK .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid>' .. table.concat(rows) .. '</w:tbl>' .. p("", { line = GAP })
end

-- The signature block: the date line, "Respectfully submitted," and the counsel lines in the right half; one block a
-- double line below the text.
local function signature(meta)
  local s = need(meta.signature, "frontmatter needs signature")
  local lines = { xe.runs("/s/ ") .. xe.inl(s.signer), xe.inl(s.signer), xe.inl(s.role) }
  for _, l in ipairs(s.counsel) do lines[#lines + 1] = xe.inl(l) end
  local out = {
    p(xe.inl(s.date), { before = BODY, keep = true }),
    p(xe.runs("Respectfully submitted,"), { left = SIG_INDENT, before = BODY, keep = true }),
  }
  for i, l in ipairs(lines) do
    out[#out + 1] = p(l, { left = SIG_INDENT, before = i == 1 and GAP or 0, keep = i < #lines or nil })
  end
  return table.concat(out)
end

local function has_note(inlines)
  for _, x in ipairs(inlines) do
    if x.t == "Note" then return true end
  end
  return false
end

-- A paragraph pandoc writes in `style`; one that anchors a footnote and is not kept takes the style's Note variant
-- (no widow control), so its lines stay on the page typst sets them on.
local function div(style, inlines)
  if has_note(inlines) and not style:find("Keep") then style = style .. " Note" end
  return pandoc.Div({ pandoc.Para(inlines) }, { ["custom-style"] = style })
end

local function labeled(label, content)
  local l = pandoc.Inlines({ pandoc.Str(label), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") })
  l:extend(content)
  return l
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- Two more of typst's rules (Unicode line breaking): no break between a section sign or pilcrow and its number,
-- also when the sign ends a word ("(¶ 5)"), nor at a space before a period, comma, colon or semicolon (". . ."):
-- that space becomes a no-break space.
local function binds(l)
  for i = 1, #l - 1 do
    local a, b = l[i], l[i + 1]
    if a.t == "Str" and b.t == "Space" then
      local nxt = l[i + 2]
      if (a.text:sub(-2) == "\u{00A7}" or a.text:sub(-2) == "\u{00B6}") or (nxt and nxt.t == "Str" and nxt.text:find("^[.,:;]")) then
        l[i + 1] = pandoc.Str("\u{00A0}")
      end
    end
  end
  return l
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = binds })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  local out = { xe.raw(cover(meta)) }
  if plain(meta.lead_in) ~= "" then
    out[#out + 1] = xe.raw(xe.para({ xe.style("BodyText") }, xe.inl(meta.lead_in)))
  end
  -- Consent statement (FRBP 7008(a); Miss. Bankr. L.R. 7008-1): an unnumbered paragraph after the lead-in.
  local consent = need(meta.consent, "frontmatter needs consent (FRBP 7008(a); Miss. Bankr. L.R. 7008-1)")
  out[#out + 1] = xe.raw(xe.para({ xe.style("BodyText") }, xe.inl(consent)))

  local blocks = doc.blocks
  local n = 0
  for bi, b in ipairs(blocks) do
    local keep = bi == #blocks and " Keep" or ""
    if b.t == "Header" then
      out[#out + 1] = xe.raw(heading(b))
    elseif b.t == "Para" or b.t == "Plain" then
      local t = plain(b.content)
      if t:sub(1, 9) == "WHEREFORE" or t:sub(1, 9) == "COMES NOW" then
        out[#out + 1] = div(keep ~= "" and "Body Keep" or "Body Text", b.content)
      else
        n = n + 1
        out[#out + 1] = div("Numbered" .. keep, labeled(n .. ".", b.content))
      end
    elseif b.t == "BulletList" or b.t == "OrderedList" then
      for i, item in ipairs(b.content) do
        local content = pandoc.Inlines({})
        for k, blk in ipairs(item) do
          if k > 1 then content:insert(pandoc.Space()) end
          content:extend(blk.content)
        end
        local k = (keep ~= "" and i == #b.content) and " Keep" or ""
        out[#out + 1] = div("Lettered" .. k, labeled("(" .. string.char(96 + i) .. ")", content))
      end
    elseif b.t == "Table" then
      out[#out + 1] = xe.raw(fee_table(b))
    else
      error("mssb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = xe.raw(signature(meta))
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
