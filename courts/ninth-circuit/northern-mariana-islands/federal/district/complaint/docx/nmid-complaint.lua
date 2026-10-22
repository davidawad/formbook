-- nmid-complaint.lua (docx engine): the D.N.M.I. complaint as Word paragraphs, so that it reads and breaks as
-- typst/nmid-complaint.typ does: the counsel block (LR 5.2.c), the court title (LR 5.2.d.1), the caption (LR 5.2.d.2,
-- 5.2.d.3: a table whose party column has the right and bottom rules, the file number and the paper's title beside
-- it), the paragraphs numbered 1., 2., ... (Fed. R. Civ. P. 10(b)); a paragraph beginning "~ " is unnumbered (the
-- prayer's lead-in, kept with what follows), headings, the prayer lettered (a), (b), ..., and the signature block,
-- kept with the last paragraph. The page (LR 5.2.a), the numbered lines 1 to 25 in the left margin, the pleading
-- rules and the footer (page number, the paper's title, the case number) are the last section and the footer this
-- filter gives fb render (FORMBOOK_FINAL, FORMBOOK_FOOTERS; tools/fb/src/docxpass.rs). Everything printed comes
-- from the sample's frontmatter and body: no case text lives in this file. Styles: docx/reference.xml.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced numbered lines, 276 a single line), the
-- spaces between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 240            -- typst pitch, pitch-single
local DROP = 192                         -- typst single-drop: a single-spaced block starts 9.6 pt into a numbered line
local FOOT_LINE, FOOT_SZ = 240, 20       -- typst pitch-footer 12 pt, footer-size 10 pt
local FOOT_GAP = 80                      -- typst footer-gap 4 pt
local INDENT = 720                       -- typst para-indent, number-box, label-box: 0.5 in
local TEXTW = 10080                      -- typst text-width: 8.5 - 1 - 0.5 in
local LEFT, TOP = 1440, 2160             -- typst left-margin 1 in, top-margin 1.5 in
local LINES = 25                         -- typst lines-per-page
local BOTTOM = 15840 - TOP - LINES * BODY -- typst bottom-margin: what the 25 numbered lines leave (84 pt)
local NUM_W = 1008                       -- typst line-numbers: a box of left-margin - 0.3 in, right-aligned
local FOOT_TOP = TOP + LINES * BODY + 960 -- typst footer-top: 48 pt below the last numbered line
local FOOT_DIST = 15840 - FOOT_TOP - 2 * FOOT_LINE - FOOT_GAP -- the footer's last line box ends this far above the page edge
local COUNSEL_W, COUNSEL_LINES = 5184, 7 -- typst counsel-width 3.6 in, counsel-lines
local CAP_LEFT, CAP_PAD = 4464, 200      -- typst caption-left 3.1 in, caption-pad 10 pt
local CAP_GUTTER = 360                   -- typst caption-gutter 0.25 in
local SIG_LEFT = 4032                    -- typst sig-left 2.8 in
local RULES_X = { 63.36, 66.24, 581.76 } -- typst pleading-rules(): 1 in - 0.12 in, 1 in - 0.08 in, 8 in + 0.08 in (pt)
local RULE = 15                          -- LibreOffice adds the caption's 0.75 pt bottom rule below the row (typst strokes take no
                                         -- room): the row's minimum height is that much less, so it ends where typst's does

local COURT_TITLE = { "IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN MARIANA ISLANDS" }

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

local function list(m)
  local out = {}
  for _, v in ipairs(m or {}) do out[#out + 1] = v end
  return out
end

-- typst grid-height(n): a single-spaced block of n lines (after its drop) rounded up to whole numbered lines.
local function grid_height(n)
  return math.ceil((DROP + n * SINGLE) / BODY) * BODY
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, tabs, style, frame }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = o.keep end
  if o.frame then props[#props + 1] = o.frame end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local function tab_at(pos, kind)
  return '<w:tabs><w:tab w:val="' .. (kind or "left") .. '" w:pos="' .. pos .. '"/></w:tabs>'
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A borderless one-row table that never splits: cells = { { width, paragraphs, tcBorders } }; `height` the row's
-- minimum height (Word grows the row to its content, as typst's calc.max does).
local function tbl(cells, height)
  local grid, tcs, total = {}, {}, 0
  for _, c in ipairs(cells) do
    total = total + c[1]
    grid[#grid + 1] = '<w:gridCol w:w="' .. c[1] .. '"/>'
    local body = #c[2] > 0 and table.concat(c[2]) or p("")
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. (c[3] or "") .. '</w:tcPr>' ..
      body .. '</w:tc>'
  end
  local trh = height and ('<w:trHeight w:val="' .. height .. '" w:hRule="atLeast"/>') or ""
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. total .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/>' .. trh .. '</w:trPr>' .. table.concat(tcs) ..
    '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Page: the last section, the numbered lines, the pleading rules and the footer
-- ---------------------------------------------------------------------------

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- A paragraph in a frame fixed to the page at (x, y), `w` wide; consecutive paragraphs with the same frame share it.
local function frame(x, y, w)
  return '<w:framePr w:w="' .. w .. '" w:hSpace="0" w:wrap="around" w:vAnchor="page" w:hAnchor="page" w:x="' .. x ..
    '" w:y="' .. y .. '"/>'
end

local function footer(meta)
  local out = {}
  -- typst line-numbers(): 1 to 25 right-aligned in the left margin, one per numbered line
  local nums = frame(0, TOP, NUM_W)
  for i = 1, LINES do out[#out + 1] = p(xe.runs(tostring(i)), { frame = nums, line = BODY, jc = "right" }) end
  -- typst footer-block(): "-N-" centered, then the title (capitals) left and the case number right, in 10 pt lines
  local sz = { sz = FOOT_SZ }
  out[#out + 1] = p(xe.runs("-", sz) .. '<w:r><w:rPr><w:sz w:val="' .. FOOT_SZ .. '"/><w:szCs w:val="' .. FOOT_SZ ..
    '"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="' .. FOOT_SZ .. '"/></w:rPr>' ..
    '<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="' .. FOOT_SZ .. '"/></w:rPr>' ..
    '<w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="' .. FOOT_SZ .. '"/></w:rPr><w:t>1</w:t></w:r>' ..
    '<w:r><w:rPr><w:sz w:val="' .. FOOT_SZ .. '"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r>' .. xe.runs("-", sz),
    { line = FOOT_LINE, jc = "center" })
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(meta.footer_title)) .. "\tCASE NO. " .. plain(meta.case_number), sz),
    { line = FOOT_LINE, before = FOOT_GAP, tabs = tab_at(TEXTW, "right") })
  -- typst pleading-rules(): a double rule at the text's left edge, a single rule at its right, the height of the page
  local rules = {}
  for _, x in ipairs(RULES_X) do
    rules[#rules + 1] = '<w:r><w:pict><v:line xmlns:v="urn:schemas-microsoft-com:vml" from="' .. x .. 'pt,0" to="' .. x ..
      'pt,792pt" strokeweight="0.75pt" strokecolor="black" style="position:absolute;mso-position-horizontal-relative:page;' ..
      'mso-position-vertical-relative:page;z-index:-1"/></w:pict></w:r>'
  end
  out[LINES + 1] = out[LINES + 1]:gsub("</w:p>$", function() return table.concat(rules) .. "</w:p>" end)
  return table.concat(out)
end

-- Letter, LR 5.2.a margins; every page with the footer above (line numbers, pleading rules, page number, title).
local SECT = '<w:sectPr><w:footerReference w:type="default" r:id="rIdNmidFtr"/><w:pgSz w:w="12240" w:h="15840"/>' ..
  '<w:pgMar w:top="' .. TOP .. '" w:right="720" w:bottom="' .. BOTTOM .. '" w:left="' .. LEFT ..
  '" w:header="720" w:footer="' .. FOOT_DIST .. '" w:gutter="0"/>' ..
  '<w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, caption
-- ---------------------------------------------------------------------------

local function cover(meta)
  local out = {}
  -- typst counsel-block(): single lines in a block at least seven numbered lines tall
  local counsel = {}
  for i, l in ipairs(list(meta.counsel)) do counsel[#counsel + 1] = p(xe.inl(l), { before = i == 1 and DROP or 0 }) end
  out[#out + 1] = tbl({ { COUNSEL_W, counsel } }, COUNSEL_LINES * BODY)
  -- typst court-title(): two single lines, bold and centered, in two numbered lines
  for i, l in ipairs(COURT_TITLE) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center", before = i == 1 and DROP or 0,
      after = i == #COURT_TITLE and 2 * BODY - DROP - #COURT_TITLE * SINGLE or 0 })
  end
  -- typst caption(): the party column (right and bottom rules) and the file number column, a row at least the
  -- party lines plus one, rounded up to whole numbered lines
  local rows = {}
  for k, party in ipairs(list(meta.caption.parties)) do
    if k > 1 then rows[#rows + 1] = xe.runs("v.") end
    for _, n in ipairs(list(party.names)) do rows[#rows + 1] = xe.inl(n) end
    rows[#rows + 1] = xe.inl(party.designation)
  end
  local left = {}
  for i, r in ipairs(rows) do left[i] = p(r, { right = CAP_PAD, before = i == 1 and DROP or 0 }) end
  local right = {
    p(xe.runs("CIVIL CASE NO. " .. plain(meta.case_number)), { before = DROP }),
    p(xe.inl(meta.brief_title, { b = true }), { before = SINGLE }),
  }
  if meta.jury_demand then right[#right + 1] = p(xe.runs("DEMAND FOR JURY TRIAL", { b = true }), { before = SINGLE }) end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  out[#out + 1] = tbl({ { CAP_LEFT, left, rule }, { CAP_GUTTER, {} }, { TEXTW - CAP_LEFT - CAP_GUTTER, right } },
    grid_height(#left + 1) - RULE)
  -- a blank numbered line between the caption and the text
  out[#out + 1] = p("", { line = BODY })
  if meta.lead_in then
    local lead = pandoc.read(plain(meta.lead_in), "markdown+smart").blocks[1]
    out[#out + 1] = p(xe.inl(lead.content), { line = BODY, first = INDENT })
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block: "Dated" beside the signature column; one row that never splits, a numbered line below the text
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local right = { p(xe.runs("Respectfully submitted,"), { before = DROP }) }
  for i, f in ipairs(list(sig.firm)) do right[#right + 1] = p(xe.inl(f), { before = i == 1 and SINGLE or 0 }) end
  right[#right + 1] = p(xe.runs("/s/ ") .. xe.inl(sig.signer), { before = SINGLE })
  right[#right + 1] = p(xe.inl(sig.signer))
  for _, l in ipairs(list(sig.lines)) do right[#right + 1] = p(xe.inl(l)) end
  local left = { p(xe.runs("Dated: ") .. xe.inl(meta.date), { before = DROP }) }
  return { p("", { line = BODY, keep = xe.KEEP }), tbl({ { SIG_LEFT, left }, { TEXTW - SIG_LEFT, right } }) }
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings on one numbered line, kept with the text (the Heading styles of docx/reference.xml): level 1 centered bold
-- capitals, 2 centered bold, 3 bold italic.
local function heading(b)
  local lvl = math.min(b.level, 3)
  local content = b.content
  if lvl == 1 then
    content = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(content, { b = true, i = lvl == 3 }))
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks })
  local meta = doc.meta
  write_file("FORMBOOK_FOOTERS", "rIdNmidFtr\t" .. footer(meta) .. "\n")
  write_file("FORMBOOK_FINAL", SECT)
  local out = cover(meta)
  local n = 0
  local blocks = doc.blocks
  for k, b in ipairs(blocks) do
    -- the last block stays on one page with the signature block (typst: one unbreakable block)
    local keep = k == #blocks and xe.KEEP or nil
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        out[#out + 1] = p(xe.runs("(" .. string.char(96 + i) .. ")\t") .. xe.inl(item[1].content),
          { line = BODY, left = 2 * INDENT, hanging = INDENT, keep = keep, tabs = tab_at(2 * INDENT) })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local c = b.content
      if c[1] and c[1].t == "Str" and c[1].text == "~" then
        -- unnumbered, kept with what follows (typst: a sticky block)
        local rest = pandoc.Inlines({ table.unpack(c, 2) })
        if rest[1] and rest[1].t == "Space" then rest:remove(1) end
        out[#out + 1] = p(xe.inl(rest), { line = BODY, first = INDENT, keep = keep or "<w:keepNext/>" })
      else
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(c), { line = BODY, first = INDENT, keep = keep,
          tabs = tab_at(2 * INDENT) })
      end
    else
      error("nmid-complaint.lua: unsupported block " .. b.t)
    end
  end
  for _, x in ipairs(signature(meta)) do out[#out + 1] = x end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
