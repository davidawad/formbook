-- N.D. Cal. complaint, docx engine (docs/DOCX.md): what the Word output adds to pandoc's conversion, so that it reads
-- and breaks as typst/cand-answer.typ does (see ../README.md): the pleading page (27 numbered lines, the line
-- numbers and rules, the footer with the page number, the paper's title and the case number; Civil L.R. 3-4(c)), the
-- counsel block, the court title on line 8 and the caption (Civil L.R. 3-4(a)), the numbered allegations (Fed. R.
-- Civ. P. 10(b)), the headings, the numbered prayer items and the signature block. Everything printed comes from the
-- sample's frontmatter and body: no case text lives in this file. Caption and signature are OOXML tables; the line
-- numbers and rules are page-anchored VML shapes in the footer, so they take no room in the text.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 240 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 240                 -- typst pitch, pitch-single
local DROP = 192                              -- typst drop: 0.8 x (24 - 12) pt
local INDENT = 720                            -- typst para-indent, list-indent: 0.5 in
local TEXTW = 8640                            -- 6 in: letter, 1.5 in left and 1 in right margins
local LINES = 27                              -- typst lines-per-page
local TOP, LEFT, RIGHT = 1440, 2160, 1440     -- typst top-margin, left-margin, right-margin
local BOTTOM = 15840 - TOP - LINES * BODY     -- typst bottom-margin, 72 pt
local NUMBER_COL = 1440                       -- typst number-col: the line numbers end 1 in from the page edge
local FOOTER_SZ = 20                          -- typst footer-size 10 pt
local FOOTER_TOP, FOOTER_GAP = 120, 80        -- typst footer-top 6 pt, footer-gap 4 pt
local CAP_LEFT, CAP_INSET, CAP_PAD = 4608, 200, 160 -- typst caption-left 3.2 in, caption-inset 10 pt, caption-pad 8 pt
local CAP_GUTTER = 432                        -- typst caption-gutter 0.3 in
local SIG_LEFT = 4032                         -- typst signature-left 2.8 in
local COUNSEL_LINES = 7                       -- typst counsel-lines: the court title on line 8

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, hanging, first, tab, jc, keep, brk }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, not o.hanging and (o.first or 0) or nil, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- A one-row table that does not split: widths in twips, a cell = { pr, body = { paragraphs } }.
local function tbl(widths, cells)
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
    '<w:tblGrid>' .. table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) ..
    '</w:tr></w:tbl>'
end

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

-- ---------------------------------------------------------------------------
-- The page: line numbers, rules and footer (fb render's $FORMBOOK_FOOTERS and $FORMBOOK_FINAL)
-- ---------------------------------------------------------------------------

local VML = 'xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office"'
-- LibreOffice keeps a VML text box's inset whatever its `inset` says: the box moves by the difference, so that its
-- lines are typst's (the numbers end at number-col, each on its body line's baseline; measured in the PDF).
local BOX_DX, BOX_DY = 4, -4.25
local BOX_PAD = 12                            -- and room below the last number for the inset LibreOffice keeps
local PAGE_POS = 'position:absolute;mso-position-horizontal:absolute;mso-position-horizontal-relative:page;' ..
  'mso-position-vertical:absolute;mso-position-vertical-relative:page'

