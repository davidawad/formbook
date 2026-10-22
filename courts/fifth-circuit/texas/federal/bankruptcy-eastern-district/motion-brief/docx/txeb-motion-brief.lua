-- txeb motion with argument and authorities, DOCX engine (docs/DOCX.md): the markdown contract -> a Word document
-- that reads and breaks as typst/txeb-motion-brief.typ does: the court title (FRBP 9004(b)(1); LBR 7010-1(1)), the
-- § caption (LBR 7010-1(2)-(4)), the title, the 14-day negative notice (LBR 7007-1), the numbered paragraphs, the
-- headings, block quotations, list items, the signature block and the certificate of service (LBR 9013-1). Every
-- case word comes from the sample (its frontmatter as written, $FORMBOOK_META, and its body); no case text lives in
-- this file. Unknown markdown is an error, never a silent drop.
--
-- The body is read as the typst template reads it: the sample's text after the frontmatter, split at blank lines,
-- each block classified by its first characters ("# ", "## ", "> ", "- ", "<!-- unnumbered -->", "<!-- flush -->",
-- "<!-- right -->", "<!-- signature -->"), its text as CommonMark with smart punctuation (typst's cmarker).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 double, 276 single), the spaces between blocks those of
-- the typst template (240 around the notice, a block quotation and a list item and above a line group, 360 between the caption
-- and the title, 480 above the caption and around the signature block), and typst's break rules on every run.

local xe = require("docx.xengine")

local DOUBLE, SINGLE = 552, 276            -- typst pitch-double 27.6 pt, pitch-single 13.8 pt
local BLOCK_GAP, CAPTION_GAP, TITLE_GAP = 240, 360, 480 -- typst block-gap 12 pt, caption-gap 18 pt, title-gap 24 pt
local INDENT = 720                         -- typst indent, 0.5 in
local BLOCK_INDENT = 1080                  -- typst block-indent, 0.75 in
local CAPTION_COLS = { 4896, 576, 3888 }   -- typst caption-case-col 3.4 in, caption-sign-col 0.4 in, the rest of 6.5 in
local CAPTION_CONT = 720                   -- typst caption-cont, 0.5 in
local SIG_COL = 4680                       -- typst sig-indent, 3.25 in

-- LBR 7007-1: the 14-day negative notice "must appear as presented"; the same words as the typst template.
local NOTICE_HEAD = "14-DAY NEGATIVE NOTICE – LBR 7007:"
local NOTICE = "No hearing will be conducted on this Motion unless a written objection is filed with the Clerk of the United States Bankruptcy Court and served upon the party filing this pleading WITHIN FOURTEEN (14) DAYS FROM THE DATE OF SERVICE shown in the certificate of service unless the Court shortens or extends the time for filing such objection. If no objection is timely served and filed, this pleading shall be deemed to be unopposed, and the Court may enter an order granting the relief sought. If an objection is filed and served in a timely manner, the Court will thereafter set a hearing with appropriate notice. If you fail to appear at the hearing, your objection may be stricken. The Court reserves the right to set a hearing on any matter."

local function starts(s, prefix) return s:sub(1, #prefix) == prefix end

local function read_file(path)
  local f = path and path ~= "" and io.open(path, "r")
  if not f then return nil end
  local s = f:read("a")
  f:close()
  return s
end

local function str(v)
  if v == nil then return "" end
  if type(v) == "table" then return "" end
  return tostring(v)
end

-- a frontmatter value that is a list of strings, or one string, as a list of strings
local function list_of(v)
  if v == nil then return {} end
  if type(v) == "table" then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = str(x) end
    return out
  end
  return { str(v) }
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a slash
-- before a letter (a zero-width space); a section sign or pilcrow ending a word ("§§") stays with the word after it
-- (typst boxes "§ 157"). None of these characters shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end
local function signs(l)
  for i = 1, #l - 1 do
    local a, b = l[i], l[i + 1]
    if a.t == "Str" and b.t == "Space" and (a.text:match("\u{00A7}$") or a.text:match("\u{00B6}$")) then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- Inline markdown as runs, read as typst's cmarker reads it (CommonMark, smart punctuation).
local function md(s, o)
  local doc = pandoc.read(s, "commonmark+smart")
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local parts = {}
  for _, b in ipairs(doc.blocks) do
    if b.t ~= "Para" and b.t ~= "Plain" then
      error("txeb-motion-brief.lua: the inline text holds a " .. b.t .. ": " .. s)
    end
    parts[#parts + 1] = xe.inl(b.content, o)
  end
  return table.concat(parts, xe.runs(" ", o))
end

-- A paragraph: o = { line, before, after, left, right, first, hanging, jc, keep, next, tabs }.
local function p(body, o)
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP elseif o.next then props[#props + 1] = "<w:keepNext/>" end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>'
  .. '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
  .. '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- Caption rows, as the typst template lays them out: { left, right, left indent } per single-spaced line.
local function caption_rows(meta)
  local rows = {}
  local function row(left, right, ind) rows[#rows + 1] = { left, right, ind or 0 } end
  row("IN RE:", "Chapter " .. str(meta.chapter))
  row("", "")
  for i, name in ipairs(list_of(meta.debtor.names)) do
    row(name .. ",", i == 1 and ("Case No. " .. str(meta.case_number)) or "")
  end
  -- LBR 7010-1(2): the debtor's address and the last four digits of the TIN are part of the caption.
  -- A missing value stays a blank for the filer to complete; the template never guesses one.
  local addr = list_of(meta.debtor.address)
  local first = addr[1]
  if first == nil or first == "" then first = "________________" end
  row("Address: " .. first, "")
  for i = 2, #addr do row(addr[i], "", CAPTION_CONT) end
  local tin = str(meta.debtor.tin_last4)
  if tin == "" then tin = "____" end
  row("Last four digits of TIN: " .. tin, "")
  row(str(meta.debtor.designation), "")
  row("", "")
  for pi, party in ipairs(meta.parties) do
    if pi > 1 then
      -- LBR 7010-1(4): a space for the adversary number, placed beside the "v." line.
      row("v.", "Adv. Proc. No. " .. str(meta.adversary_number))
      row("", "")
    end
    for _, n in ipairs(list_of(party.names)) do row(n, "") end
    row(str(party.designation), "")
  end
  return rows
end

-- The caption: a borderless table, one exact single-pitch row per caption line, the section sign in the middle
-- column; 480 above and below (typst title-gap).
local function caption(meta)
  local trs = {}
  for _, r in ipairs(caption_rows(meta)) do
    trs[#trs + 1] = '<w:tr><w:trPr><w:cantSplit/><w:trHeight w:val="' .. SINGLE .. '" w:hRule="exact"/></w:trPr>'
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAPTION_COLS[1] .. '" w:type="dxa"/></w:tcPr>'
      .. p(xe.runs(r[1]), { line = SINGLE, left = r[3] }) .. '</w:tc>'
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAPTION_COLS[2] .. '" w:type="dxa"/></w:tcPr>'
      .. p(xe.runs("\u{00A7}"), { line = SINGLE, jc = "center" }) .. '</w:tc>'
      .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAPTION_COLS[3] .. '" w:type="dxa"/></w:tcPr>'
      .. p(xe.runs(r[2]), { line = SINGLE }) .. '</w:tc></w:tr>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="9360" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid><w:gridCol w:w="'
    .. CAPTION_COLS[1] .. '"/><w:gridCol w:w="' .. CAPTION_COLS[2] .. '"/><w:gridCol w:w="' .. CAPTION_COLS[3]
    .. '"/></w:tblGrid>' .. table.concat(trs) .. '</w:tbl>'
end

-- The signature block: "Dated: <date>", then (the hanging indent's tab) the first line in the signer's column, the
-- signer's lines after it (an empty line is an empty single line); one block, 480 above and below it (typst: an
-- unbreakable grid).
local function signature(sig, out)
  local lines = list_of(sig.lines)
  for i, l in ipairs(lines) do
    local o = { line = SINGLE, left = SIG_COL, keep = i < #lines, after = i == #lines and TITLE_GAP or 0 }
    if i == 1 then
      o.before, o.hanging = TITLE_GAP, SIG_COL
      out[#out + 1] = p(xe.runs("Dated: " .. str(sig.dated) .. "\t" .. l), o)
    else
      out[#out + 1] = p(xe.runs(l), o)
    end
  end
end

-- Single-spaced lines at `left`, one paragraph per source line, kept together, 240 above (typst line-group);
-- `keep`: the last line too stays with the next paragraph.
local function line_group(left, lines, marker, out, keep)
  for i, l in ipairs(lines) do
    if starts(l, marker) then l = l:sub(#marker + 1):match("^%s*(.-)%s*$") end
    out[#out + 1] = p(md(l), { line = SINGLE, left = left, keep = keep or i < #lines, before = i == 1 and BLOCK_GAP or 0 })
  end
end

-- The body as typst reads it: the text after the frontmatter, in blocks split at blank lines.
local function body_blocks()
  local src = read_file(PANDOC_STATE.input_files[1])
  if not src then error("txeb-motion-brief.lua: cannot read the sample") end
  src = src:gsub("\r", "")
  local _, e = src:find("^%-%-%-\n.-\n%-%-%-[ \t]*\n")
  if not e then error("txeb-motion-brief.lua: the sample must start with a YAML frontmatter block") end
  local blocks, cur = {}, {}
  for line in (src:sub(e + 1) .. "\n"):gmatch("(.-)\n") do
    if line:match("^[ \t]*$") then
      if #cur > 0 then blocks[#blocks + 1] = cur; cur = {} end
    else
      cur[#cur + 1] = line:match("^%s*(.-)%s*$")
    end
  end
  if #cur > 0 then blocks[#blocks + 1] = cur end
  return blocks
end


function Pandoc(doc)
  local meta = pandoc.json.decode(read_file(os.getenv("FORMBOOK_META")) or "{}", false)
  local out = {}
  local court = {
    "IN THE UNITED STATES BANKRUPTCY COURT",
    "FOR THE EASTERN DISTRICT OF TEXAS",
    pandoc.text.upper(str(meta.division)) .. " DIVISION",
  }
  for i, l in ipairs(court) do
    -- the last court-title line carries the caption's space (typst: the caption block's above)
    out[#out + 1] = p(xe.runs(l, { b = true }), { line = SINGLE, jc = "center", after = i == #court and TITLE_GAP or 0 })
  end
  out[#out + 1] = caption(meta)
  local notice = meta.negative_notice ~= false
  out[#out + 1] = p(xe.runs(pandoc.text.upper(str(meta.title)), { b = true }),
    { line = SINGLE, before = CAPTION_GAP, jc = "center", next = true })
  if notice then
    out[#out + 1] = p(xe.runs(NOTICE_HEAD, { b = true }), { line = SINGLE, before = BLOCK_GAP, keep = true })
    out[#out + 1] = p(xe.runs(NOTICE), { line = SINGLE, after = BLOCK_GAP, keep = false })
    out[#out] = out[#out]:gsub("<w:pPr>", "<w:pPr>" .. xe.LINES, 1)
  end

  local blocks = body_blocks()
  local num = 0
  for bi, lines in ipairs(blocks) do
    local nxt = blocks[bi + 1]
    -- the last block before the signature stays with it, and a block before a line group (a certificate's address
    -- and signature) stays with that (typst: sticky), so neither stands alone
    local grouped = nxt ~= nil and (starts(nxt[1], "<!-- flush -->") or starts(nxt[1], "<!-- right -->"))
    local keep = (nxt ~= nil and nxt[1] == "<!-- signature -->") or grouped
    local first = lines[1]
    if first == "<!-- signature -->" then
      signature(meta.signature, out)
    elseif starts(first, "## ") then
      out[#out + 1] = p(md(first:sub(4), { b = true }), { line = DOUBLE, keep = true })
    elseif starts(first, "# ") then
      out[#out + 1] = p(md(first:sub(3), { b = true }), { line = DOUBLE, jc = "center", keep = true })
    elseif starts(first, "> ") then
      local t = {}
      for i, l in ipairs(lines) do t[i] = starts(l, "> ") and l:sub(3) or l end
      out[#out + 1] = p(md(table.concat(t, " ")),
        { line = SINGLE, before = BLOCK_GAP, after = BLOCK_GAP, left = BLOCK_INDENT, right = BLOCK_INDENT })
    elseif starts(first, "- ") then
      for _, l in ipairs(lines) do
        out[#out + 1] = p(md(l:sub(3)), { line = SINGLE, before = BLOCK_GAP, after = BLOCK_GAP, left = BLOCK_INDENT })
      end
    elseif starts(first, "<!-- right -->") then
      line_group(SIG_COL, lines, "<!-- right -->", out, grouped)
    elseif starts(first, "<!-- flush -->") then
      line_group(0, lines, "<!-- flush -->", out, grouped)
    elseif starts(first, "<!-- unnumbered -->") then
      local t = table.concat(lines, " "):sub(#"<!-- unnumbered -->" + 1):match("^%s*(.-)%s*$")
      out[#out + 1] = p(md(t), { line = DOUBLE, first = INDENT, keep = keep })
    elseif starts(first, "<!--") or starts(first, "#") then
      error("txeb-motion-brief.lua: the block is not in the template: " .. first)
    else
      num = num + 1
      out[#out + 1] = p(xe.runs(num .. ".\t") .. md(table.concat(lines, " ")), { line = DOUBLE, first = INDENT,
        keep = keep, tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (2 * INDENT) .. '"/></w:tabs>' })
    end
  end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
