-- E.D. Mich. motion to dismiss with brief, docx engine. Mirrors typst/mied-motion-brief.typ; the markdown contract
-- and the rules are in ../README.md. One document in four sections: the motion (its cover, the text, the conferral
-- statement, the signature block; pages 1, 2, ...), the brief's cover (no page number), the front matter (each
-- level-1 section on its own page: statement of issues, controlling authorities, the table of contents; pages ii,
-- iii, ...) and the brief (pages from 1; the certificate of service on a page of its own). The markers <!-- brief -->,
-- <!-- toc --> and <!-- body --> and the CERTIFICATE OF SERVICE heading divide the sample. Every case word comes
-- from the frontmatter and the sample. The footers (the 12 pt page number, centred; an empty one for the cover) and the
-- last section are written for fb render ($FORMBOOK_FOOTERS, $FORMBOOK_FINAL); the contents' pages come from fb
-- render's passes (needles in $FORMBOOK_NEEDLES, pages back in $FORMBOOK_PAGES; tools/fb/src/docxpages.rs).
--
-- The cross-engine layout model (lib/docx/xengine.lua; docs/EVAL-LOOP.md, "Cross-engine gate"): every paragraph in
-- exact line boxes of the typst pitch (twips = 20 x pt: 644 the body, 322 a single line), the spaces between blocks
-- those of the typst template, and the break rules of typst on every run.

local xe = require("docx.xengine")
local stringify = pandoc.utils.stringify

local BODY, SINGLE, FOOT = 644, 322, 276      -- typst pitch-body, pitch-single, pitch-footer
local TW = 9360                               -- the text width: 6.5 in
local INDENT = 720                            -- typst para-indent, number-box, quote-inset, heading-hang
local BULLET = 360                            -- typst bullet-box 0.25 in
local CAP_LEFT, CAP_GAP = 4752, 360           -- typst caption-left 3.3 in, caption-gap 0.25 in
local CAP_INSET = 200                         -- typst caption-inset 10 pt
local CAP_RIGHT_INSET = 144                   -- typst caption-right-inset 0.1 in
local RULE = 15                               -- LibreOffice sets the 0.75 pt foot rule below the cell (a typst stroke
                                              -- takes no room): the cell padding below is that much less
local DESIGNATION = 1440                      -- typst designation-indent 1 in
local SIG_LEFT = 4608                         -- typst sig-left 3.2 in
local CAPTION_ABOVE = 644                     -- typst caption-above
local TITLE_ABOVE, TEXT_ABOVE = 644, 322      -- typst title-above, text-above
local QUOTE_GAP = 322                         -- typst quote-gap
local TOC_STEP, TOC_HANG, TOC_COL = 720, 720, 720   -- typst toc-step, toc-hang, toc-col
local TOC_ABOVE, TOC_GAP_1, TOC_GAP = 644, 322, 161 -- typst toc-above, toc-gap-1, toc-gap
local SIG_ABOVE, SIG_GAP = 644, 322           -- typst sig-above, sig-gap
local FOOTER = 720                            -- the footer's line box ends 0.5 in above the page edge

local function check(cond, msg)
  if not cond then error("mied motion-brief docx: " .. msg, 0) end
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

local function line(l, o)
  return type(l) == "string" and xe.runs(l, o) or xe.inl(l, o)
end

