-- Pandoc filter for the tnmd complaint, engine docx, so that it reads and breaks as typst/tnmd-complaint.typ does:
-- court name and division, caption (one table row per party line, a column of ")" marks, on the right from the "v."
-- row down "Case No.", a blank line and "JURY DEMAND" (LR 7.03(c)), a blank line and the judges), the title, the
-- unnumbered lead-in, numbered paragraphs (Fed. R. Civ. P. 10(b)), unnumbered "~" paragraphs, headings, the
-- lettered prayer items, and the signature block kept together with the last block (Fed. R. Civ. P. 11(a)). Every
-- case word comes from the sample's frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. Body paragraphs are
-- written by pandoc in the styles of docx/reference.xml; the rest is written here.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-body 27.6 pt, pitch-single 13.8 pt
local GAP = 276                          -- typst gap: a blank single line
local HEAD_ABOVE, HEAD_BELOW = 276, 138  -- typst head-above 13.8 pt, head-below 6.9 pt
local SIG_GAP = 138                      -- typst sig-gap 6.9 pt
local INDENT = 720                       -- typst para-indent, item-indent and item-label, 0.5 in
local DESIGNATION = 1440                 -- typst designation-indent, 1 in
local SIG = 4680                         -- typst signature-indent, 3.25 in
local LEFT, MARKS = 4752, 432            -- typst caption-left 3.3 in, caption-marks 0.3 in
local TEXTW = 9360                       -- 6.5 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function list(m)
  if m == nil then return {} end
  return m
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 1331": a no-break space; typst binds it with a box).
local function bind_doubled(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and (a.text == "\u{00A7}\u{00A7}" or a.text == "\u{00B6}\u{00B6}") and b.t == "Space" then
      inlines[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inlines
end

-- A metadata value with the same break rules as the body.
local function meta_inl(m)
  if type(m) == "string" then return m end
  return pandoc.Inlines(m):walk({ Str = breaks }):walk({ Inlines = bind_doubled })
end

-- ---------------------------------------------------------------------------
-- Caption (Fed. R. Civ. P. 10(a); LR 7.03(c))
-- ---------------------------------------------------------------------------

-- The lines a caption line takes in its column (typst measures it): its width estimated from Times New Roman's
-- advances at 12 pt (capitals and wide letters 0.72 em, small letters 0.47 em, spaces 0.25 em, the rest 0.4 em).
local function caption_rows(text, indent)
  local w = indent / 20
  for _, c in utf8.codes(text) do
    local ch = utf8.char(c)
    if ch == " " then w = w + 3
    elseif ch:match("^[A-Z]$") or ch == "m" or ch == "w" then w = w + 8.64
    elseif ch:match("^[a-z]$") then w = w + 5.64
    else w = w + 4.8 end
  end
  return math.max(1, math.ceil(w / (LEFT / 20)))
end

local function tc(w, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/></w:tcPr>' .. body .. '</w:tc>'
end

local function caption(meta, out)
  out[#out + 1] = p(xe.runs("IN THE UNITED STATES DISTRICT COURT", { b = true }), { jc = "center" })
  out[#out + 1] = p(xe.runs("FOR THE MIDDLE DISTRICT OF TENNESSEE", { b = true }), { jc = "center" })
  out[#out + 1] = p(xe.inl(meta_inl(meta.division), { b = true }), { jc = "center", after = BODY })
  -- the party lines: { inlines, plain text, left indent, is "v." }; nil inlines is a blank line
  local left = {}
  local parties = list(meta.caption.parties)
  for i, side in ipairs(parties) do
    if i > 1 then
      left[#left + 1] = { nil }
      left[#left + 1] = { xe.runs("v."), "v.", 0, true }
      left[#left + 1] = { nil }
    end
    left[#left + 1] = { xe.inl(meta_inl(side.names)), plain(side.names), 0, false }
    left[#left + 1] = { nil }
    left[#left + 1] = { xe.inl(meta_inl(side.designation)), plain(side.designation), DESIGNATION, false }
  end
  local v = 1
  for k, l in ipairs(left) do
    if l[4] then v = k; break end
  end
  -- the right column, one line per row from the "v." row down; false is a blank line
  local case_no = plain(meta.case_number)
  if case_no == "" then case_no = string.rep("_", 16) end
  local right = { xe.runs("Case No. " .. case_no) }
  if meta.jury_demand == true then
    right[#right + 1] = false
    right[#right + 1] = xe.runs("JURY DEMAND")
  end
  if meta.judges and #meta.judges > 0 then
    right[#right + 1] = false
    for _, j in ipairs(meta.judges) do right[#right + 1] = xe.inl(meta_inl(j)) end
  end
  while #left < v - 1 + #right do left[#left + 1] = { nil } end
  local rw = TEXTW - LEFT - MARKS
  local rows = {}
  for k, l in ipairs(left) do
    local text, n = p(""), 1
    if l[1] then
      text = p(l[1], { left = l[3] })
      n = caption_rows(l[2], l[3])
    end
    local marks = {}
    for _ = 1, n do marks[#marks + 1] = p(xe.runs(")")) end
    local r = p("")
    local ri = right[k - v + 1]
    if k >= v and ri then r = p(ri) end
    rows[#rows + 1] = '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. tc(LEFT, text) .. tc(MARKS, table.concat(marks)) ..
      tc(rw, r) .. '</w:tr>'
  end
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' ..
    '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>' ..
    '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid><w:gridCol w:w="' .. LEFT .. '"/><w:gridCol w:w="' .. MARKS .. '"/><w:gridCol w:w="' .. rw ..
    '"/></w:tblGrid>' .. table.concat(rows) .. '</w:tbl>'
  -- the title; Word has no space after a table, so the title takes the space before it
  out[#out + 1] = p(xe.inl(meta_inl(meta.title), { b = true }), { before = BODY, jc = "center", keep = true })
end

-- ---------------------------------------------------------------------------
-- Signature (Fed. R. Civ. P. 11(a); LR 7.03(a))
-- ---------------------------------------------------------------------------

local function signature(sig, out)
  local first = sig.date and xe.inl(meta_inl(sig.date)) or xe.runs("Respectfully submitted,")
  local lines = { { first, GAP }, { xe.inl(meta_inl(sig.signer)), GAP } }
  for i, l in ipairs(list(sig.lines)) do lines[#lines + 1] = { xe.inl(meta_inl(l)), i == 1 and SIG_GAP or 0 } end
  -- kept on one page (typst's unbreakable block): every line but the last keeps with the next
  for i, l in ipairs(lines) do
    out[#out + 1] = xe.raw(p(l[1], { before = l[2], left = SIG, keep = i < #lines }))
  end
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A paragraph that starts "~ " is unnumbered: the inlines without the marker, or nil.
local function unmarked(inl)
  if inl[1] and inl[1].t == "Str" and inl[1].text == "~" then
    local rest = pandoc.Inlines({})
    for k = 2, #inl do rest:insert(inl[k]) end
    if rest[1] and rest[1].t == "Space" then rest:remove(1) end
    return rest
  end
  return nil
end

local TAB = pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>")

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  doc.blocks = doc.blocks:walk({ Inlines = xe.inlines })
  local meta = doc.meta
  for _, k in ipairs({ "title", "division", "caption", "signature" }) do
    assert(meta[k], "tnmd-complaint: frontmatter needs " .. k)
  end

  local raw = {}
  caption(meta, raw)
  local out = {}
  for _, x in ipairs(raw) do out[#out + 1] = xe.raw(x) end
  if meta.lead_in then
    out[#out + 1] = pandoc.Div({ pandoc.Para(xe.inlines(meta_inl(meta.lead_in))) }, { ["custom-style"] = "Body Text" })
  end

  -- The body as a list of items: { kind, inlines | block, level }. pandoc reads a "~ " paragraph after another
  -- paragraph as the definition of a term (the paragraph before it); both are paragraphs here.
  local items = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == "DefinitionList" then
      for _, item in ipairs(b.content) do
        items[#items + 1] = { "para", item[1] }
        for _, d in ipairs(item[2]) do
          for _, db in ipairs(d) do
            if db.t ~= "Para" and db.t ~= "Plain" then error("tnmd-complaint.lua: unsupported block " .. db.t) end
            local c = pandoc.Inlines({ pandoc.Str("~"), pandoc.Space() })
            c:extend(db.content)
            items[#items + 1] = { "para", c }
          end
        end
      end
    elseif b.t == "Header" then
      items[#items + 1] = { "head", b.content, b.level }
    elseif b.t == "Para" or b.t == "Plain" then
      items[#items + 1] = { "para", b.content }
    elseif b.t == "OrderedList" then
      items[#items + 1] = { "list", b }
    else
      error("tnmd-complaint.lua: unsupported block " .. b.t)
    end
  end

  local n = 0
  for k, it in ipairs(items) do
    local last = k == #items
    if it[1] == "head" then
      -- single-spaced, bold, centered, kept with what follows; a stack of headings (a count) has no space inside
      local prev, nxt = items[k - 1], items[k + 1]
      local before = (prev and prev[1] == "head") and 0 or HEAD_ABOVE
      local after = (nxt and nxt[1] == "head") and 0 or HEAD_BELOW
      out[#out + 1] = xe.raw(xe.para({ xe.KEEP, xe.spacing(before, after, SINGLE), xe.ind(0, nil, 0), xe.jc("center"),
        '<w:outlineLvl w:val="' .. (math.min(it[3], 3) - 1) .. '"/>' }, xe.inl(it[2], { b = true })))
    elseif it[1] == "list" then
      -- prayer items, lettered A., B., ...: the letter in a half-inch box half an inch in, the text hanging an inch in
      local its = it[2].content
      for j, item in ipairs(its) do
        local inl = pandoc.Inlines({})
        for m, b in ipairs(item) do
          if m > 1 then inl:insert(pandoc.Space()) end
          inl:extend(b.content)
        end
        local body = xe.runs(string.char(64 + j) .. ".\t") .. xe.inl(inl)
        out[#out + 1] = xe.raw(p(body, { line = BODY, left = 2 * INDENT, hanging = INDENT, tab = 2 * INDENT,
          keep = last and j == #its }))
      end
    else
      local rest = unmarked(it[2])
      local style
      local inl
      if rest then
        style, inl = "Body Text", rest
      else
        n = n + 1
        style = "Body Numbered"
        inl = pandoc.Inlines({ pandoc.Str(n .. "."), TAB })
        inl:extend(it[2])
      end
      if last then style = style == "Body Text" and "Body Keep" or "Body Numbered Keep" end
      out[#out + 1] = pandoc.Div({ pandoc.Para(inl) }, { ["custom-style"] = style })
    end
  end

  signature(meta.signature, out)
  -- pandoc would print the metadata title above the body; the caption and title are written above
  return pandoc.Pandoc(out, pandoc.Meta({}))
end
