-- idd-complaint.lua (docx engine): the D. Idaho complaint as Word paragraphs, so that it reads and breaks as
-- typst/idd-complaint.typ does: the counsel block in the upper left (Loc. Civ. R. 5.2(b)), the court title and the
-- caption four inches down or right after a longer counsel block (LR 5.2(b): a one-row table at least 3 in high
-- holds the counsel), the caption (a table whose party column has the right and bottom rules; beside it the CM/ECF
-- number, the title and the jury notation, LR 5.2(b)(3), (5) and LR 38.1), the unnumbered lead-in, the allegations
-- numbered 1., 2., ... (Fed. R. Civ. P. 10(b)), the headings, the prayer lettered (a), (b), ..., and the signature
-- block, kept with the last paragraph; the footer "N - TITLE" (LR 5.2(a): every page numbered). Everything printed
-- comes from the sample's frontmatter and body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local GAP = 276                          -- typst gap: one blank single line
local COVER_GAP = 240                    -- typst cover-gap, 12 pt below the counsel block at least
local COVER_H = 4320                     -- typst caption-top - margin: 3 in
local INDENT = 720                       -- typst para-indent and item-indent, 0.5 in
local LABEL = 720                        -- typst item-label, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4680                    -- typst caption-left, 3.25 in
local CAP_PAD, CAP_BOTTOM = 185, 160     -- typst caption-pad 10 pt less the 0.75 pt rule LibreOffice takes from the cell; caption-bottom 8 pt
local CAP_RIGHT = 504                    -- typst caption-right, 0.35 in
local SIG_LEFT = 4464                    -- typst sig-left, 3.1 in
local FOOTER = 735                       -- the footer line's foot above the page edge: typst footer-descent 30 %

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return pandoc.utils.stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A borderless one-row table that never splits: cells = { { width, paragraphs, tcBorders } }; height: the row's
-- least height (twips), if any.
local function tbl(cells, height)
  local grid, tcs = {}, {}
  for _, c in ipairs(cells) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. c[1] .. '"/>'
    local body = #c[2] > 0 and table.concat(c[2]) or p("")
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. (c[3] or "") .. '</w:tcPr>' ..
      body .. '</w:tc>'
  end
  local tr = '<w:cantSplit/>' .. (height and ('<w:trHeight w:val="' .. height .. '" w:hRule="atLeast"/>') or '')
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr>' .. tr .. '</w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, caption
-- ---------------------------------------------------------------------------

