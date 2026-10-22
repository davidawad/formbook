-- nmib-adversary-complaint.lua (docx engine, Bankruptcy Court of the Northern Mariana Islands, adversary complaint):
-- the complaint as Word paragraphs, so that it reads and breaks as typst/nmib-adversary-complaint.typ does: the
-- counsel block (numbered lines 1 to 7 at least), the court title, the Official Form 416D caption (a table, the party
-- column ruled at its right and foot), then on a new page the numbered allegations (Fed. R. Civ. P. 10(b)), headings,
-- the "~ " lead-in (unnumbered), lettered lists and the signature block. Every case word comes from the sample's
-- frontmatter and body, never from this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the numbered line, 240 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. The footer (FORMBOOK_FOOTERS)
-- holds two frames placed on the page as typst places its background and foreground: the line numbers 1 to 24, one
-- per numbered line, ending 0.45 in left of the text; and the page number, the paper's title and the case number
-- 6 pt under the last numbered line. The last section (FORMBOOK_FINAL) names that footer.

local xe = require("docx.xengine")

local BODY, SINGLE = 480, 240            -- typst pitch, pitch-single
local DROP = 192                        -- typst single-drop: 0.8 x (24 - 12) pt, a single-line block starts this far down
local LINES = 24                         -- typst lines-per-page
local TOP, LEFT = 2160, 1872             -- typst top-margin 1.5 in, left-margin 1.3 in
local TEXTW = 8928                       -- typst text-width, 6.2 in
local INDENT = 720                       -- typst para-indent, 0.5 in
local NUMBOX = 720                       -- typst num-box, 0.5 in
local LABEL = 576                        -- typst list-label, 0.4 in
local DESIG = 1440                       -- typst designation-indent, 1 in
local CAP_LEFT = 4608                    -- typst caption-left, 3.2 in
local CAP_PAD = 200                      -- typst caption-pad, 10 pt
local CAP_FOOT = 145                     -- typst caption-foot, 8 pt (160), less the 0.75 pt rule Word adds below it
local CAP_GUTTER = 432                   -- typst caption-gutter, 0.3 in
local SIG = 4032                         -- typst sig-col, 2.8 in
local COUNSEL = 7                        -- typst counsel-lines
local NUMCOL = 1224                      -- typst number-col, 1.3 in - 0.45 in
local FOOT_Y = TOP + LINES * BODY + 120  -- typst footer-block: 6 pt under the last numbered line
local FOOT_SZ, FOOT_LINE, FOOT_GAP = 20, 240, 80   -- typst footer-size 10 pt, footer-pitch 12 pt, footer-gap 4 pt

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

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, brk, tabs }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.brk then props[#props + 1] = xe.BREAK end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- One single line per item; an empty item is a blank single line (typst: single).
local function single(text, o)
  o = o or {}
  local t = plain(text)
  return p(t == "" and "" or xe.inl(text, o.r), o)
end

-- ---------------------------------------------------------------------------
-- Footer: the line numbers and the page footer, as frames on the page
-- ---------------------------------------------------------------------------

local function frame(x, y, w)
  return '<w:framePr w:w="' .. w .. '" w:hSpace="0" w:wrap="around" w:vAnchor="page" w:hAnchor="page" w:x="' .. x ..
    '" w:y="' .. y .. '"/>'
end

local PAGE = '<w:r><w:rPr><w:sz w:val="' .. FOOT_SZ .. '"/><w:szCs w:val="' .. FOOT_SZ .. '"/></w:rPr>' ..
  '<w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="' .. FOOT_SZ .. '"/></w:rPr>' ..
  '<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="' .. FOOT_SZ .. '"/></w:rPr>' ..
  '<w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="' .. FOOT_SZ .. '"/></w:rPr><w:t>1</w:t></w:r>' ..
  '<w:r><w:rPr><w:sz w:val="' .. FOOT_SZ .. '"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r>'

-- The pleading rules, the full height of the page as typst draws them (pleading-rules): a double rule 0.2 in and
-- 0.16 in left of the text, a single rule 0.1 in right of it; VML lines placed on the page, behind the text.
local function vline(x)
  return '<w:r><w:pict><v:line xmlns:v="urn:schemas-microsoft-com:vml" from="' .. x .. 'pt,0" to="' .. x ..
    'pt,792pt" strokeweight="0.75pt" strokecolor="black" style="position:absolute;' ..
    'mso-position-horizontal-relative:page;mso-position-vertical-relative:page;z-index:-1"/></w:pict></w:r>'
end
local RULES_VML = vline(79.2) .. vline(82.08) .. vline(547.2)

local function footer(meta)
  local out = {}
  local nf = frame(0, TOP, NUMCOL)
  for i = 1, LINES do
    out[#out + 1] = xe.para({ nf, xe.spacing(0, 0, BODY), xe.ind(0, nil, 0), xe.jc("right") }, xe.runs(tostring(i)))
  end
  out[#out + 1] = xe.para({ xe.spacing(0, 0, FOOT_LINE), xe.ind(0, nil, 0), xe.jc("center") }, RULES_VML .. PAGE)
  out[#out + 1] = xe.para({ '<w:tabs><w:tab w:val="right" w:pos="' .. TEXTW .. '"/></w:tabs>',
    xe.spacing(FOOT_GAP, 0, FOOT_LINE), xe.ind(0, nil, 0), xe.jc("left") },
    xe.runs(pandoc.text.upper(plain(meta.footer_title)) .. "\tCASE NO. " .. plain(meta.case_number), { sz = FOOT_SZ }))
  return table.concat(out)
end

local SECT = '<w:sectPr><w:footerReference w:type="default" r:id="rIdNmibFooter"/>' ..
  '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="2160" w:right="1440" w:bottom="2160" w:left="1872" ' ..
  'w:header="720" w:footer="1480" w:gutter="0"/><w:cols w:space="720"/></w:sectPr>'

local function write_file(env, s)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(s)
  f:close()
end

-- ---------------------------------------------------------------------------
-- Cover: counsel, court title, caption
-- ---------------------------------------------------------------------------

local function cell(w, pr, ps)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. pr .. '</w:tcPr>' .. table.concat(ps) .. '</w:tc>'
end

local function two_col(lw, left_pr, left, right_pr, right)
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/><w:tblLayout w:type="fixed"/>' ..
    '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>' ..
    '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" ' ..
    'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid><w:gridCol w:w="' ..
    lw .. '"/><w:gridCol w:w="' .. (TEXTW - lw) .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' ..
    cell(lw, left_pr, left) .. cell(TEXTW - lw, right_pr, right) .. '</w:tr></w:tbl>'
end

local RULES = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
  '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>'

local function cover(meta, out)
  -- counsel: single lines, the block at least COUNSEL numbered lines tall (the court title starts on line 8)
  local counsel = list(meta.counsel)
  for k, l in ipairs(counsel) do out[#out + 1] = single(l, { before = k == 1 and DROP or 0 }) end
  local used = DROP + #counsel * SINGLE
  local slots = math.max(COUNSEL, math.ceil(used / BODY))
  local first = true
  for _, l in ipairs(list(meta.court)) do
    out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(l)), { b = true }),
      { line = BODY, jc = "center", before = first and (slots * BODY - used) or 0 })
    first = false
  end
  -- caption (Official Form 416D): one numbered line below the court title
  local left = {}
  for i, side in ipairs(list(meta.caption)) do
    if i > 1 then left[#left + 1] = single("") end
    for _, n in ipairs(list(side.names)) do left[#left + 1] = single(n) end
    left[#left + 1] = single(side.designation, { left = DESIG })
  end
  local adv = meta.adv_number and plain(meta.adv_number) or string.rep("_", 8)
  local right = {
    single("Case No. " .. plain(meta.case_number)),
    single("Chapter " .. plain(meta.chapter)),
    single(""),
    p(xe.runs("Adv. Proc. No. " .. adv)),
    single(""),
    p(xe.inl(meta.brief_title, { b = true })),
  }
  if meta.jury_demand == true then
    right[#right + 1] = single("")
    right[#right + 1] = p(xe.runs("DEMAND FOR JURY TRIAL", { b = true }))
  end
  out[#out + 1] = p("", { line = BODY })
  out[#out + 1] = two_col(CAP_LEFT,
    RULES .. '<w:tcMar><w:top w:w="' .. DROP .. '" w:type="dxa"/><w:bottom w:w="' .. CAP_FOOT .. '" w:type="dxa"/><w:right w:w="' .. CAP_PAD ..
    '" w:type="dxa"/></w:tcMar>', left,
    '<w:tcMar><w:top w:w="' .. DROP .. '" w:type="dxa"/><w:left w:w="' .. CAP_GUTTER .. '" w:type="dxa"/></w:tcMar>', right)
end

-- ---------------------------------------------------------------------------
-- Signature: "Dated:" in the first column, the signer's lines in the second
-- ---------------------------------------------------------------------------

local function signature(meta, out)
  local sig = meta.signature or {}
  local right = { single("Respectfully submitted,"), single("") }
  for _, l in ipairs(list(sig.firm)) do right[#right + 1] = single(l) end
  right[#right + 1] = single("")
  right[#right + 1] = p(xe.runs("By: /s/ ") .. xe.inl(sig.signer))
  right[#right + 1] = single(sig.signer)
  for _, l in ipairs(list(sig.lines)) do right[#right + 1] = single(l) end
  out[#out + 1] = p("", { line = BODY })
  local top = '<w:tcMar><w:top w:w="' .. DROP .. '" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = two_col(SIG, top, { p(xe.runs("Dated: ") .. xe.inl(meta.date)) }, top, right)
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings: one numbered line each, kept with the text: level 1 centered bold capitals, level 2 centered bold,
-- level 3 bold italic at the margin.
local function heading(b, brk)
  local content = b.content
  if b.level == 1 then
    content = pandoc.Inlines(content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
  end
  local lvl = math.min(b.level, 3)
  local props = { xe.style("Heading" .. lvl), xe.KEEP }
  if brk then props[#props + 1] = xe.BREAK end
  props[#props + 1] = xe.spacing(0, 0, BODY)
  props[#props + 1] = xe.ind(0, nil, 0)
  props[#props + 1] = xe.jc(lvl <= 2 and "center" or "left")
  return xe.para(props, xe.inl(content, { b = true, i = lvl == 3 }))
end

local NUMTAB = '<w:tabs><w:tab w:val="left" w:pos="' .. (INDENT + NUMBOX) .. '"/></w:tabs>'

local function blocks(list_, out)
  local n, brk = 0, true
  for _, b in ipairs(list_) do
    if b.t == "Header" then
      out[#out + 1] = heading(b, brk)
    elseif b.t == "OrderedList" or b.t == "BulletList" then
      for k, item in ipairs(b.content) do
        local lab = b.t == "OrderedList" and ("(" .. string.char(96 + k) .. ")") or "\u{2022}"
        local inl = {}
        for _, blk in ipairs(item) do
          if blk.content then for _, x in ipairs(blk.content) do inl[#inl + 1] = x end end
        end
        out[#out + 1] = p(xe.runs(lab .. "\t") .. xe.inl(pandoc.Inlines(inl)),
          { line = BODY, left = INDENT + LABEL, hanging = LABEL, brk = brk })
        brk = false
      end
    elseif b.t == "Para" or b.t == "Plain" then
      local c = b.content
      if c[1] and c[1].t == "Str" and c[1].text == "~" then
        -- the "~ " lead-in: no number, a first-line indent
        local rest = pandoc.Inlines({ table.unpack(c, 2) })
        if rest[1] and rest[1].t == "Space" then rest:remove(1) end
        out[#out + 1] = p(xe.inl(rest), { line = BODY, first = INDENT, brk = brk })
      else
        n = n + 1
        out[#out + 1] = p(xe.runs(n .. ".\t") .. xe.inl(c), { line = BODY, first = INDENT, tabs = NUMTAB, brk = brk })
      end
    else
      error("nmib-adversary-complaint.lua: unsupported block " .. b.t)
    end
    brk = false
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 1334(b)"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  local out = {}
  cover(meta, out)
  blocks(doc.blocks, out)
  signature(meta, out)
  write_file("FORMBOOK_FOOTERS", "rIdNmibFooter\t" .. footer(meta) .. "\n")
  write_file("FORMBOOK_FINAL", SECT)
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
