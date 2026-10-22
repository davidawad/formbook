-- Adversary complaint, U.S. Bankruptcy Court, Southern District of California (casb), DOCX engine (docs/DOCX.md):
-- what the Word output adds to pandoc's conversion, so that it reads and breaks as
-- typst/casb-adversary-complaint.typ does: pleading paper (27 numbered lines of 24 pt, CASB-FORM-003; the rules
-- beside the text), the counsel block (from line 1), the court title, the caption (FRBP 7010 and Form 416: the debtor
-- and the adversary parties in a column ruled on the right and bottom; case numbers, the title of the paper and the
-- judge beside it), the lead-in, the numbered allegations (Fed. R. Civ. P. 10(b), applied by FRBP 7010), the
-- headings, the lettered list items, the unnumbered closing and the date and signature block. Everything printed
-- comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The footer carries the paper's title and case number from the sample, and the line numbers stand in a frame of
-- the same footer, anchored to the page at the top margin, one per 24 pt line on the baselines of the text; this
-- filter writes that footer (FORMBOOK_FOOTERS) and the section that names it (FORMBOOK_FINAL), which fb render
-- puts in the document (tools/fb/src/docxpass.rs).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 a numbered line, 240 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. A block of single lines
-- (counsel, caption) takes whole numbered lines, as typst's on-grid rounds it: the filter counts its wrapped lines
-- (docx/lib/lines.lua) and sets the row to the next numbered line.

local xe = require("docx.xengine")
local here = PANDOC_SCRIPT_FILE:match("^(.*)[/\\]") or "."
local L = dofile(here .. "/lib/lines.lua")
L.prep = function(x) return xe.bind_signs(xe.unabbrev(x)) end

local PITCH, SINGLE = 480, 240           -- typst pitch, pitch-single (half a numbered line)
local SIZE = 24                          -- typst type-size 12 pt, in half points
local PAGE_LINE, FOOT_LINE = 230, 208    -- typst pitch-page 11.5 pt, pitch-footer 10.4 pt
local HALF = 240                         -- typst half-gap 12 pt
local DROP = 192                         -- typst drop 9.6 pt: a single-spaced block's first line on a line number's baseline
local LINES = 27                         -- typst lines-per-page
local COUNSEL_LINES = 7                  -- typst counsel-lines
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local NUMBER_TAB = 1368                  -- typst para-indent + number-box (0.45 in): the text of an allegation
local ITEM_TEXT = 1728                   -- typst item-indent + item-box (0.7 in): the text of a list item
local TEXTW = 8640                       -- 6 in: 8.5 in less the 1.5 in and 1 in margins
local NUMBER_W = 1440                    -- typst number-width: the line numbers right-aligned in the first inch
local CAP_LEFT, CAP_GUTTER = 4608, 288   -- typst caption-left 3.2 in, caption-gutter 0.2 in
local CAP_INSET = 200                    -- typst caption-inset 10 pt
local CAP_RULE = 15                      -- the 0.75 pt rule LibreOffice adds to the row (typst draws it over the cell)
local RIGHT_INSET = 144                  -- typst right-inset 0.1 in
local SIG_LEFT = 3744                    -- typst sig-left 2.6 in
local FOOT_GAP = 40                      -- typst footer-gap 2 pt
local PAGE_SIZE, FOOT_SIZE = 20, 18      -- typst page-size 10 pt, footer-size 9 pt, in half points
local RULE = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

-- The height of a block of single lines from DROP into its first numbered line, rounded up to whole numbered lines
-- (typst on-grid).
local function grid(h, min)
  return math.max(min or 0, math.ceil((DROP + h) / PITCH)) * PITCH
end

-- Single lines a value wraps to in `width` twips (bold: o.b).
local function count(v, width, o)
  return L.count(L.runs(v, o), width, SIZE)
end

local function text(v) return pandoc.utils.stringify(v) end
local function upper(content)
  return content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
end