local function caption(meta)
  local parties = meta.caption.parties
  local left = {}
  local function add(x, o)
    o = o or {}
    o.right = CAP_PAD
    left[#left + 1] = p(x, o)
  end
  for k, party in ipairs(parties) do
    if k > 1 then add(xe.runs("v.")) end
    for _, n in ipairs(party.names) do add(xe.inl(n)) end
    -- the last designation keeps the caption's bottom padding (typst: pad(bottom: caption-bottom))
    add(xe.inl(party.designation), { after = k == #parties and CAP_BOTTOM or 0 })
  end
  local right = {
    p(xe.runs("Case No. " .. plain(meta.case_number)), { left = CAP_RIGHT }),
    p(xe.inl(meta.brief_title, { b = true }), { before = GAP, left = CAP_RIGHT }),
  }
  if meta.jury_demand == true then
    -- LR 38.1: the notation goes on the front page immediately following the title.
    right[#right + 1] = p(xe.runs("DEMAND FOR JURY TRIAL", { b = true }), { before = GAP, left = CAP_RIGHT })
  end
  local rule = '<w:tcBorders><w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'
  return tbl({ { CAP_LEFT, left, rule }, { TEXTW - CAP_LEFT, right } })
end

local function cover(meta)
  local out = {}
  -- LR 5.2(b): the counsel block in a row at least 3 in high (the caption four inches down), and at least
  -- COVER_GAP above the court title when it is longer (typst: max(caption-top - margin, used + cover-gap)).
  local counsel = {}
  local lines = meta.counsel or {}
  for i, l in ipairs(lines) do
    local s = plain(l)
    counsel[#counsel + 1] = p(s:match("%S") and xe.inl(l) or "", { after = i == #lines and COVER_GAP or 0 })
  end
  out[#out + 1] = tbl({ { TEXTW, counsel } }, COVER_H)
  for _, c in ipairs(meta.caption.court) do out[#out + 1] = p(xe.inl(c, { b = true }), { jc = "center" }) end
  -- typst: the caption a blank single line below the court title; Word keeps the space before a table in an
  -- empty paragraph of that height
  out[#out + 1] = p("", { line = GAP })
  out[#out + 1] = caption(meta)
  return out
end

-- ---------------------------------------------------------------------------
-- Signature block: the date beside the signature column; one row that never splits
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local right = { p(xe.runs("Respectfully submitted,"), { before = GAP }) }
  for i, f in ipairs(sig.firm) do right[#right + 1] = p(xe.inl(f), { before = i == 1 and GAP or 0 }) end
  right[#right + 1] = p(xe.runs("/s/ ") .. xe.inl(sig.signer), { before = GAP })
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = p(xe.inl(l)) end
  local left = { p(xe.runs("DATED this ") .. xe.inl(meta.signing_date) .. xe.runs("."), { before = GAP }) }
  return tbl({ { SIG_LEFT, left }, { TEXTW - SIG_LEFT, right } })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings at the body pitch, on the line grid, kept with the text: level 1 centered bold capitals, level 2
-- centered bold, level 3 bold, left. The Heading styles give the outline level.
local function heading(b)
  local content = b.content
  local lvl = math.min(b.level, 3)
  if lvl == 1 then
    content = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl < 3 and "center" or "left") }, xe.inl(content, { b = true }))
end

-- A body paragraph at the double pitch, first line indented: unnumbered, or the number, a tab to the end of its
-- half-inch box (typst: box(width: para-indent)), the text.
local function body_par(label, body, o)
  o = o or {}
  if label == nil then return p(body, { line = BODY, first = INDENT, keep = o.keep, before = o.before }) end
  return p(xe.runs(label .. "\t") .. body, { line = BODY, first = INDENT, keep = o.keep, before = o.before,
    tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (2 * INDENT) .. '"/></w:tabs>' })
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 201"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- The footer (LR 5.2(a)): the page number, " - " and the paper's title in capitals, flush left in a single-spaced
-- line box (typst: footer-block).
local function footer(meta)
  return '<w:p><w:pPr>' .. xe.spacing(0, 0, SINGLE) .. xe.ind(0, nil, 0) .. xe.jc("left") .. '</w:pPr>' ..
    '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>' ..
    '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>' ..
    xe.runs(" - " .. pandoc.text.upper(plain(meta.footer_title))) .. '</w:p>'
end

local FINAL = '<w:sectPr><w:footerReference w:type="default" r:id="rIdIddFooter"/>' ..
  '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" ' ..
  'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>'

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  -- pandoc would print the date as a title block; it is used only in the signature.
  meta.signing_date = meta.date
  write_file("FORMBOOK_FOOTERS", "rIdIddFooter\t" .. footer(meta) .. "\n")
  write_file("FORMBOOK_FINAL", FINAL)

  local out = cover(meta)
  if meta.lead_in then
    local lead = pandoc.read(plain(meta.lead_in), "markdown+smart").blocks[1]
    out[#out + 1] = body_par(nil, xe.inl(lead.content), { before = GAP })
  end
  local n = 0
  local blocks = doc.blocks
  for k, b in ipairs(blocks) do
    -- the last block stays on one page with the signature block (typst: one unbreakable block)
    local last = k == #blocks
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for i, item in ipairs(b.content) do
        out[#out + 1] = p(xe.runs("(" .. string.char(96 + i) .. ")\t") .. xe.inl(item[1].content),
          { line = BODY, left = INDENT + LABEL, hanging = LABEL, keep = last })
      end
    elseif b.t == "Para" or b.t == "Plain" then
      n = n + 1
      out[#out + 1] = body_par(n .. ".", xe.inl(b.content), { keep = last })
    else
      error("idd-complaint.lua: unsupported block " .. b.t)
    end
  end
  out[#out + 1] = signature(meta)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
