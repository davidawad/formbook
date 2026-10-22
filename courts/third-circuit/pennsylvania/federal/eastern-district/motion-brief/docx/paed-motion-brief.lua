-- paed motion with memorandum of law, docx engine. Mirrors typst/paed-motion-brief.typ; the markdown contract and
-- the rules are in ../README.md. One document in five sections, as the typst template pages it:
--   order (no number) | motion and certificate (1, 2, ...) | memorandum cover (no number) | contents (i) |
--   memorandum (1, 2, ...)
-- Each part's cover (court title, the caption table with its ":" column and "CIVIL ACTION / No.", the title), the
-- order's numbered items and the court's signature, the paragraphs, headings (I., A., 1.) and quotations, counsel's
-- signature (the date at the left, the counsel blocks from 2.8 in), the certificate of service kept whole, and the
-- contents with page numbers from fb render's passes (needles in $FORMBOOK_NEEDLES, pages back in $FORMBOOK_PAGES;
-- tools/fb/src/docxpages.rs). The markers <!-- order -->, <!-- motion --> and <!-- memorandum --> divide the sample.
-- Every case word comes from the frontmatter and the sample. The footers (the page number, centred; an empty one)
-- and the last section are written for fb render ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 480 the body, 276 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE = 480, 276                 -- typst pitch-body, pitch-single
local TW = 9360                               -- the text width: 6.5 in
local CAP_LEFT, CAP_COLON = 4752, 504         -- typst caption-left 3.3 in, caption-colon 0.35 in
local CAP_RIGHT_INSET = 216                   -- typst caption-right-inset 0.15 in
local CAPTION_ABOVE, TITLE_ABOVE, TEXT_ABOVE = 276, 276, 276 -- typst caption-above, title-above, text-above
local ITEM_INDENT, ITEM_BOX = 720, 576        -- typst item-indent 0.5 in, item-box 0.4 in
local HEADING_BOX = 720                       -- typst heading-box 0.5 in
local QUOTE_INSET, QUOTE_GAP = 720, 240       -- typst quote-inset 0.5 in, quote-gap 12 pt
local SIG_COL = 4032                          -- typst sig-col 2.8 in
local ORDER_SIG_COL = 5328                    -- typst order-sig-col 3.7 in
local SIG_ABOVE, SIG_GAP = 480, 240           -- typst sig-above 24 pt, sig-gap 12 pt
local ORDER_SIG_GAP = 828                     -- typst order-sig-gap 41.4 pt
local CERT_ABOVE = 480                        -- typst cert-above 24 pt
local TOC_STEP, TOC_HANG, TOC_COL = 720, 720, 720 -- typst toc-step, toc-hang, toc-col
local TOC_ABOVE, TOC_GAP = 480, 240           -- typst toc-above, toc-gap
local FOOTER = 720                            -- the footer's line box ends 0.5 in above the page edge

local function check(cond, msg)
  if not cond then error("paed motion-brief docx: " .. msg, 0) end
end

local function txt(v)
  if v == nil then return "" end
  if type(v) == "string" then return v end
  return stringify(v)
end

