-- nceb-motion-brief.lua (docx engine): the E.D.N.C. bankruptcy memorandum of law as Word paragraphs, so that it reads
-- and breaks as typst/nceb-motion-brief.typ does: the court lines and division, the caption ("In re:" and the parties
-- in a column ruled on its right and bottom, the case numbers beside it), the title, the headings, the body
-- paragraphs, block quotations (their numbered items with the number in a box), the signature block and the
-- certificate of service on a page of its own (LBR 9013-3). Everything printed comes from the sample's frontmatter and
-- body: no case text lives in this file.
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276            -- typst pitch-double, pitch-single
local GAP = 240                          -- typst gap, 12 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local HANG = 720                         -- typst heading-hang, 0.5 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4896                    -- typst caption-left, 3.4 in
local CAP_RIGHT_IND = 432                -- typst caption-gutter + caption-inset, 0.3 in
local RULE_R, RULE_B = 200, 145          -- typst rule-pad-right 10 pt, rule-pad-bottom 8 pt less the 0.75 pt rule
                                         -- LibreOffice adds to the row (measured)
local QUOTE = 1440                       -- typst quote-inset, 1 in
local QITEM = 360                        -- typst quote-item, 0.25 in
local SIG = 4320                         -- typst sig-indent, 3 in
local SERVED = 1440                      -- typst served-indent, 1 in

local function plain(m)
  if m == nil then return "" end
  if type(m) == "string" then return m end
  return stringify(m)