-- A paragraph: o = { style, keep, lines, brk, tabs, before, after, pitch, left, hanging, first, right, jc }; single
-- pitch by default; its properties in the schema's order.
local function p(body, o)
  o = o or {}
  local props = {}
  if o.style then props[#props + 1] = xe.style(o.style) end
  if o.keep then props[#props + 1] = xe.KEEP elseif o.lines then props[#props + 1] = xe.LINES end
  if o.brk then props[#props + 1] = xe.BREAK end
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

-- ---------------------------------------------------------------------------
-- Footers and sections (LR 5.1(a)(2): pages numbered)
-- ---------------------------------------------------------------------------

local function write_file(env, text)
  local path = os.getenv(env)
  if not path or path == "" then return end
  local f = assert(io.open(path, "w"))
  f:write(text)
  f:close()
end

local SZ = '<w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>'
local FOOTER_PAGE = xe.para({ xe.spacing(0, 0, FOOT), xe.ind(0, nil, 0), xe.jc("center") },
  '<w:r>' .. SZ .. '<w:fldChar w:fldCharType="begin"/></w:r>'
  .. '<w:r>' .. SZ .. '<w:instrText xml:space="preserve"> PAGE </w:instrText></w:r>'
  .. '<w:r>' .. SZ .. '<w:fldChar w:fldCharType="separate"/></w:r>'
  .. '<w:r>' .. SZ .. '<w:t>1</w:t></w:r>'
  .. '<w:r>' .. SZ .. '<w:fldChar w:fldCharType="end"/></w:r>')
local FOOTER_NONE = xe.para({ xe.spacing(0, 0, FOOT), xe.ind(0, nil, 0), xe.jc("center") }, "")

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

local NOLOOK = '<w:tblLook w:val="0000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="0" w:noVBand="0"/>'
local NOBORDER = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/>'
  .. '<w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
local RULE_XML = 'w:val="single" w:sz="6" w:space="0" w:color="000000"'

local function cover(m, title)
  local out = {}
  local court = { "UNITED STATES DISTRICT COURT", "FOR THE EASTERN DISTRICT OF MICHIGAN" }
  if m.division then court[#court + 1] = txt(m.division):upper() end
  for _, l in ipairs(court) do out[#out + 1] = p(xe.runs(l, { b = true }), { jc = "center" }) end

  -- the party column: names, a blank line, the designation set in; "v." with a blank line above and below
  local left = {}
  local gap = 0
  local function add(body, o)
    o = o or {}
    o.before = gap
    left[#left + 1] = p(body, o)
    gap = 0
  end
  for k, party in ipairs(m.caption.parties) do
    if k > 1 then
      gap = gap + SINGLE
      add(xe.runs("v."))
      gap = gap + SINGLE
    end
    for _, n in ipairs(items(party.names)) do add(line(n)) end
    gap = gap + SINGLE
    add(line(party.designation), { left = DESIGNATION })
  end
  local right = { p(xe.runs("Case No. " .. txt(m.case_number))) }
  if m.judge then right[#right + 1] = p(line(m.judge)) end
  for _, j in ipairs(items(m.judges)) do right[#right + 1] = p(line(j)) end

  local cap_right = TW - CAP_LEFT - CAP_GAP
  out[#out + 1] = xe.para({ xe.spacing(0, 0, CAPTION_ABOVE) }, "")
  out[#out + 1] = '<w:tbl><w:tblPr><w:tblW w:w="' .. TW .. '" w:type="dxa"/><w:tblInd w:w="0" w:type="dxa"/>'
    .. NOBORDER .. '<w:tblLayout w:type="fixed"/><w:tblCellMar><w:top w:w="0" w:type="dxa"/>'
    .. '<w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar>'
    .. NOLOOK .. '</w:tblPr><w:tblGrid><w:gridCol w:w="' .. CAP_LEFT .. '"/><w:gridCol w:w="' .. CAP_GAP
    .. '"/><w:gridCol w:w="' .. cap_right .. '"/></w:tblGrid><w:tr><w:trPr><w:cantSplit/></w:trPr>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_LEFT .. '" w:type="dxa"/><w:tcBorders><w:bottom ' .. RULE_XML .. '/>'
    .. '<w:right ' .. RULE_XML .. '/></w:tcBorders><w:tcMar><w:bottom w:w="' .. (CAP_INSET - RULE) .. '" w:type="dxa"/>'
    .. '<w:right w:w="' .. CAP_INSET .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(left) .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. CAP_GAP .. '" w:type="dxa"/></w:tcPr>' .. p("") .. '</w:tc>'
    .. '<w:tc><w:tcPr><w:tcW w:w="' .. cap_right .. '" w:type="dxa"/><w:tcMar><w:left w:w="' .. CAP_RIGHT_INSET
    .. '" w:type="dxa"/></w:tcMar></w:tcPr>' .. table.concat(right) .. '</w:tc></w:tr></w:tbl>'
  out[#out + 1] = p(line(title, { b = true }), { jc = "center", before = TITLE_ABOVE, after = TEXT_ABOVE })
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

-- Headings (typst heading-block): the styles in docx/reference.xml; level 1 typed in capitals; brk: opens a page.
local function heading(level, content, brk)
  level = math.min(level, 3)
  return p(xe.inl(level == 1 and upper(content) or content), { style = "Heading" .. level, keep = true, brk = brk,
    pitch = BODY })
end

local function body_par(content, indent, keep)
  return p(xe.inl(content), { pitch = BODY, first = indent and INDENT or 0, keep = keep })
end

-- A list (typst list-block): numbered items on the body pitch, the number at the indent and a tab to 1 in;
-- bulleted items single spaced, the bullet at the margin, the text hanging after it.
local function list(b)
  local out = {}
  for i, item in ipairs(b.content) do
    local content = pandoc.utils.blocks_to_inlines(item)
    if b.t == "OrderedList" then
      out[#out + 1] = p(xe.runs(i .. ".\t") .. xe.inl(content), { pitch = BODY, first = INDENT, tabs = tab_at(2 * INDENT) })
    else
      out[#out + 1] = p(xe.runs("\u{2022}\t") .. xe.inl(content), { left = BULLET, hanging = BULLET, tabs = tab_at(BULLET) })
    end
  end
  return out
end

-- A block quotation (typst quotation): single spaced, indented on both sides, a single line above and below.
local function quotation(b)
  local il = pandoc.Inlines({})
  for k, q in ipairs(b.content) do
    if k > 1 then il:insert(pandoc.Space()) end
    il:extend(q.content or {})
  end
  return p(xe.inl(il), { before = QUOTE_GAP, after = QUOTE_GAP, left = INDENT, right = INDENT })
end

-- The signature block (typst signature-block): single spaced from SIG_LEFT, the date at the left of its first line
-- (a tab), kept on one page.
local function signature(m)
  local sig = m.signature
  local lines = { { xe.runs("Respectfully submitted,"), 0 } }
  for i, f in ipairs(items(sig.firm)) do lines[#lines + 1] = { line(f), i == 1 and SIG_GAP or 0 } end
  lines[#lines + 1] = { xe.runs("By: /s/ " .. txt(sig.signer)), SIG_GAP }
  lines[#lines + 1] = { line(sig.signer), 0 }
  for _, l in ipairs(items(sig.lines)) do lines[#lines + 1] = { line(l), 0 } end
  local out = {}
  for i, l in ipairs(lines) do
    local keep = i < #lines
    if i == 1 then
      local date = m.date and (xe.runs("Dated: ") .. line(m.date)) or ""
      out[#out + 1] = p(date .. xe.runs("\t") .. l[1], { before = SIG_ABOVE, left = SIG_LEFT, hanging = SIG_LEFT,
        tabs = tab_at(SIG_LEFT), keep = keep, lines = true })
    else
      out[#out + 1] = p(l[1], { before = l[2], left = SIG_LEFT, keep = keep, lines = true })
    end
  end
  return out
end

-- The contents (typst contents): the body headings, single spaced rows indented by level, the page in a column at
-- the right after a dot leader.
local function contents(entries)
  local out = { heading(1, pandoc.Inlines({ pandoc.Str("Table"), pandoc.Space(), pandoc.Str("of"), pandoc.Space(),
    pandoc.Str("Contents") }), true) }
  for i, e in ipairs(entries) do
    local ind = (e.level - 1) * TOC_STEP
    local title = e.level == 1 and upper(e.content) or e.content
    out[#out + 1] = p(xe.inl(title) .. xe.runs(xe.LEAD) .. xe.runs(labels[e.id] or "0"), {
      lines = true, tabs = xe.leader_tab(TW), before = i == 1 and TOC_ABOVE or (e.level == 1 and TOC_GAP_1 or TOC_GAP),
      left = ind + TOC_HANG, hanging = TOC_HANG, right = TOC_COL })
  end
  return out
end

-- ---------------------------------------------------------------------------
-- Break rules on every run
-- ---------------------------------------------------------------------------

-- Break opportunities as typst has them (Unicode line breaking, UAX #14): none inside a token of adjacent parentheses
-- ("227(c)(5)"; lib/typst/xengine.typ boxes it): a word joiner (U+2060) between ")" and "("; one after a slash
-- followed by a letter ("CM/ECF"), where LibreOffice keeps the word whole: a zero-width space (U+200B) after it.
-- Neither shows in the PDF text. On the body and the metadata alike (pandoc walks both).
local function break_rules(s)
  local t = s.text
  if t:find(")(", 1, true) then t = t:gsub("%)%(", ")\u{2060}(") end
  if t:find("/", 1, true) then t = t:gsub("/([^/%d%s])", "/\u{200B}%1") end
  if t ~= s.text then return pandoc.Str(t) end
end

-- No break at a space before a period (". . ."; UAX #14 has none, LibreOffice breaks there), and none between a
-- doubled section sign or pilcrow and its number ("§§ 227(c)(1)(D)"; the typst template boxes them): no-break spaces.
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

local function marker(b, name)
  return b.t == "RawBlock" and b.text:match("^<!%-%-%s*" .. name .. "%s*%-%->$") ~= nil
end

local function is_cert(b)
  return b.t == "Header" and b.level == 1 and stringify(b.content) == "CERTIFICATE OF SERVICE"
end

local function finish(doc)
  local m = doc.meta
  check(m.caption ~= nil and m.caption.parties ~= nil, "Fed. R. Civ. P. 10(a): the caption must name the parties")
  check(m.motion_title ~= nil and m.brief_title ~= nil, "the motion and the brief need their titles")
  check(m.signature ~= nil and m.signature.signer ~= nil, "Fed. R. Civ. P. 11(a): the signature block needs a signer")
  load_pages()

  -- the parts of the sample
  local parts = { motion = {}, front = {}, after_toc = {}, body = {}, cert = {} }
  local phase, has_toc = "motion", false
  for _, b in ipairs(doc.blocks) do
    if marker(b, "brief") then phase = "front"
    elseif marker(b, "toc") then phase, has_toc = "after_toc", true
    elseif marker(b, "body") then phase = "body"
    elseif phase == "body" and is_cert(b) then phase = "cert"
    elseif b.t ~= "RawBlock" then table.insert(parts[phase], b) end
  end

  -- the contents' entries and their needles: each body heading with the words after it
  local entries, needles = {}, {}
  for i, b in ipairs(parts.body) do
    if b.t == "Header" and b.level <= 3 then
      local id = "H" .. (#entries + 1)
      entries[#entries + 1] = { id = id, level = b.level, content = b.content }
      local nxt = parts.body[i + 1] and stringify(parts.body[i + 1]) or ""
      local short = norm(stringify(b.content)):sub(1, NEEDLE_MAX)
      local long = norm(stringify(b.content) .. " " .. nxt):sub(1, NEEDLE_MAX)
      needles[#needles + 1] = table.concat({ id, "B", long, short }, "\t")
    end
  end
  if #entries > 0 then
    needles[#needles + 1] = "#section\tH1\tdecimal\t"
    write_file("FORMBOOK_NEEDLES", table.concat(needles, "\n") .. "\n")
  end
  write_file("FORMBOOK_FOOTERS", "rIdMiedPage\t" .. FOOTER_PAGE .. "\nrIdMiedNone\t" .. FOOTER_NONE .. "\n")
  write_file("FORMBOOK_FINAL", sect("rIdMiedPage", "decimal", 1))

  local x = {}
  local function add(list_) for _, s in ipairs(list_) do x[#x + 1] = s end end
  local function close(sectpr) x[#x] = end_section(x[#x], sectpr) end

  -- typst blocks(): headings, quotations, lists, paragraphs (not indented right after a quotation); front: a
  -- level-1 heading opens a page, except the first of its section; keep_last: the last paragraph stays with the
  -- signature block after it
  local function blocks(list_, front, keep_last)
    local after_quote, first = false, true
    for k, b in ipairs(list_) do
      if b.t == "Header" then
        x[#x + 1] = heading(b.level, b.content, front and b.level == 1 and not first)
        after_quote = false
      elseif b.t == "BlockQuote" then
        x[#x + 1] = quotation(b)
        after_quote = true
      elseif b.t == "OrderedList" or b.t == "BulletList" then
        add(list(b))
        after_quote = false
      elseif b.t == "Para" or b.t == "Plain" then
        x[#x + 1] = body_par(b.content, not after_quote, keep_last and k == #list_)
        after_quote = false
      else
        error("mied-motion-brief.lua: unexpected block " .. b.t)
      end
      first = false
    end
  end

  -- 1. the motion (pages 1, 2, ...)
  add(cover(m, m.motion_title))
  blocks(parts.motion)
  add(signature(m))
  close(sect("rIdMiedPage", "decimal", 1))
  -- 2. the brief's cover (no page number; it counts as i)
  add(cover(m, m.brief_title))
  close(sect("rIdMiedNone", "decimal", nil))
  -- 3. the front matter (ii, iii, ...)
  blocks(parts.front, true)
  if has_toc then
    add(contents(entries))
    blocks(parts.after_toc, true)
  end
  close(sect("rIdMiedPage", "lowerRoman", 2))
  -- 4. the brief (1, 2, ...), the signature block, the certificate of service
  blocks(parts.body, false, true)
  add(signature(m))
  if #parts.cert > 0 or phase == "cert" then
    x[#x + 1] = heading(1, pandoc.Inlines({ pandoc.Str("CERTIFICATE"), pandoc.Space(), pandoc.Str("OF"), pandoc.Space(),
      pandoc.Str("SERVICE") }), true)
    if parts.cert[1] then x[#x + 1] = body_par(parts.cert[1].content, true) end
    for k = 2, #parts.cert do
      x[#x + 1] = p(xe.inl(parts.cert[k].content), { before = k == 2 and SIG_ABOVE or 0, left = SIG_LEFT,
        keep = k < #parts.cert, lines = true })
    end
  end
  -- The frontmatter was consumed above; pandoc would otherwise write its title at the top of the document.
  return pandoc.Pandoc({ xe.raw(table.concat(x)) }, pandoc.Meta({}))
end

return { { Str = break_rules, Inlines = bind }, { Pandoc = finish } }