-- The numbers 1 to 27 in a text box at the left of the page, one per exact 24 pt line from the top margin, ending
-- at number-col; and the rules (typst pleading-rules): a double rule at the text's left edge, a single one at its
-- right, the height of the page. Both behind the text, anchored to the page.
local function furniture()
  local nums = {}
  for i = 1, LINES do
    nums[#nums + 1] = p(xe.runs(tostring(i)), { line = BODY, jc = "right" })
  end
  -- a rule: a black box 0.75 pt wide, centered on x_in inches, the height of the page
  local function rule(x_in, id)
    return '<w:r><w:pict ' .. VML .. '><v:rect id="CandRule' .. id .. '" fillcolor="black" filled="t" stroked="f" style="' .. PAGE_POS ..
      string.format(";margin-left:%.2fpt;margin-top:0;width:0.75pt;height:792pt", x_in * 72 - 0.375) ..
      ";z-index:-251658" .. (700 + id) .. '"/></w:pict></w:r>'
  end
  return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr><w:r><w:pict ' ..
    VML .. '>' ..
    '<v:shape id="CandLineNumbers" filled="f" stroked="f" style="' .. PAGE_POS .. ';margin-left:' .. BOX_DX .. 'pt;margin-top:' ..
    (TOP / 20 + BOX_DY) .. 'pt;width:' .. (NUMBER_COL / 20) .. 'pt;height:' .. (LINES * BODY / 20 + BOX_PAD) .. 'pt;z-index:-251658752">' ..
    '<v:textbox inset="0pt,0pt,0pt,0pt"><w:txbxContent>' .. table.concat(nums) .. '</w:txbxContent></v:textbox></v:shape>' ..
    '</w:pict></w:r>' .. rule(LEFT / 1440 - 0.2, 1) .. rule(LEFT / 1440 - 0.16, 2) .. rule(8.5 - RIGHT / 1440 + 0.1, 3) ..
    '</w:p>'
end

local PAGE_FIELD = '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE ' ..
  '</w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r>' ..
  '<w:r><w:fldChar w:fldCharType="end"/></w:r>'

-- The footer (typst footer-block): "-n-" centered, then the paper's title in capitals at the left and the case
-- number at the right, 10 pt in single-spaced line boxes; its foot as far above the page's foot as typst sets it.
local function footer(meta)
  local sz = { sz = FOOTER_SZ }
  local num = p(xe.runs("-", sz) .. PAGE_FIELD:gsub("<w:r>", "<w:r><w:rPr><w:sz w:val=\"" .. FOOTER_SZ ..
    "\"/><w:szCs w:val=\"" .. FOOTER_SZ .. "\"/></w:rPr>") .. xe.runs("-", sz), { jc = "center" })
  local title = xe.para({ '<w:tabs><w:tab w:val="right" w:pos="' .. TEXTW .. '"/></w:tabs>',
    xe.spacing(FOOTER_GAP, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("left") },
    xe.runs(pandoc.text.upper(plain(meta.footer_title)) .. "\tCASE NO. " .. plain(meta.case_number), sz))
  return furniture() .. num .. title
end

local function sect_pr()
  local foot = BOTTOM - FOOTER_TOP - SINGLE - FOOTER_GAP - SINGLE
  return '<w:sectPr><w:footerReference w:type="default" r:id="rIdCandFooter"/>' ..
    '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="' .. TOP .. '" w:right="' .. RIGHT .. '" w:bottom="' .. BOTTOM ..
    '" w:left="' .. LEFT .. '" w:header="720" w:footer="' .. foot .. '" w:gutter="0"/></w:sectPr>'
end

-- ---------------------------------------------------------------------------
-- Cover: counsel (lines 1-7), court title (line 8), caption
-- ---------------------------------------------------------------------------

local function cover(meta, out)
  -- the counsel lines drop so that every second baseline is a numbered line's (an empty line of the drop's height)
  out[#out + 1] = p("", { line = DROP })
  local counsel = meta.counsel or {}
  for _, l in ipairs(counsel) do out[#out + 1] = p(xe.inl(l)) end
  local court = { "UNITED STATES DISTRICT COURT", "NORTHERN DISTRICT OF CALIFORNIA" }
  if meta.division then court[#court + 1] = pandoc.text.upper(plain(meta.division)) end
  local above = math.max(0, COUNSEL_LINES * BODY - DROP - #counsel * SINGLE)
  for i, l in ipairs(court) do
    out[#out + 1] = p(xe.runs(l, { b = true }), { line = BODY, jc = "center", before = i == 1 and above or 0 })
  end
  -- the caption a numbered line and the drop below the court title (an empty line of that height: Word sets no
  -- space above a table)
  out[#out + 1] = p("", { line = BODY + DROP })
  -- the parties in a table of their own, ruled at its right and bottom, CAP_INSET right of and CAP_PAD below their
  -- lines, so the rules end with the parties as typst's box does, not with the taller right-hand column
  local left = {}
  local parties = meta.caption.parties
  for k, party in ipairs(parties) do
    if k > 1 then left[#left + 1] = p(xe.runs("v.")) end
    for _, n in ipairs(party.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(party.designation))
  end
  local right = { p(xe.runs("Case No. ") .. xe.inl(meta.case_number)) }
  local function bold(x) right[#right + 1] = p(x, { before = SINGLE }) end
  bold(xe.inl(meta.brief_title, { b = true }))
  -- an answer's dates and judge under the title, plain (typst caption_lines)
  for i, l in ipairs(meta.caption_lines or {}) do
    right[#right + 1] = p(xe.inl(l), { before = i == 1 and SINGLE or nil })
  end
  if meta.legend then bold(xe.runs(pandoc.text.upper(plain(meta.legend)), { b = true })) end
  if meta.jury_demand then bold(xe.runs("DEMAND FOR JURY TRIAL", { b = true })) end
  local r = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'
  local box = tbl({ CAP_LEFT }, { { pr = '<w:tcBorders><w:bottom ' .. r .. '/><w:right ' .. r .. '/></w:tcBorders>' ..
    '<w:tcMar><w:bottom w:w="' .. CAP_PAD .. '" w:type="dxa"/><w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar>',
    body = left } })
  out[#out + 1] = tbl({ CAP_LEFT, TEXTW - CAP_LEFT }, {
    { body = { box, p("", { line = 20 }) } },
    { pr = '<w:tcMar><w:left w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcMar>', body = right },
  })
end

-- ---------------------------------------------------------------------------
-- Signature block: the date at the margin; "Respectfully submitted,", the firm, the signature, the signer and the
-- signer's lines in the right-hand column; the row never splits. The space above it (a numbered line and the drop)
-- is a 1 pt paragraph kept with the table, its space before the rest: at the top of a page LibreOffice drops a
-- paragraph's space before, as typst drops a block's.
-- ---------------------------------------------------------------------------

local function signature(meta)
  local sig = meta.signature
  local right = { p(xe.runs("Respectfully submitted,")) }
  for i, l in ipairs(sig.firm or {}) do right[#right + 1] = p(xe.inl(l), { before = i == 1 and SINGLE or 0 }) end
  right[#right + 1] = p(xe.runs("By: /s/ ") .. xe.inl(sig.signer), { before = SINGLE })
  right[#right + 1] = p(xe.inl(sig.signer))
  for _, l in ipairs(sig.lines or {}) do right[#right + 1] = p(xe.inl(l)) end
  return p("", { keep = true, before = BODY + DROP - 20, line = 20 }) ..
    tbl({ SIG_LEFT, TEXTW - SIG_LEFT }, { { body = { p(xe.runs("Dated: ") .. xe.inl(meta.date)) } },
      { body = right } })
end

-- ---------------------------------------------------------------------------
-- The body
-- ---------------------------------------------------------------------------

-- Headings: one numbered line each, bold, kept with the text: level 1 centered in capitals, level 2 centered,
-- level 3 italic at the margin.
local function heading(el, brk)
  local content = el.content
  if el.level == 1 then
    content = content:walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local lvl = math.min(el.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, brk and xe.BREAK or "", xe.spacing(0, 0, BODY),
    xe.ind(0, nil, 0),
    xe.jc(lvl <= 2 and "center" or "left") }, xe.inl(content, { b = true, i = lvl == 3 }))
end

-- Prayer items: the label 1., 2., ... half an inch in, in a box of half an inch, the text hanging after it. When the list is the last block every item keeps with the next, so the whole list
-- moves with the signature block, as typst's sticky list block does.
local function items(list, out, keep_last, brk)
  for j, item in ipairs(list.content) do
    if #item ~= 1 or (item[1].t ~= "Plain" and item[1].t ~= "Para") then
      error("cand.lua: a list item holds one paragraph")
    end
    local lab = (list.listAttributes.start + j - 1) .. "."
    out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(item[1].content),
      { line = BODY, left = 2 * INDENT, hanging = INDENT, tab = 2 * INDENT,
        keep = keep_last, brk = brk and j == 1 })
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
-- A web address breaks only where the typst template lets it: after "?", "=", "&", or a hyphen or slash that no
-- digit, no second slash and no first slash comes next to (a zero-width space there, and none after the slashes of
-- "https://").
local function url_breaks(t)
  local cs = {}
  for _, c in utf8.codes(t) do cs[#cs + 1] = utf8.char(c) end
  local out = {}
  for i, c in ipairs(cs) do
    out[#out + 1] = c
    local nxt, prev = cs[i + 1] or "", cs[i - 1] or ""
    if nxt ~= "" and (c == "?" or c == "=" or c == "&" or ((c == "/" or c == "-") and nxt ~= "/"
        and not (c == "/" and prev == "/") and not nxt:match("^%d$"))) then
      out[#out + 1] = "\u{200B}"
    end
  end
  return table.concat(out)
end

local function breaks(s)
  local t = s.text
  local a = t:find("https?://") or t:find("www%.")
  if a then return pandoc.Str(t:sub(1, a - 1) .. url_breaks(t:sub(a))) end
  return pandoc.Str((t:gsub("%)%(", ")\u{2060}("):gsub("/([^%d])", "/\u{200B}%1")))
end

-- A doubled section sign stays with its number ("§§ 1114"), as the typst template boxes it.
local function bind_double_signs(l)
  for i = 1, #l - 1 do
    if l[i].t == "Str" and (l[i].text == "§§" or l[i].text == "¶¶") and l[i + 1].t == "Space" then
      l[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

function Pandoc(doc)
  local meta = doc.meta
  write_file("FORMBOOK_FOOTERS", "rIdCandFooter\t" .. footer(meta) .. "\n")
  write_file("FORMBOOK_FINAL", sect_pr())
  doc.blocks = doc.blocks:walk({ Str = breaks }):walk({ Inlines = bind_double_signs })
  local out = {}
  cover(meta, out)
  -- an answer's body starts on the first page, one numbered line below the caption (typst v(pitch))
  out[#out + 1] = p("", { line = BODY })
  local brk = false
  if meta.lead_in then
    out[#out + 1] = p(xe.inl(meta.lead_in), { line = BODY, first = INDENT })
  end
  local blocks = doc.blocks
  local n = 0
  local numbered = true
  for i, b in ipairs(blocks) do
    local last = i == #blocks
    if b.t == "Header" then
      -- after the jury demand, affirmative defenses or prayer heading, paragraphs are unnumbered (typst unnumbered-from)
      local h = pandoc.text.lower(pandoc.utils.stringify(b.content))
      if b.level == 1 and (h:find("affirmative defenses") or h:find("jury") or h:find("prayer")) then numbered = false end
      out[#out + 1] = heading(b, brk)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      items(b, out, last, brk)
    elseif (b.t == "Para" or b.t == "Plain") and not numbered then
      out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT, keep = last })
    elseif b.t == "Para" or b.t == "Plain" then
      -- a numbered allegation: the number after the first-line indent, a tab to the next half inch, the text; the
      -- last paragraph stays whole with the signature block (typst: a sticky, unbreakable block)
      n = n + 1
      out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(b.content), { line = BODY, first = INDENT, tab = 2 * INDENT,
        keep = last, brk = brk })
    else
      error("cand.lua: unsupported block " .. b.t)
    end
    brk = false
  end
  out[#out + 1] = signature(meta)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