-- A paragraph: o = { before, after, line, left, hanging, first, jc, keep, tab, brk }. A paragraph in a single line
-- box.
local function p(body, o)
  o = o or {}
  local line = o.line or SINGLE
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, line)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A table without borders of its own and without cell margins; cells = { { pr, body } }.
local function tbl(widths, cells, trpr)
  local grid, tcs, total = {}, {}, 0
  for i, w in ipairs(widths) do
    total = total + w
    grid[#grid + 1] = '<w:gridCol w:w="' .. w .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (cells[i].pr or "") .. '</w:tcPr>' ..
      table.concat(cells[i].body) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
    '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr>' ..
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr>' .. (trpr or "") .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: counsel (from line 1), court title, caption
-- ---------------------------------------------------------------------------

local function party_lines(sides)
  local rows = {}
  for k, s in ipairs(sides) do
    if k > 1 then rows[#rows + 1] = "vs." end
    for _, n in ipairs(s.names) do rows[#rows + 1] = n end
    rows[#rows + 1] = s.designation
  end
  return rows
end

local function line(l, o)
  return type(l) == "string" and xe.runs(l, o) or xe.inl(l, o)
end

local function cover(meta, out)
  -- counsel, at least seven numbered lines, rounded up to whole ones (typst counsel-block)
  local body, n = {}, 0
  for j, l in ipairs(meta.counsel) do
    body[#body + 1] = p(line(l), { before = j == 1 and DROP or 0 })
    n = n + count(l, TEXTW)
  end
  out[#out + 1] = tbl({ TEXTW }, { { body = body } },
    '<w:trPr><w:cantSplit/><w:trHeight w:val="' .. grid(n * SINGLE, COUNSEL_LINES) .. '" w:hRule="atLeast"/></w:trPr>')
  local court = { "UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF CALIFORNIA" }
  if meta.division then court[#court + 1] = pandoc.text.upper(text(meta.division)) end
  for _, l in ipairs(court) do out[#out + 1] = p(xe.runs(l, { b = true }), { line = PITCH, jc = "center", keep = true }) end
  -- Caption: a numbered line below the court title, on whole numbered lines (Word has no space before a table: the
  -- first paragraphs of the row carry the line and the drop).
  local lw, rw = CAP_LEFT - CAP_INSET, TEXTW - CAP_LEFT - CAP_GUTTER - RIGHT_INSET
  local left, lh = { p(xe.runs("In re"), { before = PITCH + DROP }) }, SINGLE
  for _, l in ipairs(party_lines(meta.in_re)) do
    left[#left + 1] = p(line(l))
    lh = lh + count(l, lw) * SINGLE
  end
  for j, l in ipairs(party_lines(meta.caption)) do
    left[#left + 1] = p(line(l), { before = j == 1 and HALF or 0 })
    lh = lh + count(l, lw) * SINGLE + (j == 1 and HALF or 0)
  end
  left[#left] = left[#left]:gsub('w:after="0"', 'w:after="' .. (HALF - CAP_RULE) .. '"', 1)
  lh = lh + HALF
  local right, rh = {}, 0
  local function r(v, before, o)
    right[#right + 1] = p(line(v, o), { before = (#right == 0 and PITCH + DROP or 0) + (before or 0), left = RIGHT_INSET })
    rh = rh + (before or 0) + count(v, rw, o) * SINGLE
  end
  r("Case No. " .. text(meta.case_number))
  r("Chapter " .. text(meta.chapter))
  if meta.adv_number then r("Adv. Proc. No. " .. text(meta.adv_number), HALF) end
  r(meta.brief_title, HALF, { b = true })
  if meta.judge then r(meta.judge, HALF) end
  out[#out + 1] = tbl({ CAP_LEFT, CAP_GUTTER, TEXTW - CAP_LEFT - CAP_GUTTER }, {
    { pr = '<w:tcBorders><w:bottom ' .. RULE .. '/><w:right ' .. RULE .. '/></w:tcBorders>' ..
      '<w:tcMar><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>', body = left },
    { body = { p("", { before = PITCH + DROP }) } },
    { body = right },
  }, '<w:trPr><w:cantSplit/><w:trHeight w:val="' .. (PITCH + grid(math.max(lh, rh)) - CAP_RULE) .. '" w:hRule="atLeast"/></w:trPr>')
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

local function heading(el)
  local lvl = el.level
  local content = lvl == 1 and upper(el.content) or el.content
  return xe.para({ xe.style("Heading" .. math.min(lvl, 5)), xe.KEEP, xe.spacing(0, 0, PITCH), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(content, { b = true }))
end

local function letters(n)
  local s = ""
  repeat
    n = n - 1
    s = string.char(97 + n % 26) .. s
    n = n // 26
  until n == 0
  return s
end

local function body(blocks, out)
  local n = 0
  for _, b in ipairs(blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content), { line = PITCH, first = INDENT, tab = NUMBER_TAB })
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      -- list items, lettered (a), (b), ... (typst enum "(a)"): the label half an inch in, the text a box after it
      local start = b.t == "OrderedList" and b.listAttributes.start or 1
      for j, item in ipairs(b.content) do
        for k, ib in ipairs(item) do
          local lab = k == 1 and ((b.t == "OrderedList" and ("(" .. letters(start + j - 1) .. ")") or "\u{2022}") .. "\t") or ""
          out[#out + 1] = p(xe.runs(lab) .. xe.inl(ib.content), { line = PITCH, left = ITEM_TEXT, hanging = ITEM_TEXT - INDENT })
        end
      end
    else
      error("casb: unsupported block " .. b.t)
    end
  end
end

-- The signature block, a numbered line below the text: the date left, the signature right; one table row that
-- cannot split.
local function signature(meta, out)
  local sig = meta.signature
  local right = { p(xe.runs("Respectfully submitted,"), { before = PITCH + DROP }) }
  for j, l in ipairs(sig.firm or {}) do right[#right + 1] = p(line(l), { before = j == 1 and HALF or 0 }) end
  right[#right + 1] = p(xe.runs("By: /s/ " .. text(sig.signer)), { before = HALF })
  right[#right + 1] = p(xe.runs(text(sig.signer)))
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = p(line(l)) end
  out[#out + 1] = tbl({ SIG_LEFT, CAP_GUTTER, TEXTW - SIG_LEFT - CAP_GUTTER }, {
    { body = { p(xe.runs("Dated: " .. text(meta.date)), { before = PITCH + DROP }) } },
    { body = { p("", { before = PITCH + DROP }) } },
    { body = right },
  }, "<w:trPr><w:cantSplit/></w:trPr>")
end

-- ---------------------------------------------------------------------------
-- Footer and section: the line numbers (a frame at the top margin, anchored to the page), the page number, then
-- the paper's title and the case number, each centered (typst footer-block, 4 pt below the last numbered line)
-- ---------------------------------------------------------------------------

local function footer(meta)
  local nums = {}
  for i = 1, LINES do
    if i > 1 then nums[#nums + 1] = "<w:r><w:br/></w:r>" end
    nums[#nums + 1] = "<w:r><w:t>" .. i .. "</w:t></w:r>"
  end
  local frame = '<w:p><w:pPr><w:framePr w:w="' .. NUMBER_W .. '" w:h="' .. LINES * PITCH .. '" w:hRule="exact" ' ..
    'w:hSpace="0" w:wrap="around" w:vAnchor="page" w:hAnchor="page" w:x="0" w:y="1440"/>' ..
    xe.spacing(0, 0, PITCH) .. xe.ind(0, nil, 0) .. xe.jc("right") .. '</w:pPr>' .. table.concat(nums) .. '</w:p>'
  local sz = '<w:rPr><w:sz w:val="' .. PAGE_SIZE .. '"/><w:szCs w:val="' .. PAGE_SIZE .. '"/></w:rPr>'
  local page = '<w:p><w:pPr>' .. xe.spacing(0, FOOT_GAP, PAGE_LINE) .. xe.ind(0, nil, 0) .. xe.jc("center") ..
    '</w:pPr><w:r>' .. sz .. '<w:fldChar w:fldCharType="begin"/></w:r><w:r>' .. sz ..
    '<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r>' .. sz ..
    '<w:fldChar w:fldCharType="separate"/></w:r><w:r>' .. sz .. '<w:t>1</w:t></w:r><w:r>' .. sz ..
    '<w:fldChar w:fldCharType="end"/></w:r></w:p>'
  local function fp(runs, after)
    return '<w:p><w:pPr>' .. xe.spacing(0, after, FOOT_LINE) .. xe.ind(0, nil, 0) .. xe.jc("center") ..
      '</w:pPr>' .. runs .. '</w:p>'
  end
  return frame .. page .. fp(xe.inl(upper(meta.footer_title), { sz = FOOT_SIZE }), FOOT_GAP) ..
    fp(xe.runs("CASE NO. " .. text(meta.case_number), { sz = FOOT_SIZE }), 0)
end

-- letter; top margin 1 in and 27 lines of 24 pt to the bottom margin (1 in); the footer 4 pt below the last line;
-- the double rule left of the text, the single rule right of it (typst pleading-rules)
local function sect_pr(id)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. id .. '"/><w:pgSz w:w="12240" w:h="15840"/>' ..
    '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="2160" w:header="720" w:footer="634" w:gutter="0"/>' ..
    '<w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="11" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="7" w:color="000000"/></w:pgBorders></w:sectPr>'
end

local function write_file(env, s)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(s)
  f:close()
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 157(b)"), as the typst template boxes it (xe.inl binds a single sign).
local function signs(inlines)
  for i = 1, #inlines - 1 do
    local a, b = inlines[i], inlines[i + 1]
    if a.t == "Str" and b.t == "Space" then
      local t = a.text
      if #t >= 4 and t:gsub("\u{00A7}", ""):gsub("\u{00B6}", "") == "" then
        inlines[i + 1] = pandoc.Str("\u{00A0}")
      end
    end
  end
  return inlines
end

function Pandoc(doc)
  for _, k in ipairs({ "case_number", "chapter", "counsel", "in_re", "caption", "brief_title", "footer_title", "date",
    "signature" }) do
    if doc.meta[k] == nil then error("casb: missing required metadata field `" .. k .. "`", 0) end
  end
  doc = doc:walk({ Str = breaks }):walk({ Inlines = signs })
  local meta = doc.meta
  local out = {}
  cover(meta, out)
  if meta.lead_in then out[#out + 1] = p(xe.inl(meta.lead_in), { line = PITCH, first = INDENT }) end
  body(doc.blocks, out)
  -- the closing paragraph is kept whole with the signature block, so the signature never stands on a page alone
  if meta.closing then out[#out + 1] = p(xe.inl(meta.closing), { line = PITCH, first = INDENT, keep = true }) end
  signature(meta, out)
  write_file("FORMBOOK_FOOTERS", "rIdCasbFooter\t" .. footer(meta) .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr("rIdCasbFooter"))
  local blocks = {}
  for _, x in ipairs(out) do blocks[#blocks + 1] = xe.raw(x) end
  return pandoc.Pandoc(blocks, pandoc.Meta({}))
end