end

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, page }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.page then props[#props + 1] = xe.BREAK end
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

local function tc(w, pr, body)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. w .. '" w:type="dxa"/>' .. (pr or "") .. '</w:tcPr>' .. body .. '</w:tc>'
end

-- ---------------------------------------------------------------------------
-- Caption: court, division, "In re:" and the parties (ruled right and bottom) beside the case numbers, title
-- ---------------------------------------------------------------------------

local function caption(meta, out)
  for _, l in ipairs(meta.court) do out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(l)), { b = true }), { jc = "center" }) end
  -- typst: the caption block stands 18 pt below the division
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(meta.division)), { b = true }), { jc = "center", after = 360 })
  local left = { p(xe.runs("In re:"), { after = GAP // 2 }) }
  local function party(pt)
    for _, n in ipairs(pt.names) do left[#left + 1] = p(xe.inl(n)) end
    left[#left + 1] = p(xe.inl(pt.designation), { jc = "right", after = GAP })
  end
  for _, pt in ipairs(meta.caption.in_re) do party(pt) end
  for _, pt in ipairs(meta.caption.parties) do party(pt) end
  local right = { p("", { line = SINGLE + GAP // 2 }), p(xe.runs("Case No. " .. plain(meta.case_number))),
    p(xe.runs("Chapter " .. plain(meta.chapter))) }
  if meta.adversary_number then
    right[#right + 1] = p(xe.runs("Adversary Proceeding No. " .. plain(meta.adversary_number)), { before = GAP })
  end
  local rule = '<w:tcBorders><w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>' ..
    '<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/></w:tcBorders>' ..
    '<w:tcMar><w:bottom w:w="' .. RULE_B .. '" w:type="dxa"/><w:right w:w="' .. RULE_R .. '" w:type="dxa"/></w:tcMar>'
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    '<w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. (TEXTW - CAP_LEFT) .. '"/></w:tblGrid>' ..
    '<w:tr><w:trPr><w:cantSplit/></w:trPr>' .. tc(CAP_LEFT, rule, table.concat(left)) ..
    tc(TEXTW - CAP_LEFT, '<w:tcMar><w:left w:w="' .. CAP_RIGHT_IND .. '" w:type="dxa"/></w:tcMar>', table.concat(right)) ..
    '</w:tr></w:tbl>'
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(meta.title)), { b = true }), { jc = "center", before = 360, after = GAP })
end

-- ---------------------------------------------------------------------------
-- Signature block (kept together: typst an unbreakable block) and certificate of service
-- ---------------------------------------------------------------------------

local function signature(sig, out)
  local rows = {}
  if sig.date then rows[#rows + 1] = { xe.runs("Dated: ") .. xe.inl(sig.date), 0, GAP } end
  rows[#rows + 1] = { xe.runs("Respectfully submitted,"), SIG, GAP }
  for _, s in ipairs(sig.signers) do
    rows[#rows + 1] = { xe.inl(s.sign), SIG, GAP }
    for _, l in ipairs(s.lines) do rows[#rows + 1] = { xe.inl(l), SIG, 0 } end
  end
  if sig.role then rows[#rows + 1] = { xe.inl(sig.role, { i = true }), SIG, GAP } end
  for i, r in ipairs(rows) do out[#out + 1] = p(r[1], { left = r[2], before = r[3], keep = i < #rows }) end
end

local function certificate(c, out)
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(c.title)), { b = true }), { jc = "center", page = true })
  out[#out + 1] = p(xe.inl(c.text), { line = BODY, first = INDENT, before = 360 })
  for i, l in ipairs(c.served) do out[#out + 1] = p(xe.inl(l), { left = SERVED, before = i == 1 and GAP or 0 }) end
  out[#out + 1] = p(xe.runs("Dated: ") .. xe.inl(c.date), { left = SIG, before = 360 })
  out[#out + 1] = p(xe.inl(c.signer.sign), { left = SIG, before = GAP })
  for _, l in ipairs(c.signer.lines) do out[#out + 1] = p(xe.inl(l), { left = SIG }) end
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

-- Headings, single-spaced, kept with the text: level 1 centered bold capitals (24 pt above, 12 below), level 2 bold at
-- the margin with its later lines hanging 0.5 in (12 and 12).
local function heading(b)
  local lvl = math.min(b.level, 2)
  if lvl == 1 then
    local content = pandoc.Inlines(b.content):walk({ Str = function(s) return pandoc.Str(pandoc.text.upper(s.text)) end })
    return p(xe.inl(content, { b = true }), { style = "Heading1", keep = true, before = 2 * GAP, after = GAP, jc = "center" })
  end
  return p(xe.inl(b.content, { b = true }), { style = "Heading2", keep = true, before = GAP, after = GAP, left = HANG,
    hanging = HANG })
end

-- A block quotation: its paragraphs and numbered items single-spaced, indented both sides, a gap apart; an item's
-- number, a tab to the end of its box, the text hanging after it.
local function quotation(bq, out)
  local parts = {}
  for _, b in ipairs(bq.content) do
    if b.t == "OrderedList" then
      local n = b.listAttributes.start
      for _, item in ipairs(b.content) do
        parts[#parts + 1] = { xe.runs(n .. ".\t") .. xe.inl(item[1].content), true }
        n = n + 1
      end
    elseif b.t == "Para" or b.t == "Plain" then
      parts[#parts + 1] = { xe.inl(b.content), false }
    else
      error("nceb-motion-brief.lua: unsupported block in a quotation: " .. b.t)
    end
  end
  for k, q in ipairs(parts) do
    local o = { before = k == 1 and GAP // 2 or GAP, after = k == #parts and GAP or 0, left = QUOTE, right = QUOTE }
    if q[2] then o.left, o.hanging = QUOTE + QITEM, QITEM end
    out[#out + 1] = p(q[1], o)
  end
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 105(a)"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

-- Smart punctuation as typst reads the sample (cmarker; pandoc's smart extension pairs an unclosed quotation
-- differently and can drop the space before the next one, so reference.xml turns it off). Each quotation mark is
-- left-flanking (before a non-space, and not before punctuation unless after a space or punctuation) and/or
-- right-flanking (the same, mirrored); it can open when left-flanking and not right-flanking unless after punctuation,
-- and close when right-flanking and not left-flanking unless before punctuation. A closer pairs with the nearest open
-- one of its kind: the pair is set “ ” (‘ ’). Every other double mark is “, every other single one ’. "--" and "---"
-- are dashes, "..." an ellipsis.
local function is_ws(c) return c == nil or c == 32 or c == 9 or c == 10 or c == 0xA0 end
local function is_punct(c)
  if c == nil then return false end
  if c < 128 then return (c >= 33 and c <= 47) or (c >= 58 and c <= 64) or (c >= 91 and c <= 96) or (c >= 123 and c <= 126) end
  return (c >= 0x2010 and c <= 0x2027) or c == 0xA7 or c == 0xB6
end

local function smart(inlines)
  local strs, seq = {}, {}
  local function scan(list)
    for _, el in ipairs(list) do
      if el.t == "Str" then
        local cps = {}
        for _, cp in utf8.codes(el.text) do cps[#cps + 1] = cp end
        strs[#strs + 1] = { el = el, cps = cps }
        for k = 1, #cps do seq[#seq + 1] = { s = #strs, k = k } end
      elseif el.t == "Space" or el.t == "SoftBreak" or el.t == "LineBreak" then
        seq[#seq + 1] = { cp = 32 }
      elseif el.content and type(el.content) ~= "string" and el.t ~= "Note" then
        scan(el.content)
      else
        seq[#seq + 1] = { cp = 120 }
      end
    end
  end
  scan(inlines)
  local function cp(j)
    local x = seq[j]
    if x == nil then return nil end
    return x.cp or strs[x.s].cps[x.k]
  end
  local function set(x, v) strs[x.s].cps[x.k] = v end
  local open = { [34] = {}, [39] = {} }
  local mark = { [34] = { 0x201C, 0x201D }, [39] = { 0x2018, 0x2019 } }
  for j = 1, #seq do
    local c = cp(j)
    if c == 34 or c == 39 then
      local b, a = cp(j - 1), cp(j + 1)
      local left = not is_ws(a) and (not is_punct(a) or is_ws(b) or is_punct(b))
      local right = not is_ws(b) and (not is_punct(b) or is_ws(a) or is_punct(a))
      local x = seq[j]
      set(x, c == 34 and 0x201C or 0x2019)
      if right and (not left or is_punct(a)) and #open[c] > 0 then
        set(table.remove(open[c]), mark[c][1])
        set(x, mark[c][2])
      elseif left and (not right or is_punct(b)) then
        open[c][#open[c] + 1] = x
      end
    end
  end
  for _, s in ipairs(strs) do
    s.el.text = utf8.char(table.unpack(s.cps)):gsub("%-%-%-", "\u{2014}"):gsub("%-%-", "\u{2013}"):gsub("%.%.%.", "\u{2026}")
  end
  return inlines
end

local function smart_block(el)
  el.content = smart(el.content)
  return el
end

local function smart_meta(m)
  local t = pandoc.utils.type(m)
  if t == "Inlines" then return smart(m) end
  if t == "Blocks" then return pandoc.Blocks(m):walk({ Para = smart_block, Plain = smart_block }) end
  if type(m) == "table" then for k, v in pairs(m) do m[k] = smart_meta(v) end end
  return m
end

function Pandoc(doc)
  doc = doc:walk({ Para = smart_block, Plain = smart_block, Header = smart_block })
  doc.meta = smart_meta(doc.meta)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled })
  local meta = doc.meta
  local out = {}
  caption(meta, out)
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" then
      out[#out + 1] = heading(b)
    elseif b.t == "BlockQuote" then
      quotation(b, out)
    elseif b.t == "Para" or b.t == "Plain" then
      out[#out + 1] = p(xe.inl(b.content), { line = BODY, first = INDENT })
    else
      error("nceb-motion-brief.lua: unsupported block " .. b.t)
    end
  end
  signature(meta.signature, out)
  if meta.certificate then certificate(meta.certificate, out) end
  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = xe.raw(x) end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
