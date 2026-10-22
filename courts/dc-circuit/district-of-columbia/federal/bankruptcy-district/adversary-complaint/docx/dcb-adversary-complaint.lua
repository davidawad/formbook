-- Adversary complaint for the United States Bankruptcy Court for the District of Columbia (dcb), docx engine: what
-- the Word output adds to pandoc's conversion, so that it reads and breaks as typst/dcb-adversary-complaint.typ does
-- (README "Engines"): the counsel block (LBR 5005-1(c)), the court title and the ")" caption (FRBP 9004(b)), the
-- title, the numbered paragraphs (Fed. R. Civ. P. 10(b)), the headings, the statement on final orders (FRBP 7008(a);
-- LBR 7012-1) and the signature block. Everything printed comes from the sample's frontmatter and body: no case text
-- lives in this file. Caption and signature are OOXML tables.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local INDENT = 720                       -- typst para-indent, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT, CAP_MID = 4752, 504      -- typst caption-left 3.3 in, caption-mid 0.35 in
local SIG_LEFT, SIG_GUTTER = 4032, 288   -- typst sig-left 2.8 in, sig-gutter 0.2 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, first, jc, keep }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(0, nil, o.first or 0)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A table: widths, then rows of cells (each a list of paragraphs, or { pr = .., body = {..} }).
local function tbl(widths, rows, trpr, keep)
  local grid, trs = {}, {}
  for _, w in ipairs(widths) do grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>' end
  for _, row in ipairs(rows) do
    local tcs = {}
    for i, c in ipairs(row) do
      local body = c.body or c
      tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. widths[i] .. '" w:type="dxa"/>' .. (c.pr or "") .. '</w:tcPr>' ..
        table.concat(body) .. '</w:tc>'
    end
    trs[#trs + 1] = '<w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: counsel block, court title, caption, title of the paper
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  local c = meta.counsel
  local lines = { c.name, c.bar, c.firm }
  for _, l in ipairs(c.address) do lines[#lines + 1] = l end
  lines[#lines + 1] = c.phone
  lines[#lines + 1] = c.email
  for _, l in ipairs(c.represents) do lines[#lines + 1] = l end
  for _, l in ipairs(lines) do out[#out + 1] = p(xe.inl(l)) end
  for i, l in ipairs(meta.court) do
    out[#out + 1] = p(xe.runs(plain(l), { b = true }), { jc = "center", before = i == 1 and BODY or 0,
      after = i == #meta.court and SINGLE or 0 })
  end
  -- The caption: one table row per line (typst: one grid row per line), so the ")" marks and the right column
  -- stand at the left column's lines even where one wraps.
  local cap = meta.caption
  local left = {}
  local function add(list) for _, x in ipairs(list) do left[#left + 1] = x end end
  add(cap.debtor.names)
  add({ cap.debtor.designation, "" })
  add(cap.plaintiff.names)
  add({ cap.plaintiff.designation, "v.", "" })
  add(cap.defendant.names)
  add({ cap.defendant.designation })
  local plaintiff_first = #cap.debtor.names + 3
  local adv = plain(cap.adversary_number)
  if adv == "" then adv = "____________" end
  local rows = {}
  for i, l in ipairs(left) do
    local right = ""
    if i == 1 then right = "In re:"
    elseif i == 2 then right = "Case No. " .. plain(cap.case_number)
    elseif i == 3 then right = "(Chapter " .. plain(cap.chapter) .. ")"
    elseif i == plaintiff_first then right = "Adv. Case No. " .. adv end
    rows[#rows + 1] = { { p(xe.inl(l)) }, { p(xe.runs(")"), { jc = "center" }) }, { p(xe.inl(right)) } }
  end
  out[#out + 1] = tbl({ CAP_LEFT, CAP_MID, TEXTW - CAP_LEFT - CAP_MID }, rows)
  -- typst: the caption block stands a double line above the title (Word has no space after a table)
  out[#out + 1] = p(xe.runs(plain(meta.title), { b = true }), { jc = "center", before = BODY, after = BODY })
  return out
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- A body paragraph at the double pitch, first-line indented; a numbered one: the number, a tab to 1 in (typst: the
-- number in a box of the paragraph indent), the text.
local function body_par(label, body, o)
  o = o or {}
  return p((label and xe.runs(label .. "\t") or "") .. body, { line = BODY, first = INDENT, before = o.before, keep = o.keep })
end

-- Headings: one centered line at the body pitch, level 1 bold, as written (the Heading 1 style's capitals off);
-- kept with the text after them.
local function heading(content, level, before)
  local runs = xe.inl(content, { b = level == 1 })
  runs = runs:gsub("<w:r>(<w:[^r])", "<w:r><w:rPr></w:rPr>%1")
  -- each run's properties in schema order: bold (level 2 not bold), italic, no capitals, then size and the rest
  runs = runs:gsub("<w:rPr>(.-)</w:rPr>", function(x)
    if level ~= 1 then x = '<w:b w:val="0"/><w:bCs w:val="0"/>' .. x end
    local at = x:find("<w:sz", 1, true) or x:find("<w:u ", 1, true) or x:find("<w:bdr", 1, true) or (#x + 1)
    return "<w:rPr>" .. x:sub(1, at - 1) .. '<w:caps w:val="0"/>' .. x:sub(at) .. "</w:rPr>"
  end)
  return xe.para({ xe.style("Heading" .. level), xe.KEEP, xe.spacing(before or 0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc("center") }, runs)
end

-- Statement on final orders and judgments (FRBP 7008(a); LBR 7012-1), kept with the signature block (typst: one
-- unbreakable block a double line below the text).
local function final_orders(meta)
  local consent = plain(meta.final_orders.consent)
  local stmt
  if consent == "consents" then
    stmt = "Plaintiff consents to the entry of final orders and judgments by the bankruptcy judge."
  elseif consent == "does-not-consent" then
    stmt = "Plaintiff does not consent to the entry of final orders and judgments by the bankruptcy judge."
  else
    error('dcb-adversary-complaint: final_orders.consent must be "consents" or "does-not-consent"')
  end
  local names = {}
  for _, n in ipairs(meta.caption.debtor.names) do names[#names + 1] = plain(n) end
  local cap = meta.caption
  return {
    heading("Statement on Final Orders and Judgments", 1, BODY),
    body_par(nil, xe.runs("This adversary proceeding arises in the chapter " .. plain(cap.chapter) .. " case of ") ..
      xe.runs("In re " .. table.concat(names, " "), { i = true }) ..
      xe.runs(", Case No. " .. plain(cap.case_number) .. ". " .. stmt), { keep = true }),
  }
end

-- The signature block: "Dated" at the left; "Respectfully submitted," and the signer's lines at the right.
local function signature(s)
  local left = { p(xe.runs("Dated: ") .. xe.inl(s.date), { before = BODY }) }
  local right = { p(xe.runs("Respectfully submitted,"), { before = BODY }) }
  local lines = { "By: /s/ " .. plain(s.signer), s.signer }
  if s.bar then lines[#lines + 1] = s.bar end
  for _, l in ipairs(s.address) do lines[#lines + 1] = l end
  lines[#lines + 1] = "Phone: " .. plain(s.phone)
  if s.fax then lines[#lines + 1] = "Facsimile: " .. plain(s.fax) end
  lines[#lines + 1] = "Email: " .. plain(s.email)
  for _, l in ipairs(s.role) do lines[#lines + 1] = l end
  for i, l in ipairs(lines) do right[#right + 1] = p(xe.inl(l), { before = i == 1 and SINGLE or 0 }) end
  return tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { left,
    { pr = '<w:tcMar><w:left w:w="' .. SIG_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right } } },
    '<w:trPr><w:cantSplit/></w:trPr>')
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks })
  local meta = doc.meta
  local out = cover(meta)
  local seen_heading, n = false, 0
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b.content, b.level)
      seen_heading = true
    elseif b.t == "Para" or b.t == "Plain" then
      -- after the first heading every paragraph is numbered, except a WHEREFORE paragraph
      if seen_heading and not pandoc.utils.stringify(b):match("^WHEREFORE") then
        n = n + 1
        out[#out + 1] = body_par(n .. ".", xe.inl(b.content))
      else
        out[#out + 1] = body_par(nil, xe.inl(b.content))
      end
    else
      error("dcb-adversary-complaint.lua: unsupported block " .. b.t)
    end
  end
  for _, x in ipairs(final_orders(meta)) do out[#out + 1] = x end
  out[#out + 1] = signature(meta.signature)
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