-- The items of a metadata list (or of a single metadata value).
local function items(v)
  if v == nil then return {} end
  if v.t == "MetaList" or (v.t == nil and pandoc.utils.type(v) == "List") then
    local out = {}
    for _, x in ipairs(v) do out[#out + 1] = x end
    return out
  end
  return { v }
end

-- A paragraph: o = { style, keep, lines, tabs, before, after, pitch, left, hanging, first, right, jc }; single pitch
-- by default; its properties in the schema's order.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.tabs then props[#props + 1] = o.tabs end
  props[#props + 1] = xe.spacing(o.before or 0, o.after or 0, o.pitch or SINGLE)
  if not o.style or o.left or o.hanging or o.first then
    props[#props + 1] = xe.ind(o.left or 0, o.hanging, (not o.hanging) and (o.first or 0) or nil, o.right)
  end
  if not o.style or o.jc then props[#props + 1] = xe.jc(o.jc or "left") end
  return xe.para(props, body or "")
end

local function tab_at(pos)
  return '<w:tabs><w:tab w:val="left" w:pos="' .. pos .. '"/></w:tabs>'
end

-- Vertical space of its own (typst v()): an empty paragraph in a line box of that height.
local function space(twips)
  return xe.para({ xe.spacing(0, 0, twips) }, "")
end

-- ---------------------------------------------------------------------------
-- Footers and sections
-- ---------------------------------------------------------------------------

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local FOOTER_PAGE = xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("center") },
  '<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>')
local FOOTER_NONE = xe.para({ xe.spacing(0, 0, SINGLE), xe.ind(0, nil, 0), xe.jc("center") }, "")

-- A section's properties: its footer, letter paper, 1 in margins, the page numbering.
local function sect(footer, fmt, start)
  return '<w:sectPr><w:footerReference w:type="default" r:id="' .. footer .. '"/>'
    .. '<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" '
    .. 'w:header="720" w:footer="' .. FOOTER .. '" w:gutter="0"/><w:pgNumType w:fmt="' .. fmt .. '"'
    .. (start and (' w:start="' .. start .. '"') or "") .. '/></w:sectPr>'
end

-- The section ends with this paragraph (no empty paragraph of its own: it would take a line of the page).
local function end_section(xml, sectpr)
  local last
  local from = 1
  while true do
    local j = xml:find("</w:pPr>", from, true)
    if not j then break end
    last, from = j, j + 1
  end
  check(last ~= nil, "a section must end with a paragraph")
  return xml:sub(1, last - 1) .. sectpr .. xml:sub(last)
end

-- ---------------------------------------------------------------------------
-- Cover: court title, caption, title of the paper
-- ---------------------------------------------------------------------------

local function tc(width, paras, extra)
  return '<w:tc><w:tcPr><w:tcW w:w="' .. width .. '" w:type="dxa"/>' .. (extra or "") .. "</w:tcPr>"
    .. paras .. "</w:tc>"
end

local function cover(m, title)
  local out = {}
  for _, l in ipairs(items(m.court_lines)) do out[#out + 1] = p(xe.inl(l, { b = true }), { jc = "center" }) end

  local rows = {}
  for k, party in ipairs(m.caption.parties) do
    if k > 1 then rows[#rows + 1] = xe.runs("v.") end
    for _, n in ipairs(items(party.names)) do rows[#rows + 1] = xe.inl(n) end
    rows[#rows + 1] = xe.inl(party.designation)
  end
  local left, colons = {}, {}
  for _, r in ipairs(rows) do
    left[#left + 1] = p(r)
    colons[#colons + 1] = p(xe.runs(":"))
  end
  local number = txt(m.case_number)
  if number == "" then number = "________________" end
  local mid = math.max(0, (#rows - 2) // 2)
  local right = p(xe.runs("CIVIL ACTION"), { before = mid * SINGLE }) .. p(xe.runs("No. " .. number))

  local right_w = TW - CAP_LEFT - CAP_COLON
  out[#out + 1] = space(CAPTION_ABOVE)
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/>'
    .. '<w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblLayout w:type="fixed"/>'
    .. '<w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/>'
    .. '<w:right w:w="0" w:type="dxa"/></w:tblCellMar><w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" '
    .. 'w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/></w:tblPr><w:tblGrid>'
    .. '<w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_COLON .. '"/><w:gridCol w:w="' .. right_w .. '"/>'
    .. '</w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. tc(CAP_LEFT, table.concat(left))
    .. tc(CAP_COLON, table.concat(colons))
    .. tc(right_w, right, '<w:tcMar><w:left w:w="' .. CAP_RIGHT_INSET .. '" w:type="dxa"/></w:tcMar>')
    .. "</w:tr></w:tbl>"
  out[#out + 1] = p(xe.inl(title, { b = true }), { before = TITLE_ABOVE, jc = "center" })
  out[#out + 1] = space(TEXT_ABOVE)
  return out
end

-- ---------------------------------------------------------------------------
-- Needles and pages (the contents' page numbers; fb render's multi-pass build)
-- ---------------------------------------------------------------------------

local NEEDLE_MAX = 60
local function norm(s)
  return (s:lower():gsub("[^a-z0-9]", ""))
end

local labels = {}
local function load_pages()
  local path = os.getenv("FORMBOOK_PAGES")
  if not path or path == "" then return end
  local f = io.open(path, "r")
  if not f then return end
  for l in f:lines() do
    local id, _, lab = l:match("^([^\t]+)\t([^\t]*)\t(.*)$")
    if id then labels[id] = lab end
  end
  f:close()
end

-- ---------------------------------------------------------------------------
-- Blocks
-- ---------------------------------------------------------------------------

local function upper(inlines)
  return pandoc.Inlines(inlines):walk({ Str = function(s) return pandoc.Str(s.text:upper()) end })
end

local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII" }

-- The label of a heading: I. (level 1), A. (level 2), 1. (level 3).
local function heading_label(level, n)
  if level == 1 then return (ROMAN[n] or tostring(n)) .. "." end
  if level == 2 then return string.char(64 + n) .. "." end
  return n .. "."
end

-- Headings (typst heading-block): level 1 the label and title centred in capitals; levels 2 and 3 the label in a
-- half-inch box (a tab), the title hanging after it; the styles in docx/reference.xml.
local function heading(level, label, content, before)
  if level == 1 then
    local t = label == "" and xe.inl(upper(content)) or (xe.runs(label .. " ") .. xe.inl(upper(content)))
    return p(t, { style = "Heading1", keep = true, pitch = BODY, before = before })
  end
  return p(xe.runs(label) .. xe.runs("\t") .. xe.inl(content, level == 3 and { i = true } or nil), { style = "Heading" .. level, keep = true,
    pitch = BODY, before = before, left = HEADING_BOX, hanging = HEADING_BOX, tabs = tab_at(HEADING_BOX) })
end

local function body_par(content, keep)
  return p(xe.inl(content), { style = "BodyText", pitch = BODY, keep = keep })
end

-- A block quotation (typst quotation): single spaced, indented on both sides.
local function quotation(b)
  local il = pandoc.Inlines({})
  for k, q in ipairs(b.content) do
    if k > 1 then il:insert(pandoc.Space()) end
    il:extend(q.content or {})
  end
  return p(xe.inl(il), { before = QUOTE_GAP, after = QUOTE_GAP, left = QUOTE_INSET, right = QUOTE_INSET })
end

-- Signature lines (typst sig-lines): `first` at the left of the first line, the lines from SIG_COL (a tab and a
-- hanging indent), single spaced and kept on one page.
local function sig_lines(first, lines, above)
  local out = {}
  for i, l in ipairs(lines) do
    local o = { before = i == 1 and above or l[2], left = SIG_COL, keep = i < #lines, lines = true }
    if i == 1 then
      o.hanging, o.tabs = SIG_COL, tab_at(SIG_COL)
      out[#out + 1] = p(first .. xe.runs("\t") .. l[1], o)
    else
      out[#out + 1] = p(l[1], o)
    end
  end
  return out
end

local function line(l)
  return type(l) == "string" and xe.runs(l) or xe.inl(l)
end

-- Counsel's signature (typst signature-block).
local function signature(m)
  local lines = { { xe.runs("Respectfully submitted,"), 0 } }
  for _, b in ipairs(items(m.signature.blocks)) do
    for i, l in ipairs(items(b.firm)) do lines[#lines + 1] = { line(l), i == 1 and SIG_GAP or 0 } end
    lines[#lines + 1] = { xe.runs("By: /s/ ") .. line(b.signer), SIG_GAP }
    for _, l in ipairs(items(b.lines)) do lines[#lines + 1] = { line(l), 0 } end
  end
  return sig_lines(xe.runs("Date: ") .. line(m.date), lines, SIG_ABOVE)
end

-- The proposed order's signature (typst order-signature): the court's form words.
local function order_signature()
  return {
    p(xe.runs("BY THE COURT:"), { before = SIG_ABOVE, left = ORDER_SIG_COL, keep = true }),
    p(xe.runs(string.rep("_", 30) .. " J."), { before = ORDER_SIG_GAP, left = ORDER_SIG_COL }),
  }
end

-- The certificate of service (typst certificate): heading, text and signature kept on one page.
local function certificate(m)
  local s = m.service
  local out = { heading(1, "", pandoc.Inlines({ pandoc.Str("Certificate"), pandoc.Space(), pandoc.Str("of"),
    pandoc.Space(), pandoc.Str("Service") }), CERT_ABOVE), body_par(s.text, true) }
  local lines = { { xe.runs("/s/ ") .. line(s.signer), 0 } }
  for _, l in ipairs(items(s.lines)) do lines[#lines + 1] = { line(l), 0 } end
  for _, x in ipairs(sig_lines(xe.runs("Date: ") .. line(s.date), lines, SIG_ABOVE)) do out[#out + 1] = x end
  return out
end

-- The contents (typst contents): one row per memorandum heading, single spaced, indented by level, the label in a
-- box (a tab), the page in a column at the right after a dot leader.
local function contents(entries)
  local out = { p(xe.runs("TABLE OF CONTENTS", { b = true }), { keep = true, pitch = BODY, jc = "center" }) }
  for i, e in ipairs(entries) do
    local ind = (e.level - 1) * TOC_STEP
    local tabs = '<w:tabs><w:tab w:val="left" w:pos="' .. (ind + TOC_HANG) .. '"/>'
      .. '<w:tab w:val="right" w:leader="dot" w:pos="' .. TW .. '"/></w:tabs>'
    out[#out + 1] = p(xe.runs(e.label .. "\t") .. xe.inl(e.content) .. xe.runs(xe.LEAD) .. xe.runs(labels[e.id] or "0"), {
      lines = true, tabs = tabs, before = i == 1 and TOC_ABOVE or TOC_GAP,
      left = ind + TOC_HANG, hanging = TOC_HANG, right = TOC_COL })
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Break rules on every run
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("12(b)(6)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("and/or"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("§§ 8340"; the typst template boxes them): no-break spaces.
local function bind(l)
  for i = 2, #l do
    local s, prev = l[i], l[i - 1]
    if s.t == "Str" and prev.t == "Space" and s.text:sub(1, 1) == "." then l[i - 1] = pandoc.Str("\u{00A0}") end
    if prev.t == "Space" and i > 2 and l[i - 2].t == "Str" and l[i - 2].text:match("^[§¶][§¶]+$") then
      l[i - 1] = pandoc.Str("\u{00A0}")
    end
  end
  return l
end

-- ---------------------------------------------------------------------------
-- The document
-- ---------------------------------------------------------------------------

-- split the body at the "<!-- name -->" markers (pandoc keeps them as raw html blocks)
local function sections(doc)
  local parts = {}
  local cur = nil
  for _, b in ipairs(doc.blocks) do
    local name = b.t == "RawBlock" and b.text:match("^<!%-%-%s*(%a+)%s*%-%->$")
    if name then
      cur = {}
      parts[name] = cur
    elseif cur then
      cur[#cur + 1] = b
    end
  end
  for _, n in ipairs({ "order", "motion", "memorandum" }) do
    check(parts[n] ~= nil, "the sample needs a <!-- " .. n .. " --> section")
  end
  return parts
end

local function finish(doc)
  local m = doc.meta
  check(m.caption ~= nil and m.caption.parties ~= nil, "Fed. R. Civ. P. 10(a): the caption must name the parties")
  check(m.order_title ~= nil and m.motion_title ~= nil and m.memo_title ~= nil, "the order, motion and memorandum need their titles")
  check(m.signature ~= nil and m.signature.blocks ~= nil, "Fed. R. Civ. P. 11(a): the signature block is required")
  check(m.service ~= nil, "Local Civil Rule 5.1.2(7)(b): the certificate of service is required")
  load_pages()
  local parts = sections(doc)

  -- the memorandum's headings, their labels, and their needles: each heading with the words after it
  local entries, needles = {}, {}
  local counts = { 0, 0, 0 }
  for i, b in ipairs(parts.memorandum) do
    if b.t == "Header" then
      local level = math.min(b.level, 3)
      counts[level] = counts[level] + 1
      for k = level + 1, 3 do counts[k] = 0 end
      local id = "H" .. (#entries + 1)
      local label = heading_label(level, counts[level])
      entries[#entries + 1] = { id = id, level = level, label = label, content = b.content, block = b }
      local nxt = parts.memorandum[i + 1] and stringify(parts.memorandum[i + 1]) or ""
      local short = norm(label .. stringify(b.content)):sub(1, NEEDLE_MAX)
      local long = norm(label .. stringify(b.content) .. " " .. nxt):sub(1, NEEDLE_MAX)
      needles[#needles + 1] = table.concat({ id, "B", long, short }, "\t")
    end
  end
  if #entries > 0 then
    needles[#needles + 1] = "#section\tH1\tdecimal\t"
    write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n")
  end
  write_file("FORMBOOK_FOOTERS", "rIdPaedPage\t" .. FOOTER_PAGE .. "\nrIdPaedNone\t" .. FOOTER_NONE .. "\n")
  write_file("FORMBOOK_FINAL", sect("rIdPaedPage", "decimal", 1))
  local label_of = {}
  for _, e in ipairs(entries) do label_of[e.block] = e.label end

  local x = {}
  local function add(list_) for _, s in ipairs(list_) do x[#x + 1] = s end end
  local function close(sectpr) x[#x] = end_section(x[#x], sectpr) end

  -- typst render-section: headings, quotations, the order's items, paragraphs; the last block is kept with the
  -- closing that follows it
  local function blocks(list_, numbered)
    for k, b in ipairs(list_) do
      local keep = k == #list_
      if b.t == "Header" then
        x[#x + 1] = heading(math.min(b.level, 3), numbered and label_of[b] or "", b.content)
      elseif b.t == "BlockQuote" then
        x[#x + 1] = quotation(b)
      elseif b.t == "OrderedList" then
        for j, item in ipairs(b.content) do
          x[#x + 1] = p(xe.runs(j .. ".\t") .. xe.inl(pandoc.utils.blocks_to_inlines(item)), { style = "Lettered",
            pitch = BODY, keep = keep and j == #b.content })
        end
      elseif b.t == "Para" or b.t == "Plain" then
        x[#x + 1] = body_par(b.content, keep)
      else
        error("paed-motion-brief.lua: unexpected block " .. b.t)
      end
    end
  end

  -- 1. the proposed order (no page number)
  add(cover(m, m.order_title))
  blocks(parts.order)
  add(order_signature())
  close(sect("rIdPaedNone", "decimal", nil))
  -- 2. the motion and its certificate of service (1, 2, ...)
  add(cover(m, m.motion_title))
  blocks(parts.motion)
  add(signature(m))
  add(certificate(m))
  close(sect("rIdPaedPage", "decimal", 1))
  -- 3. the memorandum's cover (no page number)
  add(cover(m, m.memo_title))
  close(sect("rIdPaedNone", "decimal", nil))
  -- 4. the contents (i, ii, ...)
  add(contents(entries))
  close(sect("rIdPaedPage", "lowerRoman", 1))
  -- 5. the memorandum (1, 2, ...), the last paragraph kept with the signature
  blocks(parts.memorandum, true)
  add(signature(m))
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(x)) }, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }
