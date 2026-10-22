-- idb.lua (docx engine, D. Idaho bankruptcy court, motion or brief in a contested matter): the paper as Word
-- paragraphs, so that it reads and breaks as typst/idb-motion-brief.typ does: the counsel block (LBR 5005-1(c)(1)),
-- the court lines, the caption (a table whose party column is ruled at its right: the debtors under "In re:", their
-- designation centered; the case number, chapter and judge beside them, LBR 5005-1(c)(3)), the title, the
-- negative-notice legend in a ruled box (LBR 2002-2(d)(1); a one-cell table), the lead-in, the body (numbered
-- paragraphs, the template's numbers; `: ` and WHEREFORE paragraphs unnumbered, `~ ` flush, `- ` bullets, `> `
-- quotations, headings, footnotes), the dated line and signature block kept with the last body paragraph, and the
-- certificate of service with its own signature. Every case word comes from the sample's frontmatter and body, never
-- from this file (contract: ../README.md).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 552 the double-spaced body, 276 a single line), the spaces
-- between blocks those of the typst template, and the break rules of typst on every run. A paragraph that carries a
-- footnote is left to pandoc in "Body Text Note" (the same layout), so that pandoc writes the note.

local xe = require("docx.xengine")

local BODY, SINGLE = 552, 276            -- typst pitch-double, pitch-single
local GAP = 276                          -- typst gap
local NOTICE_GAP = 138                   -- typst notice-gap, 6.9 pt
local INDENT = 720                       -- typst para-indent, 0.5 in
local NUM = 1440                         -- the tab after a paragraph number: para-indent + num-width
local BULLET = 432                       -- typst bullet-width, 0.3 in
local TEXTW = 9360                       -- 6.5 in
local CAP_LEFT = 4896                    -- typst caption-left, 3.4 in
local CAP_PAD_L, CAP_PAD_R = 288, 432    -- typst caption-pad-left 0.2 in, caption-pad-right 0.3 in
local INSET = 144                        -- typst notice-inset, 0.1 in
local INSET_Y = 129                      -- the same above and below the text, less the 0.75 pt rule Word adds inside the cell
local Q_LEFT, Q_RIGHT = 1080, 720        -- typst quote-left 0.75 in, quote-right 0.5 in
local SIG = 4320                         -- typst sig-indent, 3.0 in

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

-- A paragraph: o = { before, after, line, left, right, first, hanging, jc, keep, tab }.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.keep then props[#props + 1] = xe.KEEP end
  if o.tab then props[#props + 1] = '<w:tabs><w:tab w:val="left" w:pos="' .. o.tab .. '"/></w:tabs>' end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.line or SINGLE)
  local first = o.first
  if first == nil and not o.hanging then first = 0 end
  props[#props + 1] = xe.ind(o.left or 0, o.hanging, first, o.right)
  props[#props + 1] = xe.jc(o.jc or "left")
  return xe.para(props, body)
end

-- Single lines, one per item; an empty (or blank) item is a blank line (typst: lines).
local function lines(items, o, out)
  out = out or {}
  for _, l in ipairs(items) do out[#out + 1] = p(plain(l):match("^%s*$") and "" or xe.inl(l), o) end
  return out
end

local TBL_PR = '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/>' ..
  '<w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>' ..
  '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'

-- A one-row table that never splits: cells = { { width, paragraphs, tcPr extra } }.
local function tbl(cells)
  local grid, tcs = {}, {}
  for _, c in ipairs(cells) do
    grid[#grid + 1] = '<w:gridCol w:w="' .. c[1] .. '"/>'
    tcs[#tcs + 1] = '<w:tc><w:tcPr><w:tcW w:w="' .. c[1] .. '" w:type="dxa"/>' .. (c[3] or "") .. '</w:tcPr>' ..
      table.concat(c[2]) .. '</w:tc>'
  end
  return '<w:tbl><w:tblPr><w:tblW w:w="' .. TEXTW .. '" w:type="dxa"/>' .. TBL_PR .. '</w:tblPr><w:tblGrid>' ..
    table.concat(grid) .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>' .. table.concat(tcs) .. '</w:tr></w:tbl>'
end

local function rule(sides)
  local x = "<w:tcBorders>"
  for _, s in ipairs(sides) do x = x .. '<w:' .. s .. ' w:val="single" w:sz="6" w:space="0" w:color="000000"/>' end
  return x .. "</w:tcBorders>"
end

-- ---------------------------------------------------------------------------
-- Cover
-- ---------------------------------------------------------------------------

local function caption(meta)
  local d = meta.debtors
  local left = lines({ "In re:", "" }, { right = CAP_PAD_L })
  lines(list(d.names), { right = CAP_PAD_L }, left)
  left[#left + 1] = p(xe.inl(d.designation), { right = CAP_PAD_L, jc = "center" })
  local r = { "", "Case No. " .. plain(meta.case_number), "", "Chapter " .. plain(meta.chapter) }
  if meta.judge then
    r[#r + 1] = ""
    r[#r + 1] = meta.judge
  end
  local right = lines(r, { left = CAP_PAD_R })
  return tbl({ { CAP_LEFT, left, rule({ "right" }) }, { TEXTW - CAP_LEFT, right } })
end

-- LBR 2002-2(d)(1): the legend in a ruled box (a one-cell table, the inset as cell margins).
local function notice(n)
  local ps = { p(xe.runs(pandoc.text.upper(plain(n.heading)), { b = true }), { jc = "center" }) }
  for _, q in ipairs(list(n.paragraphs)) do
    local body = ""
    if q.label then body = xe.inl(q.label, { u = true }) .. xe.runs(" ") end
    ps[#ps + 1] = p(body .. xe.inl(q.text), { before = NOTICE_GAP })
  end
  local mar = '<w:tcMar><w:top w:w="' .. INSET_Y .. '" w:type="dxa"/><w:left w:w="' .. INSET .. '" w:type="dxa"/>' ..
    '<w:bottom w:w="' .. INSET_Y .. '" w:type="dxa"/><w:right w:w="' .. INSET .. '" w:type="dxa"/></w:tcMar>'
  return tbl({ { TEXTW, ps, rule({ "top", "left", "bottom", "right" }) .. mar } })
end

local function cover(meta, out)
  lines(list(meta.counsel), {}, out)
  out[#out + 1] = p(xe.runs("UNITED STATES BANKRUPTCY COURT", { b = true }), { before = GAP, jc = "center" })
  out[#out + 1] = p(xe.runs("FOR THE DISTRICT OF IDAHO", { b = true }), { jc = "center" })
  out[#out + 1] = p("", { line = GAP })     -- typst: the caption stands a single line below the court lines
  out[#out + 1] = caption(meta)
  out[#out + 1] = p(xe.runs(pandoc.text.upper(plain(meta.title)), { b = true }), { before = GAP, jc = "center" })
  if meta.notice then
    out[#out + 1] = p("", { line = GAP })
    out[#out + 1] = notice(meta.notice)
  end
  out[#out + 1] = p(xe.inl(meta.lead_in), { before = GAP, line = BODY, first = INDENT })
end

-- ---------------------------------------------------------------------------
-- Body
-- ---------------------------------------------------------------------------

local function has_note(el)
  local found = false
  pandoc.Pandoc({ el }):walk({ Note = function() found = true end })
  return found
end

-- Headings at the body pitch, bold, kept with the text: level 1 centered with a single line above, level 2
-- centered, level 3 at the left.
local function heading(b)
  local lvl = math.min(b.level, 3)
  return xe.para({ xe.style("Heading" .. lvl), xe.KEEP, xe.spacing(lvl == 1 and GAP or 0, 0, BODY), xe.ind(0, nil, 0),
    xe.jc(lvl == 3 and "left" or "center") }, xe.inl(b.content, { b = true }))
end

-- A quotation: single spaced, indented both sides, a single line above and below; a hard line break of the sample
-- stays one.
local function quotation(inl)
  local parts, cur = {}, pandoc.Inlines({})
  for _, el in ipairs(inl) do
    if el.t == "LineBreak" then
      parts[#parts + 1] = cur
      cur = pandoc.Inlines({})
    else
      cur:insert(el)
    end
  end
  parts[#parts + 1] = cur
  local body = {}
  for i, x in ipairs(parts) do body[#body + 1] = (i > 1 and xe.BR or "") .. xe.inl(x) end
  return p(table.concat(body), { before = GAP, after = GAP, left = Q_LEFT, right = Q_RIGHT })
end

-- The leading marker of a paragraph ("~", ":"), with the space after it, removed.
local function strip(inl)
  local rest = pandoc.Inlines(inl)
  rest:remove(1)
  if rest[1] and rest[1].t == "Space" then rest:remove(1) end
  return rest
end

-- typst's break opportunities that LibreOffice does not share: none inside ")(" (a word joiner), one after a
-- slash before a letter (a zero-width space). Neither shows in the PDF text.
local function breaks(s)
  return pandoc.Str((s.text:gsub("%)%(", ")\u{2060}("):gsub("/([^%d%s])", "/\u{200B}%1")))
end

-- A doubled sign stays with its number ("§§ 157"; typst boxes "[§¶]+ \S+", xe.inl binds a single sign).
local function bind_doubled(inl)
  for i = 1, #inl - 1 do
    local a, b = inl[i], inl[i + 1]
    if a.t == "Str" and a.text:match("^[\u{00A7}\u{00B6}][\u{00A7}\u{00B6}]+$") and b.t == "Space" then
      inl[i + 1] = pandoc.Str("\u{00A0}")
    end
  end
  return inl
end

-- A space before a footnote mark is not printed (typst sets the mark against the word).
local function tight_notes(inl)
  for i = #inl - 1, 1, -1 do
    if inl[i].t == "Space" and inl[i + 1].t == "Note" then inl:remove(i) end
  end
  return inl
end

function Pandoc(doc)
  doc = doc:walk({ Str = breaks }):walk({ Inlines = bind_doubled }):walk({ Inlines = tight_notes })
  local meta = doc.meta
  local out = {}
  cover(meta, out)

  -- the body runs up to the certificate of service; the signature closes it, kept with its last paragraph
  local blocks, cert = {}, {}
  local into = blocks
  for _, b in ipairs(doc.blocks) do
    if b.t == "Header" and b.level == 1 and plain(b.content):match("^CERTIFICATE") then into = cert end
    into[#into + 1] = b
  end

  local num, num_on = 0, true
  local function body(list_, keep_last)
    for i, b in ipairs(list_) do
      local keep = keep_last and i == #list_
      if b.t == "Header" then
        local t = plain(b.content)
        if b.level == 1 and (t:match("^PRAYER") or t:match("^CERTIFICATE")) then num_on = false end
        out[#out + 1] = heading(b)
      elseif b.t == "BulletList" then
        for _, item in ipairs(b.content) do
          out[#out + 1] = p(xe.runs("\u{2022}\t") .. xe.inl(item[1].content),
            { line = BODY, left = INDENT + BULLET, hanging = BULLET, keep = keep })
        end
      elseif b.t == "BlockQuote" then
        for _, q in ipairs(b.content) do out[#out + 1] = quotation(q.content) end
      elseif b.t == "Para" or b.t == "Plain" then
        local first = b.content[1] and plain(b.content[1]) or ""
        local inl, o, label = b.content, { line = BODY, first = INDENT, keep = keep }, nil
        if first == "~" then
          inl, o.first = strip(inl), 0
        elseif first == ":" then
          inl = strip(inl)
        elseif first:match("^WHEREFORE") or not num_on then
          -- unnumbered
        else
          num = num + 1
          label = num .. "."
          o.tab = NUM
        end
        if has_note(b) then
          local c = pandoc.Inlines({})
          if label then c:extend({ pandoc.Str(label), pandoc.RawInline("openxml", "<w:r><w:tab/></w:r>") }) end
          c:extend(inl)
          out[#out + 1] = pandoc.Div({ pandoc.Para(c):walk({ Inlines = xe.inlines }) }, { ["custom-style"] = "Body Text Note" })
        else
          out[#out + 1] = p((label and xe.runs(label .. "\t") or "") .. xe.inl(inl), o)
        end
      else
        error("idb.lua: unsupported block " .. b.t)
      end
    end
  end

  local last = #blocks > 0 and blocks[#blocks].t ~= "Header"
  body(blocks, last)

  -- the dated line and the signature groups (typst: signature-block), kept together
  local s = meta.signature
  out[#out + 1] = p(xe.inl(meta.dated), { before = GAP, left = INDENT, keep = true })
  local groups = {}
  if s.lines_above and #s.lines_above > 0 then groups[#groups + 1] = list(s.lines_above) end
  local by = s.by == nil and "By " or plain(s.by)
  groups[#groups + 1] = { by .. "/s/ " .. plain(s.signer), s.signer }
  if s.lines_below and #s.lines_below > 0 then groups[#groups + 1] = list(s.lines_below) end
  for g, lines_ in ipairs(groups) do
    for i, l in ipairs(lines_) do
      local final = g == #groups and i == #lines_
      out[#out + 1] = p(xe.inl(l), { before = i == 1 and GAP or 0, left = SIG, keep = not final })
    end
  end

  body(cert, false)
  local ss = meta.service_signature
  if #cert > 0 and ss then
    out[#out + 1] = p(xe.runs("By /s/ ") .. xe.inl(ss.signer), { before = GAP, left = SIG, keep = true })
    out[#out + 1] = p(xe.inl(ss.name or ss.signer), { left = SIG })
  end

  local res = {}
  for _, x in ipairs(out) do res[#res + 1] = type(x) == "string" and xe.raw(x) or x end
  return pandoc.Pandoc(res, pandoc.Meta({}))
end
